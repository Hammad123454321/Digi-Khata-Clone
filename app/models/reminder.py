"""Reminder model for customer/supplier credit."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from pydantic import Field, Index
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel


class Reminder(BaseModel):
    """Reminder model for credit payments."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    entity_type: Indexed(str, index_type=Index.ASCENDING)  # customer, supplier
    entity_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)  # customer_id or supplier_id
    amount: Decimal
    due_date: Optional[Indexed(datetime, index_type=Index.ASCENDING)] = None
    message: Optional[str] = None
    is_sent: bool = Field(default=False)
    sent_at: Optional[datetime] = None
    is_resolved: bool = Field(default=False)
    resolved_at: Optional[datetime] = None

    class Settings:
        name = "reminders"
        indexes = [
            [("business_id", 1)],
            [("entity_type", 1)],
            [("entity_id", 1)],
            [("due_date", 1)],
            [("business_id", 1), ("entity_type", 1), ("entity_id", 1)],
            [("business_id", 1), ("is_resolved", 1), ("due_date", 1)],
        ]
