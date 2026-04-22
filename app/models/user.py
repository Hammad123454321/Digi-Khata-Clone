"""User models."""
from datetime import datetime, timezone
from typing import Optional, Dict
import enum
from pydantic import Field
from beanie import Indexed, PydanticObjectId
from pymongo import IndexModel

from app.models.base import BaseModel
from app.core.security import encrypt_data, decrypt_data


class UserRoleEnum(str, enum.Enum):
    """User role enumeration."""

    OWNER = "owner"
    MANAGER = "manager"
    STAFF = "staff"


class RoleActionEnum(str, enum.Enum):
    """Permission action level."""

    VIEW = "view"
    EDIT = "edit"
    MANAGE = "manage"


class TeamInviteStatus(str, enum.Enum):
    """Team invite status."""

    PENDING = "pending"
    ACCEPTED = "accepted"
    REVOKED = "revoked"


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
    custom_role_id: Optional[PydanticObjectId] = None
    invited_by_user_id: Optional[PydanticObjectId] = None
    is_active: bool = Field(default=True)

    class Settings:
        name = "user_memberships"
        indexes = [
            [("user_id", 1)],
            [("business_id", 1)],
            [("user_id", 1), ("business_id", 1)],  # Unique constraint
        ]


class BusinessRole(BaseModel):
    """Business-scoped custom role with per-resource action level."""

    business_id: Indexed(PydanticObjectId, )
    name: str
    normalized_name: str
    permissions: Dict[str, RoleActionEnum] = Field(default_factory=dict)
    is_system: bool = Field(default=False)
    is_active: bool = Field(default=True)
    created_by_user_id: Optional[PydanticObjectId] = None

    class Settings:
        name = "business_roles"
        indexes = [
            [("business_id", 1)],
            IndexModel([("business_id", 1), ("normalized_name", 1)], unique=True),
            [("business_id", 1), ("is_active", 1)],
        ]


class TeamInvite(BaseModel):
    """Pending team-user invite mapped by normalized phone number."""

    business_id: Indexed(PydanticObjectId, )
    phone: Indexed(str, )
    name: str
    role_id: PydanticObjectId
    status: TeamInviteStatus = Field(default=TeamInviteStatus.PENDING)
    created_by_user_id: Optional[PydanticObjectId] = None
    accepted_user_id: Optional[PydanticObjectId] = None
    accepted_at: Optional[datetime] = None
    is_active: bool = Field(default=True)

    class Settings:
        name = "team_invites"
        indexes = [
            [("business_id", 1)],
            [("phone", 1)],
            [("business_id", 1), ("status", 1)],
            IndexModel(
                [("business_id", 1), ("phone", 1)],
                unique=True,
                partialFilterExpression={"status": "pending", "is_active": True},
            ),
        ]


class UserRole(BaseModel):
    """Legacy membership permission model (kept for compatibility)."""

    membership_id: PydanticObjectId
    permission: str

    class Settings:
        name = "user_roles"
        indexes = [[("membership_id", 1), ("permission", 1)]]
