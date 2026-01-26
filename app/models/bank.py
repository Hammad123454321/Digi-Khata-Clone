"""Bank account and transaction models."""
from datetime import datetime, timezone
from typing import Optional
import enum
from decimal import Decimal
from pydantic import Field
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel
from app.core.security import encrypt_data, decrypt_data


class BankAccount(BaseModel):
    """Bank account model."""

    business_id: Indexed(PydanticObjectId, )
    bank_name: str
    account_number: Optional[str] = Field(default=None)  # Encrypted account number
    account_holder_name: Optional[str] = Field(default=None)  # Encrypted account holder name
    branch: Optional[str] = None
    ifsc_code: Optional[str] = None
    opening_balance: Decimal = Field(default=Decimal("0.00"))
    current_balance: Decimal = Field(default=Decimal("0.00"))
    is_active: bool = Field(default=True)

    class Settings:
        name = "bank_accounts"
        indexes = [
            [("business_id", 1)],
            [("business_id", 1), ("is_active", 1)],
        ]

    def set_account_number(self, account_number: str) -> None:
        """Set encrypted account number."""
        if account_number:
            self.account_number = encrypt_data(account_number)
    
    def get_account_number(self) -> Optional[str]:
        """Get decrypted account number."""
        if self.account_number:
            return decrypt_data(self.account_number)
        return None
    
    def set_account_holder_name(self, name: str) -> None:
        """Set encrypted account holder name."""
        if name:
            self.account_holder_name = encrypt_data(name)
    
    def get_account_holder_name(self) -> Optional[str]:
        """Get decrypted account holder name."""
        if self.account_holder_name:
            return decrypt_data(self.account_holder_name)
        return None


class BankTransactionType(str, enum.Enum):
    """Bank transaction type."""

    DEPOSIT = "deposit"
    WITHDRAWAL = "withdrawal"
    TRANSFER = "transfer"


class BankTransaction(BaseModel):
    """Bank transaction model (ledger-style)."""

    business_id: Indexed(PydanticObjectId, )
    bank_account_id: Indexed(PydanticObjectId, )
    transaction_type: BankTransactionType
    amount: Decimal
    date: Indexed(datetime, )
    reference_number: Optional[str] = None
    remarks: Optional[str] = None
    reference_id: Optional[PydanticObjectId] = None  # Reference to expense, salary, etc.
    reference_type: Optional[str] = None  # expense, salary, transfer, etc.
    created_by_user_id: Optional[PydanticObjectId] = None

    class Settings:
        name = "bank_transactions"
        indexes = [
            [("business_id", 1)],
            [("bank_account_id", 1)],
            [("date", 1)],
            [("business_id", 1), ("bank_account_id", 1), ("date", 1)],
            [("business_id", 1), ("transaction_type", 1), ("date", 1)],
        ]


class CashBankTransfer(BaseModel):
    """Cash to Bank or Bank to Cash transfer model."""

    business_id: Indexed(PydanticObjectId, )
    transfer_type: Indexed(str, )  # cash_to_bank, bank_to_cash
    amount: Decimal
    date: Indexed(datetime, )
    from_bank_account_id: Optional[PydanticObjectId] = None
    to_bank_account_id: Optional[PydanticObjectId] = None
    remarks: Optional[str] = None
    created_by_user_id: Optional[PydanticObjectId] = None

    class Settings:
        name = "cash_bank_transfers"
        indexes = [
            [("business_id", 1)],
            [("date", 1)],
            [("business_id", 1), ("date", 1)],
            [("business_id", 1), ("transfer_type", 1), ("date", 1)],
        ]
