"""Stock management service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from beanie import PydanticObjectId

from app.core.exceptions import NotFoundError, BusinessLogicError, ValidationError
from app.models.item import Item, InventoryTransaction, InventoryTransactionType, LowStockAlert, ItemUnit
from app.core.logging import get_logger

logger = get_logger(__name__)


class StockService:
    """Stock management service."""

    @staticmethod
    async def create_item(
        business_id: str,
        name: str,
        purchase_price: Decimal,
        sale_price: Decimal,
        unit: str,
        opening_stock: Decimal = Decimal("0.000"),
        sku: Optional[str] = None,
        barcode: Optional[str] = None,
        min_stock_threshold: Optional[Decimal] = None,
        description: Optional[str] = None,
    ) -> Item:
        """Create a new item."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        # Check for duplicate SKU or barcode
        if sku:
            existing = await Item.find_one(
                Item.business_id == business_obj_id,
                Item.sku == sku,
            )
            if existing:
                raise BusinessLogicError("Item with this SKU already exists")

        if barcode:
            existing = await Item.find_one(
                Item.business_id == business_obj_id,
                Item.barcode == barcode,
            )
            if existing:
                raise BusinessLogicError("Item with this barcode already exists")

        item = Item(
            business_id=business_obj_id,
            name=name,
            sku=sku,
            barcode=barcode,
            purchase_price=purchase_price,
            sale_price=sale_price,
            unit=ItemUnit(unit),
            opening_stock=opening_stock,
            current_stock=opening_stock,
            min_stock_threshold=min_stock_threshold,
            description=description,
            is_active=True,
        )
        await item.insert()

        # Check for low stock alert
        if min_stock_threshold and opening_stock < min_stock_threshold:
            await StockService._create_low_stock_alert(business_id, str(item.id), opening_stock, min_stock_threshold)

        logger.info("item_created", business_id=business_id, item_id=str(item.id), name=name)
        return item

    @staticmethod
    async def update_item(
        item_id: str,
        business_id: str,
        name: Optional[str] = None,
        sku: Optional[str] = None,
        barcode: Optional[str] = None,
        purchase_price: Optional[Decimal] = None,
        sale_price: Optional[Decimal] = None,
        unit: Optional[str] = None,
        min_stock_threshold: Optional[Decimal] = None,
        description: Optional[str] = None,
        is_active: Optional[bool] = None,
    ) -> Item:
        """Update an item."""
        try:
            item_obj_id = PydanticObjectId(item_id)
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise NotFoundError("Item not found")

        item = await Item.find_one(
            Item.id == item_obj_id,
            Item.business_id == business_obj_id,
        )

        if not item:
            raise NotFoundError("Item not found")

        if name is not None:
            item.name = name
        if sku is not None:
            # Check for duplicate SKU
            if sku != item.sku:
                existing = await Item.find_one(
                    Item.business_id == business_obj_id,
                    Item.sku == sku,
                    Item.id != item_obj_id,
                )
                if existing:
                    raise BusinessLogicError("Item with this SKU already exists")
            item.sku = sku
        if barcode is not None:
            # Check for duplicate barcode
            if barcode != item.barcode:
                existing = await Item.find_one(
                    Item.business_id == business_obj_id,
                    Item.barcode == barcode,
                    Item.id != item_obj_id,
                )
                if existing:
                    raise BusinessLogicError("Item with this barcode already exists")
            item.barcode = barcode
        if purchase_price is not None:
            item.purchase_price = purchase_price
        if sale_price is not None:
            item.sale_price = sale_price
        if unit is not None:
            item.unit = ItemUnit(unit)
        if min_stock_threshold is not None:
            item.min_stock_threshold = min_stock_threshold
            # Check if current stock is below new threshold
            if item.current_stock < min_stock_threshold:
                await StockService._create_low_stock_alert(
                    business_id, item_id, item.current_stock, min_stock_threshold
                )
        if description is not None:
            item.description = description
        if is_active is not None:
            item.is_active = is_active

        await item.save()

        logger.info("item_updated", business_id=business_id, item_id=item_id)
        return item

    @staticmethod
    async def get_item(item_id: str, business_id: str) -> Item:
        """Get item by ID."""
        try:
            item_obj_id = PydanticObjectId(item_id)
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise NotFoundError("Item not found")

        item = await Item.find_one(
            Item.id == item_obj_id,
            Item.business_id == business_obj_id,
        )

        if not item:
            raise NotFoundError("Item not found")

        return item

    @staticmethod
    async def list_items(
        business_id: str,
        is_active: Optional[bool] = None,
        search: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Item]:
        """List items."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        query = Item.find(Item.business_id == business_obj_id)

        if is_active is not None:
            query = query.find(Item.is_active == is_active)
        if search:
            import re
            search_regex = re.compile(search, re.IGNORECASE)
            query = query.find(
                (Item.name == search_regex) | (Item.sku == search_regex) | (Item.barcode == search_regex)
            )

        items = await query.sort("+name").skip(offset).limit(limit).to_list()
        return items

    @staticmethod
    async def create_inventory_transaction(
        business_id: str,
        item_id: str,
        transaction_type: str,
        quantity: Decimal,
        date: datetime,
        unit_price: Optional[Decimal] = None,
        reference_id: Optional[str] = None,
        reference_type: Optional[str] = None,
        remarks: Optional[str] = None,
        user_id: Optional[str] = None,
    ) -> InventoryTransaction:
        """Create an inventory transaction."""
        # Get item
        item = await StockService.get_item(item_id, business_id)

        try:
            business_obj_id = PydanticObjectId(business_id)
            item_obj_id = PydanticObjectId(item_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business or item ID format",
                {
                    "business_id": [f"'{business_id}' is not a valid ObjectId"],
                    "item_id": [f"'{item_id}' is not a valid ObjectId"],
                },
            )

        user_obj_id = None
        if user_id:
            try:
                user_obj_id = PydanticObjectId(user_id)
            except (ValueError, TypeError):
                pass

        ref_obj_id = None
        if reference_id:
            try:
                ref_obj_id = PydanticObjectId(reference_id)
            except (ValueError, TypeError):
                pass

        # Create transaction
        transaction = InventoryTransaction(
            business_id=business_obj_id,
            item_id=item_obj_id,
            transaction_type=InventoryTransactionType(transaction_type),
            quantity=quantity,
            unit_price=unit_price,
            date=date,
            reference_id=ref_obj_id,
            reference_type=reference_type,
            remarks=remarks,
            created_by_user_id=user_obj_id,
        )
        await transaction.insert()

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

        await item.save()

        # Check for low stock alert
        if item.min_stock_threshold and item.current_stock < item.min_stock_threshold:
            await StockService._create_low_stock_alert(
                business_id, item_id, item.current_stock, item.min_stock_threshold
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
        business_id: str,
        item_id: str,
        current_stock: Decimal,
        threshold: Decimal,
    ) -> None:
        """Create or update low stock alert."""
        try:
            business_obj_id = PydanticObjectId(business_id)
            item_obj_id = PydanticObjectId(item_id)
        except (ValueError, TypeError):
            return

        # Check if unresolved alert exists
        alert = await LowStockAlert.find_one(
            LowStockAlert.business_id == business_obj_id,
            LowStockAlert.item_id == item_obj_id,
            LowStockAlert.is_resolved == False,
        )

        if alert:
            # Update existing alert
            alert.current_stock = current_stock
            await alert.save()
        else:
            # Create new alert
            alert = LowStockAlert(
                business_id=business_obj_id,
                item_id=item_obj_id,
                current_stock=current_stock,
                threshold=threshold,
                is_resolved=False,
            )
            await alert.insert()

    @staticmethod
    async def list_low_stock_alerts(
        business_id: str,
        is_resolved: Optional[bool] = None,
    ) -> list[LowStockAlert]:
        """List low stock alerts."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        query = LowStockAlert.find(LowStockAlert.business_id == business_obj_id)

        if is_resolved is not None:
            query = query.find(LowStockAlert.is_resolved == is_resolved)

        alerts = await query.sort("-created_at").to_list()
        return alerts

    @staticmethod
    async def resolve_low_stock_alert(alert_id: str, business_id: str) -> None:
        """Resolve a low stock alert."""
        try:
            alert_obj_id = PydanticObjectId(alert_id)
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise NotFoundError("Alert not found")

        alert = await LowStockAlert.find_one(
            LowStockAlert.id == alert_obj_id,
            LowStockAlert.business_id == business_obj_id,
        )

        if not alert:
            raise NotFoundError("Alert not found")

        alert.is_resolved = True
        alert.resolved_at = datetime.now(timezone.utc)
        await alert.save()


# Singleton instance
stock_service = StockService()
