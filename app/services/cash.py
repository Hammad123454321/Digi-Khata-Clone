"""Cash management service."""
from datetime import datetime, timezone, date, timedelta
from typing import Optional
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_

from app.core.exceptions import NotFoundError, BusinessLogicError
from app.models.cash import CashTransaction, CashBalance, CashTransactionType
from app.core.logging import get_logger

logger = get_logger(__name__)


class CashService:
    """Cash management service."""

    @staticmethod
    async def create_transaction(
        business_id: int,
        transaction_type: str,
        amount: Decimal,
        date: datetime,
        source: Optional[str] = None,
        remarks: Optional[str] = None,
        reference_id: Optional[int] = None,
        reference_type: Optional[str] = None,
        user_id: Optional[int] = None,
        db: AsyncSession = None,
    ) -> CashTransaction:
        """Create a cash transaction."""
        transaction = CashTransaction(
            business_id=business_id,
            transaction_type=CashTransactionType(transaction_type),
            amount=amount,
            date=date,
            source=source,
            remarks=remarks,
            reference_id=reference_id,
            reference_type=reference_type,
            created_by_user_id=user_id,
        )
        db.add(transaction)
        await db.flush()

        # Update daily balance
        await CashService._update_daily_balance(business_id, date.date(), db)

        logger.info(
            "cash_transaction_created",
            business_id=business_id,
            transaction_id=transaction.id,
            transaction_type=transaction_type,
            amount=str(amount),
        )

        return transaction

    @staticmethod
    async def _update_daily_balance(business_id: int, balance_date: date, db: AsyncSession) -> None:
        """Update or create daily cash balance."""
        start_of_day = datetime.combine(balance_date, datetime.min.time()).replace(tzinfo=timezone.utc)
        end_of_day = datetime.combine(balance_date, datetime.max.time()).replace(tzinfo=timezone.utc)

        # Get opening balance (previous day's closing balance)
        prev_day_start = start_of_day - timedelta(days=1)
        prev_balance_result = await db.execute(
            select(CashBalance).where(
                CashBalance.business_id == business_id,
                CashBalance.date == prev_day_start,
            )
        )
        prev_balance = prev_balance_result.scalar_one_or_none()
        opening_balance = prev_balance.closing_balance if prev_balance else Decimal("0.00")

        # Calculate totals for the day
        cash_in_result = await db.execute(
            select(func.sum(CashTransaction.amount)).where(
                CashTransaction.business_id == business_id,
                CashTransaction.transaction_type == CashTransactionType.CASH_IN,
                CashTransaction.date >= start_of_day,
                CashTransaction.date <= end_of_day,
            )
        )
        total_cash_in = cash_in_result.scalar_one() or Decimal("0.00")

        cash_out_result = await db.execute(
            select(func.sum(CashTransaction.amount)).where(
                CashTransaction.business_id == business_id,
                CashTransaction.transaction_type == CashTransactionType.CASH_OUT,
                CashTransaction.date >= start_of_day,
                CashTransaction.date <= end_of_day,
            )
        )
        total_cash_out = cash_out_result.scalar_one() or Decimal("0.00")

        closing_balance = opening_balance + total_cash_in - total_cash_out

        # Update or create balance - use start_of_day datetime for comparison and storage
        balance_result = await db.execute(
            select(CashBalance).where(
                CashBalance.business_id == business_id,
                CashBalance.date == start_of_day,
            )
        )
        balance = balance_result.scalar_one_or_none()

        if balance:
            balance.opening_balance = opening_balance
            balance.total_cash_in = total_cash_in
            balance.total_cash_out = total_cash_out
            balance.closing_balance = closing_balance
        else:
            balance = CashBalance(
                business_id=business_id,
                date=start_of_day,
                opening_balance=opening_balance,
                total_cash_in=total_cash_in,
                total_cash_out=total_cash_out,
                closing_balance=closing_balance,
            )
            db.add(balance)

        await db.flush()

    @staticmethod
    async def get_daily_balance(business_id: int, balance_date: date, db: AsyncSession) -> Optional[CashBalance]:
        """Get daily cash balance."""
        start_of_day = datetime.combine(balance_date, datetime.min.time()).replace(tzinfo=timezone.utc)
        result = await db.execute(
            select(CashBalance).where(
                CashBalance.business_id == business_id,
                CashBalance.date == start_of_day,
            )
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def get_summary(
        business_id: int,
        start_date: datetime,
        end_date: datetime,
        db: AsyncSession,
    ) -> dict:
        """Get cash summary for date range."""
        # Get opening balance (from previous day's closing balance)
        prev_day_start = datetime.combine((start_date - timedelta(days=1)).date(), datetime.min.time()).replace(tzinfo=timezone.utc)
        prev_balance_result = await db.execute(
            select(CashBalance).where(
                CashBalance.business_id == business_id,
                CashBalance.date == prev_day_start,
            )
        )
        prev_balance = prev_balance_result.scalar_one_or_none()
        opening_balance = prev_balance.closing_balance if prev_balance else Decimal("0.00")

        # Get transactions in range
        transactions_result = await db.execute(
            select(CashTransaction).where(
                CashTransaction.business_id == business_id,
                CashTransaction.date >= start_date,
                CashTransaction.date <= end_date,
            ).order_by(CashTransaction.date)
        )
        transactions = transactions_result.scalars().all()

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
            "transactions": list(transactions),
        }

    @staticmethod
    async def list_transactions(
        business_id: int,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        transaction_type: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
        db: AsyncSession = None,
    ) -> list[CashTransaction]:
        """List cash transactions."""
        query = select(CashTransaction).where(CashTransaction.business_id == business_id)

        if start_date:
            query = query.where(CashTransaction.date >= start_date)
        if end_date:
            query = query.where(CashTransaction.date <= end_date)
        if transaction_type:
            query = query.where(CashTransaction.transaction_type == CashTransactionType(transaction_type))

        query = query.order_by(CashTransaction.date.desc()).limit(limit).offset(offset)

        result = await db.execute(query)
        return list(result.scalars().all())


# Singleton instance
cash_service = CashService()

