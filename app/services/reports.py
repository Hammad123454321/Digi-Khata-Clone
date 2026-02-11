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
from app.models.item import Item
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
        }

    @staticmethod
    async def get_stock_report(
        business_id: str,
    ) -> dict:
        """Get stock report."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        items = await Item.find(
            Item.business_id == business_obj_id,
            Item.is_active == True,
        ).to_list()

        total_items = len(items)
        out_of_stock_items = [item for item in items if item.current_stock <= 0]

        total_stock_value = sum(item.current_stock * item.sale_price for item in items)

        return {
            "total_items": total_items,
            "total_value": str(total_stock_value),
            "out_of_stock_items": len(out_of_stock_items),
            "items": [
                {
                    "id": str(item.id),
                    "name": item.name,
                    "current_stock": str(item.current_stock),
                    "unit": item.unit.value,
                    "value": str(item.current_stock * item.sale_price),
                }
                for item in items
            ],
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

        return {
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "total_revenue": str(total_revenue),
            "total_profit": str(total_profit),
            "total_expenses": str(total_expenses),
            "net_profit": str(net_profit),
            "revenue_breakdown": revenue_breakdown,
            "expense_breakdown": expense_breakdown,
        }


# Singleton instance
reports_service = ReportsService()
