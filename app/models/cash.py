"""Cash management models."""
from sqlalchemy import Column, String, Numeric, Integer, ForeignKey, DateTime, Text, Enum as SQLEnum, Index, UniqueConstraint
from sqlalchemy.orm import relationship
import enum
from decimal import Decimal

from app.models.base import BaseModel


class CashTransactionType(str, enum.Enum):
    """Cash transaction type."""

    CASH_IN = "cash_in"
    CASH_OUT = "cash_out"


class CashTransaction(BaseModel):
    """Cash transaction model (ledger-style)."""

    __tablename__ = "cash_transactions"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    transaction_type = Column(SQLEnum(CashTransactionType), nullable=False, index=True)
    amount = Column(Numeric(15, 2), nullable=False)
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    source = Column(String(255), nullable=True)  # e.g., "sales", "customer_payment", "recovery"
    remarks = Column(Text, nullable=True)
    reference_id = Column(Integer, nullable=True)  # Reference to invoice, expense, etc.
    reference_type = Column(String(50), nullable=True)  # invoice, expense, transfer, etc.
    created_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # Relationships
    business = relationship("Business", back_populates="cash_transactions")

    __table_args__ = (
        Index("ix_cash_transactions_business_date", "business_id", "date"),
        Index("ix_cash_transactions_business_type_date", "business_id", "transaction_type", "date"),
    )


class CashBalance(BaseModel):
    """Daily cash balance snapshot."""

    __tablename__ = "cash_balances"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    opening_balance = Column(Numeric(15, 2), default=Decimal("0.00"), nullable=False)
    total_cash_in = Column(Numeric(15, 2), default=Decimal("0.00"), nullable=False)
    total_cash_out = Column(Numeric(15, 2), default=Decimal("0.00"), nullable=False)
    closing_balance = Column(Numeric(15, 2), nullable=False)

    __table_args__ = (UniqueConstraint("business_id", "date"),)

