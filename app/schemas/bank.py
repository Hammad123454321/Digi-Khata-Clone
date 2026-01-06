"""Bank schemas."""
from datetime import datetime
from typing import Optional
from decimal import Decimal
from pydantic import BaseModel, Field


class BankAccountCreate(BaseModel):
    """Bank account creation schema."""

    bank_name: str = Field(..., min_length=1, max_length=255)
    account_number: Optional[str] = Field(None, max_length=100)
    account_holder_name: Optional[str] = Field(None, max_length=255)
    branch: Optional[str] = Field(None, max_length=255)
    ifsc_code: Optional[str] = Field(None, max_length=50)
    opening_balance: Decimal = Field(default=Decimal("0.00"))


class BankAccountResponse(BaseModel):
    """Bank account response schema."""

    id: int
    bank_name: str
    account_number: Optional[str]
    account_holder_name: Optional[str]
    branch: Optional[str]
    ifsc_code: Optional[str]
    opening_balance: Decimal
    current_balance: Decimal
    is_active: bool

    class Config:
        from_attributes = True


class BankTransactionCreate(BaseModel):
    """Bank transaction creation schema."""

    bank_account_id: int
    transaction_type: str = Field(..., pattern="^(deposit|withdrawal|transfer)$")
    amount: Decimal = Field(..., gt=0)
    date: datetime
    reference_number: Optional[str] = None
    remarks: Optional[str] = None


class CashBankTransferCreate(BaseModel):
    """Cash-bank transfer creation schema."""

    transfer_type: str = Field(..., pattern="^(cash_to_bank|bank_to_cash)$")
    amount: Decimal = Field(..., gt=0)
    date: datetime
    bank_account_id: Optional[int] = None
    remarks: Optional[str] = None

