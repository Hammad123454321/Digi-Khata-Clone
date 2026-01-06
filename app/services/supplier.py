"""Supplier service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.core.exceptions import NotFoundError
from app.models.supplier import Supplier, SupplierTransaction, SupplierBalance
from app.core.logging import get_logger

logger = get_logger(__name__)


class SupplierService:
    """Supplier management service."""

    @staticmethod
    async def create_supplier(
        business_id: int,
        name: str,
        phone: Optional[str] = None,
        email: Optional[str] = None,
        address: Optional[str] = None,
        db: AsyncSession = None,
    ) -> Supplier:
        """Create a new supplier."""
        supplier = Supplier(
            business_id=business_id,
            name=name,
            phone=phone,
            email=email,
            address=address,
            is_active=True,
        )
        db.add(supplier)
        await db.flush()

        # Create initial balance
        balance = SupplierBalance(
            business_id=business_id,
            supplier_id=supplier.id,
            balance=Decimal("0.00"),
        )
        db.add(balance)
        await db.flush()

        logger.info("supplier_created", business_id=business_id, supplier_id=supplier.id, name=name)
        return supplier

    @staticmethod
    async def get_supplier(supplier_id: int, business_id: int, db: AsyncSession) -> Supplier:
        """Get supplier by ID."""
        result = await db.execute(
            select(Supplier).where(Supplier.id == supplier_id, Supplier.business_id == business_id)
        )
        supplier = result.scalar_one_or_none()

        if not supplier:
            raise NotFoundError("Supplier not found")

        return supplier

    @staticmethod
    async def list_suppliers(
        business_id: int,
        is_active: Optional[bool] = None,
        search: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
        db: AsyncSession = None,
    ) -> list[Supplier]:
        """List suppliers."""
        query = select(Supplier).where(Supplier.business_id == business_id)

        if is_active is not None:
            query = query.where(Supplier.is_active == is_active)
        if search:
            query = query.where(
                (Supplier.name.ilike(f"%{search}%"))
                | (Supplier.phone.ilike(f"%{search}%"))
            )

        query = query.order_by(Supplier.name).limit(limit).offset(offset)

        result = await db.execute(query)
        suppliers = result.scalars().all()

        # Add balance to each supplier
        for supplier in suppliers:
            balance_result = await db.execute(
                select(SupplierBalance).where(
                    SupplierBalance.business_id == business_id,
                    SupplierBalance.supplier_id == supplier.id,
                )
            )
            balance = balance_result.scalar_one_or_none()
            supplier.balance = balance.balance if balance else Decimal("0.00")

        return list(suppliers)

    @staticmethod
    async def record_payment(
        business_id: int,
        supplier_id: int,
        amount: Decimal,
        date: datetime,
        remarks: Optional[str] = None,
        user_id: Optional[int] = None,
        db: AsyncSession = None,
    ) -> SupplierTransaction:
        """Record supplier payment."""
        supplier = await SupplierService.get_supplier(supplier_id, business_id, db)

        # Create payment transaction
        transaction = SupplierTransaction(
            business_id=business_id,
            supplier_id=supplier_id,
            transaction_type="payment",
            amount=amount,
            date=date,
            remarks=remarks,
            created_by_user_id=user_id,
        )
        db.add(transaction)
        await db.flush()

        # Update supplier balance
        await SupplierService._update_supplier_balance(business_id, supplier_id, db)

        logger.info(
            "supplier_payment_recorded",
            business_id=business_id,
            supplier_id=supplier_id,
            amount=str(amount),
        )

        return transaction

    @staticmethod
    async def _update_supplier_balance(business_id: int, supplier_id: int, db: AsyncSession) -> None:
        """Update supplier balance."""
        # Calculate balance from transactions
        purchase_result = await db.execute(
            select(func.sum(SupplierTransaction.amount)).where(
                SupplierTransaction.business_id == business_id,
                SupplierTransaction.supplier_id == supplier_id,
                SupplierTransaction.transaction_type == "purchase",
            )
        )
        total_purchase = purchase_result.scalar_one() or Decimal("0.00")

        payment_result = await db.execute(
            select(func.sum(SupplierTransaction.amount)).where(
                SupplierTransaction.business_id == business_id,
                SupplierTransaction.supplier_id == supplier_id,
                SupplierTransaction.transaction_type == "payment",
            )
        )
        total_payment = payment_result.scalar_one() or Decimal("0.00")

        balance = total_purchase - total_payment  # Positive = payable

        # Get last transaction date
        last_trans_result = await db.execute(
            select(func.max(SupplierTransaction.date)).where(
                SupplierTransaction.business_id == business_id,
                SupplierTransaction.supplier_id == supplier_id,
            )
        )
        last_transaction_date = last_trans_result.scalar_one()

        # Update or create balance
        balance_result = await db.execute(
            select(SupplierBalance).where(
                SupplierBalance.business_id == business_id,
                SupplierBalance.supplier_id == supplier_id,
            )
        )
        supplier_balance = balance_result.scalar_one_or_none()

        if supplier_balance:
            supplier_balance.balance = balance
            supplier_balance.last_transaction_date = last_transaction_date
        else:
            supplier_balance = SupplierBalance(
                business_id=business_id,
                supplier_id=supplier_id,
                balance=balance,
                last_transaction_date=last_transaction_date,
            )
            db.add(supplier_balance)

        await db.flush()


# Singleton instance
supplier_service = SupplierService()

