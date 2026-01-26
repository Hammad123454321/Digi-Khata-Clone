"""Audit log model."""
from datetime import datetime, timezone
from typing import Optional, Any
from pydantic import Field
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel


class AuditLog(BaseModel):
    """Audit log for critical actions."""

    business_id: Indexed(PydanticObjectId, )
    user_id: Optional[Indexed(PydanticObjectId, )] = None
    action: Indexed(str, )  # e.g., "cash.edit", "stock.adjustment", "invoice.delete"
    entity_type: Indexed(str, )  # cash_transaction, item, invoice, etc.
    entity_id: Optional[Indexed(PydanticObjectId, )] = None
    old_values: Optional[dict[str, Any]] = None  # Previous state
    new_values: Optional[dict[str, Any]] = None  # New state
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None
    timestamp: Indexed(datetime, )

    class Settings:
        name = "audit_logs"
        indexes = [
            [("business_id", 1)],
            [("action", 1)],
            [("timestamp", 1)],
            [("business_id", 1), ("action", 1), ("timestamp", 1)],
            [("business_id", 1), ("entity_type", 1), ("entity_id", 1)],
        ]
