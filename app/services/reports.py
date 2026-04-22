"""Reports service."""
from datetime import datetime, timedelta
from typing import Optional
from decimal import Decimal
from collections import defaultdict
from beanie import PydanticObjectId
from beanie.operators import In

from app.models.invoice import Invoice, InvoiceType, InvoiceItem
from app.models.expense import Expense
from app.models.cash import CashTransaction, CashTransactionType
from app.models.customer import Customer
from app.models.item import Item, InventoryTransaction, InventoryTransactionType, LowStockAlert
from app.core.logging import get_logger
from app.core.exceptions import ValidationError

logger = get_logger(__name__)


class ReportsService:
    """Reports and analytics service."""

    @staticmethod
    async def get_sales_report(
        business_id: str,
        start_date: datetime,
        end_date: datetime,
    ) -> dict:
        """Get sales report."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        # Get invoices
        invoices = await Invoice.find(
            Invoice.business_id == business_obj_id,
            Invoice.date >= start_date,
            Invoice.date <= end_date,
        ).to_list()

        customer_map: dict[str, str] = {}
        customer_ids = {
            invoice.customer_id for invoice in invoices if invoice.customer_id is not None
        }
        if customer_ids:
            customers = await Customer.find(
                Customer.business_id == business_obj_id,
                In(Customer.id, list(customer_ids)),
            ).to_list()
            customer_map = {str(customer.id): customer.name for customer in customers}

        # Load items for each invoice - store in a separate dict to avoid model field issues
        invoice_items_map = {}
        invoice_ids = [invoice.id for invoice in invoices]
        if invoice_ids:
            try:
                all_items = await InvoiceItem.find(In(InvoiceItem.invoice_id, invoice_ids)).to_list()
                for item in all_items:
                    if item.invoice_id not in invoice_items_map:
                        invoice_items_map[item.invoice_id] = []
                    invoice_items_map[item.invoice_id].append(item)
            except Exception as e:
                logger.error("sales_report_items_error", business_id=business_id, error=str(e), exc_info=True)
                # Continue with empty items_map if there's an error

        total_sales = sum(inv.total_amount for inv in invoices) or Decimal("0.00")
        cash_sales = sum(inv.total_amount for inv in invoices if inv.invoice_type == InvoiceType.CASH) or Decimal("0.00")
        credit_sales = sum(inv.total_amount for inv in invoices if inv.invoice_type == InvoiceType.CREDIT) or Decimal("0.00")

        # Calculate profit (sale price - purchase price)
        # First, collect all unique item IDs
        item_ids = set()
        for invoice_id, items in invoice_items_map.items():
            for item in items:
                if item.item_id:
                    item_ids.add(item.item_id)
        
        # Batch load all items at once to avoid N+1 queries
        items_map = {}
        if item_ids:
            try:
                items = await Item.find(In(Item.id, list(item_ids))).to_list()
                items_map = {item.id: item for item in items}
            except Exception as e:
                logger.error("sales_report_item_lookup_error", business_id=business_id, error=str(e), exc_info=True)
                # Continue with empty items_map if there's an error
        
        # Calculate profit using the pre-loaded items
        total_profit = Decimal("0.00")
        for invoice_id, items in invoice_items_map.items():
            for item in items:
                if item.item_id and item.item_id in items_map:
                    try:
                        item_obj = items_map[item.item_id]
                        # Handle None purchase_price (shouldn't happen but safety check)
                        purchase_price = item_obj.purchase_price if item_obj.purchase_price is not None else Decimal("0.00")
                        profit_per_unit = item.unit_price - purchase_price
                        total_profit += profit_per_unit * item.quantity
                    except Exception as e:
                        logger.warning("sales_report_profit_calc_error", item_id=str(item.item_id), error=str(e))
                        # Continue with next item if calculation fails

        # Group invoices by date for breakdowns
        from collections import defaultdict
        daily_sales = defaultdict(lambda: {"total": Decimal("0.00"), "cash": Decimal("0.00"), "credit": Decimal("0.00"), "count": 0})
        weekly_sales = defaultdict(lambda: {"total": Decimal("0.00"), "cash": Decimal("0.00"), "credit": Decimal("0.00"), "count": 0})
        monthly_sales = defaultdict(lambda: {"total": Decimal("0.00"), "cash": Decimal("0.00"), "credit": Decimal("0.00"), "count": 0})
        
        for invoice in invoices:
            invoice_date = invoice.date.date()
            day_key = invoice_date.isoformat()
            week_start = invoice_date - timedelta(days=invoice_date.weekday())
            week_key = week_start.isoformat()
            month_key = invoice_date.strftime("%Y-%m")
            
            amount = invoice.total_amount
            is_cash = invoice.invoice_type == InvoiceType.CASH
            
            daily_sales[day_key]["total"] += amount
            daily_sales[day_key]["cash" if is_cash else "credit"] += amount
            daily_sales[day_key]["count"] += 1
            
            weekly_sales[week_key]["total"] += amount
            weekly_sales[week_key]["cash" if is_cash else "credit"] += amount
            weekly_sales[week_key]["count"] += 1
            
            monthly_sales[month_key]["total"] += amount
            monthly_sales[month_key]["cash" if is_cash else "credit"] += amount
            monthly_sales[month_key]["count"] += 1
        
        # Convert to lists for frontend
        daily_breakdown = [
            {
                "date": date_key,
                "total": str(data["total"]),
                "cash": str(data["cash"]),
                "credit": str(data["credit"]),
                "count": data["count"],
            }
            for date_key, data in sorted(daily_sales.items())
        ]
        
        weekly_breakdown = [
            {
                "week_start": week_key,
                "total": str(data["total"]),
                "cash": str(data["cash"]),
                "credit": str(data["credit"]),
                "count": data["count"],
            }
            for week_key, data in sorted(weekly_sales.items())
        ]
        
        monthly_breakdown = [
            {
                "month": f"{month_key}-01",
                "total": str(data["total"]),
                "cash": str(data["cash"]),
                "credit": str(data["credit"]),
                "count": data["count"],
            }
            for month_key, data in sorted(monthly_sales.items())
        ]

        invoice_reference_rows = sorted(
            [
                {
                    "reference_type": "invoice",
                    "reference_id": str(invoice.id),
                    "invoice_number": invoice.invoice_number,
                    "invoice_date": invoice.date.isoformat(),
                    "customer_name": (
                        customer_map.get(str(invoice.customer_id), "Unknown Customer")
                        if invoice.customer_id
                        else "Walk-in Customer"
                    ),
                    "invoice_type": invoice.invoice_type.value,
                    "invoice_total": str(invoice.total_amount),
                    "invoice_status": (
                        "paid"
                        if invoice.invoice_type == InvoiceType.CASH
                        else (
                            "paid"
                            if invoice.paid_amount >= invoice.total_amount
                            else (
                                "partially_paid"
                                if invoice.paid_amount > 0
                                else "unpaid"
                            )
                        )
                    ),
                }
                for invoice in invoices
            ],
            key=lambda row: row["invoice_date"],
            reverse=True,
        )

        return {
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "total_sales": str(total_sales),
            "cash_sales": str(cash_sales),
            "credit_sales": str(credit_sales),
            "total_profit": str(total_profit),
            "total_invoices": len(invoices),
            "invoice_count": len(invoices),  # Keep for backward compatibility
            "daily_breakdown": daily_breakdown,
            "weekly_breakdown": weekly_breakdown,
            "monthly_breakdown": monthly_breakdown,
            "invoice_reference_rows": invoice_reference_rows,
            "reference_rows": invoice_reference_rows,
        }

    @staticmethod
    async def get_cash_flow_report(
        business_id: str,
        start_date: datetime,
        end_date: datetime,
    ) -> dict:
        """Get cash flow report."""
        from app.services.cash import cash_service
        from app.models.cash import CashTransaction, CashTransactionType
        
        summary = await cash_service.get_summary(business_id, start_date, end_date)
        
        # Get transactions for the list
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )
        
        transactions_list = await CashTransaction.find(
            CashTransaction.business_id == business_obj_id,
            CashTransaction.date >= start_date,
            CashTransaction.date <= end_date,
        ).sort("+date").to_list()
        
        # Format transactions for frontend
        transactions = [
            {
                "id": str(txn.id),
                "date": txn.date.isoformat(),
                "amount": str(txn.amount if txn.transaction_type == CashTransactionType.CASH_IN else -txn.amount),
                "type": "inflow" if txn.transaction_type == CashTransactionType.CASH_IN else "outflow",
                "description": txn.remarks or txn.source or "Cash Transaction",
            }
            for txn in transactions_list
        ]

        reference_rows = [
            {
                "reference_type": txn.reference_type or "cash_transaction",
                "reference_id": str(txn.reference_id) if txn.reference_id else str(txn.id),
                "date": txn.date.isoformat(),
                "amount": str(
                    txn.amount if txn.transaction_type == CashTransactionType.CASH_IN else -txn.amount
                ),
                "direction": "inflow" if txn.transaction_type == CashTransactionType.CASH_IN else "outflow",
                "description": txn.remarks or txn.source or "Cash Transaction",
            }
            for txn in transactions_list
        ]

        return {
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "opening_balance": str(summary["opening_balance"]),
            "closing_balance": str(summary["closing_balance"]),
            "total_inflow": str(summary["total_cash_in"]),
            "total_outflow": str(summary["total_cash_out"]),
            "total_cash_in": str(summary["total_cash_in"]),  # Keep for backward compatibility
            "total_cash_out": str(summary["total_cash_out"]),  # Keep for backward compatibility
            "transactions": transactions,
            "reference_rows": reference_rows,
        }

    @staticmethod
    async def get_expense_report(
        business_id: str,
        start_date: datetime,
        end_date: datetime,
    ) -> dict:
        """Get expense report."""
        from app.services.expense import expense_service
        from app.models.expense import Expense, PaymentMode
        
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )
        
        # Get all expenses in range
        expenses = await Expense.find(
            Expense.business_id == business_obj_id,
            Expense.date >= start_date,
            Expense.date <= end_date,
        ).to_list()
        
        total_expenses = sum(e.amount for e in expenses) or Decimal("0.00")
        cash_expenses = sum(e.amount for e in expenses if e.payment_mode == PaymentMode.CASH) or Decimal("0.00")
        bank_expenses = sum(e.amount for e in expenses if e.payment_mode == PaymentMode.BANK) or Decimal("0.00")
        
        # Group by category
        category_ids = {e.category_id for e in expenses if e.category_id}
        category_map = {}
        if category_ids:
            from app.models.expense import ExpenseCategory
            categories = await ExpenseCategory.find(
                In(ExpenseCategory.id, list(category_ids))
            ).to_list()
            category_map = {c.id: c.name for c in categories}
        
        by_category = defaultdict(lambda: Decimal("0.00"))
        for expense in expenses:
            if expense.category_id:
                category_name = category_map.get(expense.category_id, "Unknown")
                by_category[category_name] += expense.amount
        
        # Convert to list format for frontend
        category_breakdown = [
            {
                "category_name": name,
                "amount": str(amount),
            }
            for name, amount in sorted(by_category.items(), key=lambda x: x[1], reverse=True)
        ]
        
        # Group by date for daily breakdown
        daily_expenses = defaultdict(lambda: Decimal("0.00"))
        for expense in expenses:
            day_key = expense.date.date().isoformat()
            daily_expenses[day_key] += expense.amount
        
        daily_breakdown = [
            {
                "date": date_key,
                "amount": str(amount),
            }
            for date_key, amount in sorted(daily_expenses.items())
        ]

        reference_rows = sorted(
            [
                {
                    "reference_type": "expense",
                    "reference_id": str(expense.id),
                    "date": expense.date.isoformat(),
                    "amount": str(expense.amount),
                    "payment_mode": expense.payment_mode.value,
                    "category": category_map.get(expense.category_id, "Uncategorized")
                    if expense.category_id
                    else "Uncategorized",
                    "description": expense.description or "Expense",
                }
                for expense in expenses
            ],
            key=lambda row: row["date"],
            reverse=True,
        )

        return {
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "total_expenses": str(total_expenses),
            "cash_expenses": str(cash_expenses),
            "bank_expenses": str(bank_expenses),
            "total_count": len(expenses),
            "category_breakdown": category_breakdown,
            "daily_breakdown": daily_breakdown,
            "by_category": {k: str(v) for k, v in by_category.items()},  # Keep for backward compatibility
            "reference_rows": reference_rows,
        }

    @staticmethod
    async def get_stock_report(
        business_id: str,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
    ) -> dict:
        """Get stock report."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        # Default to current month if no explicit date window provided.
        if end_date is None:
            end_date = datetime.now()
        if start_date is None:
            start_date = end_date.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        if start_date > end_date:
            raise ValidationError(
                "Invalid date range",
                {"start_date": ["start_date cannot be after end_date"]},
            )

        items = await Item.find(
            Item.business_id == business_obj_id,
            Item.is_active == True,
        ).to_list()

        total_items = len(items)
        if total_items == 0:
            return {
                "start_date": start_date.isoformat(),
                "end_date": end_date.isoformat(),
                "days_in_range": 0,
                "total_items": 0,
                "total_value": "0.00",  # Backward compatibility
                "total_stock_value": "0.00",
                "total_sold_qty": "0.00",
                "total_sold_value": "0.00",
                "total_estimated_margin": "0.00",
                "out_of_stock_items": 0,
                "low_stock_items": 0,
                "dead_stock_items_count": 0,
                "fast_moving_items": [],
                "dead_stock_items": [],
                "items": [],
                "entries": 0,
                "total_qty": "0.00",
                "total_amount": "0.00",
                "in_summary": {"entries": 0, "qty": "0.00", "amount": "0.00"},
                "out_summary": {"entries": 0, "qty": "0.00", "amount": "0.00"},
                "movement_summary": {
                    "all": {"entries": 0, "qty": "0.00", "amount": "0.00"},
                    "in": {"entries": 0, "qty": "0.00", "amount": "0.00"},
                    "out": {"entries": 0, "qty": "0.00", "amount": "0.00"},
                },
                "movement_entries": [],
                "period_summary": {
                    "start_date": start_date.isoformat(),
                    "end_date": end_date.isoformat(),
                    "days_in_range": 0,
                    "sold_entries": 0,
                    "sold_qty": "0.00",
                    "sold_value": "0.00",
                    "outgoing_entries": 0,
                    "outgoing_qty": "0.00",
                    "outgoing_value": "0.00",
                    "left_qty": "0.00",
                    "left_value": "0.00",
                },
                "sold_items": [],
                "sold_items_customer_breakdown": [],
                "remaining_stock_snapshot": [],
                "invoice_reference_rows": [],
                "reference_rows": [],
                "profit_loss_summary": {
                    "sales_revenue": "0.00",
                    "cogs": "0.00",
                    "gross_profit": "0.00",
                    "gross_margin_percent": "0.00",
                },
            }

        item_ids = [item.id for item in items if item.id is not None]
        transactions = []
        item_txn_map = defaultdict(list)
        if item_ids:
            transactions = await InventoryTransaction.find(
                InventoryTransaction.business_id == business_obj_id,
                In(InventoryTransaction.item_id, item_ids),
                InventoryTransaction.date <= end_date,
            ).sort("+date").to_list()
            for txn in transactions:
                item_txn_map[str(txn.item_id)].append(txn)

        low_stock_map = {}
        if item_ids:
            low_stock_alerts = await LowStockAlert.find(
                LowStockAlert.business_id == business_obj_id,
                LowStockAlert.is_resolved == False,
                In(LowStockAlert.item_id, item_ids),
            ).to_list()
            low_stock_map = {str(alert.item_id): alert for alert in low_stock_alerts}

        invoice_sale_price_by_invoice_and_item: dict[tuple[str, str], Decimal] = {}
        invoice_lookup: dict[str, Invoice] = {}
        customer_name_by_id: dict[str, str] = {}
        if transactions:
            invoice_reference_ids = {
                txn.reference_id
                for txn in transactions
                if txn.reference_type == "invoice" and txn.reference_id is not None
            }
            if invoice_reference_ids:
                invoices = await Invoice.find(
                    Invoice.business_id == business_obj_id,
                    In(Invoice.id, list(invoice_reference_ids)),
                ).to_list()
                invoice_lookup = {str(invoice.id): invoice for invoice in invoices}

                customer_ids = {
                    invoice.customer_id
                    for invoice in invoices
                    if invoice.customer_id is not None
                }
                if customer_ids:
                    customers = await Customer.find(
                        Customer.business_id == business_obj_id,
                        In(Customer.id, list(customer_ids)),
                    ).to_list()
                    customer_name_by_id = {
                        str(customer.id): customer.name for customer in customers
                    }

                invoice_items = await InvoiceItem.find(
                    In(InvoiceItem.invoice_id, list(invoice_reference_ids)),
                    In(InvoiceItem.item_id, item_ids),
                ).to_list()
                invoice_item_price_accumulator = defaultdict(
                    lambda: {"qty": Decimal("0.000"), "value": Decimal("0.00")}
                )
                for invoice_item in invoice_items:
                    if invoice_item.item_id is None:
                        continue
                    key = (str(invoice_item.invoice_id), str(invoice_item.item_id))
                    invoice_item_price_accumulator[key]["qty"] += invoice_item.quantity
                    invoice_item_price_accumulator[key]["value"] += invoice_item.total_price
                for key, totals in invoice_item_price_accumulator.items():
                    if totals["qty"] > 0:
                        invoice_sale_price_by_invoice_and_item[key] = (
                            totals["value"] / totals["qty"]
                        )

        days_in_range = max(1, (end_date.date() - start_date.date()).days + 1)
        total_stock_value = Decimal("0.00")
        total_sold_qty = Decimal("0.00")
        total_sold_value = Decimal("0.00")
        total_estimated_margin = Decimal("0.00")
        total_cogs = Decimal("0.00")
        total_left_qty = Decimal("0.00")
        sold_entries_count = 0

        out_of_stock_count = 0
        low_stock_count = 0
        dead_stock_count = 0
        fast_moving_candidates = []
        dead_stock_items = []
        sold_items_payload = []
        items_payload = []
        movement_entries = []
        sold_item_customer_rollup: dict[str, dict[str, dict]] = defaultdict(dict)
        invoice_reference_rollup: dict[str, dict] = {}
        movement_summary = {
            "all": {"entries": 0, "qty": Decimal("0.000"), "amount": Decimal("0.00")},
            "in": {"entries": 0, "qty": Decimal("0.000"), "amount": Decimal("0.00")},
            "out": {"entries": 0, "qty": Decimal("0.000"), "amount": Decimal("0.00")},
        }

        def _decimal_to_string(value: Decimal, precision: int = 2) -> str:
            return f"{value:.{precision}f}"

        def _apply_inventory_movement(running_stock: Decimal, txn: InventoryTransaction) -> Decimal:
            if txn.transaction_type == InventoryTransactionType.STOCK_IN:
                return running_stock + txn.quantity
            if txn.transaction_type == InventoryTransactionType.STOCK_OUT:
                return running_stock - txn.quantity
            if txn.transaction_type == InventoryTransactionType.WASTAGE:
                return running_stock - txn.quantity
            if txn.transaction_type == InventoryTransactionType.ADJUSTMENT:
                return txn.quantity
            return running_stock

        for item in items:
            item_id_str = str(item.id)
            running_stock = item.opening_stock or Decimal("0.000")
            purchased_qty = Decimal("0.000")
            sold_qty = Decimal("0.000")
            stock_out_qty = Decimal("0.000")
            wastage_qty = Decimal("0.000")
            adjustment_events = 0
            sold_value = Decimal("0.00")
            estimated_margin = Decimal("0.00")
            item_transactions = item_txn_map.get(item_id_str, [])

            # Rebuild stock level at the start of the selected window.
            for txn in item_transactions:
                if txn.date < start_date:
                    running_stock = _apply_inventory_movement(running_stock, txn)
                    continue
                if txn.date > end_date:
                    continue

            opening_stock = running_stock

            # Apply only movements inside selected window and aggregate analytics.
            for txn in item_transactions:
                if txn.date < start_date or txn.date > end_date:
                    continue
                stock_before_txn = running_stock
                movement_direction = None
                movement_qty = txn.quantity
                txn_unit_price = txn.unit_price if txn.unit_price is not None else Decimal("0.00")
                effective_unit_price = txn_unit_price

                if txn.transaction_type == InventoryTransactionType.STOCK_IN:
                    purchased_qty += txn.quantity
                    movement_direction = "in"
                    if effective_unit_price <= 0:
                        effective_unit_price = item.purchase_price
                elif txn.transaction_type == InventoryTransactionType.STOCK_OUT:
                    stock_out_qty += txn.quantity
                    movement_direction = "out"
                    if effective_unit_price <= 0:
                        effective_unit_price = item.sale_price
                    if txn.reference_type == "invoice":
                        invoice_id_str = str(txn.reference_id) if txn.reference_id else None
                        invoice_rate = None
                        if txn.reference_id is not None:
                            invoice_rate = invoice_sale_price_by_invoice_and_item.get(
                                (str(txn.reference_id), item_id_str)
                            )
                        if invoice_rate is not None and invoice_rate > 0:
                            effective_unit_price = invoice_rate
                        sold_qty += txn.quantity
                        sold_entries_count += 1
                        sold_value += txn.quantity * effective_unit_price
                        total_cogs += txn.quantity * item.purchase_price
                        estimated_margin += txn.quantity * (
                            effective_unit_price - item.purchase_price
                        )
                        if invoice_id_str is not None:
                            invoice = invoice_lookup.get(invoice_id_str)
                            customer_name = "Unknown Customer"
                            if invoice is not None and invoice.customer_id is not None:
                                customer_name = customer_name_by_id.get(
                                    str(invoice.customer_id), "Unknown Customer"
                                )

                            customer_entry = sold_item_customer_rollup[item_id_str].get(
                                customer_name
                            )
                            if customer_entry is None:
                                customer_entry = {
                                    "customer_name": customer_name,
                                    "qty": Decimal("0.000"),
                                    "amount": Decimal("0.00"),
                                    "invoice_ids": set(),
                                    "last_sale_at": None,
                                }
                                sold_item_customer_rollup[item_id_str][customer_name] = customer_entry

                            customer_entry["qty"] += txn.quantity
                            customer_entry["amount"] += txn.quantity * effective_unit_price
                            customer_entry["invoice_ids"].add(invoice_id_str)
                            current_last_sale = customer_entry["last_sale_at"]
                            if current_last_sale is None or txn.date > current_last_sale:
                                customer_entry["last_sale_at"] = txn.date

                            invoice_rollup = invoice_reference_rollup.get(invoice_id_str)
                            if invoice_rollup is None:
                                invoice_number = (
                                    invoice.invoice_number
                                    if invoice is not None
                                    else f"INV-{invoice_id_str[:8].upper()}"
                                )
                                invoice_rollup = {
                                    "reference_type": "invoice",
                                    "reference_id": invoice_id_str,
                                    "invoice_number": invoice_number,
                                    "invoice_date": (
                                        invoice.date.isoformat()
                                        if invoice is not None
                                        else txn.date.isoformat()
                                    ),
                                    "customer_name": customer_name,
                                    "sold_qty": Decimal("0.000"),
                                    "sold_amount": Decimal("0.00"),
                                    "invoice_count": 1,
                                    "status": (
                                        "paid"
                                        if invoice is not None and invoice.invoice_type == InvoiceType.CASH
                                        else (
                                            "paid"
                                            if invoice is not None and invoice.paid_amount >= invoice.total_amount
                                            else (
                                                "partially_paid"
                                                if invoice is not None and invoice.paid_amount > 0
                                                else "unpaid"
                                            )
                                        )
                                    ),
                                    "last_sale_at": txn.date,
                                }
                                invoice_reference_rollup[invoice_id_str] = invoice_rollup

                            invoice_rollup["sold_qty"] += txn.quantity
                            invoice_rollup["sold_amount"] += txn.quantity * effective_unit_price
                            if txn.date > invoice_rollup["last_sale_at"]:
                                invoice_rollup["last_sale_at"] = txn.date
                elif txn.transaction_type == InventoryTransactionType.WASTAGE:
                    wastage_qty += txn.quantity
                    movement_direction = "out"
                    if effective_unit_price <= 0:
                        effective_unit_price = item.purchase_price
                elif txn.transaction_type == InventoryTransactionType.ADJUSTMENT:
                    adjustment_events += 1
                    delta = txn.quantity - stock_before_txn
                    if delta > 0:
                        movement_direction = "in"
                        movement_qty = delta
                    elif delta < 0:
                        movement_direction = "out"
                        movement_qty = abs(delta)
                    else:
                        movement_direction = None
                        movement_qty = Decimal("0.000")
                    if effective_unit_price <= 0:
                        effective_unit_price = item.purchase_price

                if movement_direction is not None and movement_qty > 0:
                    movement_amount = movement_qty * effective_unit_price
                    movement_summary[movement_direction]["entries"] += 1
                    movement_summary[movement_direction]["qty"] += movement_qty
                    movement_summary[movement_direction]["amount"] += movement_amount
                    movement_summary["all"]["entries"] += 1
                    movement_summary["all"]["qty"] += movement_qty
                    movement_summary["all"]["amount"] += movement_amount
                    movement_entries.append(
                        {
                            "item_id": item_id_str,
                            "name": item.name,
                            "unit": item.unit.value,
                            "direction": movement_direction,
                            "transaction_type": (
                                txn.transaction_type.value
                                if hasattr(txn.transaction_type, "value")
                                else str(txn.transaction_type)
                            ),
                            "quantity": str(movement_qty),
                            "rate": str(effective_unit_price),
                            "amount": str(movement_amount),
                            "date": txn.date.isoformat(),
                            "reference_type": txn.reference_type,
                            "reference_id": str(txn.reference_id) if txn.reference_id else None,
                            "remarks": txn.remarks,
                        }
                    )

                running_stock = _apply_inventory_movement(running_stock, txn)
            closing_stock = running_stock
            stock_value = closing_stock * item.purchase_price
            sales_velocity_per_day = sold_qty / Decimal(str(days_in_range))
            days_of_stock_left = None
            if sales_velocity_per_day > 0 and closing_stock > 0:
                days_of_stock_left = closing_stock / sales_velocity_per_day
            if closing_stock > 0:
                total_left_qty += closing_stock

            total_stock_value += stock_value
            total_sold_qty += sold_qty
            total_sold_value += sold_value
            total_estimated_margin += estimated_margin

            is_out_of_stock = closing_stock <= 0
            if is_out_of_stock:
                out_of_stock_count += 1

            alert = low_stock_map.get(item_id_str)
            low_stock_threshold = alert.threshold if alert else None
            is_low_stock = bool(
                low_stock_threshold is not None
                and closing_stock <= low_stock_threshold
                and closing_stock > 0
            )
            if is_low_stock:
                low_stock_count += 1

            is_dead_stock = sold_qty <= 0 and closing_stock > 0
            if is_dead_stock:
                dead_stock_count += 1
                dead_stock_items.append(
                    {
                        "id": item_id_str,
                        "name": item.name,
                        "closing_stock": str(closing_stock),
                        "stock_value": str(stock_value),
                        "unit": item.unit.value,
                    }
                )

            if sold_qty > 0:
                fast_moving_candidates.append(
                    {
                        "id": item_id_str,
                        "name": item.name,
                        "sold_qty": str(sold_qty),
                        "sold_value": str(sold_value),
                        "unit": item.unit.value,
                    }
                )
                average_sale_rate = sold_value / sold_qty if sold_qty > 0 else Decimal("0.00")
                sold_items_payload.append(
                    {
                        "item_id": item_id_str,
                        "item_name": item.name,
                        "unit": item.unit.value,
                        "sold_qty": str(sold_qty),
                        "sold_amount": str(sold_value),
                        "avg_sale_rate": str(average_sale_rate),
                        "left_qty": str(closing_stock),
                        "left_value": str(stock_value),
                        "gross_profit": str(estimated_margin),
                    }
                )

            items_payload.append(
                {
                    "id": item_id_str,
                    "name": item.name,
                    "unit": item.unit.value,
                    "purchase_price": str(item.purchase_price),
                    "sale_price": str(item.sale_price),
                    "opening_stock": str(opening_stock),
                    "purchased_qty": str(purchased_qty),
                    "sold_qty": str(sold_qty),
                    "stock_out_qty": str(stock_out_qty),
                    "wastage_qty": str(wastage_qty),
                    "adjustment_events": adjustment_events,
                    "closing_stock": str(closing_stock),
                    "current_stock": str(closing_stock),  # Backward compatibility
                    "stock_value": str(stock_value),
                    "value": str(stock_value),  # Backward compatibility
                    "sold_value": str(sold_value),
                    "estimated_margin": str(estimated_margin),
                    "sales_velocity_per_day": str(sales_velocity_per_day),
                    "days_of_stock_left": str(days_of_stock_left) if days_of_stock_left is not None else None,
                    "is_out_of_stock": is_out_of_stock,
                    "is_low_stock": is_low_stock,
                    "is_dead_stock": is_dead_stock,
                    "low_stock_threshold": str(low_stock_threshold) if low_stock_threshold is not None else None,
                }
            )

        fast_moving_items = sorted(
            fast_moving_candidates,
            key=lambda item_data: Decimal(item_data["sold_qty"]),
            reverse=True,
        )[:10]
        dead_stock_items = sorted(
            dead_stock_items,
            key=lambda item_data: Decimal(item_data["stock_value"]),
            reverse=True,
        )[:20]
        items_payload = sorted(
            items_payload,
            key=lambda item_data: Decimal(item_data["stock_value"]),
            reverse=True,
        )
        movement_entries = sorted(
            movement_entries,
            key=lambda entry: entry["date"],
            reverse=True,
        )
        movement_summary_payload = {
            key: {
                "entries": value["entries"],
                "qty": str(value["qty"]),
                "amount": str(value["amount"]),
            }
            for key, value in movement_summary.items()
        }
        sold_items_payload = sorted(
            sold_items_payload,
            key=lambda item_data: Decimal(item_data["sold_amount"]),
            reverse=True,
        )
        remaining_stock_snapshot = [
            {
                "item_name": item_data["name"],
                "unit": item_data["unit"],
                "left_qty": item_data["closing_stock"],
                "left_value": item_data["stock_value"],
            }
            for item_data in sorted(
                items_payload,
                key=lambda item_data: Decimal(item_data["stock_value"]),
                reverse=True,
            )
            if Decimal(item_data["closing_stock"]) > 0
        ]

        sold_items_customer_breakdown = []
        top_customers_limit = 10
        inline_customers_limit = 3
        sold_item_lookup = {item["item_id"]: item for item in sold_items_payload}
        for sold_item in sold_items_payload:
            item_id = sold_item["item_id"]
            customer_entries_raw = list(sold_item_customer_rollup.get(item_id, {}).values())
            customer_entries_sorted = sorted(
                customer_entries_raw,
                key=lambda entry: entry["amount"],
                reverse=True,
            )

            top_customers_raw = customer_entries_sorted[:top_customers_limit]
            overflow_customers = customer_entries_sorted[top_customers_limit:]
            if overflow_customers:
                others_qty = sum(
                    (entry["qty"] for entry in overflow_customers),
                    Decimal("0.000"),
                )
                others_amount = sum(
                    (entry["amount"] for entry in overflow_customers),
                    Decimal("0.00"),
                )
                others_invoice_count = len(
                    {
                        invoice_id
                        for entry in overflow_customers
                        for invoice_id in entry["invoice_ids"]
                    }
                )
                others_last_sale_at = None
                for entry in overflow_customers:
                    last_sale_at = entry["last_sale_at"]
                    if last_sale_at is not None and (
                        others_last_sale_at is None or last_sale_at > others_last_sale_at
                    ):
                        others_last_sale_at = last_sale_at

                top_customers_raw.append(
                    {
                        "customer_name": "Others",
                        "qty": others_qty,
                        "amount": others_amount,
                        "invoice_ids": set(),
                        "invoice_count": others_invoice_count,
                        "last_sale_at": others_last_sale_at,
                    }
                )

            customers_payload = []
            for entry in top_customers_raw:
                invoice_count = entry.get("invoice_count")
                if invoice_count is None:
                    invoice_count = len(entry["invoice_ids"])
                customers_payload.append(
                    {
                        "customer_name": entry["customer_name"],
                        "qty": _decimal_to_string(entry["qty"], 3),
                        "amount": _decimal_to_string(entry["amount"], 2),
                        "invoice_count": invoice_count,
                        "last_sale_at": (
                            entry["last_sale_at"].isoformat()
                            if entry["last_sale_at"] is not None
                            else None
                        ),
                    }
                )

            sold_item["top_customers"] = customers_payload[:inline_customers_limit]
            sold_items_customer_breakdown.append(
                {
                    "item_id": item_id,
                    "item_name": sold_item["item_name"],
                    "unit": sold_item["unit"],
                    "customers": customers_payload,
                }
            )

        sold_items_customer_breakdown = sorted(
            sold_items_customer_breakdown,
            key=lambda entry: Decimal(sold_item_lookup[entry["item_id"]]["sold_amount"]),
            reverse=True,
        )

        invoice_reference_rows = sorted(
            [
                {
                    "reference_type": row["reference_type"],
                    "reference_id": row["reference_id"],
                    "invoice_number": row["invoice_number"],
                    "invoice_date": row["invoice_date"],
                    "customer_name": row["customer_name"],
                    "sold_qty": _decimal_to_string(row["sold_qty"], 3),
                    "sold_amount": _decimal_to_string(row["sold_amount"], 2),
                    "status": row["status"],
                    "last_sale_at": row["last_sale_at"].isoformat(),
                }
                for row in invoice_reference_rollup.values()
            ],
            key=lambda row: row["invoice_date"],
            reverse=True,
        )

        gross_profit = total_sold_value - total_cogs
        gross_margin_percent = Decimal("0.00")
        if total_sold_value > 0:
            gross_margin_percent = (gross_profit / total_sold_value) * Decimal("100")

        period_summary = {
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "days_in_range": days_in_range,
            "sold_entries": sold_entries_count,
            "sold_qty": _decimal_to_string(total_sold_qty, 3),
            "sold_value": _decimal_to_string(total_sold_value, 2),
            "outgoing_entries": movement_summary["out"]["entries"],
            "outgoing_qty": _decimal_to_string(movement_summary["out"]["qty"], 3),
            "outgoing_value": _decimal_to_string(movement_summary["out"]["amount"], 2),
            "left_qty": _decimal_to_string(total_left_qty, 3),
            "left_value": _decimal_to_string(total_stock_value, 2),
        }

        profit_loss_summary = {
            "sales_revenue": _decimal_to_string(total_sold_value, 2),
            "cogs": _decimal_to_string(total_cogs, 2),
            "gross_profit": _decimal_to_string(gross_profit, 2),
            "gross_margin_percent": _decimal_to_string(gross_margin_percent, 2),
        }

        return {
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "days_in_range": days_in_range,
            "total_items": total_items,
            "total_value": str(total_stock_value),  # Backward compatibility
            "total_stock_value": str(total_stock_value),
            "total_sold_qty": str(total_sold_qty),
            "total_sold_value": str(total_sold_value),
            "total_estimated_margin": str(total_estimated_margin),
            "out_of_stock_items": out_of_stock_count,
            "low_stock_items": low_stock_count,
            "dead_stock_items_count": dead_stock_count,
            "fast_moving_items": fast_moving_items,
            "dead_stock_items": dead_stock_items,
            "items": items_payload,
            "entries": movement_summary_payload["all"]["entries"],
            "total_qty": movement_summary_payload["all"]["qty"],
            "total_amount": movement_summary_payload["all"]["amount"],
            "in_summary": movement_summary_payload["in"],
            "out_summary": movement_summary_payload["out"],
            "movement_summary": movement_summary_payload,
            "movement_entries": movement_entries,
            "period_summary": period_summary,
            "sold_items": sold_items_payload,
            "sold_items_customer_breakdown": sold_items_customer_breakdown,
            "remaining_stock_snapshot": remaining_stock_snapshot,
            "invoice_reference_rows": invoice_reference_rows,
            "reference_rows": invoice_reference_rows,
            "profit_loss_summary": profit_loss_summary,
        }

    @staticmethod
    async def get_profit_loss(
        business_id: str,
        start_date: datetime,
        end_date: datetime,
    ) -> dict:
        """Get profit & loss summary."""
        try:
            # Get sales
            sales_report = await ReportsService.get_sales_report(business_id, start_date, end_date)
        except Exception as e:
            logger.error("profit_loss_sales_error", business_id=business_id, error=str(e), exc_info=True)
            sales_report = {
                "total_sales": "0.00",
                "total_profit": "0.00",
                "cash_sales": "0.00",
                "credit_sales": "0.00",
            }

        try:
            # Get expenses
            expense_report = await ReportsService.get_expense_report(business_id, start_date, end_date)
        except Exception as e:
            logger.error("profit_loss_expense_error", business_id=business_id, error=str(e), exc_info=True)
            expense_report = {
                "total_expenses": "0.00",
                "cash_expenses": "0.00",
                "bank_expenses": "0.00",
                "by_category": {},
            }

        total_revenue = Decimal(str(sales_report.get("total_sales", "0.00")))
        total_profit = Decimal(str(sales_report.get("total_profit", "0.00")))
        total_expenses = Decimal(str(expense_report.get("total_expenses", "0.00")))
        net_profit = total_profit - total_expenses
        
        # Revenue breakdown
        revenue_breakdown = {
            "total_sales": str(total_revenue),
            "cash_sales": str(sales_report.get("cash_sales", "0.00")),
            "credit_sales": str(sales_report.get("credit_sales", "0.00")),
        }
        
        # Expense breakdown
        expense_breakdown = {
            "total_expenses": str(total_expenses),
            "cash_expenses": str(expense_report.get("cash_expenses", "0.00")),
            "bank_expenses": str(expense_report.get("bank_expenses", "0.00")),
        }
        
        # Add category breakdown if available
        if "by_category" in expense_report:
            for category, amount in expense_report["by_category"].items():
                expense_breakdown[f"category_{category}"] = str(amount)

        reference_rows = []
        reference_rows.extend(sales_report.get("reference_rows", []))
        reference_rows.extend(expense_report.get("reference_rows", []))
        reference_rows = sorted(
            reference_rows,
            key=lambda row: row.get("date", row.get("invoice_date", "")),
            reverse=True,
        )

        return {
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "total_revenue": str(total_revenue),
            "total_profit": str(total_profit),
            "total_expenses": str(total_expenses),
            "net_profit": str(net_profit),
            "revenue_breakdown": revenue_breakdown,
            "expense_breakdown": expense_breakdown,
            "reference_rows": reference_rows,
        }


# Singleton instance
reports_service = ReportsService()
