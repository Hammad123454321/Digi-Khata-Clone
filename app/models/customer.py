"""Customer models."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from pydantic import Field, Index
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel
from app.core.security import encrypt_data, decrypt_data


class Customer(BaseModel):
    """Customer model."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    name: Indexed(str, index_type=Index.ASCENDING)
    phone: Optional[str] = Field(default=None)  # Encrypted phone
    email: Optional[str] = Field(default=None)  # Encrypted email
    address: Optional[str] = None
    is_active: bool = Field(default=True)

    class Settings:
        name = "customers"
        indexes = [
            [("business_id", 1)],
            [("name", 1)],
            [("business_id", 1), ("name", 1)],
            [("business_id", 1), ("is_active", 1)],
        ]

    def set_phone(self, phone: str) -> None:
        """Set encrypted phone."""
        if phone:
            self.phone = encrypt_data(phone)
    
    def get_phone(self) -> Optional[str]:
        """Get decrypted phone."""
        if self.phone:
            return decrypt_data(self.phone)
        return None
    
    def set_email(self, email: str) -> None:
        """Set encrypted email."""
        if email:
            self.email = encrypt_data(email)
    
    def get_email(self) -> Optional[str]:
        """Get decrypted email."""
        if self.email:
            return decrypt_data(self.email)
        return None


class CustomerTransaction(BaseModel):
    """Customer transaction model (ledger-style for credit tracking)."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    customer_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    transaction_type: Indexed(str, index_type=Index.ASCENDING)  # credit, payment, adjustment
    amount: Decimal
    date: Indexed(datetime, index_type=Index.ASCENDING)
    reference_id: Optional[PydanticObjectId] = None  # Reference to invoice, payment, etc.
    reference_type: Optional[str] = None  # invoice, payment, manual, etc.
    remarks: Optional[str] = None
    created_by_user_id: Optional[PydanticObjectId] = None

    class Settings:
        name = "customer_transactions"
        indexes = [
            [("business_id", 1)],
            [("customer_id", 1)],
            [("date", 1)],
            [("business_id", 1), ("customer_id", 1), ("date", 1)],
            [("business_id", 1), ("transaction_type", 1), ("date", 1)],
        ]


class CustomerBalance(BaseModel):
    """Customer balance snapshot."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    customer_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    balance: Decimal = Field(default=Decimal("0.00"))
    last_transaction_date: Optional[datetime] = None

    class Settings:
        name = "customer_balances"
        indexes = [
            [("business_id", 1), ("customer_id", 1)],  # Unique constraint
        ]
