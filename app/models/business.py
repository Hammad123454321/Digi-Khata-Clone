"""Business model."""
from sqlalchemy import Column, String, Boolean, Text, Integer
from sqlalchemy.orm import relationship

from app.models.base import BaseModel


class Business(BaseModel):
    """Business/tenant model."""

    __tablename__ = "businesses"

    name = Column(String(255), nullable=False, index=True)
    phone = Column(String(20), unique=True, nullable=False, index=True)
    email = Column(String(255), nullable=True)
    address = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    language_preference = Column(String(10), default="en", nullable=False)  # en, ur
    max_devices = Column(Integer, default=3, nullable=False)

    # Relationships
    users = relationship("UserMembership", back_populates="business", cascade="all, delete-orphan")
    devices = relationship("Device", back_populates="business", cascade="all, delete-orphan")
    items = relationship("Item", back_populates="business", cascade="all, delete-orphan")
    customers = relationship("Customer", back_populates="business", cascade="all, delete-orphan")
    suppliers = relationship("Supplier", back_populates="business", cascade="all, delete-orphan")
    invoices = relationship("Invoice", back_populates="business", cascade="all, delete-orphan")
    expenses = relationship("Expense", back_populates="business", cascade="all, delete-orphan")
    staff = relationship("Staff", back_populates="business", cascade="all, delete-orphan")
    bank_accounts = relationship("BankAccount", back_populates="business", cascade="all, delete-orphan")
    cash_transactions = relationship("CashTransaction", back_populates="business", cascade="all, delete-orphan")
    backups = relationship("Backup", back_populates="business", cascade="all, delete-orphan")

