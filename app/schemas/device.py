"""Device schemas."""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class DevicePairRequest(BaseModel):
    """Device pairing request schema."""

    device_id: str = Field(..., min_length=1, max_length=255)
    device_name: Optional[str] = Field(None, max_length=255)
    device_type: Optional[str] = Field(None, pattern="^(android|ios|web)$")
    pairing_token: str = Field(..., description="QR code pairing token")


class DeviceResponse(BaseModel):
    """Device response schema."""

    id: int
    device_id: str
    device_name: Optional[str]
    device_type: Optional[str]
    is_active: bool
    last_sync_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


class DevicePairingTokenResponse(BaseModel):
    """Device pairing token response schema."""

    pairing_token: str
    expires_at: datetime

