"""Authentication service."""
from datetime import datetime, timedelta, timezone
from typing import Optional, Dict, Any

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

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
from app.models.user import User, UserMembership, UserRoleEnum
from app.models.business import Business
from app.services.sms import sms_service
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)


class AuthService:
    """Authentication service."""

    @staticmethod
    async def request_otp(phone: str, db: AsyncSession) -> Dict[str, Any]:
        """Request OTP for phone number."""
        # Normalize phone number
        phone = phone.strip().replace(" ", "").replace("-", "")

        # Check rate limiting
        redis = await get_redis()
        rate_limit_key = f"otp_rate_limit:{phone}"
        attempts = await redis.get(rate_limit_key)
        if attempts and int(attempts) >= settings.OTP_MAX_ATTEMPTS:
            raise BusinessLogicError(
                f"Maximum OTP attempts reached. Please try again after {settings.OTP_EXPIRE_MINUTES} minutes."
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

        return {"message": "OTP sent successfully", "expires_in_minutes": settings.OTP_EXPIRE_MINUTES}

    @staticmethod
    async def verify_otp(phone: str, otp: str, device_id: Optional[str], device_name: Optional[str], db: AsyncSession) -> Dict[str, Any]:
        """Verify OTP and return tokens."""
        phone = phone.strip().replace(" ", "").replace("-", "")

        # Verify OTP from Redis
        redis = await get_redis()
        otp_key = f"otp:{phone}"
        stored_otp = await redis.get(otp_key)

        if not stored_otp or stored_otp != otp:
            raise AuthenticationError("Invalid or expired OTP")

        # Delete OTP after successful verification
        await redis.delete(otp_key)

        # Get or create user
        result = await db.execute(select(User).where(User.phone == phone))
        user = result.scalar_one_or_none()

        if not user:
            # Create new user
            user = User(phone=phone, is_active=True)
            db.add(user)
            await db.flush()
            logger.info("user_created", user_id=user.id, phone=phone)

        # Update last login
        user.last_login_at = datetime.now(timezone.utc)
        await db.flush()

        # Get user's businesses
        result = await db.execute(
            select(UserMembership)
            .where(UserMembership.user_id == user.id, UserMembership.is_active == True)
            .options(selectinload(UserMembership.business))
        )
        memberships = result.scalars().all()

        # Create tokens
        access_token = create_access_token(data={"sub": str(user.id), "phone": user.phone})
        refresh_token = create_refresh_token(data={"sub": str(user.id), "phone": user.phone})

        # Store refresh token in Redis
        refresh_key = f"refresh_token:{user.id}"
        await redis.setex(refresh_key, settings.REFRESH_TOKEN_EXPIRE_DAYS * 24 * 60 * 60, refresh_token)

        # Handle device registration if provided
        device_info = None
        if device_id:
            from app.models.device import Device
            from app.core.security import generate_device_token

            # Get first business for device registration (user can add more later)
            if memberships:
                business = memberships[0].business
                # Check device limit
                device_count_result = await db.execute(
                    select(Device).where(Device.business_id == business.id, Device.is_active == True)
                )
                device_count = len(device_count_result.scalars().all())

                if device_count >= business.max_devices:
                    raise BusinessLogicError(f"Maximum device limit ({business.max_devices}) reached for this business")

                # Check if device already exists
                device_result = await db.execute(
                    select(Device).where(Device.device_id == device_id, Device.business_id == business.id)
                )
                device = device_result.scalar_one_or_none()

                if device:
                    device.is_active = True
                    device.last_sync_at = datetime.now(timezone.utc)
                else:
                    device = Device(
                        business_id=business.id,
                        user_id=user.id,
                        device_id=device_id,
                        device_name=device_name or "Unknown Device",
                        is_active=True,
                        last_sync_at=datetime.now(timezone.utc),
                    )
                    db.add(device)

                await db.flush()
                device_info = {"device_id": device.device_id, "business_id": business.id}

        logger.info("user_authenticated", user_id=user.id, phone=phone)

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "user": {
                "id": user.id,
                "phone": user.phone,
                "name": user.name,
                "email": user.email,
            },
            "businesses": [
                {
                    "id": m.business.id,
                    "name": m.business.name,
                    "role": m.role.value,
                }
                for m in memberships
            ],
            "device": device_info,
        }

    @staticmethod
    async def refresh_access_token(refresh_token: str, db: AsyncSession) -> Dict[str, Any]:
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

        # Get user
        result = await db.execute(select(User).where(User.id == int(user_id), User.is_active == True))
        user = result.scalar_one_or_none()

        if not user:
            raise AuthenticationError("User not found or inactive")

        # Create new access token
        access_token = create_access_token(data={"sub": str(user.id), "phone": user.phone})

        return {
            "access_token": access_token,
            "token_type": "bearer",
        }

    @staticmethod
    async def set_pin(user_id: int, pin: str, db: AsyncSession) -> Dict[str, Any]:
        """Set PIN for user."""
        result = await db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()

        if not user:
            raise NotFoundError("User not found")

        user.pin_hash = get_password_hash(pin)
        await db.flush()

        logger.info("pin_set", user_id=user_id)

        return {"message": "PIN set successfully"}

    @staticmethod
    async def verify_pin(user_id: int, pin: str, db: AsyncSession) -> bool:
        """Verify PIN for user."""
        result = await db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()

        if not user or not user.pin_hash:
            return False

        return verify_password(pin, user.pin_hash)


# Singleton instance
auth_service = AuthService()

