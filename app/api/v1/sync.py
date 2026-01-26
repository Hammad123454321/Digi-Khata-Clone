"""Sync endpoints for multi-device synchronization."""
from typing import List
from fastapi import APIRouter, Depends, Header

from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.schemas.sync import (
    SyncPullRequest,
    SyncPullResponse,
    SyncPushRequest,
    SyncPushResponse,
    SyncStatusResponse,
    SyncChangeResponse,
)
from app.services.sync import sync_service

router = APIRouter(prefix="/sync", tags=["Sync"])


@router.post("/pull", response_model=SyncPullResponse)
async def pull_changes(
    request: SyncPullRequest,
    current_business: Business = Depends(get_current_business),
    x_device_id: str = Header(..., description="Device ID"),
):
    """Pull changes from server since last sync."""
    changes, next_cursor, has_more = await sync_service.pull_changes(
        business_id=str(current_business.id),
        device_id=x_device_id,
        cursor=request.cursor,
        entity_types=request.entity_types,
        limit=request.limit,
    )

    # Get total count for reference
    total_count = len(changes)

    return SyncPullResponse(
        changes=changes,
        next_cursor=next_cursor,
        has_more=has_more,
        total_count=total_count,
    )


@router.post("/push", response_model=SyncPushResponse)
async def push_changes(
    request: SyncPushRequest,
    current_business: Business = Depends(get_current_business),
    x_device_id: str = Header(..., description="Device ID"),
):
    """Push local changes to server."""
    accepted, conflicts, rejected = await sync_service.push_changes(
        business_id=str(current_business.id),
        device_id=x_device_id,
        changes=request.changes,
    )

    # Generate next cursor (current timestamp)
    from datetime import datetime, timezone

    next_cursor = datetime.now(timezone.utc).isoformat()

    return SyncPushResponse(
        accepted=accepted,
        conflicts=conflicts,
        rejected=rejected,
        next_cursor=next_cursor,
    )


@router.get("/status", response_model=SyncStatusResponse)
async def get_sync_status(
    current_business: Business = Depends(get_current_business),
    x_device_id: str = Header(..., description="Device ID"),
):
    """Get sync status for current device."""
    status = await sync_service.get_sync_status(
        business_id=str(current_business.id),
        device_id=x_device_id,
    )

    return SyncStatusResponse(**status)
