"""Invoice models."""
from datetime import datetime, timezone
from typing import Optional
import enum
from decimal import Decimal
from pydantic import Field, Index
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel


class InvoiceType(str, enum.Enum):
    """Invoice type."""

    CASH = "cash"
    CREDIT = "credit"


class Invoice(BaseModel):
    """Invoice model."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    customer_id: Optional[Indexed(PydanticObjectId, index_type=Index.ASCENDING)] = None
    invoice_number: Indexed(str, unique=True, index_type=Index.ASCENDING)
    invoice_type: Indexed(InvoiceType, index_type=Index.ASCENDING)
    date: Indexed(datetime, index_type=Index.ASCENDING)
    subtotal: Decimal
    tax_amount: Decimal = Field(default=Decimal("0.00"))
    discount_amount: Decimal = Field(default=Decimal("0.00"))
    total_amount: Decimal
    paid_amount: Decimal = Field(default=Decimal("0.00"))
    remarks: Optional[str] = None
    pdf_path: Optional[str] = None  # Path to generated PDF
    created_by_user_id: Optional[PydanticObjectId] = None

    class Settings:
        name = "invoices"
        indexes = [
            [("business_id", 1)],
            [("invoice_number", 1)],
            [("date", 1)],
            [("business_id", 1), ("date", 1)],
            [("business_id", 1), ("invoice_type", 1), ("date", 1)],
            [("business_id", 1), ("customer_id", 1)],
        ]


class InvoiceItem(BaseModel):
    """Invoice item model."""

    invoice_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    item_id: Optional[Indexed(PydanticObjectId, index_type=Index.ASCENDING)] = None
    item_name: str  # Snapshot of item name
    quantity: Decimal
    unit_price: Decimal
    total_price: Decimal

    class Settings:
        name = "invoice_items"
        indexes = [
            [("invoice_id", 1)],
            [("item_id", 1)],
            [("invoice_id", 1), ("item_id", 1)],
        ]
