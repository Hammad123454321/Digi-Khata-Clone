"""Cash management models."""
from datetime import datetime, timezone
from typing import Optional
import enum
from decimal import Decimal
from pydantic import Field
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel


class CashTransactionType(str, enum.Enum):
    """Cash transaction type."""

    CASH_IN = "cash_in"
    CASH_OUT = "cash_out"


class CashTransaction(BaseModel):
    """Cash transaction model (ledger-style)."""

    business_id: Indexed(PydanticObjectId, )
    transaction_type: CashTransactionType
    amount: Decimal
    date: Indexed(datetime, )
    source: Optional[str] = None  # e.g., "sales", "customer_payment", "recovery"
    remarks: Optional[str] = None
    reference_id: Optional[PydanticObjectId] = None  # Reference to invoice, expense, etc.
    reference_type: Optional[str] = None  # invoice, expense, transfer, etc.
    created_by_user_id: Optional[PydanticObjectId] = None

    class Settings:
        name = "cash_transactions"
        indexes = [
            [("business_id", 1)],
            [("date", 1)],
            [("business_id", 1), ("date", 1)],
            [("business_id", 1), ("transaction_type", 1), ("date", 1)],
        ]


class CashBalance(BaseModel):
    """Daily cash balance snapshot."""

    business_id: Indexed(PydanticObjectId, )
    date: Indexed(datetime, )
    opening_balance: Decimal = Field(default=Decimal("0.00"))
    total_cash_in: Decimal = Field(default=Decimal("0.00"))
    total_cash_out: Decimal = Field(default=Decimal("0.00"))
    closing_balance: Decimal

    class Settings:
        name = "cash_balances"
        indexes = [
            [("business_id", 1), ("date", 1)],  # Unique constraint
        ]
