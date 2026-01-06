"""Supplier models."""
from sqlalchemy import Column, String, Numeric, Integer, ForeignKey, Text, DateTime, Boolean, Index, UniqueConstraint
from sqlalchemy.orm import relationship
from decimal import Decimal

from app.models.base import BaseModel


class Supplier(BaseModel):
    """Supplier model."""

    __tablename__ = "suppliers"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(255), nullable=False, index=True)
    phone = Column(String(20), nullable=True, index=True)
    email = Column(String(255), nullable=True)
    address = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)

    # Relationships
    business = relationship("Business", back_populates="suppliers")
    transactions = relationship("SupplierTransaction", back_populates="supplier", cascade="all, delete-orphan")
    balances = relationship("SupplierBalance", back_populates="supplier", cascade="all, delete-orphan")

    __table_args__ = (
        Index("ix_suppliers_business_name", "business_id", "name"),
        Index("ix_suppliers_business_active", "business_id", "is_active"),
    )


class SupplierTransaction(BaseModel):
    """Supplier transaction model (ledger-style for payable tracking)."""

    __tablename__ = "supplier_transactions"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    supplier_id = Column(Integer, ForeignKey("suppliers.id", ondelete="CASCADE"), nullable=False, index=True)
    transaction_type = Column(String(50), nullable=False, index=True)  # purchase, payment, adjustment
    amount = Column(Numeric(15, 2), nullable=False)
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    reference_id = Column(Integer, nullable=True)  # Reference to purchase, payment, etc.
    reference_type = Column(String(50), nullable=True)  # purchase, payment, manual, etc.
    remarks = Column(Text, nullable=True)
    created_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # Relationships
    supplier = relationship("Supplier", back_populates="transactions")

    __table_args__ = (
        Index("ix_supplier_transactions_business_supplier_date", "business_id", "supplier_id", "date"),
        Index("ix_supplier_transactions_business_type_date", "business_id", "transaction_type", "date"),
    )


class SupplierBalance(BaseModel):
    """Supplier balance snapshot."""

    __tablename__ = "supplier_balances"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    supplier_id = Column(Integer, ForeignKey("suppliers.id", ondelete="CASCADE"), nullable=False, index=True)
    balance = Column(Numeric(15, 2), default=Decimal("0.00"), nullable=False)  # Positive = payable
    last_transaction_date = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    supplier = relationship("Supplier", back_populates="balances")

    __table_args__ = (UniqueConstraint("business_id", "supplier_id"),)

