"""Supplier schemas."""
from datetime import datetime
from typing import Optional
from decimal import Decimal
from pydantic import BaseModel, Field


class SupplierCreate(BaseModel):
    """Supplier creation schema."""

    name: str = Field(..., min_length=1, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)
    email: Optional[str] = Field(None, max_length=255)
    address: Optional[str] = None


class SupplierResponse(BaseModel):
    """Supplier response schema."""

    id: int
    name: str
    phone: Optional[str]
    email: Optional[str]
    address: Optional[str]
    is_active: bool
    balance: Optional[Decimal] = None

    class Config:
        from_attributes = True


class SupplierPaymentCreate(BaseModel):
    """Supplier payment creation schema."""

    supplier_id: int
    amount: Decimal = Field(..., gt=0)
    date: datetime
    remarks: Optional[str] = None

