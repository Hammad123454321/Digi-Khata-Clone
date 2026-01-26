"""Item and inventory models."""
from datetime import datetime, timezone
from typing import Optional
import enum
from decimal import Decimal
from pydantic import Field
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel


class ItemUnit(str, enum.Enum):
    """Item unit enumeration."""

    PIECE = "pcs"
    KILOGRAM = "kg"
    LITER = "liter"
    METER = "meter"
    BOX = "box"
    PACK = "pack"


class Item(BaseModel):
    """Item/Product model."""

    business_id: Indexed(PydanticObjectId, )
    name: Indexed(str, )
    sku: Optional[Indexed(str, )] = None
    barcode: Optional[Indexed(str, )] = None
    purchase_price: Decimal
    sale_price: Decimal
    unit: ItemUnit = Field(default=ItemUnit.PIECE)
    opening_stock: Decimal = Field(default=Decimal("0.000"))
    current_stock: Indexed(Decimal, )
    min_stock_threshold: Optional[Decimal] = None  # For low stock alerts
    is_active: bool = Field(default=True)
    description: Optional[str] = None

    class Settings:
        name = "items"
        indexes = [
            [("business_id", 1)],
            [("name", 1)],
            [("business_id", 1), ("name", 1)],
            [("business_id", 1), ("is_active", 1)],
        ]


class InventoryTransactionType(str, enum.Enum):
    """Inventory transaction type."""

    STOCK_IN = "stock_in"  # Purchase, manual addition
    STOCK_OUT = "stock_out"  # Sale, manual reduction
    WASTAGE = "wastage"
    ADJUSTMENT = "adjustment"


class InventoryTransaction(BaseModel):
    """Inventory transaction model (ledger-style)."""

    business_id: Indexed(PydanticObjectId, )
    item_id: Indexed(PydanticObjectId, )
    transaction_type: InventoryTransactionType
    quantity: Decimal
    unit_price: Optional[Decimal] = None  # Purchase price for stock_in
    date: Indexed(datetime, )
    reference_id: Optional[PydanticObjectId] = None  # Reference to invoice, purchase, etc.
    reference_type: Optional[str] = None  # invoice, purchase, manual, etc.
    remarks: Optional[str] = None
    created_by_user_id: Optional[PydanticObjectId] = None

    class Settings:
        name = "inventory_transactions"
        indexes = [
            [("business_id", 1)],
            [("item_id", 1)],
            [("date", 1)],
            [("business_id", 1), ("item_id", 1), ("date", 1)],
            [("business_id", 1), ("transaction_type", 1), ("date", 1)],
        ]


class LowStockAlert(BaseModel):
    """Low stock alert model."""

    business_id: Indexed(PydanticObjectId, )
    item_id: Indexed(PydanticObjectId, )
    current_stock: Decimal
    threshold: Decimal
    is_resolved: bool = Field(default=False)
    resolved_at: Optional[datetime] = None

    class Settings:
        name = "low_stock_alerts"
        indexes = [
            [("business_id", 1)],
            [("is_resolved", 1)],
            [("business_id", 1), ("is_resolved", 1)],
        ]
