"""Expense service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.core.exceptions import NotFoundError
from app.models.expense import ExpenseCategory, Expense, PaymentMode
from app.models.cash import CashTransaction, CashTransactionType
from app.core.logging import get_logger

logger = get_logger(__name__)


class ExpenseService:
    """Expense management service."""

    @staticmethod
    async def create_category(
        business_id: int,
        name: str,
        description: Optional[str] = None,
        db: AsyncSession = None,
    ) -> ExpenseCategory:
        """Create an expense category."""
        category = ExpenseCategory(
            business_id=business_id,
            name=name,
            description=description,
            is_active=True,
        )
        db.add(category)
        await db.flush()

        logger.info("expense_category_created", business_id=business_id, category_id=category.id, name=name)
        return category

    @staticmethod
    async def create_expense(
        business_id: int,
        amount: Decimal,
        date: datetime,
        payment_mode: str,
        category_id: Optional[int] = None,
        description: Optional[str] = None,
        user_id: Optional[int] = None,
        db: AsyncSession = None,
    ) -> Expense:
        """Create an expense."""
        if category_id:
            result = await db.execute(
                select(ExpenseCategory).where(
                    ExpenseCategory.id == category_id,
                    ExpenseCategory.business_id == business_id,
                )
            )
            if not result.scalar_one_or_none():
                raise NotFoundError("Expense category not found")

        expense = Expense(
            business_id=business_id,
            category_id=category_id,
            amount=amount,
            date=date,
            payment_mode=PaymentMode(payment_mode),
            description=description,
            created_by_user_id=user_id,
        )
        db.add(expense)
        await db.flush()

        # Create cash transaction if payment mode is cash
        if payment_mode == "cash":
            from app.services.cash import cash_service
            await cash_service.create_transaction(
                business_id=business_id,
                transaction_type="cash_out",
                amount=amount,
                date=date,
                source="expense",
                remarks=description or f"Expense: {category_id}",
                reference_id=expense.id,
                reference_type="expense",
                user_id=user_id,
                db=db,
            )

        logger.info("expense_created", business_id=business_id, expense_id=expense.id, amount=str(amount))
        return expense

    @staticmethod
    async def list_expenses(
        business_id: int,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        category_id: Optional[int] = None,
        payment_mode: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
        db: AsyncSession = None,
    ) -> list[Expense]:
        """List expenses."""
        query = select(Expense).where(Expense.business_id == business_id)

        if start_date:
            query = query.where(Expense.date >= start_date)
        if end_date:
            query = query.where(Expense.date <= end_date)
        if category_id:
            query = query.where(Expense.category_id == category_id)
        if payment_mode:
            query = query.where(Expense.payment_mode == PaymentMode(payment_mode))

        query = query.order_by(Expense.date.desc()).limit(limit).offset(offset)

        result = await db.execute(query)
        return list(result.scalars().all())

    @staticmethod
    async def get_summary(
        business_id: int,
        start_date: datetime,
        end_date: datetime,
        db: AsyncSession,
    ) -> dict:
        """Get expense summary for date range."""
        result = await db.execute(
            select(func.sum(Expense.amount)).where(
                Expense.business_id == business_id,
                Expense.date >= start_date,
                Expense.date <= end_date,
            )
        )
        total_expenses = result.scalar_one() or Decimal("0.00")

        # Group by category
        result = await db.execute(
            select(ExpenseCategory.name, func.sum(Expense.amount))
            .join(Expense, Expense.category_id == ExpenseCategory.id)
            .where(
                Expense.business_id == business_id,
                Expense.date >= start_date,
                Expense.date <= end_date,
            )
            .group_by(ExpenseCategory.name)
        )
        by_category = {row[0]: row[1] for row in result.all()}

        return {
            "start_date": start_date,
            "end_date": end_date,
            "total_expenses": total_expenses,
            "by_category": by_category,
        }


# Singleton instance
expense_service = ExpenseService()

