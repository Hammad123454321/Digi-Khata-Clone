"""Expense models."""
from sqlalchemy import Column, String, Numeric, Integer, ForeignKey, Text, DateTime, Boolean, Enum as SQLEnum, Index
from sqlalchemy.orm import relationship
import enum
from decimal import Decimal

from app.models.base import BaseModel


class PaymentMode(str, enum.Enum):
    """Payment mode enumeration."""

    CASH = "cash"
    BANK = "bank"


class ExpenseCategory(BaseModel):
    """Expense category model."""

    __tablename__ = "expense_categories"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(255), nullable=False, index=True)
    description = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)

    # Relationships
    expenses = relationship("Expense", back_populates="category", cascade="all, delete-orphan")

    __table_args__ = (
        Index("ix_expense_categories_business_name", "business_id", "name"),
        Index("ix_expense_categories_business_active", "business_id", "is_active"),
    )


class Expense(BaseModel):
    """Expense model."""

    __tablename__ = "expenses"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    category_id = Column(Integer, ForeignKey("expense_categories.id", ondelete="SET NULL"), nullable=True, index=True)
    amount = Column(Numeric(15, 2), nullable=False)
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    payment_mode = Column(SQLEnum(PaymentMode), nullable=False, index=True)
    description = Column(Text, nullable=True)
    reference_id = Column(Integer, nullable=True)  # Reference to bank transaction, etc.
    reference_type = Column(String(50), nullable=True)
    created_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # Relationships
    business = relationship("Business", back_populates="expenses")
    category = relationship("ExpenseCategory", back_populates="expenses")

    __table_args__ = (
        Index("ix_expenses_business_date", "business_id", "date"),
        Index("ix_expenses_business_category_date", "business_id", "category_id", "date"),
        Index("ix_expenses_business_payment_date", "business_id", "payment_mode", "date"),
    )

