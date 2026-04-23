"""API dependencies."""
from typing import Optional, Dict

from fastapi import Depends, HTTPException, Header, Request
from beanie import PydanticObjectId

from app.core.exceptions import AuthenticationError, AuthorizationError, NotFoundError
from app.core.translations import translate, get_user_language
from app.models.user import User, UserMembership
from app.models.business import Business
from app.models.device import Device
from app.core.permissions import can_access
from app.services.rbac import rbac_service

from app.core.logging import get_logger
from app.core.security import verify_token

logger = get_logger(__name__)

_VIEW_METHODS = {"GET", "HEAD", "OPTIONS"}
_ROUTE_RESOURCE_MAP = {
    "customers": "customers",
    "suppliers": "suppliers",
    "invoices": "invoices",
    "stock": "stock",
    "cash": "cash",
    "expenses": "expenses",
    "reports": "reports",
    "banks": "cash",
    "roles": "team",
    "team": "team",
    "staff": "team",
    "devices": "team",
}


def _resolve_route_segment(path: str) -> Optional[str]:
    """Resolve first route segment for /api/v1/* path."""
    parts = [part for part in path.split("/") if part]
    if len(parts) >= 3 and parts[0] == "api" and parts[1] == "v1":
        return parts[2].lower()
    if parts:
        return parts[0].lower()
    return None


def _resolve_required_action(method: str) -> str:
    """Map HTTP method to required action level."""
    return "view" if method.upper() in _VIEW_METHODS else "edit"


async def get_current_user(
    authorization: Optional[str] = Header(None),
) -> User:
    """Get current authenticated user from JWT token."""
    if not authorization:
        raise AuthenticationError(translate("authorization_header_missing", "en"))

    try:
        scheme, token = authorization.split()
        if scheme.lower() != "bearer":
            raise AuthenticationError(translate("invalid_authorization_scheme", "en"))
    except ValueError:
        raise AuthenticationError(translate("invalid_authorization_header", "en"))

    payload = verify_token(token)
    if not payload:
        raise AuthenticationError(translate("invalid_or_expired_token", "en"))

    user_id = payload.get("sub")
    if not user_id:
        raise AuthenticationError(translate("invalid_token_payload", "en"))

    # Try to find user by id (could be ObjectId string or int)
    try:
        from beanie import PydanticObjectId
        user = await User.get(PydanticObjectId(user_id))
    except (ValueError, TypeError):
        # Fallback: if user_id is stored as int in token, query by a custom field
        # For now, we'll need to update token generation to use ObjectId strings
        # This is a temporary workaround - should use ObjectId in tokens
        raise AuthenticationError(translate("invalid_user_id_format", "en"))
    
    if not user or not user.is_active:
        language = get_user_language(user=user) if user else "en"
        raise AuthenticationError(translate("user_not_found_or_inactive", language))

    return user


async def get_current_membership(
    current_user: User = Depends(get_current_user),
    x_business_id: Optional[str] = Header(None),
) -> UserMembership:
    """Get current user's active membership in selected business."""
    language = get_user_language(user=current_user)

    if not x_business_id:
        raise HTTPException(
            status_code=400,
            detail=translate("business_id_header_required", language),
        )

    try:
        business_obj_id = PydanticObjectId(x_business_id)
    except (ValueError, TypeError):
        raise HTTPException(
            status_code=400,
            detail=translate("invalid_business_id_format", language),
        )

    membership = await UserMembership.find_one(
        UserMembership.user_id == current_user.id,
        UserMembership.business_id == business_obj_id,
        UserMembership.is_active == True,
    )
    if membership is None:
        raise AuthorizationError(translate("user_no_business_access", language))
    return membership


async def get_current_business(
    request: Request,
    current_user: User = Depends(get_current_user),
    membership: UserMembership = Depends(get_current_membership),
) -> Business:
    """Get current business context from header + membership."""
    language = get_user_language(user=current_user)
    business = await Business.get(membership.business_id)
    if not business or not business.is_active:
        raise NotFoundError(translate("business_not_found_or_inactive", language))

    segment = _resolve_route_segment(request.url.path)
    resource = _ROUTE_RESOURCE_MAP.get(segment or "")
    if resource:
        permissions = await rbac_service.get_effective_permissions(membership)
        request.state.current_permissions = permissions
        required_action = _resolve_required_action(request.method)
        if not can_access(permissions, resource=resource, action=required_action):
            raise AuthorizationError(translate("access_denied", language))

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
        language = get_user_language(user=current_user)
        
        membership = await UserMembership.find_one(
            UserMembership.user_id == current_user.id,
            UserMembership.business_id == current_business.id,
            UserMembership.is_active == True,
        )

        if not membership:
            raise AuthorizationError(translate("user_no_business_access", language))

        # Owner and manager have all permissions
        if membership.role.value in ["owner", "manager"]:
            return membership

        # Check specific role
        if membership.role.value != required_role:
            raise AuthorizationError(translate("required_role", language, role=required_role))

        return membership

    return role_checker


async def get_current_permissions(
    request: Request,
    membership: UserMembership = Depends(get_current_membership),
) -> Dict[str, str]:
    """Resolve current membership permissions."""
    cached = getattr(request.state, "current_permissions", None)
    if isinstance(cached, dict):
        return cached
    permissions = await rbac_service.get_effective_permissions(membership)
    request.state.current_permissions = permissions
    return permissions


def require_permission(resource: str, action: str):
    """Dependency factory for permission checks."""

    async def permission_checker(
        current_user: User = Depends(get_current_user),
        permissions: Dict[str, str] = Depends(get_current_permissions),
    ) -> Dict[str, str]:
        language = get_user_language(user=current_user)
        if not can_access(permissions, resource=resource, action=action):
            raise AuthorizationError(
                translate(
                    "access_denied",
                    language,
                )
            )
        return permissions

    return permission_checker
