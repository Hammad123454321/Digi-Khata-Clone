"""API dependencies."""
from typing import Optional

from fastapi import Depends, HTTPException, Header, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.security import verify_token
from app.core.exceptions import AuthenticationError, AuthorizationError
from app.models.user import User, UserMembership
from app.models.business import Business
from app.models.device import Device

from app.core.logging import get_logger

logger = get_logger(__name__)


async def get_current_user(
    authorization: Optional[str] = Header(None),
    db: AsyncSession = Depends(get_db),
) -> User:
    """Get current authenticated user from JWT token."""
    if not authorization:
        raise AuthenticationError("Authorization header missing")

    try:
        scheme, token = authorization.split()
        if scheme.lower() != "bearer":
            raise AuthenticationError("Invalid authorization scheme")
    except ValueError:
        raise AuthenticationError("Invalid authorization header format")

    payload = verify_token(token)
    if not payload:
        raise AuthenticationError("Invalid or expired token")

    user_id = payload.get("sub")
    if not user_id:
        raise AuthenticationError("Invalid token payload")

    result = await db.execute(select(User).where(User.id == int(user_id), User.is_active == True))
    user = result.scalar_one_or_none()

    if not user:
        raise AuthenticationError("User not found or inactive")

    return user


async def get_current_business(
    current_user: User = Depends(get_current_user),
    x_business_id: Optional[int] = Header(None),
    db: AsyncSession = Depends(get_db),
) -> Business:
    """Get current business context from header."""
    if not x_business_id:
        raise HTTPException(status_code=400, detail="X-Business-Id header required")

    # Check if user has membership in this business
    result = await db.execute(
        select(UserMembership).where(
            UserMembership.user_id == current_user.id,
            UserMembership.business_id == x_business_id,
            UserMembership.is_active == True,
        )
    )
    membership = result.scalar_one_or_none()

    if not membership:
        raise AuthorizationError("User does not have access to this business")

    # Get business
    result = await db.execute(select(Business).where(Business.id == x_business_id, Business.is_active == True))
    business = result.scalar_one_or_none()

    if not business:
        raise NotFoundError("Business not found or inactive")

    return business


async def get_current_device(
    current_user: User = Depends(get_current_user),
    current_business: Business = Depends(get_current_business),
    x_device_id: Optional[str] = Header(None),
    db: AsyncSession = Depends(get_db),
) -> Optional[Device]:
    """Get current device from header (optional)."""
    if not x_device_id:
        return None

    result = await db.execute(
        select(Device).where(
            Device.device_id == x_device_id,
            Device.business_id == current_business.id,
            Device.user_id == current_user.id,
            Device.is_active == True,
        )
    )
    device = result.scalar_one_or_none()

    return device


def require_role(required_role: str):
    """Dependency factory for role-based access control."""

    async def role_checker(
        current_user: User = Depends(get_current_user),
        current_business: Business = Depends(get_current_business),
        db: AsyncSession = Depends(get_db),
    ):
        """Check if user has required role in business."""
        result = await db.execute(
            select(UserMembership).where(
                UserMembership.user_id == current_user.id,
                UserMembership.business_id == current_business.id,
                UserMembership.is_active == True,
            )
        )
        membership = result.scalar_one_or_none()

        if not membership:
            raise AuthorizationError("User does not have access to this business")

        # Owner and manager have all permissions
        if membership.role.value in ["owner", "manager"]:
            return membership

        # Check specific role
        if membership.role.value != required_role:
            raise AuthorizationError(f"Required role: {required_role}")

        return membership

    return role_checker

