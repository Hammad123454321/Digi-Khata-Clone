"""Staff schemas."""
from datetime import datetime
from typing import Optional
from decimal import Decimal
from pydantic import BaseModel, Field


class StaffCreate(BaseModel):
    """Staff creation schema."""

    name: str = Field(..., min_length=1, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)
    email: Optional[str] = Field(None, max_length=255)
    role: Optional[str] = Field(None, max_length=100)
    address: Optional[str] = None


class StaffResponse(BaseModel):
    """Staff response schema."""

    id: int
    name: str
    phone: Optional[str]
    email: Optional[str]
    role: Optional[str]
    address: Optional[str]
    is_active: bool

    class Config:
        from_attributes = True


class StaffSalaryCreate(BaseModel):
    """Staff salary creation schema."""

    staff_id: int
    amount: Decimal = Field(..., gt=0)
    date: datetime
    payment_mode: str = Field(..., pattern="^(cash|bank)$")
    remarks: Optional[str] = None

