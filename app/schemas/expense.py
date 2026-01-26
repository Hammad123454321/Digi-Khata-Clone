"""Expense schemas."""
from datetime import datetime
from typing import Optional
from decimal import Decimal
from pydantic import BaseModel, Field


class ExpenseCategoryCreate(BaseModel):
    """Expense category creation schema."""

    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None


class ExpenseCategoryResponse(BaseModel):
    """Expense category response schema."""

    id: str
    name: str
    description: Optional[str]
    is_active: bool

    class Config:
        from_attributes = True


class ExpenseCreate(BaseModel):
    """Expense creation schema."""

    category_id: Optional[str] = None
    amount: Decimal = Field(..., gt=0)
    date: datetime
    payment_mode: str = Field(..., pattern="^(cash|bank)$")
    description: Optional[str] = None


class ExpenseResponse(BaseModel):
    """Expense response schema."""

    id: str
    category_id: Optional[str]
    amount: Decimal
    date: datetime
    payment_mode: str
    description: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True

