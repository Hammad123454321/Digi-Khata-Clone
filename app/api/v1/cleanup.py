"""Cleanup API endpoints."""
from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.services.cleanup import cleanup_service
from app.core.config import get_settings
from app.core.logging import get_logger

router = APIRouter(prefix="/cleanup", tags=["cleanup"])
settings = get_settings()
logger = get_logger(__name__)


@router.post("/audit-logs")
async def cleanup_audit_logs(
    retention_days: Optional[int] = None,
    current_user: User = Depends(get_current_user),
):
    """
    Clean up old audit logs.
    
    Args:
        retention_days: Number of days to retain (defaults to configured value, max 365)
    """
    if retention_days and retention_days > settings.AUDIT_LOG_MAX_RETENTION_DAYS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Retention cannot exceed {settings.AUDIT_LOG_MAX_RETENTION_DAYS} days",
        )

    result = await cleanup_service.cleanup_audit_logs(
        retention_days=retention_days
    )
    return result


@router.post("/backups")
async def cleanup_backups(
    retention_days: Optional[int] = None,
    current_user: User = Depends(get_current_user),
):
    """
    Clean up expired backups.
    
    Args:
        retention_days: Number of days to retain (defaults to configured value)
    """
    result = await cleanup_service.cleanup_expired_backups(
        retention_days=retention_days
    )
    return result


@router.post("/all")
async def cleanup_all(
    audit_retention_days: Optional[int] = None,
    backup_retention_days: Optional[int] = None,
    current_user: User = Depends(get_current_user),
):
    """
    Run all cleanup tasks.
    
    Args:
        audit_retention_days: Audit log retention (defaults to configured value)
        backup_retention_days: Backup retention (defaults to configured value)
    """
    if (
        audit_retention_days
        and audit_retention_days > settings.AUDIT_LOG_MAX_RETENTION_DAYS
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Audit retention cannot exceed {settings.AUDIT_LOG_MAX_RETENTION_DAYS} days",
        )

    result = await cleanup_service.run_all_cleanups(
        audit_retention_days=audit_retention_days,
        backup_retention_days=backup_retention_days,
    )
    return result


@router.put("/audit-retention/{business_id}")
async def update_audit_retention(
    business_id: str,
    retention_days: int,
    current_user: User = Depends(get_current_user),
    current_business: Business = Depends(get_current_business),
):
    """
    Update audit log retention for a business.
    Allows extending retention up to 1 year (365 days).
    
    Args:
        business_id: Business ID
        retention_days: New retention period (1-365 days)
    """
    # Verify user has access to this business
    if str(current_business.id) != business_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied to this business",
        )

    if retention_days < 1 or retention_days > settings.AUDIT_LOG_MAX_RETENTION_DAYS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Retention must be between 1 and {settings.AUDIT_LOG_MAX_RETENTION_DAYS} days",
        )

    result = await cleanup_service.update_audit_retention(
        business_id=business_id, retention_days=retention_days
    )
    return result
