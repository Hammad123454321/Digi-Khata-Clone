"""Role management endpoints."""
from __future__ import annotations

from fastapi import APIRouter, Depends

from app.api.dependencies import get_current_business, get_current_user, require_permission
from app.models.business import Business
from app.models.user import User
from app.schemas.rbac import RoleCreate, RoleResponse, RoleUpdate
from app.services.rbac import rbac_service

router = APIRouter(prefix="/roles", tags=["Roles"])


@router.post("", response_model=RoleResponse, status_code=201)
async def create_role(
    data: RoleCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
    _: dict = Depends(require_permission("team", "manage")),
):
    """Create a custom business role."""
    role = await rbac_service.create_role(
        business_id=str(current_business.id),
        name=data.name,
        permissions={k: v.value for k, v in data.permissions.items()},
        created_by_user_id=str(current_user.id),
    )
    return RoleResponse(
        id=str(role.id),
        business_id=str(role.business_id),
        name=role.name,
        permissions=role.permissions,
        is_active=role.is_active,
        is_system=role.is_system,
    )


@router.get("", response_model=list[RoleResponse])
async def list_roles(
    current_business: Business = Depends(get_current_business),
    _: dict = Depends(require_permission("team", "view")),
):
    """List active custom roles for current business."""
    roles = await rbac_service.list_roles(business_id=str(current_business.id))
    return [
        RoleResponse(
            id=str(role.id),
            business_id=str(role.business_id),
            name=role.name,
            permissions=role.permissions,
            is_active=role.is_active,
            is_system=role.is_system,
        )
        for role in roles
    ]


@router.patch("/{role_id}", response_model=RoleResponse)
async def update_role(
    role_id: str,
    data: RoleUpdate,
    current_business: Business = Depends(get_current_business),
    _: dict = Depends(require_permission("team", "manage")),
):
    """Update an existing custom role."""
    role = await rbac_service.update_role(
        business_id=str(current_business.id),
        role_id=role_id,
        name=data.name,
        permissions=(
            {k: v.value for k, v in data.permissions.items()}
            if data.permissions is not None
            else None
        ),
    )
    return RoleResponse(
        id=str(role.id),
        business_id=str(role.business_id),
        name=role.name,
        permissions=role.permissions,
        is_active=role.is_active,
        is_system=role.is_system,
    )


@router.delete("/{role_id}", response_model=dict)
async def delete_role(
    role_id: str,
    current_business: Business = Depends(get_current_business),
    _: dict = Depends(require_permission("team", "manage")),
):
    """Soft-delete custom role if not currently assigned."""
    await rbac_service.delete_role(
        business_id=str(current_business.id),
        role_id=role_id,
    )
    return {"message": "Role deleted successfully"}

