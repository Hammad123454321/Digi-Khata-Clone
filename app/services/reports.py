"""Reports service."""
from datetime import datetime
from typing import Optional
from decimal import Decimal
from beanie import PydanticObjectId

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

        # Load items for each invoice
        for invoice in invoices:
            invoice.items = await InvoiceItem.find(InvoiceItem.invoice_id == invoice.id).to_list()

        total_sales = sum(inv.total_amount for inv in invoices)
        cash_sales = sum(inv.total_amount for inv in invoices if inv.invoice_type == InvoiceType.CASH)
        credit_sales = sum(inv.total_amount for inv in invoices if inv.invoice_type == InvoiceType.CREDIT)

        # Calculate profit (sale price - purchase price)
        # First, collect all unique item IDs
        item_ids = set()
        for invoice in invoices:
            for item in invoice.items:
                if item.item_id:
                    item_ids.add(item.item_id)
        
        # Batch load all items at once to avoid N+1 queries
        items_map = {}
        if item_ids:
            items = await Item.find(Item.id.in_(list(item_ids))).to_list()
            items_map = {item.id: item for item in items}
        
        # Calculate profit using the pre-loaded items
        total_profit = Decimal("0.00")
        for invoice in invoices:
            for item in invoice.items:
                if item.item_id and item.item_id in items_map:
                    item_obj = items_map[item.item_id]
                    profit_per_unit = item.unit_price - item_obj.purchase_price
                    total_profit += profit_per_unit * item.quantity

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
        # Get sales
        sales_report = await ReportsService.get_sales_report(business_id, start_date, end_date)

        # Get expenses
        expense_report = await ReportsService.get_expense_report(business_id, start_date, end_date)

        net_profit = sales_report["total_profit"] - expense_report["total_expenses"]

        return {
            "start_date": start_date,
            "end_date": end_date,
            "total_revenue": sales_report["total_sales"],
            "total_profit": sales_report["total_profit"],
            "total_expenses": expense_report["total_expenses"],
            "net_profit": net_profit,
        }


# Singleton instance
reports_service = ReportsService()
