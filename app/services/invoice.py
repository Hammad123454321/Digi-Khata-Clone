"""Invoice service."""
from datetime import datetime, timezone
from typing import Optional, List
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.core.exceptions import NotFoundError, BusinessLogicError
from app.models.invoice import Invoice, InvoiceItem, InvoiceType
from app.models.item import Item
from app.models.customer import Customer, CustomerTransaction, CustomerBalance
from app.models.cash import CashTransaction, CashTransactionType
from app.models.item import InventoryTransaction, InventoryTransactionType
from sqlalchemy.orm import selectinload
from app.core.logging import get_logger

logger = get_logger(__name__)


class InvoiceService:
    """Invoice management service."""

    @staticmethod
    async def generate_invoice_number(business_id: int, db: AsyncSession) -> str:
        """Generate unique invoice number."""
        # Get count of invoices for this business
        result = await db.execute(
            select(func.count(Invoice.id)).where(Invoice.business_id == business_id)
        )
        count = result.scalar_one() or 0

        # Format: INV-{business_id}-{sequential_number}
        invoice_number = f"INV-{business_id}-{count + 1:06d}"
        return invoice_number

    @staticmethod
    async def create_invoice(
        business_id: int,
        customer_id: Optional[int],
        invoice_type: str,
        date: datetime,
        items: List[dict],
        tax_amount: Decimal = Decimal("0.00"),
        discount_amount: Decimal = Decimal("0.00"),
        remarks: Optional[str] = None,
        user_id: Optional[int] = None,
        db: AsyncSession = None,
    ) -> Invoice:
        """Create a new invoice."""
        # Validate customer if provided
        if customer_id:
            result = await db.execute(
                select(Customer).where(Customer.id == customer_id, Customer.business_id == business_id)
            )
            customer = result.scalar_one_or_none()
            if not customer:
                raise NotFoundError("Customer not found")

        # Generate invoice number
        invoice_number = await InvoiceService.generate_invoice_number(business_id, db)

        # Calculate subtotal
        subtotal = sum(item["quantity"] * item["unit_price"] for item in items)
        total_amount = subtotal + tax_amount - discount_amount

        # Create invoice
        invoice = Invoice(
            business_id=business_id,
            customer_id=customer_id,
            invoice_number=invoice_number,
            invoice_type=InvoiceType(invoice_type),
            date=date,
            subtotal=subtotal,
            tax_amount=tax_amount,
            discount_amount=discount_amount,
            total_amount=total_amount,
            paid_amount=Decimal("0.00") if invoice_type == "credit" else total_amount,
            remarks=remarks,
            created_by_user_id=user_id,
        )
        db.add(invoice)
        await db.flush()

        # Create invoice items and update stock
        for item_data in items:
            invoice_item = InvoiceItem(
                invoice_id=invoice.id,
                item_id=item_data.get("item_id"),
                item_name=item_data["item_name"],
                quantity=item_data["quantity"],
                unit_price=item_data["unit_price"],
                total_price=item_data["quantity"] * item_data["unit_price"],
            )
            db.add(invoice_item)

            # Update stock if item_id provided
            if item_data.get("item_id"):
                from app.services.stock import stock_service
                await stock_service.create_inventory_transaction(
                    business_id=business_id,
                    item_id=item_data["item_id"],
                    transaction_type="stock_out",
                    quantity=item_data["quantity"],
                    date=date,
                    reference_id=invoice.id,
                    reference_type="invoice",
                    user_id=user_id,
                    db=db,
                )

        await db.flush()

        # Handle cash/credit transactions
        if invoice_type == "cash":
            # Create cash transaction
            from app.services.cash import cash_service
            await cash_service.create_transaction(
                business_id=business_id,
                transaction_type="cash_in",
                amount=total_amount,
                date=date,
                source="sales",
                remarks=f"Invoice {invoice_number}",
                reference_id=invoice.id,
                reference_type="invoice",
                user_id=user_id,
                db=db,
            )
        elif invoice_type == "credit" and customer_id:
            # Create customer credit transaction
            customer_transaction = CustomerTransaction(
                business_id=business_id,
                customer_id=customer_id,
                transaction_type="credit",
                amount=total_amount,
                date=date,
                reference_id=invoice.id,
                reference_type="invoice",
                remarks=f"Invoice {invoice_number}",
                created_by_user_id=user_id,
            )
            db.add(customer_transaction)
            await db.flush()

            # Update customer balance
            await InvoiceService._update_customer_balance(business_id, customer_id, db)

        # Generate PDF (async, can be done later)
        # pdf_service = PDFService()
        # pdf_path = await pdf_service.generate_invoice_pdf(invoice.id, db)
        # invoice.pdf_path = pdf_path

        logger.info("invoice_created", business_id=business_id, invoice_id=invoice.id, invoice_number=invoice_number)

        return invoice

    @staticmethod
    async def _update_customer_balance(business_id: int, customer_id: int, db: AsyncSession) -> None:
        """Update customer balance."""
        # Calculate balance from transactions
        result = await db.execute(
            select(func.sum(CustomerTransaction.amount)).where(
                CustomerTransaction.business_id == business_id,
                CustomerTransaction.customer_id == customer_id,
                CustomerTransaction.transaction_type == "credit",
            )
        )
        total_credit = result.scalar_one() or Decimal("0.00")

        result = await db.execute(
            select(func.sum(CustomerTransaction.amount)).where(
                CustomerTransaction.business_id == business_id,
                CustomerTransaction.customer_id == customer_id,
                CustomerTransaction.transaction_type == "payment",
            )
        )
        total_payment = result.scalar_one() or Decimal("0.00")

        balance = total_credit - total_payment

        # Get last transaction date
        result = await db.execute(
            select(func.max(CustomerTransaction.date)).where(
                CustomerTransaction.business_id == business_id,
                CustomerTransaction.customer_id == customer_id,
            )
        )
        last_transaction_date = result.scalar_one()

        # Update or create balance
        result = await db.execute(
            select(CustomerBalance).where(
                CustomerBalance.business_id == business_id,
                CustomerBalance.customer_id == customer_id,
            )
        )
        customer_balance = result.scalar_one_or_none()

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
    async def get_invoice(invoice_id: int, business_id: int, db: AsyncSession) -> Invoice:
        """Get invoice by ID."""
        result = await db.execute(
            select(Invoice)
            .where(Invoice.id == invoice_id, Invoice.business_id == business_id)
            .options(selectinload(Invoice.items))
        )
        invoice = result.scalar_one_or_none()

        if not invoice:
            raise NotFoundError("Invoice not found")

        return invoice

    @staticmethod
    async def list_invoices(
        business_id: int,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        customer_id: Optional[int] = None,
        invoice_type: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
        db: AsyncSession = None,
    ) -> List[Invoice]:
        """List invoices."""
        query = select(Invoice).where(Invoice.business_id == business_id)

        if start_date:
            query = query.where(Invoice.date >= start_date)
        if end_date:
            query = query.where(Invoice.date <= end_date)
        if customer_id:
            query = query.where(Invoice.customer_id == customer_id)
        if invoice_type:
            query = query.where(Invoice.invoice_type == InvoiceType(invoice_type))

        query = query.order_by(Invoice.date.desc()).limit(limit).offset(offset)

        result = await db.execute(query)
        return list(result.scalars().all())


# Singleton instance
invoice_service = InvoiceService()

