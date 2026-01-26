"""Expense endpoints."""
from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, Query

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


@router.get("/categories", response_model=List[ExpenseCategoryResponse])
async def list_categories(
    is_active: Optional[bool] = Query(None),
    current_business: Business = Depends(get_current_business),
):
    """List expense categories."""
    categories = await expense_service.list_categories(
        business_id=str(current_business.id),
        is_active=is_active,
    )
    # Convert ObjectIds to strings for response
    return [
        ExpenseCategoryResponse(
            id=str(c.id),
            name=c.name,
            description=c.description,
            is_active=c.is_active,
        )
        for c in categories
    ]


@router.post("/categories", response_model=ExpenseCategoryResponse, status_code=201)
async def create_category(
    data: ExpenseCategoryCreate,
    current_business: Business = Depends(get_current_business),
):
    """Create an expense category."""
    category = await expense_service.create_category(
        business_id=str(current_business.id),
        name=data.name,
        description=data.description,
    )
    # Convert ObjectId to string for response
    return ExpenseCategoryResponse(
        id=str(category.id),
        name=category.name,
        description=category.description,
        is_active=category.is_active,
    )


@router.post("", response_model=ExpenseResponse, status_code=201)
async def create_expense(
    data: ExpenseCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
):
    """Create an expense."""
    expense = await expense_service.create_expense(
        business_id=str(current_business.id),
        amount=data.amount,
        date=data.date,
        payment_mode=data.payment_mode,
        category_id=str(data.category_id) if data.category_id else None,
        description=data.description,
        user_id=str(current_user.id),
    )
    # Convert ObjectIds to strings for response
    return ExpenseResponse(
        id=str(expense.id),
        category_id=str(expense.category_id) if expense.category_id else None,
        amount=expense.amount,
        date=expense.date,
        payment_mode=expense.payment_mode.value,
        description=expense.description,
        created_at=expense.created_at,
    )


@router.get("", response_model=List[ExpenseResponse])
async def list_expenses(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    category_id: Optional[str] = Query(None),
    payment_mode: Optional[str] = Query(None, pattern="^(cash|bank)$"),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
):
    """List expenses."""
    expenses = await expense_service.list_expenses(
        business_id=str(current_business.id),
        start_date=start_date,
        end_date=end_date,
        category_id=category_id,
        payment_mode=payment_mode,
        limit=limit,
        offset=offset,
    )
    # Convert ObjectIds to strings for response
    return [
        ExpenseResponse(
            id=str(e.id),
            category_id=str(e.category_id) if e.category_id else None,
            amount=e.amount,
            date=e.date,
            payment_mode=e.payment_mode.value,
            description=e.description,
            created_at=e.created_at,
        )
        for e in expenses
    ]


@router.post("/summary", response_model=dict)
async def get_expense_summary(
    start_date: datetime = Query(...),
    end_date: datetime = Query(...),
    current_business: Business = Depends(get_current_business),
):
    """Get expense summary."""
    return await expense_service.get_summary(
        business_id=str(current_business.id),
        start_date=start_date,
        end_date=end_date,
    )
