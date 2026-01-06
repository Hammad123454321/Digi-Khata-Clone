"""Device model for multi-device support."""
from sqlalchemy import Column, String, Boolean, Integer, ForeignKey, DateTime, Text, UniqueConstraint
from sqlalchemy.orm import relationship

from app.models.base import BaseModel


class Device(BaseModel):
    """Device model for multi-device sync."""

    __tablename__ = "devices"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    device_id = Column(String(255), unique=True, nullable=False, index=True)  # Unique device identifier
    device_name = Column(String(255), nullable=True)
    device_type = Column(String(50), nullable=True)  # android, ios, web
    fcm_token = Column(Text, nullable=True)  # For push notifications
    is_active = Column(Boolean, default=True, nullable=False)
    last_sync_at = Column(DateTime(timezone=True), nullable=True)
    sync_cursor = Column(String(255), nullable=True)  # For incremental sync
    pairing_token = Column(String(255), nullable=True, index=True)  # For QR code pairing
    pairing_token_expires_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    business = relationship("Business", back_populates="devices")
    user = relationship("User", back_populates="devices")

    __table_args__ = (UniqueConstraint("business_id", "device_id"),)

