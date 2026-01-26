"""Sync change log model for multi-device synchronization."""
from datetime import datetime, timezone
from typing import Optional, Any
import enum
from pydantic import Field, Index
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel


class SyncAction(str, enum.Enum):
    """Sync action type."""

    CREATE = "create"
    UPDATE = "update"
    DELETE = "delete"


class SyncChangeLog(BaseModel):
    """Change log for tracking entity modifications for sync."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    device_id: Optional[Indexed(str, index_type=Index.ASCENDING)] = None  # Device that made the change (null for server changes)
    entity_type: Indexed(str, index_type=Index.ASCENDING)  # cash_transaction, item, invoice, customer, etc.
    entity_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    action: Indexed(SyncAction, index_type=Index.ASCENDING)
    data: Optional[dict[str, Any]] = None  # Snapshot of entity data at time of change
    sync_timestamp: Indexed(datetime, index_type=Index.ASCENDING)  # When change occurred
    synced_devices: Optional[list[str]] = None  # List of device_ids that have synced this change

    class Settings:
        name = "sync_change_logs"
        indexes = [
            [("business_id", 1)],
            [("sync_timestamp", 1)],
            [("entity_type", 1)],
            [("entity_id", 1)],
            [("device_id", 1)],
            [("business_id", 1), ("sync_timestamp", 1)],
            [("business_id", 1), ("entity_type", 1), ("entity_id", 1)],
            [("business_id", 1), ("device_id", 1)],
            [("entity_type", 1), ("entity_id", 1), ("sync_timestamp", 1)],
        ]
