"""Sync service for multi-device synchronization."""
from datetime import datetime, timezone
from typing import List, Optional, Dict, Any, Tuple
from decimal import Decimal
from beanie import PydanticObjectId
from beanie.operators import In

from app.core.exceptions import BusinessLogicError, NotFoundError, ValidationError
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
        business_id: str,
        device_id: str,
        cursor: Optional[str] = None,
        entity_types: Optional[List[str]] = None,
        limit: int = 100,
    ) -> Tuple[List[SyncChangeResponse], Optional[str], bool]:
        """Pull changes from server since last sync cursor."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        # Verify device exists and is active
        device = await Device.find_one(
            Device.business_id == business_obj_id,
            Device.device_id == device_id,
            Device.is_active == True,
        )

        if not device:
            raise NotFoundError("Device not found or inactive")

        # Build query
        query = SyncChangeLog.find(
            SyncChangeLog.business_id == business_obj_id,
            SyncChangeLog.entity_id != None,
        )

        # Filter out changes already synced to this device
        if device.sync_cursor:
            # Parse cursor (timestamp format: ISO string)
            try:
                cursor_timestamp = datetime.fromisoformat(device.sync_cursor.replace("Z", "+00:00"))
                query = query.find(SyncChangeLog.sync_timestamp > cursor_timestamp)
            except (ValueError, AttributeError):
                # Invalid cursor, start from beginning
                pass

        # Filter by entity types if specified
        if entity_types:
            query = query.find(In(SyncChangeLog.entity_type, entity_types))

        # Exclude changes made by this device (to avoid circular sync)
        # MongoDB query: $or with device_id null or not equal
        # Note: Beanie doesn't support complex $or directly, so we'll filter after fetching
        changes = await query.sort("+sync_timestamp").limit(limit + 1).to_list()

        # Filter out changes made by this device
        changes = [
            c for c in changes
            if c.device_id is None or c.device_id != device_id
        ]

        # Check if more changes exist
        has_more = len(changes) > limit
        if has_more:
            changes = changes[:limit]

        # Get total count (approximate)
        total_count = len(changes) if not has_more else limit + 1

        # Convert to response format
        change_responses = []
        latest_timestamp = None

        for change in changes:
            change_responses.append(
                SyncChangeResponse(
                    entity_type=change.entity_type,
                    entity_id=str(change.entity_id) if change.entity_id else None,
                    action=change.action.value,
                    data=change.data or {},
                    sync_timestamp=change.sync_timestamp,
                    change_id=str(change.id),
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
        await device.save()

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
        business_id: str,
        device_id: str,
        changes: List[SyncChangeRequest],
    ) -> Tuple[List[str], List[SyncConflict], List[Dict[str, Any]]]:
        """Push changes from device to server."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        # Verify device exists and is active
        device = await Device.find_one(
            Device.business_id == business_obj_id,
            Device.device_id == device_id,
            Device.is_active == True,
        )

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
                    )
                elif change_request.action in ["create", "update"]:
                    await SyncService._apply_create_or_update(
                        business_id=business_id,
                        entity_type=change_request.entity_type,
                        entity_id=change_request.entity_id,
                        data=change_request.data,
                        action=change_request.action,
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
                entity_obj_id = None
                if change_request.entity_id:
                    try:
                        entity_obj_id = PydanticObjectId(change_request.entity_id)
                    except (ValueError, TypeError):
                        pass

                change_log = SyncChangeLog(
                    business_id=business_obj_id,
                    device_id=device_id,
                    entity_type=change_request.entity_type,
                    entity_id=entity_obj_id,
                    action=SyncAction(change_request.action),
                    data=change_request.data,
                    sync_timestamp=current_timestamp,
                )
                await change_log.insert()

                accepted.append(str(change_log.id))

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
        await device.save()

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
        business_id: str,
        entity_type: str,
        entity_id: str,
        client_updated_at: datetime,
    ) -> Optional[SyncConflict]:
        """Check if there's a conflict between client and server versions."""
        try:
            business_obj_id = PydanticObjectId(business_id)
            entity_obj_id = PydanticObjectId(entity_id)
        except (ValueError, TypeError):
            return None

        # Get the latest change log entry for this entity
        latest_change = await SyncChangeLog.find(
            SyncChangeLog.business_id == business_obj_id,
            SyncChangeLog.entity_type == entity_type,
            SyncChangeLog.entity_id == entity_obj_id,
        ).sort("-sync_timestamp").limit(1).first()

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
        business_id: str,
        entity_type: str,
        entity_id: str,
    ):
        """Apply delete operation."""
        model_class = SyncService._get_model_class(entity_type)
        if not model_class:
            raise BusinessLogicError(f"Unknown entity type: {entity_type}")

        try:
            business_obj_id = PydanticObjectId(business_id)
            entity_obj_id = PydanticObjectId(entity_id)
        except (ValueError, TypeError):
            raise NotFoundError(f"Invalid ID format for {entity_type}")

        # Get entity
        entity = await model_class.find_one(
            model_class.id == entity_obj_id,
            model_class.business_id == business_obj_id,
        )

        if entity:
            await entity.delete()

    @staticmethod
    async def _apply_create_or_update(
        business_id: str,
        entity_type: str,
        entity_id: str,
        data: Dict[str, Any],
        action: str,
    ):
        """Apply create or update operation."""
        model_class = SyncService._get_model_class(entity_type)
        if not model_class:
            raise BusinessLogicError(f"Unknown entity type: {entity_type}")

        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        # Convert Decimal strings back to Decimal
        data = SyncService._convert_decimals(data)

        if action == "create":
            # Create new entity
            entity = model_class(**data)
            entity.business_id = business_obj_id
            await entity.insert()
        else:  # update
            try:
                entity_obj_id = PydanticObjectId(entity_id)
            except (ValueError, TypeError):
                raise NotFoundError(f"Invalid entity ID format for {entity_type}")

            # Get existing entity
            entity = await model_class.find_one(
                model_class.id == entity_obj_id,
                model_class.business_id == business_obj_id,
            )

            if not entity:
                raise NotFoundError(f"{entity_type} with id {entity_id} not found")

            # Update fields
            for key, value in data.items():
                if hasattr(entity, key) and key != "id" and key != "business_id":
                    setattr(entity, key, value)

            await entity.save()

    @staticmethod
    def _get_model_class(entity_type: str):
        """Get Beanie model class for entity type."""
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
        business_id: str,
        device_id: str,
    ) -> Dict[str, Any]:
        """Get sync status for a device."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        # Get device
        device = await Device.find_one(
            Device.business_id == business_obj_id,
            Device.device_id == device_id,
        )

        if not device:
            raise NotFoundError("Device not found")

        # Count pending changes
        query = SyncChangeLog.find(
            SyncChangeLog.business_id == business_obj_id,
        )

        if device.sync_cursor:
            try:
                cursor_timestamp = datetime.fromisoformat(device.sync_cursor.replace("Z", "+00:00"))
                query = query.find(SyncChangeLog.sync_timestamp > cursor_timestamp)
            except (ValueError, AttributeError):
                pass

        # Exclude changes made by this device
        changes = await query.to_list()
        pending_changes = [
            c for c in changes
            if c.device_id is None or c.device_id != device_id
        ]
        pending_count = len(pending_changes)

        return {
            "last_sync_at": device.last_sync_at,
            "sync_cursor": device.sync_cursor,
            "pending_changes_count": pending_count,
            "device_id": device.device_id,
            "is_active": device.is_active,
        }

    @staticmethod
    async def log_change(
        business_id: str,
        entity_type: str,
        entity_id: str,
        action: SyncAction,
        data: Dict[str, Any],
        device_id: Optional[str] = None,
    ):
        """Log a change for sync (called when entities are modified)."""
        try:
            business_obj_id = PydanticObjectId(business_id)
            entity_obj_id = PydanticObjectId(entity_id) if entity_id else None
        except (ValueError, TypeError):
            return

        change_log = SyncChangeLog(
            business_id=business_obj_id,
            device_id=device_id,  # None for server-initiated changes
            entity_type=entity_type,
            entity_id=entity_obj_id,
            action=action,
            data=data,
            sync_timestamp=datetime.now(timezone.utc),
        )
        await change_log.insert()


# Service instance
sync_service = SyncService()
