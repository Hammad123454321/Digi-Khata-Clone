"""Cash management endpoints."""
from datetime import datetime, date
from typing import List, Optional
from fastapi import APIRouter, Depends, Query

from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.schemas.cash import (
    CashTransactionCreate,
    CashTransactionResponse,
    CashBalanceResponse,
    CashSummaryRequest,
    CashSummaryResponse,
)
from app.services.cash import cash_service

router = APIRouter(prefix="/cash", tags=["Cash Management"])


@router.post("/transactions", response_model=CashTransactionResponse, status_code=201)
async def create_cash_transaction(
    data: CashTransactionCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
):
    """Create a cash transaction."""
    transaction = await cash_service.create_transaction(
        business_id=str(current_business.id),
        transaction_type=data.transaction_type,
        amount=data.amount,
        date=data.date,
        source=data.source,
        remarks=data.remarks,
        reference_id=str(data.reference_id) if data.reference_id else None,
        reference_type=data.reference_type,
        user_id=str(current_user.id),
    )
    return transaction


@router.get("/transactions", response_model=List[CashTransactionResponse])
async def list_cash_transactions(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    transaction_type: Optional[str] = Query(None, pattern="^(cash_in|cash_out)$"),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
):
    """List cash transactions."""
    transactions = await cash_service.list_transactions(
        business_id=str(current_business.id),
        start_date=start_date,
        end_date=end_date,
        transaction_type=transaction_type,
        limit=limit,
        offset=offset,
    )
    return transactions


@router.get("/balance/{balance_date}", response_model=CashBalanceResponse)
async def get_daily_balance(
    balance_date: date,
    current_business: Business = Depends(get_current_business),
):
    """Get daily cash balance."""
    balance = await cash_service.get_daily_balance(str(current_business.id), balance_date)
    if not balance:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Balance not found for this date")
    return balance


@router.post("/summary", response_model=CashSummaryResponse)
async def get_cash_summary(
    data: CashSummaryRequest,
    current_business: Business = Depends(get_current_business),
):
    """Get cash summary for date range."""
    summary = await cash_service.get_summary(
        business_id=str(current_business.id),
        start_date=data.start_date,
        end_date=data.end_date,
    )
    return summary
