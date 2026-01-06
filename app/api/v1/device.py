"""Device endpoints."""
from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.schemas.device import DevicePairRequest, DeviceResponse, DevicePairingTokenResponse
from app.services.device import device_service

router = APIRouter(prefix="/devices", tags=["Devices"])


@router.get("/pairing-token", response_model=DevicePairingTokenResponse)
async def generate_pairing_token(
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Generate QR code pairing token."""
    return await device_service.generate_pairing_token(current_business.id, current_user.id, db)


@router.post("/pair", response_model=DeviceResponse, status_code=201)
async def pair_device(
    data: DevicePairRequest,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Pair a device using QR code token."""
    device = await device_service.pair_device(
        business_id=current_business.id,
        user_id=current_user.id,
        device_id=data.device_id,
        pairing_token=data.pairing_token,
        device_name=data.device_name,
        device_type=data.device_type,
        db=db,
    )
    await db.commit()
    return device


@router.get("", response_model=List[DeviceResponse])
async def list_devices(
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """List all devices for business."""
    return await device_service.list_devices(current_business.id, db)


@router.post("/{device_id}/revoke", status_code=200)
async def revoke_device(
    device_id: int,
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """Revoke a device."""
    await device_service.revoke_device(device_id, current_business.id, db)
    await db.commit()
    return {"message": "Device revoked"}

