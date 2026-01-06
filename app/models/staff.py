"""Staff models."""
from sqlalchemy import Column, String, Numeric, Integer, ForeignKey, Text, DateTime, Boolean, Index
from sqlalchemy.orm import relationship
from decimal import Decimal

from app.models.base import BaseModel


class Staff(BaseModel):
    """Staff model."""

    __tablename__ = "staff"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(255), nullable=False, index=True)
    phone = Column(String(20), nullable=True, index=True)
    email = Column(String(255), nullable=True)
    role = Column(String(100), nullable=True)
    address = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)

    # Relationships
    business = relationship("Business", back_populates="staff")
    salaries = relationship("StaffSalary", back_populates="staff", cascade="all, delete-orphan")

    __table_args__ = (
        Index("ix_staff_business_name", "business_id", "name"),
        Index("ix_staff_business_active", "business_id", "is_active"),
    )


class StaffSalary(BaseModel):
    """Staff salary record model."""

    __tablename__ = "staff_salaries"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    staff_id = Column(Integer, ForeignKey("staff.id", ondelete="CASCADE"), nullable=False, index=True)
    amount = Column(Numeric(15, 2), nullable=False)
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    payment_mode = Column(String(50), nullable=False, index=True)  # cash, bank
    remarks = Column(Text, nullable=True)
    reference_id = Column(Integer, nullable=True)  # Reference to bank transaction, etc.
    reference_type = Column(String(50), nullable=True)
    created_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # Relationships
    staff = relationship("Staff", back_populates="salaries")

    __table_args__ = (
        Index("ix_staff_salaries_business_staff_date", "business_id", "staff_id", "date"),
        Index("ix_staff_salaries_business_date", "business_id", "date"),
    )

