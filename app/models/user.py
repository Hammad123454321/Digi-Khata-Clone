"""User models."""
from datetime import datetime, timezone
from sqlalchemy import Column, String, Boolean, Integer, ForeignKey, Enum as SQLEnum, DateTime, UniqueConstraint
from sqlalchemy.orm import relationship
import enum

from app.models.base import BaseModel


class UserRoleEnum(str, enum.Enum):
    """User role enumeration."""

    OWNER = "owner"
    MANAGER = "manager"
    STAFF = "staff"


class User(BaseModel):
    """User model."""

    __tablename__ = "users"

    phone = Column(String(20), unique=True, nullable=False, index=True)
    name = Column(String(255), nullable=True)
    email = Column(String(255), nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    pin_hash = Column(String(255), nullable=True)  # Optional PIN for app lock
    last_login_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    memberships = relationship("UserMembership", back_populates="user", cascade="all, delete-orphan")
    devices = relationship("Device", back_populates="user", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<User {self.phone}>"


class UserMembership(BaseModel):
    """User membership in a business (multi-tenant)."""

    __tablename__ = "user_memberships"

    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    role = Column(SQLEnum(UserRoleEnum), default=UserRoleEnum.STAFF, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)

    # Relationships
    user = relationship("User", back_populates="memberships")
    business = relationship("Business", back_populates="users")

    __table_args__ = (UniqueConstraint("user_id", "business_id"),)


class UserRole(BaseModel):
    """User role permissions (for future RBAC)."""

    __tablename__ = "user_roles"

    membership_id = Column(Integer, ForeignKey("user_memberships.id", ondelete="CASCADE"), nullable=False)
    permission = Column(String(100), nullable=False)  # e.g., "cash.view", "stock.edit"

    __table_args__ = (UniqueConstraint("membership_id", "permission"),)

