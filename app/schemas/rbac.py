"""RBAC and team-management schemas."""
from __future__ import annotations

from typing import Dict, Optional

from pydantic import BaseModel, Field, field_validator

from app.models.user import RoleActionEnum


class RoleCreate(BaseModel):
    """Create custom role request."""

    name: str = Field(..., min_length=2, max_length=64)
    permissions: Dict[str, RoleActionEnum] = Field(default_factory=dict)

    @field_validator("name")
    @classmethod
    def normalize_name(cls, value: str) -> str:
        return value.strip()


class RoleUpdate(BaseModel):
    """Update custom role request."""

    name: Optional[str] = Field(default=None, min_length=2, max_length=64)
    permissions: Optional[Dict[str, RoleActionEnum]] = None


class RoleResponse(BaseModel):
    """Custom role response."""

    id: str
    business_id: str
    name: str
    permissions: Dict[str, RoleActionEnum]
    is_active: bool
    is_system: bool


class TeamUserCreate(BaseModel):
    """Create/invite team user request."""

    name: str = Field(..., min_length=1, max_length=120)
    phone: str = Field(..., min_length=6, max_length=32)
    role_id: str


class TeamUserUpdate(BaseModel):
    """Update team-user role assignment."""

    role_id: str
    is_active: Optional[bool] = None


class TeamUserResponse(BaseModel):
    """Team-user view model."""

    membership_id: Optional[str] = None
    user_id: Optional[str] = None
    name: Optional[str] = None
    phone: Optional[str] = None
    legacy_role: str
    role_id: Optional[str] = None
    role_name: Optional[str] = None
    is_active: bool
    is_pending: bool
    invite_id: Optional[str] = None

