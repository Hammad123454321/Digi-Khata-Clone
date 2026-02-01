"""Reports service."""
from datetime import datetime
from typing import Optional
from decimal import Decimal
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

        return {
            "start_date": start_date,
            "end_date": end_date,
            "total_sales": total_sales,
            "cash_sales": cash_sales,
            "credit_sales": credit_sales,
            "total_profit": total_profit,
            "invoice_count": len(invoices),
        }

    @staticmethod
    async def get_cash_flow_report(
        business_id: str,
        start_date: datetime,
        end_date: datetime,
    ) -> dict:
        """Get cash flow report."""
        from app.services.cash import cash_service
        summary = await cash_service.get_summary(business_id, start_date, end_date)

        return {
            "start_date": start_date,
            "end_date": end_date,
            "opening_balance": summary["opening_balance"],
            "total_cash_in": summary["total_cash_in"],
            "total_cash_out": summary["total_cash_out"],
            "closing_balance": summary["closing_balance"],
        }

    @staticmethod
    async def get_expense_report(
        business_id: str,
        start_date: datetime,
        end_date: datetime,
    ) -> dict:
        """Get expense report."""
        from app.services.expense import expense_service
        return await expense_service.get_summary(business_id, start_date, end_date)

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
        low_stock_items = [item for item in items if item.min_stock_threshold and item.current_stock < item.min_stock_threshold]

        total_stock_value = sum(item.current_stock * item.purchase_price for item in items)

        return {
            "total_items": total_items,
            "low_stock_count": len(low_stock_items),
            "total_stock_value": total_stock_value,
            "low_stock_items": [
                {
                    "id": str(item.id),
                    "name": item.name,
                    "current_stock": item.current_stock,
                    "threshold": item.min_stock_threshold,
                }
                for item in low_stock_items
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
                "total_sales": Decimal("0.00"),
                "total_profit": Decimal("0.00"),
            }

        try:
            # Get expenses
            expense_report = await ReportsService.get_expense_report(business_id, start_date, end_date)
        except Exception as e:
            logger.error("profit_loss_expense_error", business_id=business_id, error=str(e), exc_info=True)
            expense_report = {
                "total_expenses": Decimal("0.00"),
            }

        total_revenue = sales_report.get("total_sales", Decimal("0.00"))
        total_profit = sales_report.get("total_profit", Decimal("0.00"))
        total_expenses = expense_report.get("total_expenses", Decimal("0.00"))
        net_profit = total_profit - total_expenses

        return {
            "start_date": start_date,
            "end_date": end_date,
            "total_revenue": total_revenue,
            "total_profit": total_profit,
            "total_expenses": total_expenses,
            "net_profit": net_profit,
        }


# Singleton instance
reports_service = ReportsService()
