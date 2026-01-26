"""Audit log model."""
from datetime import datetime, timezone
from typing import Optional, Any
from pydantic import Field, Index
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel


class AuditLog(BaseModel):
    """Audit log for critical actions."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    user_id: Optional[Indexed(PydanticObjectId, index_type=Index.ASCENDING)] = None
    action: Indexed(str, index_type=Index.ASCENDING)  # e.g., "cash.edit", "stock.adjustment", "invoice.delete"
    entity_type: Indexed(str, index_type=Index.ASCENDING)  # cash_transaction, item, invoice, etc.
    entity_id: Optional[Indexed(PydanticObjectId, index_type=Index.ASCENDING)] = None
    old_values: Optional[dict[str, Any]] = None  # Previous state
    new_values: Optional[dict[str, Any]] = None  # New state
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None
    timestamp: Indexed(datetime, index_type=Index.ASCENDING)

    class Settings:
        name = "audit_logs"
        indexes = [
            [("business_id", 1)],
            [("action", 1)],
            [("timestamp", 1)],
            [("business_id", 1), ("action", 1), ("timestamp", 1)],
            [("business_id", 1), ("entity_type", 1), ("entity_id", 1)],
        ]
