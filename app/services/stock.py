"""Stock management service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.core.exceptions import NotFoundError, BusinessLogicError
from app.models.item import Item, InventoryTransaction, InventoryTransactionType, LowStockAlert
from app.core.logging import get_logger

logger = get_logger(__name__)


class StockService:
    """Stock management service."""

    @staticmethod
    async def create_item(
        business_id: int,
        name: str,
        purchase_price: Decimal,
        sale_price: Decimal,
        unit: str,
        opening_stock: Decimal = Decimal("0.000"),
        sku: Optional[str] = None,
        barcode: Optional[str] = None,
        min_stock_threshold: Optional[Decimal] = None,
        description: Optional[str] = None,
        db: AsyncSession = None,
    ) -> Item:
        """Create a new item."""
        # Check for duplicate SKU or barcode
        if sku:
            result = await db.execute(
                select(Item).where(Item.business_id == business_id, Item.sku == sku)
            )
            if result.scalar_one_or_none():
                raise BusinessLogicError("Item with this SKU already exists")

        if barcode:
            result = await db.execute(
                select(Item).where(Item.business_id == business_id, Item.barcode == barcode)
            )
            if result.scalar_one_or_none():
                raise BusinessLogicError("Item with this barcode already exists")

        item = Item(
            business_id=business_id,
            name=name,
            sku=sku,
            barcode=barcode,
            purchase_price=purchase_price,
            sale_price=sale_price,
            unit=unit,
            opening_stock=opening_stock,
            current_stock=opening_stock,
            min_stock_threshold=min_stock_threshold,
            description=description,
            is_active=True,
        )
        db.add(item)
        await db.flush()

        # Check for low stock alert
        if min_stock_threshold and opening_stock < min_stock_threshold:
            await StockService._create_low_stock_alert(business_id, item.id, opening_stock, min_stock_threshold, db)

        logger.info("item_created", business_id=business_id, item_id=item.id, name=name)
        return item

    @staticmethod
    async def update_item(
        item_id: int,
        business_id: int,
        name: Optional[str] = None,
        sku: Optional[str] = None,
        barcode: Optional[str] = None,
        purchase_price: Optional[Decimal] = None,
        sale_price: Optional[Decimal] = None,
        unit: Optional[str] = None,
        min_stock_threshold: Optional[Decimal] = None,
        description: Optional[str] = None,
        is_active: Optional[bool] = None,
        db: AsyncSession = None,
    ) -> Item:
        """Update an item."""
        result = await db.execute(
            select(Item).where(Item.id == item_id, Item.business_id == business_id)
        )
        item = result.scalar_one_or_none()

        if not item:
            raise NotFoundError("Item not found")

        if name is not None:
            item.name = name
        if sku is not None:
            # Check for duplicate SKU
            if sku != item.sku:
                result = await db.execute(
                    select(Item).where(Item.business_id == business_id, Item.sku == sku, Item.id != item_id)
                )
                if result.scalar_one_or_none():
                    raise BusinessLogicError("Item with this SKU already exists")
            item.sku = sku
        if barcode is not None:
            # Check for duplicate barcode
            if barcode != item.barcode:
                result = await db.execute(
                    select(Item).where(Item.business_id == business_id, Item.barcode == barcode, Item.id != item_id)
                )
                if result.scalar_one_or_none():
                    raise BusinessLogicError("Item with this barcode already exists")
            item.barcode = barcode
        if purchase_price is not None:
            item.purchase_price = purchase_price
        if sale_price is not None:
            item.sale_price = sale_price
        if unit is not None:
            item.unit = unit
        if min_stock_threshold is not None:
            item.min_stock_threshold = min_stock_threshold
            # Check if current stock is below new threshold
            if item.current_stock < min_stock_threshold:
                await StockService._create_low_stock_alert(
                    business_id, item_id, item.current_stock, min_stock_threshold, db
                )
        if description is not None:
            item.description = description
        if is_active is not None:
            item.is_active = is_active

        await db.flush()

        logger.info("item_updated", business_id=business_id, item_id=item_id)
        return item

    @staticmethod
    async def get_item(item_id: int, business_id: int, db: AsyncSession) -> Item:
        """Get item by ID."""
        result = await db.execute(
            select(Item).where(Item.id == item_id, Item.business_id == business_id)
        )
        item = result.scalar_one_or_none()

        if not item:
            raise NotFoundError("Item not found")

        return item

    @staticmethod
    async def list_items(
        business_id: int,
        is_active: Optional[bool] = None,
        search: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
        db: AsyncSession = None,
    ) -> list[Item]:
        """List items."""
        query = select(Item).where(Item.business_id == business_id)

        if is_active is not None:
            query = query.where(Item.is_active == is_active)
        if search:
            query = query.where(
                (Item.name.ilike(f"%{search}%"))
                | (Item.sku.ilike(f"%{search}%"))
                | (Item.barcode.ilike(f"%{search}%"))
            )

        query = query.order_by(Item.name).limit(limit).offset(offset)

        result = await db.execute(query)
        return list(result.scalars().all())

    @staticmethod
    async def create_inventory_transaction(
        business_id: int,
        item_id: int,
        transaction_type: str,
        quantity: Decimal,
        date: datetime,
        unit_price: Optional[Decimal] = None,
        reference_id: Optional[int] = None,
        reference_type: Optional[str] = None,
        remarks: Optional[str] = None,
        user_id: Optional[int] = None,
        db: AsyncSession = None,
    ) -> InventoryTransaction:
        """Create an inventory transaction."""
        # Get item
        item = await StockService.get_item(item_id, business_id, db)

        # Create transaction
        transaction = InventoryTransaction(
            business_id=business_id,
            item_id=item_id,
            transaction_type=InventoryTransactionType(transaction_type),
            quantity=quantity,
            unit_price=unit_price,
            date=date,
            reference_id=reference_id,
            reference_type=reference_type,
            remarks=remarks,
            created_by_user_id=user_id,
        )
        db.add(transaction)
        await db.flush()

        # Update item stock
        if transaction_type == "stock_in":
            item.current_stock += quantity
        elif transaction_type == "stock_out":
            if item.current_stock < quantity:
                raise BusinessLogicError(f"Insufficient stock. Available: {item.current_stock}")
            item.current_stock -= quantity
        elif transaction_type == "wastage":
            if item.current_stock < quantity:
                raise BusinessLogicError(f"Insufficient stock for wastage. Available: {item.current_stock}")
            item.current_stock -= quantity
        elif transaction_type == "adjustment":
            # Adjustment can be positive or negative
            item.current_stock = quantity

        await db.flush()

        # Check for low stock alert
        if item.min_stock_threshold and item.current_stock < item.min_stock_threshold:
            await StockService._create_low_stock_alert(
                business_id, item_id, item.current_stock, item.min_stock_threshold, db
            )

        logger.info(
            "inventory_transaction_created",
            business_id=business_id,
            item_id=item_id,
            transaction_type=transaction_type,
            quantity=str(quantity),
        )

        return transaction

    @staticmethod
    async def _create_low_stock_alert(
        business_id: int,
        item_id: int,
        current_stock: Decimal,
        threshold: Decimal,
        db: AsyncSession,
    ) -> None:
        """Create or update low stock alert."""
        # Check if unresolved alert exists
        result = await db.execute(
            select(LowStockAlert).where(
                LowStockAlert.business_id == business_id,
                LowStockAlert.item_id == item_id,
                LowStockAlert.is_resolved == False,
            )
        )
        alert = result.scalar_one_or_none()

        if alert:
            # Update existing alert
            alert.current_stock = current_stock
        else:
            # Create new alert
            alert = LowStockAlert(
                business_id=business_id,
                item_id=item_id,
                current_stock=current_stock,
                threshold=threshold,
                is_resolved=False,
            )
            db.add(alert)

        await db.flush()

    @staticmethod
    async def list_low_stock_alerts(
        business_id: int,
        is_resolved: Optional[bool] = None,
        db: AsyncSession = None,
    ) -> list[LowStockAlert]:
        """List low stock alerts."""
        query = select(LowStockAlert).where(LowStockAlert.business_id == business_id)

        if is_resolved is not None:
            query = query.where(LowStockAlert.is_resolved == is_resolved)

        query = query.order_by(LowStockAlert.created_at.desc())

        result = await db.execute(query)
        return list(result.scalars().all())

    @staticmethod
    async def resolve_low_stock_alert(alert_id: int, business_id: int, db: AsyncSession) -> None:
        """Resolve a low stock alert."""
        result = await db.execute(
            select(LowStockAlert).where(
                LowStockAlert.id == alert_id,
                LowStockAlert.business_id == business_id,
            )
        )
        alert = result.scalar_one_or_none()

        if not alert:
            raise NotFoundError("Alert not found")

        alert.is_resolved = True
        alert.resolved_at = datetime.now(timezone.utc)
        await db.flush()


# Singleton instance
stock_service = StockService()

