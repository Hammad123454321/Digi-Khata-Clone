"""RBAC and team-management service."""
from __future__ import annotations

from datetime import datetime, timezone
from typing import Dict, Optional

from beanie import PydanticObjectId
from beanie.operators import In
from pymongo.errors import DuplicateKeyError

from app.core.exceptions import ConflictError, NotFoundError, ValidationError
from app.core.logging import get_logger
from app.core.permissions import normalize_permissions, permissions_for_legacy_role
from app.core.phone import normalize_phone_number
from app.models.user import (
    BusinessRole,
    RoleActionEnum,
    TeamInvite,
    TeamInviteStatus,
    User,
    UserMembership,
    UserRoleEnum,
)

logger = get_logger(__name__)


class RBACService:
    """Business-scoped RBAC helper service."""

    @staticmethod
    async def activate_pending_invites_for_user(user: User) -> None:
        """Attach memberships for pending invites matching verified phone."""
        invites = await TeamInvite.find(
            TeamInvite.phone == user.phone,
            TeamInvite.status == TeamInviteStatus.PENDING,
            TeamInvite.is_active == True,
        ).to_list()

        if not invites:
            return

        for invite in invites:
            existing_membership = await UserMembership.find_one(
                UserMembership.user_id == user.id,
                UserMembership.business_id == invite.business_id,
            )
            if existing_membership is None:
                membership = UserMembership(
                    user_id=user.id,
                    business_id=invite.business_id,
                    role=UserRoleEnum.STAFF,
                    custom_role_id=invite.role_id,
                    invited_by_user_id=invite.created_by_user_id,
                    is_active=True,
                )
                await membership.insert()
            else:
                existing_membership.custom_role_id = invite.role_id
                existing_membership.is_active = True
                await existing_membership.save()

            invite.status = TeamInviteStatus.ACCEPTED
            invite.accepted_user_id = user.id
            invite.accepted_at = datetime.now(timezone.utc)
            invite.is_active = False
            await invite.save()

            if (not user.name or not user.name.strip()) and invite.name.strip():
                user.name = invite.name.strip()

        await user.save()
        logger.info("team_invites_activated", user_id=str(user.id), count=len(invites))

    @staticmethod
    async def get_effective_permissions(
        membership: UserMembership,
    ) -> Dict[str, str]:
        """Resolve effective permissions from custom role or legacy role."""
        if membership.role in (UserRoleEnum.OWNER, UserRoleEnum.MANAGER):
            return permissions_for_legacy_role(membership.role)

        if membership.custom_role_id:
            role = await BusinessRole.find_one(
                BusinessRole.id == membership.custom_role_id,
                BusinessRole.business_id == membership.business_id,
                BusinessRole.is_active == True,
            )
            if role:
                return normalize_permissions(
                    {
                        resource: (
                            action.value if isinstance(action, RoleActionEnum) else str(action)
                        )
                        for resource, action in role.permissions.items()
                    }
                )
        return permissions_for_legacy_role(membership.role)

    @staticmethod
    async def build_business_access_payload(
        membership: UserMembership,
    ) -> Dict[str, object]:
        """Build business access payload for auth responses."""
        permissions = await RBACService.get_effective_permissions(membership)
        custom_role_name: Optional[str] = None
        if membership.custom_role_id:
            role = await BusinessRole.find_one(
                BusinessRole.id == membership.custom_role_id,
                BusinessRole.business_id == membership.business_id,
                BusinessRole.is_active == True,
            )
            if role:
                custom_role_name = role.name
        return {
            "legacy_role": membership.role.value,
            "role_id": str(membership.custom_role_id) if membership.custom_role_id else None,
            "role_name": custom_role_name,
            "permissions": permissions,
        }

    @staticmethod
    async def create_role(
        *,
        business_id: str,
        name: str,
        permissions: Dict[str, str],
        created_by_user_id: str,
    ) -> BusinessRole:
        business_obj_id = PydanticObjectId(business_id)
        creator_obj_id = PydanticObjectId(created_by_user_id)
        normalized_name = name.strip().lower()
        if not normalized_name:
            raise ValidationError("Role name is required")

        role = BusinessRole(
            business_id=business_obj_id,
            name=name.strip(),
            normalized_name=normalized_name,
            permissions={
                resource: RoleActionEnum(action)
                for resource, action in normalize_permissions(permissions).items()
            },
            created_by_user_id=creator_obj_id,
            is_active=True,
        )
        try:
            await role.insert()
        except DuplicateKeyError as exc:
            raise ConflictError("Role with this name already exists") from exc
        return role

    @staticmethod
    async def list_roles(*, business_id: str) -> list[BusinessRole]:
        business_obj_id = PydanticObjectId(business_id)
        return await BusinessRole.find(
            BusinessRole.business_id == business_obj_id,
            BusinessRole.is_active == True,
        ).sort("+name").to_list()

    @staticmethod
    async def update_role(
        *,
        business_id: str,
        role_id: str,
        name: Optional[str] = None,
        permissions: Optional[Dict[str, str]] = None,
    ) -> BusinessRole:
        business_obj_id = PydanticObjectId(business_id)
        role_obj_id = PydanticObjectId(role_id)
        role = await BusinessRole.find_one(
            BusinessRole.id == role_obj_id,
            BusinessRole.business_id == business_obj_id,
            BusinessRole.is_active == True,
        )
        if role is None:
            raise NotFoundError("Role not found")

        if name is not None:
            normalized_name = name.strip().lower()
            if not normalized_name:
                raise ValidationError("Role name is required")
            role.name = name.strip()
            role.normalized_name = normalized_name
        if permissions is not None:
            role.permissions = {
                resource: RoleActionEnum(action)
                for resource, action in normalize_permissions(permissions).items()
            }
        try:
            await role.save()
        except DuplicateKeyError as exc:
            raise ConflictError("Role with this name already exists") from exc
        return role

    @staticmethod
    async def delete_role(*, business_id: str, role_id: str) -> None:
        business_obj_id = PydanticObjectId(business_id)
        role_obj_id = PydanticObjectId(role_id)
        role = await BusinessRole.find_one(
            BusinessRole.id == role_obj_id,
            BusinessRole.business_id == business_obj_id,
            BusinessRole.is_active == True,
        )
        if role is None:
            raise NotFoundError("Role not found")

        assigned_memberships = await UserMembership.find(
            UserMembership.business_id == business_obj_id,
            UserMembership.custom_role_id == role_obj_id,
            UserMembership.is_active == True,
        ).count()
        if assigned_memberships > 0:
            raise ConflictError("Role is assigned to team members and cannot be deleted")

        role.is_active = False
        await role.save()

    @staticmethod
    async def provision_team_user(
        *,
        business_id: str,
        actor_user_id: str,
        name: str,
        phone: str,
        role_id: str,
    ) -> dict:
        business_obj_id = PydanticObjectId(business_id)
        actor_obj_id = PydanticObjectId(actor_user_id)
        role_obj_id = PydanticObjectId(role_id)
        role = await BusinessRole.find_one(
            BusinessRole.id == role_obj_id,
            BusinessRole.business_id == business_obj_id,
            BusinessRole.is_active == True,
        )
        if role is None:
            raise NotFoundError("Role not found")

        normalized_phone = normalize_phone_number(phone)
        user = await User.find_one(User.phone == normalized_phone)
        if user is not None:
            membership = await UserMembership.find_one(
                UserMembership.user_id == user.id,
                UserMembership.business_id == business_obj_id,
            )
            if membership is None:
                membership = UserMembership(
                    user_id=user.id,
                    business_id=business_obj_id,
                    role=UserRoleEnum.STAFF,
                    custom_role_id=role.id,
                    invited_by_user_id=actor_obj_id,
                    is_active=True,
                )
                await membership.insert()
            else:
                membership.custom_role_id = role.id
                membership.is_active = True
                await membership.save()
            return {
                "status": "attached_existing_user",
                "membership_id": str(membership.id),
                "user_id": str(user.id),
                "phone": normalized_phone,
                "name": user.name or name.strip(),
                "role_id": str(role.id),
                "role_name": role.name,
            }

        invite = await TeamInvite.find_one(
            TeamInvite.business_id == business_obj_id,
            TeamInvite.phone == normalized_phone,
            TeamInvite.status == TeamInviteStatus.PENDING,
            TeamInvite.is_active == True,
        )
        if invite is None:
            invite = TeamInvite(
                business_id=business_obj_id,
                phone=normalized_phone,
                name=name.strip(),
                role_id=role.id,
                status=TeamInviteStatus.PENDING,
                created_by_user_id=actor_obj_id,
                is_active=True,
            )
            await invite.insert()
        else:
            invite.name = name.strip()
            invite.role_id = role.id
            invite.created_by_user_id = actor_obj_id
            await invite.save()

        return {
            "status": "invited_pending_signup",
            "invite_id": str(invite.id),
            "phone": normalized_phone,
            "name": invite.name,
            "role_id": str(role.id),
            "role_name": role.name,
        }

    @staticmethod
    async def list_team_users(*, business_id: str) -> list[dict]:
        business_obj_id = PydanticObjectId(business_id)
        memberships = await UserMembership.find(
            UserMembership.business_id == business_obj_id,
        ).to_list()
        role_ids = {m.custom_role_id for m in memberships if m.custom_role_id is not None}
        roles = (
            await BusinessRole.find(
                BusinessRole.business_id == business_obj_id,
                In(BusinessRole.id, list(role_ids)),
            ).to_list()
            if role_ids
            else []
        )
        role_map = {role.id: role for role in roles}

        user_ids = [m.user_id for m in memberships]
        users = (
            await User.find(In(User.id, user_ids)).to_list()
            if user_ids
            else []
        )
        user_map = {user.id: user for user in users}

        response = []
        for membership in memberships:
            user = user_map.get(membership.user_id)
            role = role_map.get(membership.custom_role_id) if membership.custom_role_id else None
            response.append(
                {
                    "membership_id": str(membership.id),
                    "user_id": str(membership.user_id),
                    "name": user.name if user else None,
                    "phone": user.phone if user else None,
                    "legacy_role": membership.role.value,
                    "role_id": str(role.id) if role else None,
                    "role_name": role.name if role else None,
                    "is_active": membership.is_active,
                    "is_pending": False,
                }
            )

        invites = await TeamInvite.find(
            TeamInvite.business_id == business_obj_id,
            TeamInvite.status == TeamInviteStatus.PENDING,
            TeamInvite.is_active == True,
        ).to_list()
        for invite in invites:
            role = role_map.get(invite.role_id)
            if role is None:
                role = await BusinessRole.find_one(BusinessRole.id == invite.role_id)
            response.append(
                {
                    "membership_id": None,
                    "user_id": None,
                    "name": invite.name,
                    "phone": invite.phone,
                    "legacy_role": UserRoleEnum.STAFF.value,
                    "role_id": str(invite.role_id),
                    "role_name": role.name if role else None,
                    "is_active": True,
                    "is_pending": True,
                    "invite_id": str(invite.id),
                }
            )
        return response

    @staticmethod
    async def update_membership_role(
        *,
        business_id: str,
        membership_id: str,
        role_id: str,
        is_active: Optional[bool] = None,
    ) -> UserMembership:
        business_obj_id = PydanticObjectId(business_id)
        membership_obj_id = PydanticObjectId(membership_id)
        role_obj_id = PydanticObjectId(role_id)

        role = await BusinessRole.find_one(
            BusinessRole.id == role_obj_id,
            BusinessRole.business_id == business_obj_id,
            BusinessRole.is_active == True,
        )
        if role is None:
            raise NotFoundError("Role not found")

        membership = await UserMembership.find_one(
            UserMembership.id == membership_obj_id,
            UserMembership.business_id == business_obj_id,
        )
        if membership is None:
            raise NotFoundError("Membership not found")

        membership.custom_role_id = role.id
        if is_active is not None:
            membership.is_active = is_active
        await membership.save()
        return membership


rbac_service = RBACService()
