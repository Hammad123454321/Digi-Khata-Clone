"""RBAC permission helpers."""
from __future__ import annotations

from typing import Dict

from app.models.user import RoleActionEnum, UserRoleEnum

_ACTION_PRIORITY = {
    RoleActionEnum.VIEW.value: 1,
    RoleActionEnum.EDIT.value: 2,
    RoleActionEnum.MANAGE.value: 3,
}

DEFAULT_OWNER_PERMISSIONS: Dict[str, str] = {"*": RoleActionEnum.MANAGE.value}
DEFAULT_MANAGER_PERMISSIONS: Dict[str, str] = {"*": RoleActionEnum.MANAGE.value}
DEFAULT_STAFF_PERMISSIONS: Dict[str, str] = {
    "customers": RoleActionEnum.EDIT.value,
    "suppliers": RoleActionEnum.EDIT.value,
    "invoices": RoleActionEnum.EDIT.value,
    "stock": RoleActionEnum.EDIT.value,
    "cash": RoleActionEnum.EDIT.value,
    "expenses": RoleActionEnum.EDIT.value,
    "reports": RoleActionEnum.VIEW.value,
    "purchase_price": RoleActionEnum.VIEW.value,
}


def action_satisfies(granted_action: str, required_action: str) -> bool:
    """Check whether granted action includes required action level."""
    granted_level = _ACTION_PRIORITY.get(granted_action)
    required_level = _ACTION_PRIORITY.get(required_action)
    if granted_level is None or required_level is None:
        return False
    return granted_level >= required_level


def normalize_permissions(raw_permissions: Dict[str, str] | None) -> Dict[str, str]:
    """Normalize permission map to canonical resource/action strings."""
    if not raw_permissions:
        return {}

    normalized: Dict[str, str] = {}
    for resource, action in raw_permissions.items():
        resource_key = str(resource).strip().lower()
        action_value = str(action).strip().lower()
        if not resource_key or action_value not in _ACTION_PRIORITY:
            continue
        normalized[resource_key] = action_value
    return normalized


def permissions_for_legacy_role(role: UserRoleEnum) -> Dict[str, str]:
    """Default permissions for legacy enum roles."""
    if role == UserRoleEnum.OWNER:
        return DEFAULT_OWNER_PERMISSIONS.copy()
    if role == UserRoleEnum.MANAGER:
        return DEFAULT_MANAGER_PERMISSIONS.copy()
    return DEFAULT_STAFF_PERMISSIONS.copy()


def can_access(
    permissions: Dict[str, str],
    *,
    resource: str,
    action: str,
) -> bool:
    """Check access against permission map."""
    requested_resource = resource.strip().lower()
    requested_action = action.strip().lower()

    wildcard = permissions.get("*")
    if wildcard and action_satisfies(wildcard, requested_action):
        return True

    granted = permissions.get(requested_resource)
    if granted and action_satisfies(granted, requested_action):
        return True

    return False

