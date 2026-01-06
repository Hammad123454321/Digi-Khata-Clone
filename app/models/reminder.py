"""Reminder model for customer/supplier credit."""
from sqlalchemy import Column, String, Numeric, Integer, ForeignKey, Text, DateTime, Boolean, Index
from sqlalchemy.orm import relationship
from decimal import Decimal

from app.models.base import BaseModel


class Reminder(BaseModel):
    """Reminder model for credit payments."""

    __tablename__ = "reminders"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    entity_type = Column(String(50), nullable=False, index=True)  # customer, supplier
    entity_id = Column(Integer, nullable=False, index=True)  # customer_id or supplier_id
    amount = Column(Numeric(15, 2), nullable=False)
    due_date = Column(DateTime(timezone=True), nullable=True, index=True)
    message = Column(Text, nullable=True)
    is_sent = Column(Boolean, default=False, nullable=False)
    sent_at = Column(DateTime(timezone=True), nullable=True)
    is_resolved = Column(Boolean, default=False, nullable=False)
    resolved_at = Column(DateTime(timezone=True), nullable=True)

    __table_args__ = (
        Index("ix_reminders_business_entity", "business_id", "entity_type", "entity_id"),
        Index("ix_reminders_business_resolved_due", "business_id", "is_resolved", "due_date"),
    )

