"""Supplier endpoints."""
from typing import List, Optional
from decimal import Decimal
from fastapi import APIRouter, Depends, Query

from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.models.supplier import SupplierBalance
from app.schemas.supplier import SupplierCreate, SupplierResponse, SupplierPaymentCreate, SupplierPurchaseCreate
from app.services.supplier import supplier_service

router = APIRouter(prefix="/suppliers", tags=["Suppliers"])


@router.post("", response_model=SupplierResponse, status_code=201)
async def create_supplier(
    data: SupplierCreate,
    current_business: Business = Depends(get_current_business),
):
    """Create a new supplier."""
    supplier = await supplier_service.create_supplier(
        business_id=str(current_business.id),
        name=data.name,
        phone=data.phone,
        email=data.email,
        address=data.address,
    )
    # Convert ObjectId to string for response
    return SupplierResponse(
        id=str(supplier.id),
        name=supplier.name,
        phone=supplier.get_phone() if hasattr(supplier, 'get_phone') else supplier.phone,
        email=supplier.get_email() if hasattr(supplier, 'get_email') else supplier.email,
        address=supplier.address,
        is_active=supplier.is_active,
        balance=None,
    )


@router.get("", response_model=List[SupplierResponse])
async def list_suppliers(
    is_active: Optional[bool] = Query(None),
    search: Optional[str] = Query(None),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
):
    """List suppliers."""
    suppliers, balance_map = await supplier_service.list_suppliers(
        business_id=str(current_business.id),
        is_active=is_active,
        search=search,
        limit=limit,
        offset=offset,
    )
    # Convert ObjectIds to strings for response
    return [
        SupplierResponse(
            id=str(s.id),
            name=s.name,
            phone=s.get_phone() if hasattr(s, 'get_phone') else s.phone,
            email=s.get_email() if hasattr(s, 'get_email') else s.email,
            address=s.address,
            is_active=s.is_active,
            balance=balance_map.get(s.id, Decimal("0.00")),
        )
        for s in suppliers
    ]


@router.get("/{supplier_id}", response_model=SupplierResponse)
async def get_supplier(
    supplier_id: str,
    current_business: Business = Depends(get_current_business),
):
    """Get supplier details."""
    supplier = await supplier_service.get_supplier(supplier_id, str(current_business.id))
    
    # Add balance
    balance = await SupplierBalance.find_one(
        SupplierBalance.business_id == current_business.id,
        SupplierBalance.supplier_id == supplier.id,
    )
    supplier_balance = balance.balance if balance else Decimal("0.00")
    
    # Convert ObjectId to string for response
    return SupplierResponse(
        id=str(supplier.id),
        name=supplier.name,
        phone=supplier.get_phone() if hasattr(supplier, 'get_phone') else supplier.phone,
        email=supplier.get_email() if hasattr(supplier, 'get_email') else supplier.email,
        address=supplier.address,
        is_active=supplier.is_active,
        balance=supplier_balance,
    )


@router.post("/{supplier_id}/payments", status_code=201)
async def record_payment(
    supplier_id: str,
    data: SupplierPaymentCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
):
    """Record supplier payment."""
    transaction = await supplier_service.record_payment(
        business_id=str(current_business.id),
        supplier_id=supplier_id,
        amount=data.amount,
        date=data.date,
        remarks=data.remarks,
        user_id=str(current_user.id),
    )
    return transaction


@router.post("/{supplier_id}/purchases", status_code=201)
async def record_purchase(
    supplier_id: str,
    data: SupplierPurchaseCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
):
    """Record supplier purchase (with optional stock integration)."""
    transaction = await supplier_service.record_purchase(
        business_id=str(current_business.id),
        supplier_id=supplier_id,
        amount=data.amount,
        date=data.date,
        items=data.items,
        remarks=data.remarks,
        user_id=str(current_user.id),
    )
    return transaction

