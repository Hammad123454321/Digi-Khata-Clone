"""Sync service for multi-device synchronization."""
from datetime import datetime, timezone
from typing import List, Optional, Dict, Any, Tuple
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, or_

from app.core.exceptions import BusinessLogicError, NotFoundError
from app.models.sync import SyncChangeLog, SyncAction
from app.models.device import Device
from app.core.logging import get_logger
from app.schemas.sync import (
    SyncChangeRequest,
    SyncChangeResponse,
    SyncConflict,
)

logger = get_logger(__name__)

# Entity type mappings to models
ENTITY_MODEL_MAP = {
    "cash_transaction": "CashTransaction",
    "item": "Item",
    "invoice": "Invoice",
    "customer": "Customer",
    "supplier": "Supplier",
    "expense": "Expense",
    "expense_category": "ExpenseCategory",
    "staff": "Staff",
    "bank_account": "BankAccount",
    "bank_transaction": "BankTransaction",
    "customer_transaction": "CustomerTransaction",
    "supplier_transaction": "SupplierTransaction",
    "inventory_transaction": "InventoryTransaction",
}


class SyncService:
    """Sync service for handling pull/push operations."""

    @staticmethod
    async def pull_changes(
        business_id: int,
        device_id: str,
        cursor: Optional[str] = None,
        entity_types: Optional[List[str]] = None,
        limit: int = 100,
        db: AsyncSession = None,
    ) -> Tuple[List[SyncChangeResponse], Optional[str], bool]:
        """Pull changes from server since last sync cursor."""
        # Verify device exists and is active
        device_result = await db.execute(
            select(Device).where(
                Device.business_id == business_id,
                Device.device_id == device_id,
                Device.is_active == True,
            )
        )
        device = device_result.scalar_one_or_none()

        if not device:
            raise NotFoundError("Device not found or inactive")

        # Build query
        query = select(SyncChangeLog).where(
            SyncChangeLog.business_id == business_id,
            SyncChangeLog.entity_id.isnot(None),
        )

        # Filter out changes already synced to this device
        if device.sync_cursor:
            # Parse cursor (timestamp format: ISO string)
            try:
                cursor_timestamp = datetime.fromisoformat(device.sync_cursor.replace("Z", "+00:00"))
                query = query.where(SyncChangeLog.sync_timestamp > cursor_timestamp)
            except (ValueError, AttributeError):
                # Invalid cursor, start from beginning
                pass

        # Filter by entity types if specified
        if entity_types:
            query = query.where(SyncChangeLog.entity_type.in_(entity_types))

        # Exclude changes made by this device (to avoid circular sync)
        query = query.where(
            or_(
                SyncChangeLog.device_id.is_(None),
                SyncChangeLog.device_id != device_id,
            )
        )

        # Order by timestamp
        query = query.order_by(SyncChangeLog.sync_timestamp.asc())

        # Get total count
        count_result = await db.execute(
            select(func.count(SyncChangeLog.id)).where(query.whereclause)
        )
        total_count = count_result.scalar_one() or 0

        # Apply limit
        query = query.limit(limit + 1)  # Get one extra to check if more exists

        # Execute query
        result = await db.execute(query)
        changes = result.scalars().all()

        # Check if more changes exist
        has_more = len(changes) > limit
        if has_more:
            changes = changes[:limit]

        # Convert to response format
        change_responses = []
        latest_timestamp = None

        for change in changes:
            change_responses.append(
                SyncChangeResponse(
                    entity_type=change.entity_type,
                    entity_id=change.entity_id,
                    action=change.action.value,
                    data=change.data or {},
                    sync_timestamp=change.sync_timestamp,
                    change_id=change.id,
                )
            )
            if not latest_timestamp or change.sync_timestamp > latest_timestamp:
                latest_timestamp = change.sync_timestamp

        # Generate next cursor
        next_cursor = None
        if latest_timestamp:
            next_cursor = latest_timestamp.isoformat()

        # Update device sync cursor
        device.last_sync_at = datetime.now(timezone.utc)
        if next_cursor:
            device.sync_cursor = next_cursor

        await db.commit()

        logger.info(
            "sync_pull_completed",
            business_id=business_id,
            device_id=device_id,
            changes_count=len(change_responses),
            total_count=total_count,
        )

        return change_responses, next_cursor, has_more

    @staticmethod
    async def push_changes(
        business_id: int,
        device_id: str,
        changes: List[SyncChangeRequest],
        db: AsyncSession = None,
    ) -> Tuple[List[int], List[SyncConflict], List[Dict[str, Any]]]:
        """Push changes from device to server."""
        # Verify device exists and is active
        device_result = await db.execute(
            select(Device).where(
                Device.business_id == business_id,
                Device.device_id == device_id,
                Device.is_active == True,
            )
        )
        device = device_result.scalar_one_or_none()

        if not device:
            raise NotFoundError("Device not found or inactive")

        accepted = []
        conflicts = []
        rejected = []

        current_timestamp = datetime.now(timezone.utc)

        for change_request in changes:
            try:
                # Check for conflicts
                conflict = await SyncService._check_conflict(
                    business_id=business_id,
                    entity_type=change_request.entity_type,
                    entity_id=change_request.entity_id,
                    client_updated_at=change_request.updated_at,
                    db=db,
                )

                if conflict:
                    conflicts.append(conflict)
                    continue

                # Apply change based on action
                if change_request.action == "delete":
                    await SyncService._apply_delete(
                        business_id=business_id,
                        entity_type=change_request.entity_type,
                        entity_id=change_request.entity_id,
                        db=db,
                    )
                elif change_request.action in ["create", "update"]:
                    await SyncService._apply_create_or_update(
                        business_id=business_id,
                        entity_type=change_request.entity_type,
                        entity_id=change_request.entity_id,
                        data=change_request.data,
                        action=change_request.action,
                        db=db,
                    )
                else:
                    rejected.append(
                        {
                            "entity_type": change_request.entity_type,
                            "entity_id": change_request.entity_id,
                            "error": f"Invalid action: {change_request.action}",
                        }
                    )
                    continue

                # Create change log entry
                change_log = SyncChangeLog(
                    business_id=business_id,
                    device_id=device_id,
                    entity_type=change_request.entity_type,
                    entity_id=change_request.entity_id,
                    action=SyncAction(change_request.action),
                    data=change_request.data,
                    sync_timestamp=current_timestamp,
                )
                db.add(change_log)
                await db.flush()

                accepted.append(change_log.id)

            except Exception as e:
                logger.error(
                    "sync_push_error",
                    business_id=business_id,
                    device_id=device_id,
                    entity_type=change_request.entity_type,
                    entity_id=change_request.entity_id,
                    error=str(e),
                )
                rejected.append(
                    {
                        "entity_type": change_request.entity_type,
                        "entity_id": change_request.entity_id,
                        "error": str(e),
                    }
                )

        # Update device sync info
        device.last_sync_at = current_timestamp
        device.sync_cursor = current_timestamp.isoformat()

        await db.commit()

        logger.info(
            "sync_push_completed",
            business_id=business_id,
            device_id=device_id,
            accepted_count=len(accepted),
            conflicts_count=len(conflicts),
            rejected_count=len(rejected),
        )

        return accepted, conflicts, rejected

    @staticmethod
    async def _check_conflict(
        business_id: int,
        entity_type: str,
        entity_id: int,
        client_updated_at: datetime,
        db: AsyncSession,
    ) -> Optional[SyncConflict]:
        """Check if there's a conflict between client and server versions."""
        # Get the latest change log entry for this entity
        latest_change_result = await db.execute(
            select(SyncChangeLog)
            .where(
                SyncChangeLog.business_id == business_id,
                SyncChangeLog.entity_type == entity_type,
                SyncChangeLog.entity_id == entity_id,
            )
            .order_by(SyncChangeLog.sync_timestamp.desc())
            .limit(1)
        )
        latest_change = latest_change_result.scalar_one_or_none()

        if not latest_change:
            # No server version, no conflict
            return None

        # Check if server version is newer than client version
        if latest_change.sync_timestamp > client_updated_at:
            # Conflict: server has newer version
            return SyncConflict(
                entity_type=entity_type,
                entity_id=entity_id,
                server_version=latest_change.sync_timestamp,
                client_version=client_updated_at,
                server_data=latest_change.data or {},
                client_data={},  # Will be filled by caller if needed
                resolution=None,
            )

        return None

    @staticmethod
    async def _apply_delete(
        business_id: int,
        entity_type: str,
        entity_id: int,
        db: AsyncSession,
    ):
        """Apply delete operation."""
        model_class = await SyncService._get_model_class(entity_type)
        if not model_class:
            raise BusinessLogicError(f"Unknown entity type: {entity_type}")

        # Get entity
        result = await db.execute(
            select(model_class).where(
                model_class.id == entity_id,
                model_class.business_id == business_id,
            )
        )
        entity = result.scalar_one_or_none()

        if entity:
            await db.delete(entity)
            await db.flush()

    @staticmethod
    async def _apply_create_or_update(
        business_id: int,
        entity_type: str,
        entity_id: int,
        data: Dict[str, Any],
        action: str,
        db: AsyncSession,
    ):
        """Apply create or update operation."""
        model_class = await SyncService._get_model_class(entity_type)
        if not model_class:
            raise BusinessLogicError(f"Unknown entity type: {entity_type}")

        # Convert Decimal strings back to Decimal
        data = SyncService._convert_decimals(data)

        if action == "create":
            # Create new entity
            entity = model_class(**data)
            entity.business_id = business_id
            db.add(entity)
            await db.flush()
        else:  # update
            # Get existing entity
            result = await db.execute(
                select(model_class).where(
                    model_class.id == entity_id,
                    model_class.business_id == business_id,
                )
            )
            entity = result.scalar_one_or_none()

            if not entity:
                raise NotFoundError(f"{entity_type} with id {entity_id} not found")

            # Update fields
            for key, value in data.items():
                if hasattr(entity, key) and key != "id" and key != "business_id":
                    setattr(entity, key, value)

            await db.flush()

    @staticmethod
    async def _get_model_class(entity_type: str):
        """Get SQLAlchemy model class for entity type."""
        from app.models import (
            cash,
            item,
            invoice,
            customer,
            supplier,
            expense,
            staff,
            bank,
        )

        model_map = {
            "cash_transaction": cash.CashTransaction,
            "item": item.Item,
            "invoice": invoice.Invoice,
            "customer": customer.Customer,
            "supplier": supplier.Supplier,
            "expense": expense.Expense,
            "expense_category": expense.ExpenseCategory,
            "staff": staff.Staff,
            "bank_account": bank.BankAccount,
            "bank_transaction": bank.BankTransaction,
            "customer_transaction": customer.CustomerTransaction,
            "supplier_transaction": supplier.SupplierTransaction,
            "inventory_transaction": item.InventoryTransaction,
        }

        return model_map.get(entity_type)

    @staticmethod
    def _convert_decimals(data: Dict[str, Any]) -> Dict[str, Any]:
        """Convert string numbers to Decimal for numeric fields."""
        converted = {}
        for key, value in data.items():
            if isinstance(value, str):
                # Try to convert to Decimal if it looks like a number
                try:
                    if "." in value:
                        converted[key] = Decimal(value)
                    else:
                        converted[key] = int(value)
                except (ValueError, TypeError):
                    converted[key] = value
            elif isinstance(value, dict):
                converted[key] = SyncService._convert_decimals(value)
            elif isinstance(value, list):
                converted[key] = [
                    SyncService._convert_decimals(item) if isinstance(item, dict) else item
                    for item in value
                ]
            else:
                converted[key] = value
        return converted

    @staticmethod
    async def get_sync_status(
        business_id: int,
        device_id: str,
        db: AsyncSession,
    ) -> Dict[str, Any]:
        """Get sync status for a device."""
        # Get device
        device_result = await db.execute(
            select(Device).where(
                Device.business_id == business_id,
                Device.device_id == device_id,
            )
        )
        device = device_result.scalar_one_or_none()

        if not device:
            raise NotFoundError("Device not found")

        # Count pending changes
        query = select(func.count(SyncChangeLog.id)).where(
            SyncChangeLog.business_id == business_id,
        )

        if device.sync_cursor:
            try:
                cursor_timestamp = datetime.fromisoformat(device.sync_cursor.replace("Z", "+00:00"))
                query = query.where(SyncChangeLog.sync_timestamp > cursor_timestamp)
            except (ValueError, AttributeError):
                pass

        # Exclude changes made by this device
        query = query.where(
            or_(
                SyncChangeLog.device_id.is_(None),
                SyncChangeLog.device_id != device_id,
            )
        )

        pending_result = await db.execute(query)
        pending_count = pending_result.scalar_one() or 0

        return {
            "last_sync_at": device.last_sync_at,
            "sync_cursor": device.sync_cursor,
            "pending_changes_count": pending_count,
            "device_id": device.device_id,
            "is_active": device.is_active,
        }

    @staticmethod
    async def log_change(
        business_id: int,
        entity_type: str,
        entity_id: int,
        action: SyncAction,
        data: Dict[str, Any],
        device_id: Optional[str] = None,
        db: AsyncSession = None,
    ):
        """Log a change for sync (called when entities are modified)."""
        change_log = SyncChangeLog(
            business_id=business_id,
            device_id=device_id,  # None for server-initiated changes
            entity_type=entity_type,
            entity_id=entity_id,
            action=action,
            data=data,
            sync_timestamp=datetime.now(timezone.utc),
        )
        db.add(change_log)
        await db.flush()


# Service instance
sync_service = SyncService()

