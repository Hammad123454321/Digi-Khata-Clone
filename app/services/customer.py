"""Customer service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from beanie import PydanticObjectId

from app.core.exceptions import NotFoundError, BusinessLogicError, ValidationError
from app.core.validators import validate_positive_amount
from app.models.customer import Customer, CustomerTransaction, CustomerBalance
from app.models.cash import CashTransaction, CashTransactionType
from app.core.logging import get_logger

logger = get_logger(__name__)


class CustomerService:
    """Customer management service."""

    @staticmethod
    async def create_customer(
        business_id: str,  # ObjectId string
        name: str,
        phone: Optional[str] = None,
        email: Optional[str] = None,
        address: Optional[str] = None,
    ) -> Customer:
        """Create a new customer."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        customer = Customer(
            business_id=business_obj_id,
            name=name,
            address=address,
            is_active=True,
        )
        if phone:
            customer.set_phone(phone)
        if email:
            customer.set_email(email)
        await customer.insert()

        # Create initial balance
        balance = CustomerBalance(
            business_id=business_obj_id,
            customer_id=customer.id,
            balance=Decimal("0.00"),
        )
        await balance.insert()

        logger.info("customer_created", business_id=business_id, customer_id=str(customer.id), name=name)
        return customer

    @staticmethod
    async def get_customer(customer_id: str, business_id: str) -> Customer:
        """Get customer by ID."""
        try:
            customer_obj_id = PydanticObjectId(customer_id)
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise NotFoundError("Customer not found")

        customer = await Customer.find_one(
            Customer.id == customer_obj_id,
            Customer.business_id == business_obj_id,
        )

        if not customer:
            raise NotFoundError("Customer not found")

        return customer

    @staticmethod
    async def list_customers(
        business_id: str,
        is_active: Optional[bool] = None,
        search: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Customer]:
        """List customers."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        query = Customer.find(Customer.business_id == business_obj_id)

        if is_active is not None:
            query = query.find(Customer.is_active == is_active)
        if search:
            # MongoDB regex for case-insensitive search
            import re
            search_regex = re.compile(search, re.IGNORECASE)
            query = query.find(
                (Customer.name == search_regex) | (Customer.phone == search_regex)
            )

        customers = await query.sort("+name").skip(offset).limit(limit).to_list()
        # Note: balances for each customer are resolved at the API layer when needed,
        # to avoid mutating Beanie/Pydantic models with undeclared fields.
        return customers

    @staticmethod
    async def record_payment(
        business_id: str,
        customer_id: str,
        amount: Decimal,
        date: datetime,
        invoice_id: Optional[str] = None,
        remarks: Optional[str] = None,
        user_id: Optional[str] = None,
    ) -> CustomerTransaction:
        """Record customer payment (optionally linked to invoice)."""
        # Validate amount
        validate_positive_amount(amount, "payment amount")
        
        try:
            business_obj_id = PydanticObjectId(business_id)
            customer_obj_id = PydanticObjectId(customer_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business or customer ID format",
                {
                    "business_id": [f"'{business_id}' is not a valid ObjectId"],
                    "customer_id": [f"'{customer_id}' is not a valid ObjectId"],
                },
            )

        customer = await CustomerService.get_customer(customer_id, business_id)

        # If invoice_id provided, validate and update invoice
        invoice = None
        if invoice_id:
            from app.models.invoice import Invoice
            
            try:
                invoice_obj_id = PydanticObjectId(invoice_id)
            except (ValueError, TypeError):
                raise NotFoundError("Invalid invoice ID format")
            
            invoice = await Invoice.find_one(
                Invoice.id == invoice_obj_id,
                Invoice.business_id == business_obj_id,
                Invoice.customer_id == customer_obj_id,
            )
            
            if not invoice:
                raise NotFoundError("Invoice not found or does not belong to this customer")
            
            # Validate invoice is credit type
            if invoice.invoice_type.value != "credit":
                raise BusinessLogicError("Only credit invoices can receive payments")
            
            # Calculate new paid amount
            new_paid_amount = invoice.paid_amount + amount
            
            # Validate payment doesn't exceed total amount
            if new_paid_amount > invoice.total_amount:
                raise BusinessLogicError(
                    f"Payment amount exceeds invoice balance. "
                    f"Invoice total: {invoice.total_amount}, "
                    f"Already paid: {invoice.paid_amount}, "
                    f"Remaining: {invoice.total_amount - invoice.paid_amount}"
                )
            
            # Update invoice paid amount
            invoice.paid_amount = new_paid_amount
            await invoice.save()

        # Create payment transaction
        user_obj_id = None
        if user_id:
            try:
                user_obj_id = PydanticObjectId(user_id)
            except (ValueError, TypeError):
                pass

        transaction = CustomerTransaction(
            business_id=business_obj_id,
            customer_id=customer_obj_id,
            transaction_type="payment",
            amount=amount,
            date=date,
            reference_id=PydanticObjectId(invoice_id) if invoice_id else None,
            reference_type="invoice" if invoice_id else None,
            remarks=remarks,
            created_by_user_id=user_obj_id,
        )
        await transaction.insert()

        # Create cash transaction
        from app.services.cash import cash_service
        payment_remarks = f"Payment from {customer.name}"
        if invoice:
            payment_remarks += f" (Invoice {invoice.invoice_number})"
        
        await cash_service.create_transaction(
            business_id=business_id,
            transaction_type="cash_in",
            amount=amount,
            date=date,
            source="customer_payment",
            remarks=payment_remarks,
            reference_id=str(transaction.id),
            reference_type="customer_payment",
            user_id=user_id,
        )

        # Update customer balance
        await CustomerService._update_customer_balance(business_id, customer_id)

        logger.info(
            "customer_payment_recorded",
            business_id=business_id,
            customer_id=customer_id,
            invoice_id=invoice_id,
            amount=str(amount),
        )

        return transaction

    @staticmethod
    async def _update_customer_balance(business_id: str, customer_id: str) -> None:
        """Update customer balance."""
        try:
            business_obj_id = PydanticObjectId(business_id)
            customer_obj_id = PydanticObjectId(customer_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business or customer ID format",
                {
                    "business_id": [f"'{business_id}' is not a valid ObjectId"],
                    "customer_id": [f"'{customer_id}' is not a valid ObjectId"],
                },
            )

        # Calculate balance from transactions
        credit_transactions = await CustomerTransaction.find(
            CustomerTransaction.business_id == business_obj_id,
            CustomerTransaction.customer_id == customer_obj_id,
            CustomerTransaction.transaction_type == "credit",
        ).to_list()
        total_credit = sum(t.amount for t in credit_transactions) or Decimal("0.00")

        payment_transactions = await CustomerTransaction.find(
            CustomerTransaction.business_id == business_obj_id,
            CustomerTransaction.customer_id == customer_obj_id,
            CustomerTransaction.transaction_type == "payment",
        ).to_list()
        total_payment = sum(t.amount for t in payment_transactions) or Decimal("0.00")

        balance = total_credit - total_payment

        # Get last transaction date
        all_transactions = await CustomerTransaction.find(
            CustomerTransaction.business_id == business_obj_id,
            CustomerTransaction.customer_id == customer_obj_id,
        ).sort("-date").limit(1).to_list()
        
        last_transaction_date = all_transactions[0].date if all_transactions else datetime.now(timezone.utc)

        # Update or create balance
        customer_balance = await CustomerBalance.find_one(
            CustomerBalance.business_id == business_obj_id,
            CustomerBalance.customer_id == customer_obj_id,
        )

        if customer_balance:
            customer_balance.balance = balance
            customer_balance.last_transaction_date = last_transaction_date
            await customer_balance.save()
        else:
            customer_balance = CustomerBalance(
                business_id=business_obj_id,
                customer_id=customer_obj_id,
                balance=balance,
                last_transaction_date=last_transaction_date,
            )
            await customer_balance.insert()

    @staticmethod
    async def list_transactions(
        business_id: str,
        customer_id: str,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[CustomerTransaction]:
        """List customer transactions."""
        try:
            business_obj_id = PydanticObjectId(business_id)
            customer_obj_id = PydanticObjectId(customer_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business or customer ID format",
                {
                    "business_id": [f"'{business_id}' is not a valid ObjectId"],
                    "customer_id": [f"'{customer_id}' is not a valid ObjectId"],
                },
            )

        query = CustomerTransaction.find(
            CustomerTransaction.business_id == business_obj_id,
            CustomerTransaction.customer_id == customer_obj_id,
        )

        if start_date:
            query = query.find(CustomerTransaction.date >= start_date)
        if end_date:
            query = query.find(CustomerTransaction.date <= end_date)

        transactions = await query.sort("-date").skip(offset).limit(limit).to_list()
        return transactions


# Singleton instance
customer_service = CustomerService()
