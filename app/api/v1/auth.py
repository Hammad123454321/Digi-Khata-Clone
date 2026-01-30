"""Authentication endpoints."""
from fastapi import APIRouter, Depends, HTTPException
from starlette.requests import Request

from app.core.exceptions import AuthenticationError
from app.core.translations import translate, get_user_language
from app.schemas.auth import OTPRequest, OTPVerify, TokenRefresh, PINSet, PINVerify, TokenResponse
from app.services.auth import auth_service
from app.api.dependencies import get_current_user
from app.models.user import User

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/request-otp", response_model=dict)
async def request_otp(data: OTPRequest, request: Request):
    """Request OTP for phone number."""
    language = get_user_language(request=request)
    return await auth_service.request_otp(data.phone, language=language)


@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(data: OTPVerify, request: Request):
    """Verify OTP and get access token."""
    language = get_user_language(request=request)
    return await auth_service.verify_otp(data.phone, data.otp, data.device_id, data.device_name, language=language)


@router.post("/refresh", response_model=dict)
async def refresh_token(data: TokenRefresh):
    """Refresh access token."""
    return await auth_service.refresh_access_token(data.refresh_token)


@router.post("/set-pin", response_model=dict)
async def set_pin(data: PINSet, current_user: User = Depends(get_current_user)):
    """Set PIN for user."""
    return await auth_service.set_pin(str(current_user.id), data.pin)


@router.post("/verify-pin", response_model=dict)
async def verify_pin(
    data: PINVerify,
    current_user: User = Depends(get_current_user),
):
    """Verify PIN for user."""
    language = get_user_language(user=current_user)
    is_valid = await auth_service.verify_pin(str(current_user.id), data.pin)
    if not is_valid:
        raise AuthenticationError(translate("invalid_pin", language))
    return {"valid": True}


@router.patch("/me/language", response_model=dict)
async def update_language(
    language: str,
    current_user: User = Depends(get_current_user),
):
    """Update current user's language preference."""
    current_language = get_user_language(user=current_user)
    
    if language not in ("en", "ur", "ar"):
        raise HTTPException(
            status_code=400,
            detail=translate("invalid_language", current_language)
        )

    current_user.language_preference = language
    await current_user.save()

    return {"language_preference": current_user.language_preference}

