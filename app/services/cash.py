"""Cash management service."""
from datetime import datetime, timezone, date, timedelta
from typing import Optional
from decimal import Decimal
from beanie import PydanticObjectId

from app.core.exceptions import NotFoundError, BusinessLogicError
from app.core.validators import validate_positive_amount
from app.models.cash import CashTransaction, CashBalance, CashTransactionType
from app.core.logging import get_logger

logger = get_logger(__name__)


class CashService:
    """Cash management service."""

    @staticmethod
    async def create_transaction(
        business_id: str,
        transaction_type: str,
        amount: Decimal,
        date: datetime,
        source: Optional[str] = None,
        remarks: Optional[str] = None,
        reference_id: Optional[str] = None,
        reference_type: Optional[str] = None,
        user_id: Optional[str] = None,
    ) -> CashTransaction:
        """Create a cash transaction."""
        validate_positive_amount(amount, "transaction amount")
        
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        user_obj_id = None
        if user_id:
            try:
                user_obj_id = PydanticObjectId(user_id)
            except (ValueError, TypeError):
                pass

        ref_obj_id = None
        if reference_id:
            try:
                ref_obj_id = PydanticObjectId(reference_id)
            except (ValueError, TypeError):
                pass

        transaction = CashTransaction(
            business_id=business_obj_id,
            transaction_type=CashTransactionType(transaction_type),
            amount=amount,
            date=date,
            source=source,
            remarks=remarks,
            reference_id=ref_obj_id,
            reference_type=reference_type,
            created_by_user_id=user_obj_id,
        )
        await transaction.insert()

        # Update daily balance
        await CashService._update_daily_balance(business_id, date.date())

        logger.info(
            "cash_transaction_created",
            business_id=business_id,
            transaction_id=str(transaction.id),
            transaction_type=transaction_type,
            amount=str(amount),
        )

        return transaction

    @staticmethod
    async def _update_daily_balance(business_id: str, balance_date: date) -> None:
        """Update or create daily cash balance."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        start_of_day = datetime.combine(balance_date, datetime.min.time()).replace(tzinfo=timezone.utc)
        end_of_day = datetime.combine(balance_date, datetime.max.time()).replace(tzinfo=timezone.utc)

        # Get opening balance (previous day's closing balance)
        prev_day_start = start_of_day - timedelta(days=1)
        prev_balance = await CashBalance.find_one(
            CashBalance.business_id == business_obj_id,
            CashBalance.date == prev_day_start,
        )
        opening_balance = prev_balance.closing_balance if prev_balance else Decimal("0.00")

        # Calculate totals for the day
        cash_in_transactions = await CashTransaction.find(
            CashTransaction.business_id == business_obj_id,
            CashTransaction.transaction_type == CashTransactionType.CASH_IN,
            CashTransaction.date >= start_of_day,
            CashTransaction.date <= end_of_day,
        ).to_list()
        total_cash_in = sum(t.amount for t in cash_in_transactions) or Decimal("0.00")

        cash_out_transactions = await CashTransaction.find(
            CashTransaction.business_id == business_obj_id,
            CashTransaction.transaction_type == CashTransactionType.CASH_OUT,
            CashTransaction.date >= start_of_day,
            CashTransaction.date <= end_of_day,
        ).to_list()
        total_cash_out = sum(t.amount for t in cash_out_transactions) or Decimal("0.00")

        closing_balance = opening_balance + total_cash_in - total_cash_out

        # Update or create balance
        balance = await CashBalance.find_one(
            CashBalance.business_id == business_obj_id,
            CashBalance.date == start_of_day,
        )

        if balance:
            balance.opening_balance = opening_balance
            balance.total_cash_in = total_cash_in
            balance.total_cash_out = total_cash_out
            balance.closing_balance = closing_balance
            await balance.save()
        else:
            balance = CashBalance(
                business_id=business_obj_id,
                date=start_of_day,
                opening_balance=opening_balance,
                total_cash_in=total_cash_in,
                total_cash_out=total_cash_out,
                closing_balance=closing_balance,
            )
            await balance.insert()

    @staticmethod
    async def get_daily_balance(business_id: str, balance_date: date) -> Optional[CashBalance]:
        """Get daily cash balance. Returns calculated balance if record doesn't exist."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        start_of_day = datetime.combine(balance_date, datetime.min.time()).replace(tzinfo=timezone.utc)
        end_of_day = datetime.combine(balance_date, datetime.max.time()).replace(tzinfo=timezone.utc)
        
        balance = await CashBalance.find_one(
            CashBalance.business_id == business_obj_id,
            CashBalance.date == start_of_day,
        )
        
        # If balance exists, return it
        if balance:
            return balance
        
        # If balance doesn't exist, calculate it from previous day and transactions
        # Get previous day's closing balance
        prev_day_date = balance_date - timedelta(days=1)
        prev_day_start = datetime.combine(prev_day_date, datetime.min.time()).replace(tzinfo=timezone.utc)
        prev_balance = await CashBalance.find_one(
            CashBalance.business_id == business_obj_id,
            CashBalance.date == prev_day_start,
        )
        opening_balance = prev_balance.closing_balance if prev_balance else Decimal("0.00")
        
        # Get transactions for this date
        transactions = await CashTransaction.find(
            CashTransaction.business_id == business_obj_id,
            CashTransaction.date >= start_of_day,
            CashTransaction.date <= end_of_day,
        ).to_list()
        
        # Calculate totals
        total_cash_in = sum(t.amount for t in transactions if t.transaction_type == CashTransactionType.CASH_IN)
        total_cash_out = sum(t.amount for t in transactions if t.transaction_type == CashTransactionType.CASH_OUT)
        closing_balance = opening_balance + total_cash_in - total_cash_out
        
        # Return calculated balance (not saved to DB)
        return CashBalance(
            business_id=business_obj_id,
            date=start_of_day,
            opening_balance=opening_balance,
            total_cash_in=total_cash_in,
            total_cash_out=total_cash_out,
            closing_balance=closing_balance,
        )

    @staticmethod
    async def get_summary(
        business_id: str,
        start_date: datetime,
        end_date: datetime,
    ) -> dict:
        """Get cash summary for date range."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        # Get opening balance (from previous day's closing balance)
        prev_day_start = datetime.combine((start_date - timedelta(days=1)).date(), datetime.min.time()).replace(tzinfo=timezone.utc)
        prev_balance = await CashBalance.find_one(
            CashBalance.business_id == business_obj_id,
            CashBalance.date == prev_day_start,
        )
        opening_balance = prev_balance.closing_balance if prev_balance else Decimal("0.00")

        # Get transactions in range
        transactions = await CashTransaction.find(
            CashTransaction.business_id == business_obj_id,
            CashTransaction.date >= start_date,
            CashTransaction.date <= end_date,
        ).sort("+date").to_list()

        # Calculate totals
        total_cash_in = sum(t.amount for t in transactions if t.transaction_type == CashTransactionType.CASH_IN)
        total_cash_out = sum(t.amount for t in transactions if t.transaction_type == CashTransactionType.CASH_OUT)
        closing_balance = opening_balance + total_cash_in - total_cash_out

        return {
            "start_date": start_date,
            "end_date": end_date,
            "opening_balance": opening_balance,
            "total_cash_in": total_cash_in,
            "total_cash_out": total_cash_out,
            "closing_balance": closing_balance,
            "transactions": transactions,
        }

    @staticmethod
    async def list_transactions(
        business_id: str,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        transaction_type: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[CashTransaction]:
        """List cash transactions."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        query = CashTransaction.find(CashTransaction.business_id == business_obj_id)

        if start_date:
            query = query.find(CashTransaction.date >= start_date)
        if end_date:
            query = query.find(CashTransaction.date <= end_date)
        if transaction_type:
            query = query.find(CashTransaction.transaction_type == CashTransactionType(transaction_type))

        transactions = await query.sort("-date").skip(offset).limit(limit).to_list()
        return transactions


# Singleton instance
cash_service = CashService()
