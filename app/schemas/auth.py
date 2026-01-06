"""Authentication schemas."""
from typing import Optional
from pydantic import BaseModel, Field, field_validator


class OTPRequest(BaseModel):
    """OTP request schema."""

    phone: str = Field(..., min_length=10, max_length=20, description="Phone number")

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        """Normalize phone number."""
        return v.strip().replace(" ", "").replace("-", "")


class OTPVerify(BaseModel):
    """OTP verification schema."""

    phone: str = Field(..., min_length=10, max_length=20)
    otp: str = Field(..., min_length=4, max_length=10)
    device_id: Optional[str] = Field(None, description="Unique device identifier")
    device_name: Optional[str] = Field(None, description="Device name")

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        """Normalize phone number."""
        return v.strip().replace(" ", "").replace("-", "")


class TokenRefresh(BaseModel):
    """Token refresh schema."""

    refresh_token: str = Field(..., description="Refresh token")


class PINSet(BaseModel):
    """PIN set schema."""

    pin: str = Field(..., min_length=4, max_length=10, description="PIN code")


class PINVerify(BaseModel):
    """PIN verify schema."""

    pin: str = Field(..., min_length=4, max_length=10, description="PIN code")


class TokenResponse(BaseModel):
    """Token response schema."""

    access_token: str
    refresh_token: Optional[str] = None
    token_type: str = "bearer"
    user: dict
    businesses: Optional[list] = None
    device: Optional[dict] = None

