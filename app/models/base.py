"""Base model classes for Beanie."""
from datetime import datetime, timezone
from beanie import Document
from pydantic import Field, ConfigDict
from typing import Optional


class TimestampMixin:
    """Mixin for timestamp fields."""
    
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        description="Creation timestamp"
    )
    updated_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        description="Last update timestamp"
    )


class BaseModel(Document, TimestampMixin):
    """Base model with common fields."""
    
    model_config = ConfigDict(
        arbitrary_types_allowed=True,
    )
    
    class Settings:
        """Beanie document settings."""
        use_cache = True
        cache_expiration_time = 3600
        validate_on_save = True
