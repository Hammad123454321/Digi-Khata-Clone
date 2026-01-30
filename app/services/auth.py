"""Authentication service."""
from datetime import datetime, timedelta, timezone
from typing import Optional, Dict, Any

from app.core.security import (
    generate_otp,
    create_access_token,
    create_refresh_token,
    verify_token,
    verify_password,
    get_password_hash,
)
from app.core.config import get_settings
from app.core.redis_client import get_redis
from app.core.exceptions import AuthenticationError, BusinessLogicError, NotFoundError
from app.core.translations import translate
from app.models.user import User, UserMembership, UserRoleEnum
from app.models.business import Business
from app.services.sms import sms_service
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)


class AuthService:
    """Authentication service."""

    @staticmethod
    async def request_otp(phone: str, language: str = "en") -> Dict[str, Any]:
        """Request OTP for phone number."""
        # Normalize phone number
        phone = phone.strip().replace(" ", "").replace("-", "")

        # Check rate limiting
        redis = await get_redis()
        rate_limit_key = f"otp_rate_limit:{phone}"
        attempts = await redis.get(rate_limit_key)
        if attempts and int(attempts) >= settings.OTP_MAX_ATTEMPTS:
            raise BusinessLogicError(
                translate("max_otp_attempts", language, minutes=settings.OTP_EXPIRE_MINUTES)
            )

        # Generate OTP
        otp = generate_otp()

        # Store OTP in Redis with expiration
        otp_key = f"otp:{phone}"
        await redis.setex(otp_key, settings.OTP_EXPIRE_MINUTES * 60, otp)

        # Increment rate limit counter
        await redis.incr(rate_limit_key)
        await redis.expire(rate_limit_key, settings.OTP_EXPIRE_MINUTES * 60)

        # Send OTP via SMS
        await sms_service.send_otp(phone, otp)

        logger.info("otp_requested", phone=phone)

        return {
            "message": translate("otp_sent_successfully", language) if language != "en" else "OTP sent successfully",
            "expires_in_minutes": settings.OTP_EXPIRE_MINUTES
        }

    @staticmethod
    async def verify_otp(phone: str, otp: str, device_id: Optional[str], device_name: Optional[str], language: str = "en") -> Dict[str, Any]:
        """Verify OTP and return tokens."""
        phone = phone.strip().replace(" ", "").replace("-", "")

        # Verify OTP from Redis
        redis = await get_redis()
        otp_key = f"otp:{phone}"
        stored_otp = await redis.get(otp_key)

        if not stored_otp or stored_otp != otp:
            raise AuthenticationError(translate("invalid_or_expired_otp", language))

        # Delete OTP after successful verification
        await redis.delete(otp_key)

        # Get or create user
        user = await User.find_one(User.phone == phone)

        if not user:
            # Create new user
            user = User(phone=phone, is_active=True)
            await user.insert()
            logger.info("user_created", user_id=str(user.id), phone=phone)

        # Update last login
        user.last_login_at = datetime.now(timezone.utc)
        await user.save()

        # Get user's businesses
        memberships = await UserMembership.find(
            UserMembership.user_id == user.id,
            UserMembership.is_active == True,
        ).to_list()

        # Load businesses for memberships
        businesses = []
        for membership in memberships:
            business = await Business.get(membership.business_id)
            if business:
                businesses.append(business)

        # Create tokens - use string id for ObjectId compatibility
        access_token = create_access_token(data={"sub": str(user.id), "phone": user.phone})
        refresh_token = create_refresh_token(data={"sub": str(user.id), "phone": user.phone})

        # Store refresh token in Redis
        refresh_key = f"refresh_token:{user.id}"
        await redis.setex(refresh_key, settings.REFRESH_TOKEN_EXPIRE_DAYS * 24 * 60 * 60, refresh_token)

        # Handle device registration if provided
        # Note: Device registration requires at least one business.
        # If user has no businesses, device registration is skipped.
        # User should create a business first, then register device.
        device_info = None
        if device_id and businesses:
            from app.models.device import Device
            from app.core.security import generate_device_token

            # Use first business for device registration (user can add more businesses later)
            business = businesses[0]
            # Check device limit
            device_count = await Device.find(
                Device.business_id == business.id,
                Device.is_active == True,
            ).count()

            if device_count >= business.max_devices:
                raise BusinessLogicError(translate("max_devices_reached", language, limit=business.max_devices))

            # Check if device already exists
            device = await Device.find_one(
                Device.device_id == device_id,
                Device.business_id == business.id,
            )

            if device:
                device.is_active = True
                device.last_sync_at = datetime.now(timezone.utc)
                await device.save()
            else:
                device = Device(
                    business_id=business.id,
                    user_id=user.id,
                    device_id=device_id,
                    device_name=device_name or "Unknown Device",
                    is_active=True,
                    last_sync_at=datetime.now(timezone.utc),
                )
                await device.insert()

            device_info = {"device_id": device.device_id, "business_id": str(business.id)}
        elif device_id and not businesses:
            # Log that device registration was skipped due to no businesses
            logger.info(
                "device_registration_skipped_no_business",
                user_id=str(user.id),
                device_id=device_id,
                message="User has no businesses. Device registration skipped. Create a business first."
            )

        logger.info("user_authenticated", user_id=str(user.id), phone=phone)

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "user": {
                "id": str(user.id),
                "phone": user.phone,
                "name": user.name,
                "email": user.get_email() if hasattr(user, 'get_email') else user.email,
                "language_preference": user.language_preference,
                "default_business_id": str(user.default_business_id) if user.default_business_id else None,
            },
            "businesses": [
                {
                    "id": str(business.id),
                    "name": business.name,
                    "role": next((m.role.value for m in memberships if m.business_id == business.id), "staff"),
                }
                for business in businesses
            ],
            "device": device_info,
            "language_preference": user.language_preference,
            "default_business_id": str(user.default_business_id) if user.default_business_id else None,
        }

    @staticmethod
    async def refresh_access_token(refresh_token: str) -> Dict[str, Any]:
        """Refresh access token using refresh token."""
        payload = verify_token(refresh_token, token_type="refresh")
        if not payload:
            raise AuthenticationError("Invalid or expired refresh token")

        user_id = payload.get("sub")
        if not user_id:
            raise AuthenticationError("Invalid token payload")

        # Verify refresh token in Redis
        redis = await get_redis()
        refresh_key = f"refresh_token:{user_id}"
        stored_token = await redis.get(refresh_key)

        if not stored_token or stored_token != refresh_token:
            raise AuthenticationError("Invalid refresh token")

        # Get user - try ObjectId first, then fallback
        try:
            from beanie import PydanticObjectId
            user = await User.get(PydanticObjectId(user_id))
        except (ValueError, TypeError):
            # Fallback for int IDs if needed
            user = await User.find_one(User.id == int(user_id), User.is_active == True)

        if not user or not user.is_active:
            raise AuthenticationError("User not found or inactive")

        # Create new access token
        access_token = create_access_token(data={"sub": str(user.id), "phone": user.phone})

        return {
            "access_token": access_token,
            "token_type": "bearer",
        }

    @staticmethod
    async def set_pin(user_id: str, pin: str) -> Dict[str, Any]:
        """Set PIN for user."""
        try:
            from beanie import PydanticObjectId
            user = await User.get(PydanticObjectId(user_id))
        except (ValueError, TypeError):
            user = await User.find_one(User.id == int(user_id))

        if not user:
            raise NotFoundError("User not found")

        user.pin_hash = get_password_hash(pin)
        await user.save()

        logger.info("pin_set", user_id=user_id)

        return {"message": "PIN set successfully"}

    @staticmethod
    async def verify_pin(user_id: str, pin: str) -> bool:
        """Verify PIN for user."""
        try:
            from beanie import PydanticObjectId
            user = await User.get(PydanticObjectId(user_id))
        except (ValueError, TypeError):
            user = await User.find_one(User.id == int(user_id))

        if not user or not user.pin_hash:
            return False

        return verify_password(pin, user.pin_hash)


# Singleton instance
auth_service = AuthService()
