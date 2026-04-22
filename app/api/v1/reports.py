"""Reports endpoints."""
from __future__ import annotations

from datetime import datetime
from typing import Optional, Tuple

from fastapi import APIRouter, Depends, Query

from app.api.dependencies import get_current_business, get_current_permissions, require_permission
from app.core.exceptions import ValidationError
from app.core.permissions import can_access
from app.models.business import Business
from app.services.reports import reports_service

router = APIRouter(prefix="/reports", tags=["Reports"])


def _resolve_datetime_range(
    *,
    start_date: Optional[datetime],
    end_date: Optional[datetime],
    start_datetime: Optional[datetime],
    end_datetime: Optional[datetime],
    required: bool,
) -> Tuple[Optional[datetime], Optional[datetime]]:
    resolved_start = start_datetime or start_date
    resolved_end = end_datetime or end_date

    if required and (resolved_start is None or resolved_end is None):
        raise ValidationError("start_date/end_date or start_datetime/end_datetime are required")
    if resolved_start and resolved_end and resolved_start > resolved_end:
        raise ValidationError("start date cannot be after end date")
    return resolved_start, resolved_end


@router.get("/sales", response_model=dict)
async def get_sales_report(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    start_datetime: Optional[datetime] = Query(None),
    end_datetime: Optional[datetime] = Query(None),
    current_business: Business = Depends(get_current_business),
    _: dict = Depends(require_permission("reports", "view")),
):
    """Get sales report."""
    resolved_start, resolved_end = _resolve_datetime_range(
        start_date=start_date,
        end_date=end_date,
        start_datetime=start_datetime,
        end_datetime=end_datetime,
        required=True,
    )
    return await reports_service.get_sales_report(
        business_id=str(current_business.id),
        start_date=resolved_start,
        end_date=resolved_end,
    )


@router.get("/cash-flow", response_model=dict)
async def get_cash_flow_report(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    start_datetime: Optional[datetime] = Query(None),
    end_datetime: Optional[datetime] = Query(None),
    current_business: Business = Depends(get_current_business),
    _: dict = Depends(require_permission("reports", "view")),
):
    """Get cash flow report."""
    resolved_start, resolved_end = _resolve_datetime_range(
        start_date=start_date,
        end_date=end_date,
        start_datetime=start_datetime,
        end_datetime=end_datetime,
        required=True,
    )
    return await reports_service.get_cash_flow_report(
        business_id=str(current_business.id),
        start_date=resolved_start,
        end_date=resolved_end,
    )


@router.get("/expenses", response_model=dict)
async def get_expense_report(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    start_datetime: Optional[datetime] = Query(None),
    end_datetime: Optional[datetime] = Query(None),
    current_business: Business = Depends(get_current_business),
    _: dict = Depends(require_permission("reports", "view")),
):
    """Get expense report."""
    resolved_start, resolved_end = _resolve_datetime_range(
        start_date=start_date,
        end_date=end_date,
        start_datetime=start_datetime,
        end_datetime=end_datetime,
        required=True,
    )
    return await reports_service.get_expense_report(
        business_id=str(current_business.id),
        start_date=resolved_start,
        end_date=resolved_end,
    )


@router.get("/stock", response_model=dict)
async def get_stock_report(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    start_datetime: Optional[datetime] = Query(None),
    end_datetime: Optional[datetime] = Query(None),
    current_business: Business = Depends(get_current_business),
    permissions: dict = Depends(get_current_permissions),
    _: dict = Depends(require_permission("reports", "view")),
):
    """Get stock report."""
    resolved_start, resolved_end = _resolve_datetime_range(
        start_date=start_date,
        end_date=end_date,
        start_datetime=start_datetime,
        end_datetime=end_datetime,
        required=False,
    )
    report = await reports_service.get_stock_report(
        business_id=str(current_business.id),
        start_date=resolved_start,
        end_date=resolved_end,
    )

    # Hide sensitive purchase-price derived item fields when permission is absent.
    if not can_access(permissions, resource="purchase_price", action="view"):
        for item in report.get("items", []):
            item["purchase_price"] = "0.00"
    return report


@router.get("/profit-loss", response_model=dict)
async def get_profit_loss(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    start_datetime: Optional[datetime] = Query(None),
    end_datetime: Optional[datetime] = Query(None),
    current_business: Business = Depends(get_current_business),
    _: dict = Depends(require_permission("reports", "view")),
):
    """Get profit & loss summary."""
    resolved_start, resolved_end = _resolve_datetime_range(
        start_date=start_date,
        end_date=end_date,
        start_datetime=start_datetime,
        end_datetime=end_datetime,
        required=True,
    )
    return await reports_service.get_profit_loss(
        business_id=str(current_business.id),
        start_date=resolved_start,
        end_date=resolved_end,
    )
