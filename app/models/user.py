"""User models."""
from datetime import datetime, timezone
from typing import Optional
import enum
from pydantic import Field
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel
from app.core.security import encrypt_data, decrypt_data


class UserRoleEnum(str, enum.Enum):
    """User role enumeration."""

    OWNER = "owner"
    MANAGER = "manager"
    STAFF = "staff"


class User(BaseModel):
    """User model."""

    phone: Indexed(str, unique=True)  # Keep unencrypted for OTP/auth lookups
    name: Optional[str] = None
    email: Optional[str] = Field(default=None)  # Encrypted email
    is_active: bool = Field(default=True)
    pin_hash: Optional[str] = None  # Optional PIN for app lock
    last_login_at: Optional[datetime] = None
    language_preference: str = Field(default="en")  # en, ur, ar
    default_business_id: Optional[PydanticObjectId] = None

    class Settings:
        name = "users"
        indexes = [
            [("phone", 1)],
            [("is_active", 1)],
        ]

    def __repr__(self):
        return f"<User {self.phone}>"
    
    def set_email(self, email: str) -> None:
        """Set encrypted email."""
        if email:
            self.email = encrypt_data(email)
    
    def get_email(self) -> Optional[str]:
        """Get decrypted email."""
        if self.email:
            return decrypt_data(self.email)
        return None


class UserMembership(BaseModel):
    """User membership in a business (multi-tenant)."""

    user_id: Indexed(PydanticObjectId, )
    business_id: Indexed(PydanticObjectId, )
    role: UserRoleEnum = Field(default=UserRoleEnum.STAFF)
    is_active: bool = Field(default=True)

    class Settings:
        name = "user_memberships"
        indexes = [
            [("user_id", 1)],
            [("business_id", 1)],
            [("user_id", 1), ("business_id", 1)],  # Unique constraint
        ]


class UserRole(BaseModel):
    """User role permissions (for future RBAC)."""

    membership_id: PydanticObjectId
    permission: str  # e.g., "cash.view", "stock.edit"

    class Settings:
        name = "user_roles"
        indexes = [
            [("membership_id", 1), ("permission", 1)],  # Unique constraint
        ]
