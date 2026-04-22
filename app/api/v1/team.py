"""Team user management endpoints."""
from __future__ import annotations

from fastapi import APIRouter, Depends

from app.api.dependencies import get_current_business, get_current_user, require_permission
from app.models.business import Business
from app.models.user import User
from app.schemas.rbac import TeamUserCreate, TeamUserResponse, TeamUserUpdate
from app.services.rbac import rbac_service

router = APIRouter(prefix="/team", tags=["Team"])


@router.post("/users", response_model=dict, status_code=201)
async def create_team_user(
    data: TeamUserCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
    _: dict = Depends(require_permission("team", "manage")),
):
    """Create or invite a team user by phone and assign custom role."""
    return await rbac_service.provision_team_user(
        business_id=str(current_business.id),
        actor_user_id=str(current_user.id),
        name=data.name,
        phone=data.phone,
        role_id=data.role_id,
    )


@router.get("/users", response_model=list[TeamUserResponse])
async def list_team_users(
    current_business: Business = Depends(get_current_business),
    _: dict = Depends(require_permission("team", "view")),
):
    """List active team memberships and pending invites."""
    users = await rbac_service.list_team_users(business_id=str(current_business.id))
    return [TeamUserResponse(**user) for user in users]


@router.patch("/users/{membership_id}", response_model=TeamUserResponse)
async def update_team_user(
    membership_id: str,
    data: TeamUserUpdate,
    current_business: Business = Depends(get_current_business),
    _: dict = Depends(require_permission("team", "manage")),
):
    """Update team member role assignment."""
    membership = await rbac_service.update_membership_role(
        business_id=str(current_business.id),
        membership_id=membership_id,
        role_id=data.role_id,
        is_active=data.is_active,
    )
    team_rows = await rbac_service.list_team_users(business_id=str(current_business.id))
    for row in team_rows:
        if row.get("membership_id") == str(membership.id):
            return TeamUserResponse(**row)
    # Fallback should not happen, but keep a valid response in edge case.
    return TeamUserResponse(
        membership_id=str(membership.id),
        user_id=str(membership.user_id),
        legacy_role=membership.role.value,
        role_id=str(membership.custom_role_id) if membership.custom_role_id else None,
        role_name=None,
        is_active=membership.is_active,
        is_pending=False,
    )

