"""Backup model."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from pydantic import Field, Index
from beanie import Indexed, PydanticObjectId

from app.models.base import BaseModel


class Backup(BaseModel):
    """Backup snapshot model."""

    business_id: Indexed(PydanticObjectId, index_type=Index.ASCENDING)
    backup_type: Indexed(str, index_type=Index.ASCENDING)  # auto, manual
    file_path: str  # S3 path or local path
    file_size: Optional[Decimal] = None  # Size in MB
    status: Indexed(str, index_type=Index.ASCENDING)  # completed, failed, in_progress
    error_message: Optional[str] = None
    backup_date: Indexed(datetime, index_type=Index.ASCENDING)

    class Settings:
        name = "backups"
        indexes = [
            [("business_id", 1)],
            [("backup_date", 1)],
            [("status", 1)],
            [("business_id", 1), ("backup_date", 1)],
            [("business_id", 1), ("status", 1)],
        ]
