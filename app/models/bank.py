"""Bank account and transaction models."""
from sqlalchemy import Column, String, Numeric, Integer, ForeignKey, Text, DateTime, Boolean, Enum as SQLEnum, Index
from sqlalchemy.orm import relationship
import enum
from decimal import Decimal

from app.models.base import BaseModel


class BankAccount(BaseModel):
    """Bank account model."""

    __tablename__ = "bank_accounts"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    bank_name = Column(String(255), nullable=False)
    account_number = Column(String(100), nullable=True)
    account_holder_name = Column(String(255), nullable=True)
    branch = Column(String(255), nullable=True)
    ifsc_code = Column(String(50), nullable=True)
    opening_balance = Column(Numeric(15, 2), default=Decimal("0.00"), nullable=False)
    current_balance = Column(Numeric(15, 2), default=Decimal("0.00"), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)

    # Relationships
    business = relationship("Business", back_populates="bank_accounts")
    transactions = relationship("BankTransaction", back_populates="bank_account", cascade="all, delete-orphan")
    cash_transfers_from = relationship("CashBankTransfer", foreign_keys="CashBankTransfer.from_bank_account_id", back_populates="from_bank_account")
    cash_transfers_to = relationship("CashBankTransfer", foreign_keys="CashBankTransfer.to_bank_account_id", back_populates="to_bank_account")

    __table_args__ = (Index("ix_bank_accounts_business_active", "business_id", "is_active"),)


class BankTransactionType(str, enum.Enum):
    """Bank transaction type."""

    DEPOSIT = "deposit"
    WITHDRAWAL = "withdrawal"
    TRANSFER = "transfer"


class BankTransaction(BaseModel):
    """Bank transaction model (ledger-style)."""

    __tablename__ = "bank_transactions"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    bank_account_id = Column(Integer, ForeignKey("bank_accounts.id", ondelete="CASCADE"), nullable=False, index=True)
    transaction_type = Column(SQLEnum(BankTransactionType), nullable=False, index=True)
    amount = Column(Numeric(15, 2), nullable=False)
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    reference_number = Column(String(100), nullable=True)
    remarks = Column(Text, nullable=True)
    reference_id = Column(Integer, nullable=True)  # Reference to expense, salary, etc.
    reference_type = Column(String(50), nullable=True)  # expense, salary, transfer, etc.
    created_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # Relationships
    bank_account = relationship("BankAccount", back_populates="transactions")

    __table_args__ = (
        Index("ix_bank_transactions_business_account_date", "business_id", "bank_account_id", "date"),
        Index("ix_bank_transactions_business_type_date", "business_id", "transaction_type", "date"),
    )


class CashBankTransfer(BaseModel):
    """Cash to Bank or Bank to Cash transfer model."""

    __tablename__ = "cash_bank_transfers"

    business_id = Column(Integer, ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False, index=True)
    transfer_type = Column(String(50), nullable=False, index=True)  # cash_to_bank, bank_to_cash
    amount = Column(Numeric(15, 2), nullable=False)
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    from_bank_account_id = Column(Integer, ForeignKey("bank_accounts.id", ondelete="SET NULL"), nullable=True)
    to_bank_account_id = Column(Integer, ForeignKey("bank_accounts.id", ondelete="SET NULL"), nullable=True)
    remarks = Column(Text, nullable=True)
    created_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # Relationships
    from_bank_account = relationship("BankAccount", foreign_keys=[from_bank_account_id], back_populates="cash_transfers_from")
    to_bank_account = relationship("BankAccount", foreign_keys=[to_bank_account_id], back_populates="cash_transfers_to")

    __table_args__ = (
        Index("ix_cash_bank_transfers_business_date", "business_id", "date"),
        Index("ix_cash_bank_transfers_business_type_date", "business_id", "transfer_type", "date"),
    )

