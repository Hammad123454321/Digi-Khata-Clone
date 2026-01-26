"""Business endpoints."""
from typing import List
from fastapi import APIRouter, Depends

from app.api.dependencies import get_current_user, get_current_business, require_role
from app.models.user import User
from app.models.business import Business
from app.schemas.business import BusinessCreate, BusinessUpdate, BusinessResponse
from app.services.business import business_service

router = APIRouter(prefix="/businesses", tags=["Businesses"])


@router.post("", response_model=BusinessResponse, status_code=201)
async def create_business(
    data: BusinessCreate,
    current_user: User = Depends(get_current_user),
):
    """Create a new business."""
    business = await business_service.create_business(
        name=data.name,
        phone=data.phone,
        user_id=str(current_user.id),
        email=data.email,
        address=data.address,
        language_preference=data.language_preference,
        max_devices=data.max_devices,
    )
    # Convert ObjectId to string for response
    return BusinessResponse(
        id=str(business.id),
        name=business.name,
        phone=business.phone,
        email=business.email,
        address=business.address,
        is_active=business.is_active,
        language_preference=business.language_preference,
        max_devices=business.max_devices,
    )


@router.get("", response_model=List[BusinessResponse])
async def list_businesses(
    current_user: User = Depends(get_current_user),
):
    """List all businesses for current user."""
    businesses = await business_service.list_user_businesses(str(current_user.id))
    # Convert ObjectIds to strings for response
    return [
        BusinessResponse(
            id=str(business.id),
            name=business.name,
            phone=business.phone,
            email=business.email,
            address=business.address,
            is_active=business.is_active,
            language_preference=business.language_preference,
            max_devices=business.max_devices,
        )
        for business in businesses
    ]


@router.get("/{business_id}", response_model=BusinessResponse)
async def get_business(
    business_id: str,
    current_business: Business = Depends(get_current_business),
):
    """Get business details."""
    # Convert ObjectId to string for response
    return BusinessResponse(
        id=str(current_business.id),
        name=current_business.name,
        phone=current_business.phone,
        email=current_business.email,
        address=current_business.address,
        is_active=current_business.is_active,
        language_preference=current_business.language_preference,
        max_devices=current_business.max_devices,
    )


@router.patch("/{business_id}", response_model=BusinessResponse)
async def update_business(
    business_id: str,
    data: BusinessUpdate,
    current_business: Business = Depends(get_current_business),
):
    """Update business."""
    business = await business_service.update_business(
        business_id=str(current_business.id),
        name=data.name,
        email=data.email,
        address=data.address,
        language_preference=data.language_preference,
        max_devices=data.max_devices,
    )
    # Convert ObjectId to string for response
    return BusinessResponse(
        id=str(business.id),
        name=business.name,
        phone=business.phone,
        email=business.email,
        address=business.address,
        is_active=business.is_active,
        language_preference=business.language_preference,
        max_devices=business.max_devices,
    )
