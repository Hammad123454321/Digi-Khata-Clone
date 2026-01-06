"""Item and inventory models."""
from sqlalchemy import Column, String, Numeric, Integer, ForeignKey, Boolean, Text, Enum as SQLEnum, DateTime, Index
from sqlalchemy.orm import relationship
import enum
from decimal import Decimal

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

    __tablename__ = "items"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(255), nullable=False, index=True)
    sku = Column(String(100), nullable=True, index=True)
    barcode = Column(String(100), nullable=True, index=True)
    purchase_price = Column(Numeric(15, 2), nullable=False)
    sale_price = Column(Numeric(15, 2), nullable=False)
    unit = Column(SQLEnum(ItemUnit), default=ItemUnit.PIECE, nullable=False)
    opening_stock = Column(Numeric(15, 3), default=Decimal("0.000"), nullable=False)
    current_stock = Column(Numeric(15, 3), default=Decimal("0.000"), nullable=False, index=True)
    min_stock_threshold = Column(Numeric(15, 3), nullable=True)  # For low stock alerts
    is_active = Column(Boolean, default=True, nullable=False)
    description = Column(Text, nullable=True)

    # Relationships
    business = relationship("Business", back_populates="items")
    inventory_transactions = relationship("InventoryTransaction", back_populates="item", cascade="all, delete-orphan")
    invoice_items = relationship("InvoiceItem", back_populates="item")
    low_stock_alerts = relationship("LowStockAlert", back_populates="item", cascade="all, delete-orphan")

    __table_args__ = (
        Index("ix_items_business_name", "business_id", "name"),
        Index("ix_items_business_active", "business_id", "is_active"),
    )


class InventoryTransactionType(str, enum.Enum):
    """Inventory transaction type."""

    STOCK_IN = "stock_in"  # Purchase, manual addition
    STOCK_OUT = "stock_out"  # Sale, manual reduction
    WASTAGE = "wastage"
    ADJUSTMENT = "adjustment"


class InventoryTransaction(BaseModel):
    """Inventory transaction model (ledger-style)."""

    __tablename__ = "inventory_transactions"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    item_id = Column(Integer, ForeignKey("items.id", ondelete="CASCADE"), nullable=False, index=True)
    transaction_type = Column(SQLEnum(InventoryTransactionType), nullable=False, index=True)
    quantity = Column(Numeric(15, 3), nullable=False)
    unit_price = Column(Numeric(15, 2), nullable=True)  # Purchase price for stock_in
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    reference_id = Column(Integer, nullable=True)  # Reference to invoice, purchase, etc.
    reference_type = Column(String(50), nullable=True)  # invoice, purchase, manual, etc.
    remarks = Column(Text, nullable=True)
    created_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # Relationships
    item = relationship("Item", back_populates="inventory_transactions")

    __table_args__ = (
        Index("ix_inventory_transactions_business_item_date", "business_id", "item_id", "date"),
        Index("ix_inventory_transactions_business_type_date", "business_id", "transaction_type", "date"),
    )


class LowStockAlert(BaseModel):
    """Low stock alert model."""

    __tablename__ = "low_stock_alerts"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    item_id = Column(Integer, ForeignKey("items.id", ondelete="CASCADE"), nullable=False, index=True)
    current_stock = Column(Numeric(15, 3), nullable=False)
    threshold = Column(Numeric(15, 3), nullable=False)
    is_resolved = Column(Boolean, default=False, nullable=False)
    resolved_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    item = relationship("Item", back_populates="low_stock_alerts")

    __table_args__ = (Index("ix_low_stock_alerts_business_resolved", "business_id", "is_resolved"),)

