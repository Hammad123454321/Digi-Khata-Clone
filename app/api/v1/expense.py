"""Expense endpoints."""
from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.schemas.expense import (
    ExpenseCategoryCreate,
    ExpenseCategoryResponse,
    ExpenseCreate,
    ExpenseResponse,
)
from app.services.expense import expense_service

router = APIRouter(prefix="/expenses", tags=["Expenses"])


@router.post("/categories", response_model=ExpenseCategoryResponse, status_code=201)
async def create_category(
    data: ExpenseCategoryCreate,
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """Create an expense category."""
    category = await expense_service.create_category(
        business_id=current_business.id,
        name=data.name,
        description=data.description,
        db=db,
    )
    await db.commit()
    return category


@router.post("", response_model=ExpenseResponse, status_code=201)
async def create_expense(
    data: ExpenseCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create an expense."""
    expense = await expense_service.create_expense(
        business_id=current_business.id,
        amount=data.amount,
        date=data.date,
        payment_mode=data.payment_mode,
        category_id=data.category_id,
        description=data.description,
        user_id=current_user.id,
        db=db,
    )
    await db.commit()
    return expense


@router.get("", response_model=List[ExpenseResponse])
async def list_expenses(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    category_id: Optional[int] = Query(None),
    payment_mode: Optional[str] = Query(None, pattern="^(cash|bank)$"),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """List expenses."""
    expenses = await expense_service.list_expenses(
        business_id=current_business.id,
        start_date=start_date,
        end_date=end_date,
        category_id=category_id,
        payment_mode=payment_mode,
        limit=limit,
        offset=offset,
        db=db,
    )
    return expenses


@router.post("/summary", response_model=dict)
async def get_expense_summary(
    start_date: datetime = Query(...),
    end_date: datetime = Query(...),
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """Get expense summary."""
    return await expense_service.get_summary(
        business_id=current_business.id,
        start_date=start_date,
        end_date=end_date,
        db=db,
    )

