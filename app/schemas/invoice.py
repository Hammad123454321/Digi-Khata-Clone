"""Invoice schemas."""
from datetime import datetime
from typing import Optional, List
from decimal import Decimal
from pydantic import BaseModel, Field


class InvoiceItemCreate(BaseModel):
    """Invoice item creation schema."""

    item_id: Optional[int] = None
    item_name: str = Field(..., min_length=1, max_length=255)
    quantity: Decimal = Field(..., gt=0)
    unit_price: Decimal = Field(..., ge=0)


class InvoiceCreate(BaseModel):
    """Invoice creation schema."""

    customer_id: Optional[int] = None
    invoice_type: str = Field(..., pattern="^(cash|credit)$")
    date: datetime
    items: List[InvoiceItemCreate] = Field(..., min_items=1)
    tax_amount: Decimal = Field(default=Decimal("0.00"), ge=0)
    discount_amount: Decimal = Field(default=Decimal("0.00"), ge=0)
    remarks: Optional[str] = None


class InvoiceItemResponse(BaseModel):
    """Invoice item response schema."""

    id: int
    item_id: Optional[int]
    item_name: str
    quantity: Decimal
    unit_price: Decimal
    total_price: Decimal

    class Config:
        from_attributes = True


class InvoiceResponse(BaseModel):
    """Invoice response schema."""

    id: int
    invoice_number: str
    customer_id: Optional[int]
    invoice_type: str
    date: datetime
    subtotal: Decimal
    tax_amount: Decimal
    discount_amount: Decimal
    total_amount: Decimal
    paid_amount: Decimal
    remarks: Optional[str]
    pdf_path: Optional[str]
    items: List[InvoiceItemResponse]
    created_at: datetime

    class Config:
        from_attributes = True


class InvoiceListResponse(BaseModel):
    """Invoice list response schema."""

    id: int
    invoice_number: str
    customer_id: Optional[int]
    invoice_type: str
    date: datetime
    total_amount: Decimal
    paid_amount: Decimal
    created_at: datetime

    class Config:
        from_attributes = True

