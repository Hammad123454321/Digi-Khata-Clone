"""Sync schemas."""
from typing import List, Optional, Dict, Any
from datetime import datetime
from pydantic import BaseModel, Field


class SyncChangeRequest(BaseModel):
    """Single change to sync."""

    entity_type: str = Field(..., description="Entity type (e.g., 'cash_transaction', 'item', 'invoice')")
    entity_id: str = Field(..., description="Entity ID")
    action: str = Field(..., pattern="^(create|update|delete)$", description="Action type")
    data: Dict[str, Any] = Field(..., description="Entity data snapshot")
    updated_at: datetime = Field(..., description="Last update timestamp from client")
    version: Optional[int] = Field(None, description="Entity version for conflict detection")


class SyncPullRequest(BaseModel):
    """Request to pull changes from server."""

    cursor: Optional[str] = Field(None, description="Last sync cursor (timestamp or sequence)")
    entity_types: Optional[List[str]] = Field(None, description="Filter by entity types")
    limit: int = Field(100, ge=1, le=1000, description="Maximum number of changes to return")


class SyncChangeResponse(BaseModel):
    """Single change response."""

    entity_type: str
    entity_id: str
    action: str
    data: Dict[str, Any]
    sync_timestamp: datetime
    change_id: str


class SyncPullResponse(BaseModel):
    """Response for pull changes."""

    changes: List[SyncChangeResponse]
    next_cursor: Optional[str] = Field(None, description="Cursor for next page")
    has_more: bool = Field(False, description="Whether more changes are available")
    total_count: int = Field(0, description="Total changes available")


class SyncPushRequest(BaseModel):
    """Request to push changes to server."""

    changes: List[SyncChangeRequest] = Field(..., max_items=1000, description="List of changes to sync")


class SyncConflict(BaseModel):
    """Conflict information."""

    entity_type: str
    entity_id: str
    server_version: datetime
    client_version: datetime
    server_data: Dict[str, Any]
    client_data: Dict[str, Any]
    resolution: Optional[str] = Field(None, description="Resolution strategy applied")


class SyncPushResponse(BaseModel):
    """Response for push changes."""

    accepted: List[str] = Field(default_factory=list, description="Accepted change IDs")
    conflicts: List[SyncConflict] = Field(default_factory=list, description="Conflicts detected")
    rejected: List[Dict[str, Any]] = Field(default_factory=list, description="Rejected changes with errors")
    next_cursor: Optional[str] = Field(None, description="New sync cursor after push")


class SyncStatusResponse(BaseModel):
    """Sync status response."""

    last_sync_at: Optional[datetime] = Field(None, description="Last successful sync timestamp")
    sync_cursor: Optional[str] = Field(None, description="Current sync cursor")
    pending_changes_count: int = Field(0, description="Number of pending changes on server")
    device_id: str
    is_active: bool

