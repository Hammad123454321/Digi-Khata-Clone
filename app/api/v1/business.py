"""Business endpoints."""
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from beanie import PydanticObjectId

from app.api.dependencies import get_current_user, get_current_business, require_role
from app.models.user import User, UserMembership
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
        owner_name=data.owner_name,
        email=data.email,
        address=data.address,
        area=data.area,
        city=data.city,
        business_category=data.business_category,
        language_preference=data.language_preference,
        max_devices=data.max_devices,
        business_type=data.business_type,
        custom_business_type=data.custom_business_type,
    )
    # Convert ObjectId to string for response
    return BusinessResponse(
        id=str(business.id),
        name=business.name,
        phone=business.phone,
        owner_name=business.owner_name,
        email=business.email,
        address=business.address,
        area=business.area,
        city=business.city,
        business_category=business.business_category,
        is_active=business.is_active,
        language_preference=business.language_preference,
        max_devices=business.max_devices,
        business_type=business.business_type,
        custom_business_type=business.custom_business_type,
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
            owner_name=business.owner_name,
            email=business.email,
            address=business.address,
            area=business.area,
            city=business.city,
            business_category=business.business_category,
            is_active=business.is_active,
            language_preference=business.language_preference,
            max_devices=business.max_devices,
            business_type=business.business_type,
            custom_business_type=business.custom_business_type,
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
        owner_name=current_business.owner_name,
        email=current_business.email,
        address=current_business.address,
        area=current_business.area,
        city=current_business.city,
        business_category=current_business.business_category,
        is_active=current_business.is_active,
        language_preference=current_business.language_preference,
        max_devices=current_business.max_devices,
        business_type=current_business.business_type,
        custom_business_type=current_business.custom_business_type,
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
        owner_name=data.owner_name,
        email=data.email,
        address=data.address,
        area=data.area,
        city=data.city,
        business_category=data.business_category,
        language_preference=data.language_preference,
        max_devices=data.max_devices,
    )
    # Convert ObjectId to string for response
    return BusinessResponse(
        id=str(business.id),
        name=business.name,
        phone=business.phone,
        owner_name=business.owner_name,
        email=business.email,
        address=business.address,
        area=business.area,
        city=business.city,
        business_category=business.business_category,
        is_active=business.is_active,
        language_preference=business.language_preference,
        max_devices=business.max_devices,
        business_type=business.business_type,
        custom_business_type=business.custom_business_type,
    )


@router.post("/{business_id}/set-default", response_model=dict)
async def set_default_business(
    business_id: str,
    current_user: User = Depends(get_current_user),
):
    """Set the default business for the current user."""
    try:
        business_obj_id = PydanticObjectId(business_id)
    except (ValueError, TypeError):
        raise HTTPException(status_code=400, detail="Invalid business ID format")

    membership = await UserMembership.find_one(
        UserMembership.user_id == current_user.id,
        UserMembership.business_id == business_obj_id,
        UserMembership.is_active == True,
    )
    if not membership:
        raise HTTPException(status_code=403, detail="You do not have access to this business")

    current_user.default_business_id = business_obj_id
    await current_user.save()

    return {"default_business_id": str(current_user.default_business_id)}
