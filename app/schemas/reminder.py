"""Reminder schemas."""
from datetime import datetime
from typing import Optional, Literal
from decimal import Decimal
from pydantic import BaseModel, Field


class ReminderCreate(BaseModel):
    """Reminder creation schema."""

    entity_type: Literal["customer", "supplier"]
    entity_id: str
    amount: Decimal = Field(..., gt=0)
    due_date: Optional[datetime] = None
    message: Optional[str] = None
    send_sms: bool = False


class ReminderResponse(BaseModel):
    """Reminder response schema."""

    id: str
    entity_type: str
    entity_id: str
    entity_name: Optional[str] = None
    entity_phone: Optional[str] = None
    amount: Decimal
    due_date: Optional[datetime] = None
    message: Optional[str] = None
    is_sent: bool
    sent_at: Optional[datetime] = None
    is_resolved: bool
    resolved_at: Optional[datetime] = None
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True
