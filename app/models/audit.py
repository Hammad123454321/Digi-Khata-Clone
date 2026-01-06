"""Audit log model."""
from sqlalchemy import Column, String, Integer, ForeignKey, Text, DateTime, JSON, Index
from sqlalchemy.orm import relationship

from app.models.base import BaseModel


class AuditLog(BaseModel):
    """Audit log for critical actions."""

    __tablename__ = "audit_logs"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    action = Column(String(100), nullable=False, index=True)  # e.g., "cash.edit", "stock.adjustment", "invoice.delete"
    entity_type = Column(String(50), nullable=False, index=True)  # cash_transaction, item, invoice, etc.
    entity_id = Column(Integer, nullable=True, index=True)
    old_values = Column(JSON, nullable=True)  # Previous state
    new_values = Column(JSON, nullable=True)  # New state
    ip_address = Column(String(45), nullable=True)
    user_agent = Column(Text, nullable=True)
    timestamp = Column(DateTime(timezone=True), nullable=False, index=True)

    __table_args__ = (
        Index("ix_audit_logs_business_action_timestamp", "business_id", "action", "timestamp"),
        Index("ix_audit_logs_business_entity", "business_id", "entity_type", "entity_id"),
    )

