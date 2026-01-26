"""Expense models."""
from datetime import datetime, timezone
from typing import Optional
import enum
from decimal import Decimal
from pydantic import Field, Index
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel


class PaymentMode(str, enum.Enum):
    """Payment mode enumeration."""

    CASH = "cash"
    BANK = "bank"


class ExpenseCategory(BaseModel):
    """Expense category model."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    name: Indexed(str, index_type=Index.ASCENDING)
    description: Optional[str] = None
    is_active: bool = Field(default=True)

    class Settings:
        name = "expense_categories"
        indexes = [
            [("business_id", 1)],
            [("name", 1)],
            [("business_id", 1), ("name", 1)],
            [("business_id", 1), ("is_active", 1)],
        ]


class Expense(BaseModel):
    """Expense model."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    category_id: Optional[Indexed(PydanticObjectId, index_type=Index.ASCENDING)] = None
    amount: Decimal
    date: Indexed(datetime, index_type=Index.ASCENDING)
    payment_mode: Indexed(PaymentMode, index_type=Index.ASCENDING)
    description: Optional[str] = None
    reference_id: Optional[PydanticObjectId] = None  # Reference to bank transaction, etc.
    reference_type: Optional[str] = None
    created_by_user_id: Optional[PydanticObjectId] = None

    class Settings:
        name = "expenses"
        indexes = [
            [("business_id", 1)],
            [("date", 1)],
            [("business_id", 1), ("date", 1)],
            [("business_id", 1), ("category_id", 1), ("date", 1)],
            [("business_id", 1), ("payment_mode", 1), ("date", 1)],
        ]
