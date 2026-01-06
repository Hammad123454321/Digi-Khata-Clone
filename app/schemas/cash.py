"""Cash management schemas."""
from datetime import datetime
from typing import Optional
from decimal import Decimal
from pydantic import BaseModel, Field


class CashTransactionCreate(BaseModel):
    """Cash transaction creation schema."""

    transaction_type: str = Field(..., pattern="^(cash_in|cash_out)$")
    amount: Decimal = Field(..., gt=0)
    date: datetime
    source: Optional[str] = Field(None, max_length=255)
    remarks: Optional[str] = None
    reference_id: Optional[int] = None
    reference_type: Optional[str] = Field(None, max_length=50)


class CashTransactionResponse(BaseModel):
    """Cash transaction response schema."""

    id: int
    transaction_type: str
    amount: Decimal
    date: datetime
    source: Optional[str]
    remarks: Optional[str]
    reference_id: Optional[int]
    reference_type: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


class CashBalanceResponse(BaseModel):
    """Cash balance response schema."""

    date: datetime
    opening_balance: Decimal
    total_cash_in: Decimal
    total_cash_out: Decimal
    closing_balance: Decimal

    class Config:
        from_attributes = True


class CashSummaryRequest(BaseModel):
    """Cash summary request schema."""

    start_date: datetime
    end_date: datetime


class CashSummaryResponse(BaseModel):
    """Cash summary response schema."""

    start_date: datetime
    end_date: datetime
    opening_balance: Decimal
    total_cash_in: Decimal
    total_cash_out: Decimal
    closing_balance: Decimal
    transactions: list[CashTransactionResponse]

