"""Supplier service."""
from datetime import datetime, timezone
from typing import Optional, List
from decimal import Decimal
from beanie import PydanticObjectId
from beanie.operators import In

from app.core.exceptions import NotFoundError, BusinessLogicError, ValidationError
from app.core.validators import validate_positive_amount
from app.models.supplier import Supplier, SupplierTransaction, SupplierBalance
from app.core.logging import get_logger

logger = get_logger(__name__)


class SupplierService:
    """Supplier management service."""

    @staticmethod
    async def create_supplier(
        business_id: str,
        name: str,
        phone: Optional[str] = None,
        email: Optional[str] = None,
        address: Optional[str] = None,
    ) -> Supplier:
        """Create a new supplier."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        supplier = Supplier(
            business_id=business_obj_id,
            name=name,
            address=address,
            is_active=True,
        )
        if phone:
            supplier.set_phone(phone)
        if email:
            supplier.set_email(email)
        await supplier.insert()

        # Create initial balance
        balance = SupplierBalance(
            business_id=business_obj_id,
            supplier_id=supplier.id,
            balance=Decimal("0.00"),
        )
        await balance.insert()

        logger.info("supplier_created", business_id=business_id, supplier_id=str(supplier.id), name=name)
        return supplier

    @staticmethod
    async def get_supplier(supplier_id: str, business_id: str) -> Supplier:
        """Get supplier by ID."""
        try:
            supplier_obj_id = PydanticObjectId(supplier_id)
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise NotFoundError("Supplier not found")

        supplier = await Supplier.find_one(
            Supplier.id == supplier_obj_id,
            Supplier.business_id == business_obj_id,
        )

        if not supplier:
            raise NotFoundError("Supplier not found")

        return supplier

    @staticmethod
    async def list_suppliers(
        business_id: str,
        is_active: Optional[bool] = None,
        search: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Supplier]:
        """List suppliers."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        query = Supplier.find(Supplier.business_id == business_obj_id)

        if is_active is not None:
            query = query.find(Supplier.is_active == is_active)
        if search:
            import re
            search_regex = re.compile(search, re.IGNORECASE)
            query = query.find(
                (Supplier.name == search_regex) | (Supplier.phone == search_regex)
            )

        suppliers = await query.sort("+name").skip(offset).limit(limit).to_list()

        # Load all balances in one query
        if suppliers:
            supplier_ids = [s.id for s in suppliers]
            balances = await SupplierBalance.find(
                SupplierBalance.business_id == business_obj_id,
                In(SupplierBalance.supplier_id, supplier_ids),
            ).to_list()
            balance_map = {b.supplier_id: b.balance for b in balances}
            
            for supplier in suppliers:
                supplier.balance = balance_map.get(supplier.id, Decimal("0.00"))

        return suppliers

    @staticmethod
    async def record_payment(
        business_id: str,
        supplier_id: str,
        amount: Decimal,
        date: datetime,
        remarks: Optional[str] = None,
        user_id: Optional[str] = None,
    ) -> SupplierTransaction:
        """Record supplier payment."""
        validate_positive_amount(amount, "payment amount")
        
        try:
            business_obj_id = PydanticObjectId(business_id)
            supplier_obj_id = PydanticObjectId(supplier_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business or supplier ID format",
                {
                    "business_id": [f"'{business_id}' is not a valid ObjectId"],
                    "supplier_id": [f"'{supplier_id}' is not a valid ObjectId"],
                },
            )

        supplier = await SupplierService.get_supplier(supplier_id, business_id)

        user_obj_id = None
        if user_id:
            try:
                user_obj_id = PydanticObjectId(user_id)
            except (ValueError, TypeError):
                pass

        transaction = SupplierTransaction(
            business_id=business_obj_id,
            supplier_id=supplier_obj_id,
            transaction_type="payment",
            amount=amount,
            date=date,
            remarks=remarks,
            created_by_user_id=user_obj_id,
        )
        await transaction.insert()

        # Create cash transaction
        from app.services.cash import cash_service
        await cash_service.create_transaction(
            business_id=business_id,
            transaction_type="cash_out",
            amount=amount,
            date=date,
            source="supplier_payment",
            remarks=f"Payment to {supplier.name}",
            reference_id=str(transaction.id),
            reference_type="supplier_payment",
            user_id=user_id,
        )

        # Update supplier balance
        await SupplierService._update_supplier_balance(business_id, supplier_id)

        logger.info(
            "supplier_payment_recorded",
            business_id=business_id,
            supplier_id=supplier_id,
            amount=str(amount),
        )

        return transaction

    @staticmethod
    async def record_purchase(
        business_id: str,
        supplier_id: str,
        amount: Decimal,
        date: datetime,
        items: Optional[List] = None,
        remarks: Optional[str] = None,
        user_id: Optional[str] = None,
    ) -> SupplierTransaction:
        """Record supplier purchase (with optional stock integration)."""
        validate_positive_amount(amount, "purchase amount")
        
        try:
            business_obj_id = PydanticObjectId(business_id)
            supplier_obj_id = PydanticObjectId(supplier_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business or supplier ID format",
                {
                    "business_id": [f"'{business_id}' is not a valid ObjectId"],
                    "supplier_id": [f"'{supplier_id}' is not a valid ObjectId"],
                },
            )

        supplier = await SupplierService.get_supplier(supplier_id, business_id)

        user_obj_id = None
        if user_id:
            try:
                user_obj_id = PydanticObjectId(user_id)
            except (ValueError, TypeError):
                pass

        transaction = SupplierTransaction(
            business_id=business_obj_id,
            supplier_id=supplier_obj_id,
            transaction_type="purchase",
            amount=amount,
            date=date,
            remarks=remarks,
            created_by_user_id=user_obj_id,
        )
        await transaction.insert()

        # If items provided, validate and create inventory transactions
        if items:
            from app.services.stock import stock_service
            
            errors = []
            for idx, item_data in enumerate(items):
                item_id = item_data.item_id
                quantity = item_data.quantity
                unit_price = item_data.unit_price
                
                try:
                    item = await stock_service.get_item(str(item_id), business_id)
                except NotFoundError:
                    errors.append(f"Item {idx + 1}: Item with ID {item_id} not found")
                    continue
                except Exception as e:
                    errors.append(f"Item {idx + 1}: Error validating item {item_id}: {str(e)}")
                    continue
            
            if errors:
                error_message = "Purchase item validation failed:\n" + "\n".join(f"  - {err}" for err in errors)
                logger.error(
                    "supplier_purchase_validation_failed",
                    business_id=business_id,
                    supplier_id=supplier_id,
                    errors=errors,
                )
                raise BusinessLogicError(error_message)
            
            transaction_errors = []
            for idx, item_data in enumerate(items):
                item_id = item_data.item_id
                quantity = item_data.quantity
                unit_price = item_data.unit_price
                
                try:
                    await stock_service.create_inventory_transaction(
                        business_id=business_id,
                        item_id=str(item_id),
                        transaction_type="stock_in",
                        quantity=quantity,
                        date=date,
                        unit_price=unit_price,
                        reference_id=str(transaction.id),
                        reference_type="supplier_purchase",
                        remarks=f"Purchase from {supplier.name}",
                        user_id=user_id,
                    )
                except Exception as e:
                    try:
                        item = await stock_service.get_item(str(item_id), business_id)
                        item_name = item.name
                    except:
                        item_name = f"Item ID {item_id}"
                    
                    error_msg = f"Item {idx + 1} ({item_name}): {str(e)}"
                    transaction_errors.append(error_msg)
                    logger.error(
                        "supplier_purchase_stock_error",
                        item_id=item_id,
                        item_name=item_name,
                        error=str(e),
                    )
            
            if transaction_errors:
                error_message = "Failed to create inventory transactions:\n" + "\n".join(f"  - {err}" for err in transaction_errors)
                logger.error(
                    "supplier_purchase_transaction_failed",
                    business_id=business_id,
                    supplier_id=supplier_id,
                    transaction_id=str(transaction.id),
                    errors=transaction_errors,
                )
                raise BusinessLogicError(error_message)

        # Update supplier balance
        await SupplierService._update_supplier_balance(business_id, supplier_id)

        logger.info(
            "supplier_purchase_recorded",
            business_id=business_id,
            supplier_id=supplier_id,
            amount=str(amount),
            items_count=len(items) if items else 0,
        )

        return transaction

    @staticmethod
    async def _update_supplier_balance(business_id: str, supplier_id: str) -> None:
        """Update supplier balance."""
        try:
            business_obj_id = PydanticObjectId(business_id)
            supplier_obj_id = PydanticObjectId(supplier_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business or supplier ID format",
                {
                    "business_id": [f"'{business_id}' is not a valid ObjectId"],
                    "supplier_id": [f"'{supplier_id}' is not a valid ObjectId"],
                },
            )

        # Calculate balance from transactions
        purchase_transactions = await SupplierTransaction.find(
            SupplierTransaction.business_id == business_obj_id,
            SupplierTransaction.supplier_id == supplier_obj_id,
            SupplierTransaction.transaction_type == "purchase",
        ).to_list()
        total_purchase = sum(t.amount for t in purchase_transactions) or Decimal("0.00")

        payment_transactions = await SupplierTransaction.find(
            SupplierTransaction.business_id == business_obj_id,
            SupplierTransaction.supplier_id == supplier_obj_id,
            SupplierTransaction.transaction_type == "payment",
        ).to_list()
        total_payment = sum(t.amount for t in payment_transactions) or Decimal("0.00")

        balance = total_purchase - total_payment  # Positive = payable

        # Get last transaction date
        all_transactions = await SupplierTransaction.find(
            SupplierTransaction.business_id == business_obj_id,
            SupplierTransaction.supplier_id == supplier_obj_id,
        ).sort("-date").limit(1).to_list()
        
        last_transaction_date = all_transactions[0].date if all_transactions else datetime.now(timezone.utc)

        # Update or create balance
        supplier_balance = await SupplierBalance.find_one(
            SupplierBalance.business_id == business_obj_id,
            SupplierBalance.supplier_id == supplier_obj_id,
        )

        if supplier_balance:
            supplier_balance.balance = balance
            supplier_balance.last_transaction_date = last_transaction_date
            await supplier_balance.save()
        else:
            supplier_balance = SupplierBalance(
                business_id=business_obj_id,
                supplier_id=supplier_obj_id,
                balance=balance,
                last_transaction_date=last_transaction_date,
            )
            await supplier_balance.insert()


# Singleton instance
supplier_service = SupplierService()
