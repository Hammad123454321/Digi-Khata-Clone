"""Customer models."""
from sqlalchemy import Column, String, Numeric, Integer, ForeignKey, Text, DateTime, Boolean, Index, UniqueConstraint
from sqlalchemy.orm import relationship
from decimal import Decimal

from app.models.base import BaseModel


class Customer(BaseModel):
    """Customer model."""

    __tablename__ = "customers"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(255), nullable=False, index=True)
    phone = Column(String(20), nullable=True, index=True)
    email = Column(String(255), nullable=True)
    address = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)

    # Relationships
    business = relationship("Business", back_populates="customers")
    transactions = relationship("CustomerTransaction", back_populates="customer", cascade="all, delete-orphan")
    balances = relationship("CustomerBalance", back_populates="customer", cascade="all, delete-orphan")
    invoices = relationship("Invoice", back_populates="customer")

    __table_args__ = (
        Index("ix_customers_business_name", "business_id", "name"),
        Index("ix_customers_business_active", "business_id", "is_active"),
    )


class CustomerTransaction(BaseModel):
    """Customer transaction model (ledger-style for credit tracking)."""

    __tablename__ = "customer_transactions"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id", ondelete="CASCADE"), nullable=False, index=True)
    transaction_type = Column(String(50), nullable=False, index=True)  # credit, payment, adjustment
    amount = Column(Numeric(15, 2), nullable=False)
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    reference_id = Column(Integer, nullable=True)  # Reference to invoice, payment, etc.
    reference_type = Column(String(50), nullable=True)  # invoice, payment, manual, etc.
    remarks = Column(Text, nullable=True)
    created_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # Relationships
    customer = relationship("Customer", back_populates="transactions")

    __table_args__ = (
        Index("ix_customer_transactions_business_customer_date", "business_id", "customer_id", "date"),
        Index("ix_customer_transactions_business_type_date", "business_id", "transaction_type", "date"),
    )


class CustomerBalance(BaseModel):
    """Customer balance snapshot."""

    __tablename__ = "customer_balances"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id", ondelete="CASCADE"), nullable=False, index=True)
    balance = Column(Numeric(15, 2), default=Decimal("0.00"), nullable=False)
    last_transaction_date = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    customer = relationship("Customer", back_populates="balances")

    __table_args__ = (UniqueConstraint("business_id", "customer_id"),)

