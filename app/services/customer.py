"""Customer service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.core.exceptions import NotFoundError, BusinessLogicError
from app.models.customer import Customer, CustomerTransaction, CustomerBalance
from app.models.cash import CashTransaction, CashTransactionType
from app.core.logging import get_logger

logger = get_logger(__name__)


class CustomerService:
    """Customer management service."""

    @staticmethod
    async def create_customer(
        business_id: int,
        name: str,
        phone: Optional[str] = None,
        email: Optional[str] = None,
        address: Optional[str] = None,
        db: AsyncSession = None,
    ) -> Customer:
        """Create a new customer."""
        customer = Customer(
            business_id=business_id,
            name=name,
            phone=phone,
            email=email,
            address=address,
            is_active=True,
        )
        db.add(customer)
        await db.flush()

        # Create initial balance
        balance = CustomerBalance(
            business_id=business_id,
            customer_id=customer.id,
            balance=Decimal("0.00"),
        )
        db.add(balance)
        await db.flush()

        logger.info("customer_created", business_id=business_id, customer_id=customer.id, name=name)
        return customer

    @staticmethod
    async def get_customer(customer_id: int, business_id: int, db: AsyncSession) -> Customer:
        """Get customer by ID."""
        result = await db.execute(
            select(Customer).where(Customer.id == customer_id, Customer.business_id == business_id)
        )
        customer = result.scalar_one_or_none()

        if not customer:
            raise NotFoundError("Customer not found")

        return customer

    @staticmethod
    async def list_customers(
        business_id: int,
        is_active: Optional[bool] = None,
        search: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
        db: AsyncSession = None,
    ) -> list[Customer]:
        """List customers."""
        query = select(Customer).where(Customer.business_id == business_id)

        if is_active is not None:
            query = query.where(Customer.is_active == is_active)
        if search:
            query = query.where(
                (Customer.name.ilike(f"%{search}%"))
                | (Customer.phone.ilike(f"%{search}%"))
            )

        query = query.order_by(Customer.name).limit(limit).offset(offset)

        result = await db.execute(query)
        customers = result.scalars().all()

        # Add balance to each customer
        for customer in customers:
            balance_result = await db.execute(
                select(CustomerBalance).where(
                    CustomerBalance.business_id == business_id,
                    CustomerBalance.customer_id == customer.id,
                )
            )
            balance = balance_result.scalar_one_or_none()
            customer.balance = balance.balance if balance else Decimal("0.00")

        return list(customers)

    @staticmethod
    async def record_payment(
        business_id: int,
        customer_id: int,
        amount: Decimal,
        date: datetime,
        remarks: Optional[str] = None,
        user_id: Optional[int] = None,
        db: AsyncSession = None,
    ) -> CustomerTransaction:
        """Record customer payment."""
        customer = await CustomerService.get_customer(customer_id, business_id, db)

        # Create payment transaction
        transaction = CustomerTransaction(
            business_id=business_id,
            customer_id=customer_id,
            transaction_type="payment",
            amount=amount,
            date=date,
            remarks=remarks,
            created_by_user_id=user_id,
        )
        db.add(transaction)
        await db.flush()

        # Create cash transaction
        from app.services.cash import cash_service
        await cash_service.create_transaction(
            business_id=business_id,
            transaction_type="cash_in",
            amount=amount,
            date=date,
            source="customer_payment",
            remarks=f"Payment from {customer.name}",
            reference_id=transaction.id,
            reference_type="customer_payment",
            user_id=user_id,
            db=db,
        )

        # Update customer balance
        await CustomerService._update_customer_balance(business_id, customer_id, db)

        logger.info(
            "customer_payment_recorded",
            business_id=business_id,
            customer_id=customer_id,
            amount=str(amount),
        )

        return transaction

    @staticmethod
    async def _update_customer_balance(business_id: int, customer_id: int, db: AsyncSession) -> None:
        """Update customer balance."""
        # Calculate balance from transactions
        credit_result = await db.execute(
            select(func.sum(CustomerTransaction.amount)).where(
                CustomerTransaction.business_id == business_id,
                CustomerTransaction.customer_id == customer_id,
                CustomerTransaction.transaction_type == "credit",
            )
        )
        total_credit = credit_result.scalar_one() or Decimal("0.00")

        payment_result = await db.execute(
            select(func.sum(CustomerTransaction.amount)).where(
                CustomerTransaction.business_id == business_id,
                CustomerTransaction.customer_id == customer_id,
                CustomerTransaction.transaction_type == "payment",
            )
        )
        total_payment = payment_result.scalar_one() or Decimal("0.00")

        balance = total_credit - total_payment

        # Get last transaction date
        last_trans_result = await db.execute(
            select(func.max(CustomerTransaction.date)).where(
                CustomerTransaction.business_id == business_id,
                CustomerTransaction.customer_id == customer_id,
            )
        )
        last_transaction_date = last_trans_result.scalar_one()

        # Update or create balance
        balance_result = await db.execute(
            select(CustomerBalance).where(
                CustomerBalance.business_id == business_id,
                CustomerBalance.customer_id == customer_id,
            )
        )
        customer_balance = balance_result.scalar_one_or_none()

        if customer_balance:
            customer_balance.balance = balance
            customer_balance.last_transaction_date = last_transaction_date
        else:
            customer_balance = CustomerBalance(
                business_id=business_id,
                customer_id=customer_id,
                balance=balance,
                last_transaction_date=last_transaction_date,
            )
            db.add(customer_balance)

        await db.flush()

    @staticmethod
    async def list_transactions(
        business_id: int,
        customer_id: int,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        limit: int = 100,
        offset: int = 0,
        db: AsyncSession = None,
    ) -> list[CustomerTransaction]:
        """List customer transactions."""
        query = select(CustomerTransaction).where(
            CustomerTransaction.business_id == business_id,
            CustomerTransaction.customer_id == customer_id,
        )

        if start_date:
            query = query.where(CustomerTransaction.date >= start_date)
        if end_date:
            query = query.where(CustomerTransaction.date <= end_date)

        query = query.order_by(CustomerTransaction.date.desc()).limit(limit).offset(offset)

        result = await db.execute(query)
        return list(result.scalars().all())


# Singleton instance
customer_service = CustomerService()

