"""Invoice models."""
from sqlalchemy import Column, String, Numeric, Integer, ForeignKey, Text, DateTime, Boolean, Enum as SQLEnum, Index
from sqlalchemy.orm import relationship
import enum
from decimal import Decimal

from app.models.base import BaseModel


class InvoiceType(str, enum.Enum):
    """Invoice type."""

    CASH = "cash"
    CREDIT = "credit"


class Invoice(BaseModel):
    """Invoice model."""

    __tablename__ = "invoices"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id", ondelete="SET NULL"), nullable=True, index=True)
    invoice_number = Column(String(100), unique=True, nullable=False, index=True)
    invoice_type = Column(SQLEnum(InvoiceType), nullable=False, index=True)
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    subtotal = Column(Numeric(15, 2), nullable=False)
    tax_amount = Column(Numeric(15, 2), default=Decimal("0.00"), nullable=False)
    discount_amount = Column(Numeric(15, 2), default=Decimal("0.00"), nullable=False)
    total_amount = Column(Numeric(15, 2), nullable=False)
    paid_amount = Column(Numeric(15, 2), default=Decimal("0.00"), nullable=False)
    remarks = Column(Text, nullable=True)
    pdf_path = Column(String(500), nullable=True)  # Path to generated PDF
    created_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # Relationships
    business = relationship("Business", back_populates="invoices")
    customer = relationship("Customer", back_populates="invoices")
    items = relationship("InvoiceItem", back_populates="invoice", cascade="all, delete-orphan")

    __table_args__ = (
        Index("ix_invoices_business_date", "business_id", "date"),
        Index("ix_invoices_business_type_date", "business_id", "invoice_type", "date"),
        Index("ix_invoices_business_customer", "business_id", "customer_id"),
    )


class InvoiceItem(BaseModel):
    """Invoice item model."""

    __tablename__ = "invoice_items"

    invoice_id = Column(Integer, ForeignKey("invoices.id", ondelete="CASCADE"), nullable=False, index=True)
    item_id = Column(Integer, ForeignKey("items.id", ondelete="SET NULL"), nullable=True, index=True)
    item_name = Column(String(255), nullable=False)  # Snapshot of item name
    quantity = Column(Numeric(15, 3), nullable=False)
    unit_price = Column(Numeric(15, 2), nullable=False)
    total_price = Column(Numeric(15, 2), nullable=False)

    # Relationships
    invoice = relationship("Invoice", back_populates="items")
    item = relationship("Item", back_populates="invoice_items")

    __table_args__ = (Index("ix_invoice_items_invoice_item", "invoice_id", "item_id"),)

