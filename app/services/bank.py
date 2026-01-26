"""Bank service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from beanie import PydanticObjectId

from app.core.exceptions import NotFoundError, BusinessLogicError
from app.core.validators import validate_positive_amount
from app.models.bank import BankAccount, BankTransaction, BankTransactionType, CashBankTransfer
from app.models.cash import CashTransaction, CashTransactionType
from app.core.logging import get_logger

logger = get_logger(__name__)


class BankService:
    """Bank management service."""

    @staticmethod
    async def create_account(
        business_id: str,
        bank_name: str,
        account_number: Optional[str] = None,
        account_holder_name: Optional[str] = None,
        branch: Optional[str] = None,
        ifsc_code: Optional[str] = None,
        opening_balance: Decimal = Decimal("0.00"),
    ) -> BankAccount:
        """Create a bank account."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        account = BankAccount(
            business_id=business_obj_id,
            bank_name=bank_name,
            branch=branch,
            ifsc_code=ifsc_code,
            opening_balance=opening_balance,
            current_balance=opening_balance,
            is_active=True,
        )
        if account_number:
            account.set_account_number(account_number)
        if account_holder_name:
            account.set_account_holder_name(account_holder_name)
        await account.insert()

        logger.info("bank_account_created", business_id=business_id, account_id=str(account.id), bank_name=bank_name)
        return account

    @staticmethod
    async def create_transaction(
        business_id: str,
        bank_account_id: str,
        transaction_type: str,
        amount: Decimal,
        date: datetime,
        reference_number: Optional[str] = None,
        remarks: Optional[str] = None,
        user_id: Optional[str] = None,
    ) -> BankTransaction:
        """Create a bank transaction."""
        validate_positive_amount(amount, "transaction amount")
        
        try:
            business_obj_id = PydanticObjectId(business_id)
            account_obj_id = PydanticObjectId(bank_account_id)
        except (ValueError, TypeError):
            raise ValueError("Invalid business or bank account ID format")

        account = await BankAccount.find_one(
            BankAccount.id == account_obj_id,
            BankAccount.business_id == business_obj_id,
        )

        if not account:
            raise NotFoundError("Bank account not found")

        user_obj_id = None
        if user_id:
            try:
                user_obj_id = PydanticObjectId(user_id)
            except (ValueError, TypeError):
                pass

        transaction = BankTransaction(
            business_id=business_obj_id,
            bank_account_id=account_obj_id,
            transaction_type=BankTransactionType(transaction_type),
            amount=amount,
            date=date,
            reference_number=reference_number,
            remarks=remarks,
            created_by_user_id=user_obj_id,
        )
        await transaction.insert()

        # Update account balance
        if transaction_type == "deposit":
            account.current_balance += amount
        elif transaction_type == "withdrawal":
            if account.current_balance < amount:
                raise BusinessLogicError("Insufficient balance")
            account.current_balance -= amount

        await account.save()

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
        business_id: str,
        transfer_type: str,
        amount: Decimal,
        date: datetime,
        bank_account_id: Optional[str] = None,
        remarks: Optional[str] = None,
        user_id: Optional[str] = None,
    ) -> CashBankTransfer:
        """Create cash-bank transfer."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        if transfer_type == "cash_to_bank":
            if not bank_account_id:
                raise BusinessLogicError("Bank account required for cash to bank transfer")

            try:
                account_obj_id = PydanticObjectId(bank_account_id)
            except (ValueError, TypeError):
                raise NotFoundError("Invalid bank account ID format")

            account = await BankAccount.find_one(
                BankAccount.id == account_obj_id,
                BankAccount.business_id == business_obj_id,
            )
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
            )

        elif transfer_type == "bank_to_cash":
            if not bank_account_id:
                raise BusinessLogicError("Bank account required for bank to cash transfer")

            try:
                account_obj_id = PydanticObjectId(bank_account_id)
            except (ValueError, TypeError):
                raise NotFoundError("Invalid bank account ID format")

            account = await BankAccount.find_one(
                BankAccount.id == account_obj_id,
                BankAccount.business_id == business_obj_id,
            )
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
            )

        # Create transfer record
        user_obj_id = None
        if user_id:
            try:
                user_obj_id = PydanticObjectId(user_id)
            except (ValueError, TypeError):
                pass

        from_account_id = None
        to_account_id = None
        if bank_account_id:
            try:
                account_obj_id = PydanticObjectId(bank_account_id)
                if transfer_type == "bank_to_cash":
                    from_account_id = account_obj_id
                else:
                    to_account_id = account_obj_id
            except (ValueError, TypeError):
                pass

        transfer = CashBankTransfer(
            business_id=business_obj_id,
            transfer_type=transfer_type,
            amount=amount,
            date=date,
            from_bank_account_id=from_account_id,
            to_bank_account_id=to_account_id,
            remarks=remarks,
            created_by_user_id=user_obj_id,
        )
        await transfer.insert()

        logger.info("transfer_created", business_id=business_id, transfer_type=transfer_type, amount=str(amount))
        return transfer


# Singleton instance
bank_service = BankService()
