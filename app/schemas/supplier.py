"""Supplier schemas."""
from datetime import datetime
from typing import Optional, List
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

    id: str
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

    amount: Decimal = Field(..., gt=0, description="Payment amount must be positive")
    date: datetime
    remarks: Optional[str] = None


class SupplierPurchaseItem(BaseModel):
    """Supplier purchase item schema."""

    item_id: str = Field(..., description="Item ID")
    quantity: Decimal = Field(..., gt=0, description="Quantity must be positive")
    unit_price: Optional[Decimal] = Field(None, gt=0, description="Unit price must be positive if provided")


class SupplierPurchaseCreate(BaseModel):
    """Supplier purchase creation schema."""

    amount: Decimal = Field(..., gt=0, description="Purchase amount must be positive")
    date: datetime
    items: Optional[List[SupplierPurchaseItem]] = Field(None, description="List of items purchased")
    remarks: Optional[str] = None
