"""Staff endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Depends, Query

from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.schemas.staff import StaffCreate, StaffResponse, StaffSalaryCreate
from app.services.staff import staff_service

router = APIRouter(prefix="/staff", tags=["Staff"])


@router.post("", response_model=StaffResponse, status_code=201)
async def create_staff(
    data: StaffCreate,
    current_business: Business = Depends(get_current_business),
):
    """Create a new staff member."""
    staff = await staff_service.create_staff(
        business_id=str(current_business.id),
        name=data.name,
        phone=data.phone,
        email=data.email,
        role=data.role,
        address=data.address,
    )
    # Convert ObjectId to string for response
    return StaffResponse(
        id=str(staff.id),
        name=staff.name,
        phone=staff.get_phone() if hasattr(staff, 'get_phone') else staff.phone,
        email=staff.get_email() if hasattr(staff, 'get_email') else staff.email,
        role=staff.role,
        address=staff.address,
        is_active=staff.is_active,
    )


@router.get("", response_model=List[StaffResponse])
async def list_staff(
    is_active: Optional[bool] = Query(None),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
):
    """List staff."""
    staff_list = await staff_service.list_staff(
        business_id=str(current_business.id),
        is_active=is_active,
        limit=limit,
        offset=offset,
    )
    # Convert ObjectIds to strings for response
    return [
        StaffResponse(
            id=str(s.id),
            name=s.name,
            phone=s.get_phone() if hasattr(s, 'get_phone') else s.phone,
            email=s.get_email() if hasattr(s, 'get_email') else s.email,
            role=s.role,
            address=s.address,
            is_active=s.is_active,
        )
        for s in staff_list
    ]


@router.get("/{staff_id}", response_model=StaffResponse)
async def get_staff(
    staff_id: str,
    current_business: Business = Depends(get_current_business),
):
    """Get staff details."""
    staff = await staff_service.get_staff(staff_id, str(current_business.id))
    # Convert ObjectId to string for response
    return StaffResponse(
        id=str(staff.id),
        name=staff.name,
        phone=staff.get_phone() if hasattr(staff, 'get_phone') else staff.phone,
        email=staff.get_email() if hasattr(staff, 'get_email') else staff.email,
        role=staff.role,
        address=staff.address,
        is_active=staff.is_active,
    )


@router.post("/{staff_id}/salaries", status_code=201)
async def record_salary(
    staff_id: str,
    data: StaffSalaryCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
):
    """Record staff salary."""
    salary = await staff_service.record_salary(
        business_id=str(current_business.id),
        staff_id=staff_id,
        amount=data.amount,
        date=data.date,
        payment_mode=data.payment_mode,
        remarks=data.remarks,
        user_id=str(current_user.id),
    )
    return salary
