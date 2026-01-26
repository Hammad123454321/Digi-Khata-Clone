"""Expense service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from beanie import PydanticObjectId

from app.core.exceptions import NotFoundError, BusinessLogicError
from app.core.validators import validate_positive_amount
from app.models.expense import ExpenseCategory, Expense, PaymentMode
from app.models.cash import CashTransaction, CashTransactionType
from app.core.logging import get_logger

logger = get_logger(__name__)


class ExpenseService:
    """Expense management service."""

    @staticmethod
    async def create_category(
        business_id: str,
        name: str,
        description: Optional[str] = None,
    ) -> ExpenseCategory:
        """Create an expense category."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        category = ExpenseCategory(
            business_id=business_obj_id,
            name=name,
            description=description,
            is_active=True,
        )
        await category.insert()

        logger.info("expense_category_created", business_id=business_id, category_id=str(category.id), name=name)
        return category

    @staticmethod
    async def list_categories(
        business_id: str,
        is_active: Optional[bool] = None,
    ) -> list[ExpenseCategory]:
        """List expense categories."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        query = ExpenseCategory.find(ExpenseCategory.business_id == business_obj_id)

        if is_active is not None:
            query = query.find(ExpenseCategory.is_active == is_active)

        categories = await query.sort("+name").to_list()
        return categories

    @staticmethod
    async def create_expense(
        business_id: str,
        amount: Decimal,
        date: datetime,
        payment_mode: str,
        category_id: Optional[str] = None,
        description: Optional[str] = None,
        user_id: Optional[str] = None,
    ) -> Expense:
        """Create an expense."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        category_obj_id = None
        if category_id:
            try:
                category_obj_id = PydanticObjectId(category_id)
                category = await ExpenseCategory.find_one(
                    ExpenseCategory.id == category_obj_id,
                    ExpenseCategory.business_id == business_obj_id,
                )
                if not category:
                    raise NotFoundError("Expense category not found")
            except (ValueError, TypeError):
                raise NotFoundError("Invalid category ID format")

        # Validate amount
        validate_positive_amount(amount, "expense amount")
        
        user_obj_id = None
        if user_id:
            try:
                user_obj_id = PydanticObjectId(user_id)
            except (ValueError, TypeError):
                pass

        expense = Expense(
            business_id=business_obj_id,
            category_id=category_obj_id,
            amount=amount,
            date=date,
            payment_mode=PaymentMode(payment_mode),
            description=description,
            created_by_user_id=user_obj_id,
        )
        await expense.insert()

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
                reference_id=str(expense.id),
                reference_type="expense",
                user_id=user_id,
            )
        elif payment_mode == "bank":
            # Create bank transaction for bank expenses
            from app.models.bank import BankAccount
            from app.services.bank import bank_service
            
            # Get first active bank account for the business
            bank_account = await BankAccount.find_one(
                BankAccount.business_id == business_obj_id,
                BankAccount.is_active == True,
            )
            
            if bank_account:
                await bank_service.create_transaction(
                    business_id=business_id,
                    bank_account_id=str(bank_account.id),
                    transaction_type="withdrawal",
                    amount=amount,
                    date=date,
                    remarks=description or f"Expense: {category_id}",
                    user_id=user_id,
                )
            else:
                logger.warning(
                    "expense_bank_no_account",
                    business_id=business_id,
                    expense_id=str(expense.id),
                    message="Bank expense created but no active bank account found",
                )

        logger.info("expense_created", business_id=business_id, expense_id=str(expense.id), amount=str(amount))
        return expense

    @staticmethod
    async def list_expenses(
        business_id: str,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        category_id: Optional[str] = None,
        payment_mode: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Expense]:
        """List expenses."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        query = Expense.find(Expense.business_id == business_obj_id)

        if start_date:
            query = query.find(Expense.date >= start_date)
        if end_date:
            query = query.find(Expense.date <= end_date)
        if category_id:
            try:
                category_obj_id = PydanticObjectId(category_id)
                query = query.find(Expense.category_id == category_obj_id)
            except (ValueError, TypeError):
                pass
        if payment_mode:
            query = query.find(Expense.payment_mode == PaymentMode(payment_mode))

        expenses = await query.sort("-date").skip(offset).limit(limit).to_list()
        return expenses

    @staticmethod
    async def get_summary(
        business_id: str,
        start_date: datetime,
        end_date: datetime,
    ) -> dict:
        """Get expense summary for date range."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        # Get all expenses in range
        expenses = await Expense.find(
            Expense.business_id == business_obj_id,
            Expense.date >= start_date,
            Expense.date <= end_date,
        ).to_list()

        total_expenses = sum(e.amount for e in expenses) or Decimal("0.00")

        # Group by category
        by_category = {}
        category_ids = {e.category_id for e in expenses if e.category_id}
        
        if category_ids:
            categories = await ExpenseCategory.find(
                ExpenseCategory.id.in_(list(category_ids))
            ).to_list()
            category_map = {c.id: c.name for c in categories}
            
            for expense in expenses:
                if expense.category_id:
                    category_name = category_map.get(expense.category_id, "Unknown")
                    by_category[category_name] = by_category.get(category_name, Decimal("0.00")) + expense.amount

        return {
            "start_date": start_date,
            "end_date": end_date,
            "total_expenses": total_expenses,
            "by_category": by_category,
        }


# Singleton instance
expense_service = ExpenseService()
