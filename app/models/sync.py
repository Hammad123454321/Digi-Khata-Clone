"""Sync change log model for multi-device synchronization."""
from sqlalchemy import Column, String, Integer, ForeignKey, Text, DateTime, JSON, Index, Enum as SQLEnum
from sqlalchemy.orm import relationship
import enum

from app.models.base import BaseModel


class SyncAction(str, enum.Enum):
    """Sync action type."""

    CREATE = "create"
    UPDATE = "update"
    DELETE = "delete"


class SyncChangeLog(BaseModel):
    """Change log for tracking entity modifications for sync."""

    __tablename__ = "sync_change_logs"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    device_id = Column(String(255), nullable=True, index=True)  # Device that made the change (null for server changes)
    entity_type = Column(String(50), nullable=False, index=True)  # cash_transaction, item, invoice, customer, etc.
    entity_id = Column(Integer, nullable=False, index=True)
    action = Column(SQLEnum(SyncAction), nullable=False, index=True)
    data = Column(JSON, nullable=True)  # Snapshot of entity data at time of change
    sync_timestamp = Column(DateTime(timezone=True), nullable=False, index=True)  # When change occurred
    synced_devices = Column(JSON, nullable=True)  # List of device_ids that have synced this change

    __table_args__ = (
        Index("ix_sync_change_logs_business_timestamp", "business_id", "sync_timestamp"),
        Index("ix_sync_change_logs_business_entity", "business_id", "entity_type", "entity_id"),
        Index("ix_sync_change_logs_business_device", "business_id", "device_id"),
        Index("ix_sync_change_logs_entity", "entity_type", "entity_id", "sync_timestamp"),
    )

