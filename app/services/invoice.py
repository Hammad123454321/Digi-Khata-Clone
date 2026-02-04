"""Invoice service."""
from datetime import datetime, timezone
from typing import Optional, List
from decimal import Decimal
from beanie import PydanticObjectId

from app.core.exceptions import NotFoundError, BusinessLogicError, ValidationError
from app.models.invoice import Invoice, InvoiceItem, InvoiceType
from app.models.item import Item
from app.models.customer import Customer, CustomerTransaction
from app.models.cash import CashTransaction, CashTransactionType
from app.models.item import InventoryTransaction, InventoryTransactionType
from app.core.logging import get_logger

logger = get_logger(__name__)


class InvoiceService:
    """Invoice management service."""

    @staticmethod
    async def generate_invoice_number(business_id: str) -> str:
        """Generate unique invoice number."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        # Get count of invoices for this business
        count = await Invoice.find(Invoice.business_id == business_obj_id).count()

        # Format: INV-{business_id}-{sequential_number}
        invoice_number = f"INV-{business_id[:8]}-{count + 1:06d}"
        return invoice_number

    @staticmethod
    async def create_invoice(
        business_id: str,
        customer_id: Optional[str],
        invoice_type: str,
        date: datetime,
        items: List[dict],
        tax_amount: Decimal = Decimal("0.00"),
        discount_amount: Decimal = Decimal("0.00"),
        remarks: Optional[str] = None,
        user_id: Optional[str] = None,
    ) -> Invoice:
        """Create a new invoice."""
        # Validate customer is required for all invoices
        if not customer_id:
            raise BusinessLogicError("Customer is required for all invoices")
        
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        # Validate customer exists and belongs to business
        try:
            customer_obj_id = PydanticObjectId(customer_id)
            customer = await Customer.find_one(
                Customer.id == customer_obj_id,
                Customer.business_id == business_obj_id,
            )
            if not customer:
                raise NotFoundError("Customer not found")
        except (ValueError, TypeError):
            raise NotFoundError("Invalid customer ID format")

        # Validate stock availability BEFORE creating invoice
        from app.services.stock import stock_service
        for item_data in items:
            if item_data.get("item_id"):
                item_id = item_data["item_id"]
                quantity = item_data["quantity"]
                
                try:
                    item = await stock_service.get_item(str(item_id), business_id)
                    if item.current_stock < quantity:
                        raise BusinessLogicError(
                            f"Insufficient stock for item '{item.name}'. "
                            f"Available: {item.current_stock}, Required: {quantity}"
                        )
                except NotFoundError:
                    raise NotFoundError(f"Item with id {item_id} not found")

        # Generate invoice number
        invoice_number = await InvoiceService.generate_invoice_number(business_id)

        # Calculate subtotal
        subtotal = sum(item["quantity"] * item["unit_price"] for item in items)
        total_amount = subtotal + tax_amount - discount_amount

        user_obj_id = None
        if user_id:
            try:
                user_obj_id = PydanticObjectId(user_id)
            except (ValueError, TypeError):
                pass

        # Create invoice
        # Normalize remarks: convert empty string to None, strip whitespace
        normalized_remarks = None
        if remarks:
            normalized_remarks = remarks.strip() if isinstance(remarks, str) else str(remarks).strip()
            if not normalized_remarks:
                normalized_remarks = None
        
        invoice = Invoice(
            business_id=business_obj_id,
            customer_id=customer_obj_id,
            invoice_number=invoice_number,
            invoice_type=InvoiceType(invoice_type),
            date=date,
            subtotal=subtotal,
            tax_amount=tax_amount,
            discount_amount=discount_amount,
            total_amount=total_amount,
            paid_amount=Decimal("0.00") if invoice_type == "credit" else total_amount,
            remarks=normalized_remarks,
            created_by_user_id=user_obj_id,
        )
        await invoice.insert()

        # Create invoice items and update stock
        for item_data in items:
            item_obj_id = None
            if item_data.get("item_id"):
                try:
                    item_obj_id = PydanticObjectId(str(item_data["item_id"]))
                except (ValueError, TypeError):
                    pass

            invoice_item = InvoiceItem(
                invoice_id=invoice.id,
                item_id=item_obj_id,
                item_name=item_data["item_name"],
                quantity=item_data["quantity"],
                unit_price=item_data["unit_price"],
                total_price=item_data["quantity"] * item_data["unit_price"],
            )
            await invoice_item.insert()

            # Update stock if item_id provided
            if item_data.get("item_id"):
                from app.services.stock import stock_service
                await stock_service.create_inventory_transaction(
                    business_id=business_id,
                    item_id=str(item_data["item_id"]),
                    transaction_type="stock_out",
                    quantity=item_data["quantity"],
                    date=date,
                    reference_id=str(invoice.id),
                    reference_type="invoice",
                    user_id=user_id,
                )

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
                reference_id=str(invoice.id),
                reference_type="invoice",
                user_id=user_id,
            )
        elif invoice_type == "credit" and customer_id:
            # Create customer credit transaction
            customer_transaction = CustomerTransaction(
                business_id=business_obj_id,
                customer_id=customer_obj_id,
                transaction_type="credit",
                amount=total_amount,
                date=date,
                reference_id=invoice.id,
                reference_type="invoice",
                remarks=f"Invoice {invoice_number}",
                created_by_user_id=user_obj_id,
            )
            await customer_transaction.insert()

            # Update customer balance
            from app.services.customer import customer_service
            await customer_service._update_customer_balance(business_id, customer_id)

        logger.info("invoice_created", business_id=business_id, invoice_id=str(invoice.id), invoice_number=invoice_number)

        return invoice

    @staticmethod
    async def get_invoice(invoice_id: str, business_id: str) -> Invoice:
        """Get invoice by ID."""
        try:
            invoice_obj_id = PydanticObjectId(invoice_id)
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise NotFoundError("Invoice not found")

        invoice = await Invoice.find_one(
            Invoice.id == invoice_obj_id,
            Invoice.business_id == business_obj_id,
        )

        if not invoice:
            raise NotFoundError("Invoice not found")

        # Note: Items are loaded separately in the endpoint, not here
        # This keeps the Invoice model clean and avoids Pydantic validation issues

        return invoice

    @staticmethod
    async def list_invoices(
        business_id: str,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        customer_id: Optional[str] = None,
        invoice_type: Optional[str] = None,
        is_paid: Optional[bool] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> List[Invoice]:
        """List invoices."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        query = Invoice.find(Invoice.business_id == business_obj_id)

        if start_date:
            query = query.find(Invoice.date >= start_date)
        if end_date:
            query = query.find(Invoice.date <= end_date)
        if customer_id:
            try:
                customer_obj_id = PydanticObjectId(customer_id)
                query = query.find(Invoice.customer_id == customer_obj_id)
            except (ValueError, TypeError):
                pass
        if invoice_type:
            query = query.find(Invoice.invoice_type == InvoiceType(invoice_type))
        if is_paid is not None:
            # Note: MongoDB doesn't support direct field comparison in queries like this
            # We'll filter after fetching
            pass

        invoices = await query.sort("-date").skip(offset).limit(limit).to_list()

        # Filter by is_paid if needed
        if is_paid is not None:
            if is_paid:
                invoices = [inv for inv in invoices if inv.paid_amount >= inv.total_amount]
            else:
                invoices = [inv for inv in invoices if inv.paid_amount < inv.total_amount]

        # Note: Items are not loaded here since list endpoint only returns summary info
        # Items are loaded separately in get_invoice endpoint when needed

        return invoices

    @staticmethod
    async def get_unpaid_invoices(
        business_id: str,
        customer_id: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> List[Invoice]:
        """Get unpaid invoices (credit invoices with paid_amount < total_amount)."""
        return await InvoiceService.list_invoices(
            business_id=business_id,
            customer_id=customer_id,
            invoice_type="credit",
            is_paid=False,
            limit=limit,
            offset=offset,
        )

    @staticmethod
    def is_invoice_paid(invoice: Invoice) -> bool:
        """Check if invoice is fully paid."""
        return invoice.paid_amount >= invoice.total_amount

    @staticmethod
    def get_invoice_balance(invoice: Invoice) -> Decimal:
        """Get remaining balance on invoice."""
        return max(Decimal("0.00"), invoice.total_amount - invoice.paid_amount)


# Singleton instance
invoice_service = InvoiceService()
