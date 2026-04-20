"""Invoice models."""
from datetime import datetime, timezone
from typing import Optional
import enum
from decimal import Decimal
from pydantic import Field
from beanie import Indexed, PydanticObjectId
from pymongo import IndexModel

from app.models.base import BaseModel


class InvoiceType(str, enum.Enum):
    """Invoice type."""

    CASH = "cash"
    CREDIT = "credit"


class Invoice(BaseModel):
    """Invoice model."""

    business_id: Indexed(PydanticObjectId, )
    customer_id: Optional[Indexed(PydanticObjectId, )] = None
    invoice_number: Indexed(str, unique=True, )
    invoice_type: InvoiceType
    date: Indexed(datetime, )
    subtotal: Decimal
    tax_amount: Decimal = Field(default=Decimal("0.00"))
    discount_amount: Decimal = Field(default=Decimal("0.00"))
    total_amount: Decimal
    paid_amount: Decimal = Field(default=Decimal("0.00"))
    remarks: Optional[str] = None
    client_request_id: Optional[str] = None  # Idempotency key from client for create retries
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
            IndexModel(
                [("business_id", 1), ("client_request_id", 1)],
                unique=True,
                partialFilterExpression={"client_request_id": {"$type": "string"}},
            ),
        ]


class InvoiceItem(BaseModel):
    """Invoice item model."""

    invoice_id: Indexed(PydanticObjectId, )
    item_id: Optional[Indexed(PydanticObjectId, )] = None
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
