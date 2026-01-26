"""Customer schemas."""
from datetime import datetime
from typing import Optional
from decimal import Decimal
from pydantic import BaseModel, Field


class CustomerCreate(BaseModel):
    """Customer creation schema."""

    name: str = Field(..., min_length=1, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)
    email: Optional[str] = Field(None, max_length=255)
    address: Optional[str] = None


class CustomerUpdate(BaseModel):
    """Customer update schema."""

    name: Optional[str] = Field(None, min_length=1, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)
    email: Optional[str] = Field(None, max_length=255)
    address: Optional[str] = None
    is_active: Optional[bool] = None


class CustomerResponse(BaseModel):
    """Customer response schema."""

    id: str
    name: str
    phone: Optional[str]
    email: Optional[str]
    address: Optional[str]
    is_active: bool
    balance: Optional[Decimal] = None

    class Config:
        from_attributes = True


class CustomerPaymentCreate(BaseModel):
    """Customer payment creation schema."""

    amount: Decimal = Field(..., gt=0, description="Payment amount must be positive")
    date: datetime
    invoice_id: Optional[str] = Field(None, description="Optional invoice ID to link payment to specific invoice")
    remarks: Optional[str] = None


class CustomerTransactionResponse(BaseModel):
    """Customer transaction response schema."""

    id: str
    transaction_type: str
    amount: Decimal
    date: datetime
    reference_id: Optional[str]
    reference_type: Optional[str]
    remarks: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True

