"""Base model classes for Beanie."""
from datetime import datetime, timezone
from decimal import Decimal
from beanie import Document
from pydantic import Field, ConfigDict, model_validator
from typing import Optional, Any


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
    
    @model_validator(mode='before')
    @classmethod
    def convert_decimal128(cls, data: Any) -> Any:
        """Convert MongoDB Decimal128 to Python Decimal."""
        try:
            from bson.decimal128 import Decimal128
        except ImportError:
            # If bson is not available, return data as-is
            return data
        
        if isinstance(data, dict):
            converted = {}
            for key, value in data.items():
                if isinstance(value, Decimal128):
                    converted[key] = Decimal(str(value))
                elif isinstance(value, dict):
                    converted[key] = cls.convert_decimal128(value)
                elif isinstance(value, list):
                    converted[key] = [
                        cls.convert_decimal128(item) if isinstance(item, (dict, Decimal128)) else (
                            Decimal(str(item)) if isinstance(item, Decimal128) else item
                        )
                        for item in value
                    ]
                else:
                    converted[key] = value
            return converted
        elif isinstance(data, Decimal128):
            return Decimal(str(data))
        return data
    
    class Settings:
        """Beanie document settings."""
        use_cache = True
        cache_expiration_time = 3600
        validate_on_save = True
