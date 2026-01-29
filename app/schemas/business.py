"""Business schemas."""
from typing import Optional
from pydantic import BaseModel, Field, model_validator

from app.models.business import BusinessTypeEnum


class BusinessCreate(BaseModel):
    """Business creation schema."""

    name: str = Field(..., min_length=1, max_length=255)
    phone: str = Field(..., min_length=10, max_length=20)
    email: Optional[str] = Field(None, max_length=255)
    address: Optional[str] = None
    language_preference: str = Field(default="en", pattern="^(en|ur|ar)$")
    max_devices: int = Field(default=3, ge=1, le=10)
    business_type: BusinessTypeEnum = Field(default=BusinessTypeEnum.OTHER)
    custom_business_type: Optional[str] = None  # Required if business_type is OTHER

    @model_validator(mode="after")
    def validate_custom_business_type(self):
        if self.business_type == BusinessTypeEnum.OTHER:
            if not self.custom_business_type or not self.custom_business_type.strip():
                raise ValueError("custom_business_type is required when business_type is 'other'")
        return self


class BusinessUpdate(BaseModel):
    """Business update schema."""

    name: Optional[str] = Field(None, min_length=1, max_length=255)
    email: Optional[str] = Field(None, max_length=255)
    address: Optional[str] = None
    language_preference: Optional[str] = Field(None, pattern="^(en|ur|ar)$")
    max_devices: Optional[int] = Field(None, ge=1, le=10)


class BusinessResponse(BaseModel):
    """Business response schema."""

    id: str
    name: str
    phone: str
    email: Optional[str]
    address: Optional[str]
    is_active: bool
    language_preference: str
    max_devices: int
    business_type: BusinessTypeEnum
    custom_business_type: Optional[str] = None

    class Config:
        from_attributes = True

