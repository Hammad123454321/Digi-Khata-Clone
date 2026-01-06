"""Customer endpoints."""
from typing import List, Optional
from datetime import datetime
from decimal import Decimal
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.schemas.customer import (
    CustomerCreate,
    CustomerUpdate,
    CustomerResponse,
    CustomerPaymentCreate,
    CustomerTransactionResponse,
)
from app.services.customer import customer_service

router = APIRouter(prefix="/customers", tags=["Customers"])


@router.post("", response_model=CustomerResponse, status_code=201)
async def create_customer(
    data: CustomerCreate,
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """Create a new customer."""
    customer = await customer_service.create_customer(
        business_id=current_business.id,
        name=data.name,
        phone=data.phone,
        email=data.email,
        address=data.address,
        db=db,
    )
    await db.commit()
    return customer


@router.get("", response_model=List[CustomerResponse])
async def list_customers(
    is_active: Optional[bool] = Query(None),
    search: Optional[str] = Query(None),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """List customers."""
    customers = await customer_service.list_customers(
        business_id=current_business.id,
        is_active=is_active,
        search=search,
        limit=limit,
        offset=offset,
        db=db,
    )
    return customers


@router.get("/{customer_id}", response_model=CustomerResponse)
async def get_customer(
    customer_id: int,
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """Get customer details."""
    customer = await customer_service.get_customer(customer_id, current_business.id, db)
    
    # Add balance
    from app.models.customer import CustomerBalance
    from sqlalchemy import select
    result = await db.execute(
        select(CustomerBalance).where(
            CustomerBalance.business_id == current_business.id,
            CustomerBalance.customer_id == customer_id,
        )
    )
    balance = result.scalar_one_or_none()
    customer.balance = balance.balance if balance else Decimal("0.00")
    
    return customer


@router.post("/{customer_id}/payments", response_model=CustomerTransactionResponse, status_code=201)
async def record_payment(
    customer_id: int,
    data: CustomerPaymentCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Record customer payment."""
    transaction = await customer_service.record_payment(
        business_id=current_business.id,
        customer_id=customer_id,
        amount=data.amount,
        date=data.date,
        remarks=data.remarks,
        user_id=current_user.id,
        db=db,
    )
    await db.commit()
    return transaction


@router.get("/{customer_id}/transactions", response_model=List[CustomerTransactionResponse])
async def list_customer_transactions(
    customer_id: int,
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """List customer transactions."""
    transactions = await customer_service.list_transactions(
        business_id=current_business.id,
        customer_id=customer_id,
        start_date=start_date,
        end_date=end_date,
        limit=limit,
        offset=offset,
        db=db,
    )
    return transactions

