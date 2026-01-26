"""Reports endpoints."""
from datetime import datetime
from fastapi import APIRouter, Depends, Query

from app.api.dependencies import get_current_business
from app.models.business import Business
from app.services.reports import reports_service

router = APIRouter(prefix="/reports", tags=["Reports"])


@router.get("/sales", response_model=dict)
async def get_sales_report(
    start_date: datetime = Query(...),
    end_date: datetime = Query(...),
    current_business: Business = Depends(get_current_business),
):
    """Get sales report."""
    return await reports_service.get_sales_report(
        business_id=str(current_business.id),
        start_date=start_date,
        end_date=end_date,
    )


@router.get("/cash-flow", response_model=dict)
async def get_cash_flow_report(
    start_date: datetime = Query(...),
    end_date: datetime = Query(...),
    current_business: Business = Depends(get_current_business),
):
    """Get cash flow report."""
    return await reports_service.get_cash_flow_report(
        business_id=str(current_business.id),
        start_date=start_date,
        end_date=end_date,
    )


@router.get("/expenses", response_model=dict)
async def get_expense_report(
    start_date: datetime = Query(...),
    end_date: datetime = Query(...),
    current_business: Business = Depends(get_current_business),
):
    """Get expense report."""
    return await reports_service.get_expense_report(
        business_id=str(current_business.id),
        start_date=start_date,
        end_date=end_date,
    )


@router.get("/stock", response_model=dict)
async def get_stock_report(
    current_business: Business = Depends(get_current_business),
):
    """Get stock report."""
    return await reports_service.get_stock_report(str(current_business.id))


@router.get("/profit-loss", response_model=dict)
async def get_profit_loss(
    start_date: datetime = Query(...),
    end_date: datetime = Query(...),
    current_business: Business = Depends(get_current_business),
):
    """Get profit & loss summary."""
    return await reports_service.get_profit_loss(
        business_id=str(current_business.id),
        start_date=start_date,
        end_date=end_date,
    )
