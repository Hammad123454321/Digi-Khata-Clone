"""Cash management endpoints."""
from datetime import datetime, date
from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
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
    db: AsyncSession = Depends(get_db),
):
    """Create a cash transaction."""
    transaction = await cash_service.create_transaction(
        business_id=current_business.id,
        transaction_type=data.transaction_type,
        amount=data.amount,
        date=data.date,
        source=data.source,
        remarks=data.remarks,
        reference_id=data.reference_id,
        reference_type=data.reference_type,
        user_id=current_user.id,
        db=db,
    )
    await db.commit()
    return transaction


@router.get("/transactions", response_model=List[CashTransactionResponse])
async def list_cash_transactions(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    transaction_type: Optional[str] = Query(None, pattern="^(cash_in|cash_out)$"),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """List cash transactions."""
    transactions = await cash_service.list_transactions(
        business_id=current_business.id,
        start_date=start_date,
        end_date=end_date,
        transaction_type=transaction_type,
        limit=limit,
        offset=offset,
        db=db,
    )
    return transactions


@router.get("/balance/{balance_date}", response_model=CashBalanceResponse)
async def get_daily_balance(
    balance_date: date,
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """Get daily cash balance."""
    balance = await cash_service.get_daily_balance(current_business.id, balance_date, db)
    if not balance:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("Balance not found for this date")
    return balance


@router.post("/summary", response_model=CashSummaryResponse)
async def get_cash_summary(
    data: CashSummaryRequest,
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """Get cash summary for date range."""
    summary = await cash_service.get_summary(
        business_id=current_business.id,
        start_date=data.start_date,
        end_date=data.end_date,
        db=db,
    )
    return summary

