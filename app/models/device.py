"""Device model for multi-device support."""
from datetime import datetime, timezone
from typing import Optional
from pydantic import Field, Index
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel


class Device(BaseModel):
    """Device model for multi-device sync."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    user_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    device_id: Indexed(str, unique=True, index_type=Index.ASCENDING)  # Unique device identifier
    device_name: Optional[str] = None
    device_type: Optional[str] = None  # android, ios, web
    fcm_token: Optional[str] = None  # For push notifications
    is_active: bool = Field(default=True)
    last_sync_at: Optional[datetime] = None
    sync_cursor: Optional[str] = None  # For incremental sync
    pairing_token: Optional[Indexed(str, index_type=Index.ASCENDING)] = None  # For QR code pairing
    pairing_token_expires_at: Optional[datetime] = None

    class Settings:
        name = "devices"
        indexes = [
            [("business_id", 1)],
            [("user_id", 1)],
            [("device_id", 1)],
            [("business_id", 1), ("device_id", 1)],  # Unique constraint
        ]
