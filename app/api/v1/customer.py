"""Customer endpoints."""
from typing import List, Optional
from datetime import datetime
from decimal import Decimal
from fastapi import APIRouter, Depends, Query

from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.models.customer import CustomerBalance
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
):
    """Create a new customer."""
    customer = await customer_service.create_customer(
        business_id=str(current_business.id),
        name=data.name,
        phone=data.phone,
        email=data.email,
        address=data.address,
    )
    return customer


@router.get("", response_model=List[CustomerResponse])
async def list_customers(
    is_active: Optional[bool] = Query(None),
    search: Optional[str] = Query(None),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
):
    """List customers."""
    customers = await customer_service.list_customers(
        business_id=str(current_business.id),
        is_active=is_active,
        search=search,
        limit=limit,
        offset=offset,
    )
    return customers


@router.get("/{customer_id}", response_model=CustomerResponse)
async def get_customer(
    customer_id: str,
    current_business: Business = Depends(get_current_business),
):
    """Get customer details."""
    customer = await customer_service.get_customer(customer_id, str(current_business.id))
    
    # Add balance
    balance = await CustomerBalance.find_one(
        CustomerBalance.business_id == current_business.id,
        CustomerBalance.customer_id == customer.id,
    )
    customer.balance = balance.balance if balance else Decimal("0.00")
    
    return customer


@router.post("/{customer_id}/payments", response_model=CustomerTransactionResponse, status_code=201)
async def record_payment(
    customer_id: str,
    data: CustomerPaymentCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
):
    """Record customer payment (optionally linked to invoice)."""
    transaction = await customer_service.record_payment(
        business_id=str(current_business.id),
        customer_id=customer_id,
        amount=data.amount,
        date=data.date,
        invoice_id=str(data.invoice_id) if data.invoice_id else None,
        remarks=data.remarks,
        user_id=str(current_user.id),
    )
    return transaction


@router.get("/{customer_id}/transactions", response_model=List[CustomerTransactionResponse])
async def list_customer_transactions(
    customer_id: str,
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
):
    """List customer transactions."""
    transactions = await customer_service.list_transactions(
        business_id=str(current_business.id),
        customer_id=customer_id,
        start_date=start_date,
        end_date=end_date,
        limit=limit,
        offset=offset,
    )
    return transactions

