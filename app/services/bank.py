"""Bank service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.exceptions import NotFoundError, BusinessLogicError
from app.models.bank import BankAccount, BankTransaction, BankTransactionType, CashBankTransfer
from app.models.cash import CashTransaction, CashTransactionType
from app.core.logging import get_logger

logger = get_logger(__name__)


class BankService:
    """Bank management service."""

    @staticmethod
    async def create_account(
        business_id: int,
        bank_name: str,
        account_number: Optional[str] = None,
        account_holder_name: Optional[str] = None,
        branch: Optional[str] = None,
        ifsc_code: Optional[str] = None,
        opening_balance: Decimal = Decimal("0.00"),
        db: AsyncSession = None,
    ) -> BankAccount:
        """Create a bank account."""
        account = BankAccount(
            business_id=business_id,
            bank_name=bank_name,
            account_number=account_number,
            account_holder_name=account_holder_name,
            branch=branch,
            ifsc_code=ifsc_code,
            opening_balance=opening_balance,
            current_balance=opening_balance,
            is_active=True,
        )
        db.add(account)
        await db.flush()

        logger.info("bank_account_created", business_id=business_id, account_id=account.id, bank_name=bank_name)
        return account

    @staticmethod
    async def create_transaction(
        business_id: int,
        bank_account_id: int,
        transaction_type: str,
        amount: Decimal,
        date: datetime,
        reference_number: Optional[str] = None,
        remarks: Optional[str] = None,
        user_id: Optional[int] = None,
        db: AsyncSession = None,
    ) -> BankTransaction:
        """Create a bank transaction."""
        result = await db.execute(
            select(BankAccount).where(
                BankAccount.id == bank_account_id,
                BankAccount.business_id == business_id,
            )
        )
        account = result.scalar_one_or_none()

        if not account:
            raise NotFoundError("Bank account not found")

        transaction = BankTransaction(
            business_id=business_id,
            bank_account_id=bank_account_id,
            transaction_type=BankTransactionType(transaction_type),
            amount=amount,
            date=date,
            reference_number=reference_number,
            remarks=remarks,
            created_by_user_id=user_id,
        )
        db.add(transaction)
        await db.flush()

        # Update account balance
        if transaction_type == "deposit":
            account.current_balance += amount
        elif transaction_type == "withdrawal":
            if account.current_balance < amount:
                raise BusinessLogicError("Insufficient balance")
            account.current_balance -= amount

        await db.flush()

        logger.info(
            "bank_transaction_created",
            business_id=business_id,
            account_id=bank_account_id,
            transaction_type=transaction_type,
            amount=str(amount),
        )

        return transaction

    @staticmethod
    async def create_transfer(
        business_id: int,
        transfer_type: str,
        amount: Decimal,
        date: datetime,
        bank_account_id: Optional[int] = None,
        remarks: Optional[str] = None,
        user_id: Optional[int] = None,
        db: AsyncSession = None,
    ) -> CashBankTransfer:
        """Create cash-bank transfer."""
        if transfer_type == "cash_to_bank":
            if not bank_account_id:
                raise BusinessLogicError("Bank account required for cash to bank transfer")

            result = await db.execute(
                select(BankAccount).where(
                    BankAccount.id == bank_account_id,
                    BankAccount.business_id == business_id,
                )
            )
            account = result.scalar_one_or_none()
            if not account:
                raise NotFoundError("Bank account not found")

            # Create bank deposit
            await BankService.create_transaction(
                business_id=business_id,
                bank_account_id=bank_account_id,
                transaction_type="deposit",
                amount=amount,
                date=date,
                remarks=remarks or "Cash to bank transfer",
                user_id=user_id,
                db=db,
            )

            # Create cash out
            from app.services.cash import cash_service
            await cash_service.create_transaction(
                business_id=business_id,
                transaction_type="cash_out",
                amount=amount,
                date=date,
                source="bank_transfer",
                remarks=remarks or f"Transfer to {account.bank_name}",
                reference_id=bank_account_id,
                reference_type="bank_transfer",
                user_id=user_id,
                db=db,
            )

        elif transfer_type == "bank_to_cash":
            if not bank_account_id:
                raise BusinessLogicError("Bank account required for bank to cash transfer")

            result = await db.execute(
                select(BankAccount).where(
                    BankAccount.id == bank_account_id,
                    BankAccount.business_id == business_id,
                )
            )
            account = result.scalar_one_or_none()
            if not account:
                raise NotFoundError("Bank account not found")

            # Create bank withdrawal
            await BankService.create_transaction(
                business_id=business_id,
                bank_account_id=bank_account_id,
                transaction_type="withdrawal",
                amount=amount,
                date=date,
                remarks=remarks or "Bank to cash transfer",
                user_id=user_id,
                db=db,
            )

            # Create cash in
            from app.services.cash import cash_service
            await cash_service.create_transaction(
                business_id=business_id,
                transaction_type="cash_in",
                amount=amount,
                date=date,
                source="bank_transfer",
                remarks=remarks or f"Transfer from {account.bank_name}",
                reference_id=bank_account_id,
                reference_type="bank_transfer",
                user_id=user_id,
                db=db,
            )

        # Create transfer record
        transfer = CashBankTransfer(
            business_id=business_id,
            transfer_type=transfer_type,
            amount=amount,
            date=date,
            from_bank_account_id=bank_account_id if transfer_type == "bank_to_cash" else None,
            to_bank_account_id=bank_account_id if transfer_type == "cash_to_bank" else None,
            remarks=remarks,
            created_by_user_id=user_id,
        )
        db.add(transfer)
        await db.flush()

        logger.info("transfer_created", business_id=business_id, transfer_type=transfer_type, amount=str(amount))
        return transfer


# Singleton instance
bank_service = BankService()

