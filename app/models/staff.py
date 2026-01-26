"""Staff models."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from pydantic import Field, Index
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel
from app.core.security import encrypt_data, decrypt_data


class Staff(BaseModel):
    """Staff model."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    name: Indexed(str, index_type=Index.ASCENDING)
    phone: Optional[str] = Field(default=None)  # Encrypted phone
    email: Optional[str] = Field(default=None)  # Encrypted email
    role: Optional[str] = None
    address: Optional[str] = None
    is_active: bool = Field(default=True)

    class Settings:
        name = "staff"
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


class StaffSalary(BaseModel):
    """Staff salary record model."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    staff_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    amount: Decimal
    date: Indexed(datetime, index_type=Index.ASCENDING)
    payment_mode: Indexed(str, index_type=Index.ASCENDING)  # cash, bank
    remarks: Optional[str] = None
    reference_id: Optional[PydanticObjectId] = None  # Reference to bank transaction, etc.
    reference_type: Optional[str] = None
    created_by_user_id: Optional[PydanticObjectId] = None

    class Settings:
        name = "staff_salaries"
        indexes = [
            [("business_id", 1)],
            [("staff_id", 1)],
            [("date", 1)],
            [("business_id", 1), ("staff_id", 1), ("date", 1)],
            [("business_id", 1), ("date", 1)],
        ]
