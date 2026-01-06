"""Backup model."""
from sqlalchemy import Column, String, Integer, ForeignKey, Text, DateTime, Boolean, Numeric, Index
from sqlalchemy.orm import relationship

from app.models.base import BaseModel


class Backup(BaseModel):
    """Backup snapshot model."""

    __tablename__ = "backups"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    backup_type = Column(String(50), nullable=False, index=True)  # auto, manual
    file_path = Column(String(500), nullable=False)  # S3 path or local path
    file_size = Column(Numeric(15, 2), nullable=True)  # Size in MB
    status = Column(String(50), nullable=False, index=True)  # completed, failed, in_progress
    error_message = Column(Text, nullable=True)
    backup_date = Column(DateTime(timezone=True), nullable=False, index=True)

    # Relationships
    business = relationship("Business", back_populates="backups")

    __table_args__ = (
        Index("ix_backups_business_date", "business_id", "backup_date"),
        Index("ix_backups_business_status", "business_id", "status"),
    )

