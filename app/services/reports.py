"""Reports service."""
from datetime import datetime
from typing import Optional
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.models.invoice import Invoice, InvoiceType
from app.models.expense import Expense
from app.models.cash import CashTransaction, CashTransactionType
from app.models.item import Item
from app.core.logging import get_logger

logger = get_logger(__name__)


class ReportsService:
    """Reports and analytics service."""

    @staticmethod
    async def get_sales_report(
        business_id: int,
        start_date: datetime,
        end_date: datetime,
        db: AsyncSession,
    ) -> dict:
        """Get sales report."""
        # Get invoices
        result = await db.execute(
            select(Invoice).where(
                Invoice.business_id == business_id,
                Invoice.date >= start_date,
                Invoice.date <= end_date,
            )
        )
        invoices = result.scalars().all()

        total_sales = sum(inv.total_amount for inv in invoices)
        cash_sales = sum(inv.total_amount for inv in invoices if inv.invoice_type == InvoiceType.CASH)
        credit_sales = sum(inv.total_amount for inv in invoices if inv.invoice_type == InvoiceType.CREDIT)

        # Calculate profit (sale price - purchase price)
        total_profit = Decimal("0.00")
        for invoice in invoices:
            for item in invoice.items:
                if item.item_id:
                    item_result = await db.execute(
                        select(Item).where(Item.id == item.item_id)
                    )
                    item_obj = item_result.scalar_one_or_none()
                    if item_obj:
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
        business_id: int,
        start_date: datetime,
        end_date: datetime,
        db: AsyncSession,
    ) -> dict:
        """Get cash flow report."""
        from app.services.cash import cash_service
        summary = await cash_service.get_summary(business_id, start_date, end_date, db)

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
        business_id: int,
        start_date: datetime,
        end_date: datetime,
        db: AsyncSession,
    ) -> dict:
        """Get expense report."""
        from app.services.expense import expense_service
        return await expense_service.get_summary(business_id, start_date, end_date, db)

    @staticmethod
    async def get_stock_report(
        business_id: int,
        db: AsyncSession,
    ) -> dict:
        """Get stock report."""
        result = await db.execute(
            select(Item).where(Item.business_id == business_id, Item.is_active == True)
        )
        items = result.scalars().all()

        total_items = len(items)
        low_stock_items = [item for item in items if item.min_stock_threshold and item.current_stock < item.min_stock_threshold]

        total_stock_value = sum(item.current_stock * item.purchase_price for item in items)

        return {
            "total_items": total_items,
            "low_stock_count": len(low_stock_items),
            "total_stock_value": total_stock_value,
            "low_stock_items": [
                {
                    "id": item.id,
                    "name": item.name,
                    "current_stock": item.current_stock,
                    "threshold": item.min_stock_threshold,
                }
                for item in low_stock_items
            ],
        }

    @staticmethod
    async def get_profit_loss(
        business_id: int,
        start_date: datetime,
        end_date: datetime,
        db: AsyncSession,
    ) -> dict:
        """Get profit & loss summary."""
        # Get sales
        sales_report = await ReportsService.get_sales_report(business_id, start_date, end_date, db)

        # Get expenses
        expense_report = await ReportsService.get_expense_report(business_id, start_date, end_date, db)

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

