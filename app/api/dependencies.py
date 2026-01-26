"""API dependencies."""
from typing import Optional

from fastapi import Depends, HTTPException, Header, Request
from beanie import PydanticObjectId

from app.core.exceptions import AuthenticationError, AuthorizationError, NotFoundError
from app.models.user import User, UserMembership
from app.models.business import Business
from app.models.device import Device

from app.core.logging import get_logger
from app.core.security import verify_token

logger = get_logger(__name__)


async def get_current_user(
    authorization: Optional[str] = Header(None),
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

    # Try to find user by id (could be ObjectId string or int)
    try:
        from beanie import PydanticObjectId
        user = await User.get(PydanticObjectId(user_id))
    except (ValueError, TypeError):
        # Fallback: if user_id is stored as int in token, query by a custom field
        # For now, we'll need to update token generation to use ObjectId strings
        # This is a temporary workaround - should use ObjectId in tokens
        raise AuthenticationError("Invalid user ID format")
    
    if not user or not user.is_active:
        raise AuthenticationError("User not found or inactive")

    return user


async def get_current_business(
    current_user: User = Depends(get_current_user),
    x_business_id: Optional[str] = Header(None),
) -> Business:
    """Get current business context from header."""
    if not x_business_id:
        raise HTTPException(status_code=400, detail="X-Business-Id header required")

    # Convert business_id to ObjectId
    try:
        from beanie import PydanticObjectId
        business_obj_id = PydanticObjectId(x_business_id)
    except (ValueError, TypeError):
        raise HTTPException(status_code=400, detail="Invalid business ID format")

    # Check if user has membership in this business
    membership = await UserMembership.find_one(
        UserMembership.user_id == current_user.id,
        UserMembership.business_id == business_obj_id,
        UserMembership.is_active == True,
    )

    if not membership:
        raise AuthorizationError("User does not have access to this business")

    # Get business
    business = await Business.get(business_obj_id)
    if not business or not business.is_active:
        raise NotFoundError("Business not found or inactive")

    return business


async def get_current_device(
    current_user: User = Depends(get_current_user),
    current_business: Business = Depends(get_current_business),
    x_device_id: Optional[str] = Header(None),
) -> Optional[Device]:
    """Get current device from header (optional)."""
    if not x_device_id:
        return None

    device = await Device.find_one(
        Device.device_id == x_device_id,
        Device.business_id == current_business.id,
        Device.user_id == current_user.id,
        Device.is_active == True,
    )

    return device


def require_role(required_role: str):
    """Dependency factory for role-based access control."""

    async def role_checker(
        current_user: User = Depends(get_current_user),
        current_business: Business = Depends(get_current_business),
    ):
        """Check if user has required role in business."""
        membership = await UserMembership.find_one(
            UserMembership.user_id == current_user.id,
            UserMembership.business_id == current_business.id,
            UserMembership.is_active == True,
        )

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
