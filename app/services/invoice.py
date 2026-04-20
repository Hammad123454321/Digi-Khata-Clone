"""Invoice service."""
from datetime import datetime, timezone
from typing import Optional, List, Dict
from decimal import Decimal
from beanie import PydanticObjectId
from pymongo.errors import DuplicateKeyError

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
        client_request_id: Optional[str] = None,
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

        normalized_request_id = (
            client_request_id.strip()
            if isinstance(client_request_id, str)
            else None
        )
        if normalized_request_id == "":
            normalized_request_id = None

        # Idempotency guard: if this invoice request was already processed, return it.
        if normalized_request_id:
            existing_invoice = await Invoice.find_one(
                Invoice.business_id == business_obj_id,
                Invoice.client_request_id == normalized_request_id,
            )
            if existing_invoice:
                logger.info(
                    "invoice_idempotent_replay",
                    business_id=business_id,
                    client_request_id=normalized_request_id,
                    invoice_id=str(existing_invoice.id),
                    invoice_number=existing_invoice.invoice_number,
                )
                return existing_invoice

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
        
        invoice = None
        invoice_number = None
        max_attempts = 3
        for _ in range(max_attempts):
            invoice_number = await InvoiceService.generate_invoice_number(business_id)
            candidate = Invoice(
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
                client_request_id=normalized_request_id,
                created_by_user_id=user_obj_id,
            )
            try:
                await candidate.insert()
                invoice = candidate
                break
            except DuplicateKeyError:
                if normalized_request_id:
                    existing_invoice = await Invoice.find_one(
                        Invoice.business_id == business_obj_id,
                        Invoice.client_request_id == normalized_request_id,
                    )
                    if existing_invoice:
                        logger.info(
                            "invoice_idempotent_duplicate_blocked",
                            business_id=business_id,
                            client_request_id=normalized_request_id,
                            invoice_id=str(existing_invoice.id),
                            invoice_number=existing_invoice.invoice_number,
                        )
                        return existing_invoice
                # Retry on collision (for example, race on invoice_number generation).
                continue

        if invoice is None or invoice_number is None:
            raise BusinessLogicError("Unable to create invoice at the moment. Please retry.")

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
    async def _validate_stock_for_invoice_update(
        business_obj_id: PydanticObjectId,
        existing_items: List[InvoiceItem],
        next_items: List[dict],
    ) -> None:
        """Validate only the extra required stock compared with existing invoice items."""
        existing_qty_by_item: Dict[str, Decimal] = {}
        for item in existing_items:
            if not item.item_id:
                continue
            key = str(item.item_id)
            existing_qty_by_item[key] = existing_qty_by_item.get(key, Decimal("0")) + item.quantity

        next_qty_by_item: Dict[str, Decimal] = {}
        for item in next_items:
            item_id = item.get("item_id")
            if not item_id:
                continue
            key = str(item_id)
            quantity = item.get("quantity", Decimal("0"))
            next_qty_by_item[key] = next_qty_by_item.get(key, Decimal("0")) + quantity

        for item_id, next_qty in next_qty_by_item.items():
            current_qty = existing_qty_by_item.get(item_id, Decimal("0"))
            required_extra = next_qty - current_qty
            if required_extra <= 0:
                continue

            item_obj_id = PydanticObjectId(item_id)
            item = await Item.find_one(
                Item.id == item_obj_id,
                Item.business_id == business_obj_id,
            )
            if not item:
                raise NotFoundError(f"Item with id {item_id} not found")
            if item.current_stock < required_extra:
                raise BusinessLogicError(
                    f"Insufficient stock for item '{item.name}'. "
                    f"Available: {item.current_stock}, Required: {required_extra}"
                )

    @staticmethod
    async def _reverse_invoice_inventory_effects(
        business_obj_id: PydanticObjectId,
        invoice_obj_id: PydanticObjectId,
    ) -> None:
        """Reverse stock effects for inventory transactions linked with an invoice."""
        inventory_rows = await InventoryTransaction.find(
            InventoryTransaction.business_id == business_obj_id,
            InventoryTransaction.reference_type == "invoice",
            InventoryTransaction.reference_id == invoice_obj_id,
        ).to_list()

        for movement in inventory_rows:
            item = await Item.find_one(
                Item.id == movement.item_id,
                Item.business_id == business_obj_id,
            )
            if not item:
                continue

            if movement.transaction_type == InventoryTransactionType.STOCK_OUT:
                item.current_stock += movement.quantity
            elif movement.transaction_type == InventoryTransactionType.STOCK_IN:
                item.current_stock -= movement.quantity

            if item.current_stock < Decimal("0"):
                item.current_stock = Decimal("0")
            await item.save()

        if inventory_rows:
            await InventoryTransaction.find(
                InventoryTransaction.business_id == business_obj_id,
                InventoryTransaction.reference_type == "invoice",
                InventoryTransaction.reference_id == invoice_obj_id,
            ).delete()

    @staticmethod
    async def update_invoice(
        invoice_id: str,
        business_id: str,
        date: Optional[datetime] = None,
        items: Optional[List[dict]] = None,
        tax_amount: Optional[Decimal] = None,
        discount_amount: Optional[Decimal] = None,
        remarks: Optional[str] = None,
        user_id: Optional[str] = None,
    ) -> Invoice:
        """Update invoice with side-effect reconciliation."""
        invoice = await InvoiceService.get_invoice(invoice_id, business_id)

        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        current_items = await InvoiceItem.find(
            InvoiceItem.invoice_id == invoice.id,
        ).to_list()

        next_date = date or invoice.date
        next_tax = tax_amount if tax_amount is not None else invoice.tax_amount
        next_discount = (
            discount_amount if discount_amount is not None else invoice.discount_amount
        )

        normalized_remarks = remarks
        if isinstance(normalized_remarks, str):
            normalized_remarks = normalized_remarks.strip()
            if normalized_remarks == "":
                normalized_remarks = None
        if remarks is None:
            normalized_remarks = invoice.remarks

        next_items = items
        if next_items is None:
            next_items = [
                {
                    "item_id": str(item.item_id) if item.item_id else None,
                    "item_name": item.item_name,
                    "quantity": item.quantity,
                    "unit_price": item.unit_price,
                }
                for item in current_items
            ]

        if not next_items:
            raise BusinessLogicError("Invoice must contain at least one item")

        await InvoiceService._validate_stock_for_invoice_update(
            business_obj_id=business_obj_id,
            existing_items=current_items,
            next_items=next_items,
        )

        next_subtotal = sum(
            item["quantity"] * item["unit_price"] for item in next_items
        )
        next_total = next_subtotal + next_tax - next_discount

        if invoice.invoice_type == InvoiceType.CREDIT and invoice.paid_amount > next_total:
            raise BusinessLogicError(
                "Updated total cannot be lower than already received payment"
            )

        invoice.date = next_date
        invoice.subtotal = next_subtotal
        invoice.tax_amount = next_tax
        invoice.discount_amount = next_discount
        invoice.total_amount = next_total
        invoice.remarks = normalized_remarks
        if invoice.invoice_type == InvoiceType.CASH:
            invoice.paid_amount = next_total
        await invoice.save()

        await InvoiceService._reverse_invoice_inventory_effects(
            business_obj_id=business_obj_id,
            invoice_obj_id=invoice.id,
        )
        await InvoiceItem.find(InvoiceItem.invoice_id == invoice.id).delete()

        for item_data in next_items:
            item_obj_id = None
            if item_data.get("item_id"):
                item_obj_id = PydanticObjectId(str(item_data["item_id"]))

            invoice_item = InvoiceItem(
                invoice_id=invoice.id,
                item_id=item_obj_id,
                item_name=item_data["item_name"],
                quantity=item_data["quantity"],
                unit_price=item_data["unit_price"],
                total_price=item_data["quantity"] * item_data["unit_price"],
            )
            await invoice_item.insert()

            if item_data.get("item_id"):
                from app.services.stock import stock_service

                await stock_service.create_inventory_transaction(
                    business_id=business_id,
                    item_id=str(item_data["item_id"]),
                    transaction_type="stock_out",
                    quantity=item_data["quantity"],
                    date=next_date,
                    reference_id=str(invoice.id),
                    reference_type="invoice",
                    user_id=user_id,
                )

        if invoice.invoice_type == InvoiceType.CASH:
            cash_rows = await CashTransaction.find(
                CashTransaction.business_id == business_obj_id,
                CashTransaction.reference_type == "invoice",
                CashTransaction.reference_id == invoice.id,
            ).to_list()
            if cash_rows:
                for row in cash_rows:
                    row.amount = next_total
                    row.date = next_date
                    row.remarks = f"Invoice {invoice.invoice_number}"
                    await row.save()
            else:
                from app.services.cash import cash_service

                await cash_service.create_transaction(
                    business_id=business_id,
                    transaction_type="cash_in",
                    amount=next_total,
                    date=next_date,
                    source="sales",
                    remarks=f"Invoice {invoice.invoice_number}",
                    reference_id=str(invoice.id),
                    reference_type="invoice",
                    user_id=user_id,
                )
        elif invoice.customer_id:
            credit_rows = await CustomerTransaction.find(
                CustomerTransaction.business_id == business_obj_id,
                CustomerTransaction.reference_type == "invoice",
                CustomerTransaction.reference_id == invoice.id,
                CustomerTransaction.transaction_type == "credit",
            ).to_list()
            if credit_rows:
                for row in credit_rows:
                    row.amount = next_total
                    row.date = next_date
                    row.remarks = f"Invoice {invoice.invoice_number}"
                    await row.save()
            else:
                user_obj_id = None
                if user_id:
                    try:
                        user_obj_id = PydanticObjectId(user_id)
                    except (ValueError, TypeError):
                        user_obj_id = None
                await CustomerTransaction(
                    business_id=business_obj_id,
                    customer_id=invoice.customer_id,
                    transaction_type="credit",
                    amount=next_total,
                    date=next_date,
                    reference_id=invoice.id,
                    reference_type="invoice",
                    remarks=f"Invoice {invoice.invoice_number}",
                    created_by_user_id=user_obj_id,
                ).insert()

            from app.services.customer import customer_service

            await customer_service._update_customer_balance(
                business_id,
                str(invoice.customer_id),
            )

        logger.info(
            "invoice_updated",
            business_id=business_id,
            invoice_id=str(invoice.id),
        )
        return invoice

    @staticmethod
    async def delete_invoice(invoice_id: str, business_id: str) -> None:
        """Delete invoice and reverse related side-effects."""
        invoice = await InvoiceService.get_invoice(invoice_id, business_id)

        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        if invoice.invoice_type == InvoiceType.CREDIT:
            payment_rows = await CustomerTransaction.find(
                CustomerTransaction.business_id == business_obj_id,
                CustomerTransaction.reference_type == "invoice",
                CustomerTransaction.reference_id == invoice.id,
                CustomerTransaction.transaction_type == "payment",
            ).to_list()
            if payment_rows:
                raise BusinessLogicError(
                    "Cannot delete an invoice that has payment entries. "
                    "Delete linked payments first."
                )

        await InvoiceService._reverse_invoice_inventory_effects(
            business_obj_id=business_obj_id,
            invoice_obj_id=invoice.id,
        )
        await InvoiceItem.find(InvoiceItem.invoice_id == invoice.id).delete()

        await CashTransaction.find(
            CashTransaction.business_id == business_obj_id,
            CashTransaction.reference_type == "invoice",
            CashTransaction.reference_id == invoice.id,
        ).delete()

        if invoice.invoice_type == InvoiceType.CREDIT and invoice.customer_id:
            await CustomerTransaction.find(
                CustomerTransaction.business_id == business_obj_id,
                CustomerTransaction.reference_type == "invoice",
                CustomerTransaction.reference_id == invoice.id,
                CustomerTransaction.transaction_type == "credit",
            ).delete()

            from app.services.customer import customer_service

            await customer_service._update_customer_balance(
                business_id,
                str(invoice.customer_id),
            )

        await invoice.delete()

        logger.info(
            "invoice_deleted",
            business_id=business_id,
            invoice_id=invoice_id,
        )

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
