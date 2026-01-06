"""Authentication endpoints."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.exceptions import AuthenticationError
from app.schemas.auth import OTPRequest, OTPVerify, TokenRefresh, PINSet, PINVerify, TokenResponse
from app.services.auth import auth_service
from app.api.dependencies import get_current_user
from app.models.user import User

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/request-otp", response_model=dict)
async def request_otp(data: OTPRequest, db: AsyncSession = Depends(get_db)):
    """Request OTP for phone number."""
    return await auth_service.request_otp(data.phone, db)


@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(data: OTPVerify, db: AsyncSession = Depends(get_db)):
    """Verify OTP and get access token."""
    return await auth_service.verify_otp(data.phone, data.otp, data.device_id, data.device_name, db)


@router.post("/refresh", response_model=dict)
async def refresh_token(data: TokenRefresh, db: AsyncSession = Depends(get_db)):
    """Refresh access token."""
    return await auth_service.refresh_access_token(data.refresh_token, db)


@router.post("/set-pin", response_model=dict)
async def set_pin(data: PINSet, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    """Set PIN for user."""
    return await auth_service.set_pin(current_user.id, data.pin, db)


@router.post("/verify-pin", response_model=dict)
async def verify_pin(data: PINVerify, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    """Verify PIN for user."""
    is_valid = await auth_service.verify_pin(current_user.id, data.pin, db)
    if not is_valid:
        raise AuthenticationError("Invalid PIN")
    return {"valid": True}

