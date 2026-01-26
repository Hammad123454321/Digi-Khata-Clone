"""Business schemas."""
from typing import Optional
from pydantic import BaseModel, Field


class BusinessCreate(BaseModel):
    """Business creation schema."""

    name: str = Field(..., min_length=1, max_length=255)
    phone: str = Field(..., min_length=10, max_length=20)
    email: Optional[str] = Field(None, max_length=255)
    address: Optional[str] = None
    language_preference: str = Field(default="en", pattern="^(en|ur)$")
    max_devices: int = Field(default=3, ge=1, le=10)


class BusinessUpdate(BaseModel):
    """Business update schema."""

    name: Optional[str] = Field(None, min_length=1, max_length=255)
    email: Optional[str] = Field(None, max_length=255)
    address: Optional[str] = None
    language_preference: Optional[str] = Field(None, pattern="^(en|ur)$")
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

    class Config:
        from_attributes = True

