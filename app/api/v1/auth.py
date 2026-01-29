"""Authentication endpoints."""
from fastapi import APIRouter, Depends, HTTPException

from app.core.exceptions import AuthenticationError
from app.schemas.auth import OTPRequest, OTPVerify, TokenRefresh, PINSet, PINVerify, TokenResponse
from app.services.auth import auth_service
from app.api.dependencies import get_current_user
from app.models.user import User

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/request-otp", response_model=dict)
async def request_otp(data: OTPRequest):
    """Request OTP for phone number."""
    return await auth_service.request_otp(data.phone)


@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(data: OTPVerify):
    """Verify OTP and get access token."""
    return await auth_service.verify_otp(data.phone, data.otp, data.device_id, data.device_name)


@router.post("/refresh", response_model=dict)
async def refresh_token(data: TokenRefresh):
    """Refresh access token."""
    return await auth_service.refresh_access_token(data.refresh_token)


@router.post("/set-pin", response_model=dict)
async def set_pin(data: PINSet, current_user: User = Depends(get_current_user)):
    """Set PIN for user."""
    return await auth_service.set_pin(str(current_user.id), data.pin)


@router.post("/verify-pin", response_model=dict)
async def verify_pin(data: PINVerify, current_user: User = Depends(get_current_user)):
    """Verify PIN for user."""
    is_valid = await auth_service.verify_pin(str(current_user.id), data.pin)
    if not is_valid:
        raise AuthenticationError("Invalid PIN")
    return {"valid": True}


@router.patch("/me/language", response_model=dict)
async def update_language(language: str, current_user: User = Depends(get_current_user)):
    """Update current user's language preference."""
    if language not in ("en", "ur", "ar"):
        raise HTTPException(status_code=400, detail="Invalid language. Allowed values: en, ur, ar")

    current_user.language_preference = language
    await current_user.save()

    return {"language_preference": current_user.language_preference}

