"""Device service."""
from datetime import datetime, timezone, timedelta
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.core.exceptions import NotFoundError, BusinessLogicError, AuthenticationError
from app.models.device import Device
from app.core.security import generate_device_token
from app.core.config import get_settings
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)


class DeviceService:
    """Device management service."""

    @staticmethod
    async def generate_pairing_token(business_id: int, user_id: int, db: AsyncSession) -> dict:
        """Generate QR code pairing token."""
        # Check device limit
        device_count_result = await db.execute(
            select(func.count(Device.id)).where(
                Device.business_id == business_id,
                Device.is_active == True,
            )
        )
        device_count = device_count_result.scalar_one() or 0

        # Get business max_devices
        from app.models.business import Business
        business_result = await db.execute(select(Business).where(Business.id == business_id))
        business = business_result.scalar_one_or_none()
        max_devices = business.max_devices if business else settings.MAX_DEVICES_PER_BUSINESS

        if device_count >= max_devices:
            raise BusinessLogicError(f"Maximum device limit ({max_devices}) reached")

        # Generate token
        token = generate_device_token()
        expires_at = datetime.now(timezone.utc) + timedelta(minutes=10)  # 10 minute expiry

        # Store token in Redis
        from app.core.redis_client import get_redis
        redis = await get_redis()
        token_key = f"pairing_token:{token}"
        await redis.setex(
            token_key,
            600,  # 10 minutes
            f"{business_id}:{user_id}",
        )

        logger.info("pairing_token_generated", business_id=business_id, user_id=user_id)

        return {"pairing_token": token, "expires_at": expires_at}

    @staticmethod
    async def pair_device(
        business_id: int,
        user_id: int,
        device_id: str,
        pairing_token: str,
        device_name: Optional[str] = None,
        device_type: Optional[str] = None,
        db: AsyncSession = None,
    ) -> Device:
        """Pair a device using QR code token."""
        # Verify token
        from app.core.redis_client import get_redis
        redis = await get_redis()
        token_key = f"pairing_token:{pairing_token}"
        token_data = await redis.get(token_key)

        if not token_data:
            raise AuthenticationError("Invalid or expired pairing token")

        # Parse token data
        stored_business_id, stored_user_id = token_data.split(":")
        if int(stored_business_id) != business_id or int(stored_user_id) != user_id:
            raise AuthenticationError("Pairing token does not match business/user")

        # Delete token after use
        await redis.delete(token_key)

        # Check if device already exists
        result = await db.execute(
            select(Device).where(
                Device.device_id == device_id,
                Device.business_id == business_id,
            )
        )
        device = result.scalar_one_or_none()

        if device:
            # Reactivate existing device
            device.is_active = True
            device.last_sync_at = datetime.now(timezone.utc)
            device.user_id = user_id
            if device_name:
                device.device_name = device_name
            if device_type:
                device.device_type = device_type
        else:
            # Check device limit
            device_count_result = await db.execute(
                select(func.count(Device.id)).where(
                    Device.business_id == business_id,
                    Device.is_active == True,
                )
            )
            device_count = device_count_result.scalar_one() or 0

            from app.models.business import Business
            business_result = await db.execute(select(Business).where(Business.id == business_id))
            business = business_result.scalar_one_or_none()
            max_devices = business.max_devices if business else settings.MAX_DEVICES_PER_BUSINESS

            if device_count >= max_devices:
                raise BusinessLogicError(f"Maximum device limit ({max_devices}) reached")

            # Create new device
            device = Device(
                business_id=business_id,
                user_id=user_id,
                device_id=device_id,
                device_name=device_name or "Unknown Device",
                device_type=device_type or "android",
                is_active=True,
                last_sync_at=datetime.now(timezone.utc),
            )
            db.add(device)

        await db.flush()

        logger.info("device_paired", business_id=business_id, user_id=user_id, device_id=device_id)
        return device

    @staticmethod
    async def list_devices(business_id: int, db: AsyncSession) -> list[Device]:
        """List all devices for a business."""
        result = await db.execute(
            select(Device).where(
                Device.business_id == business_id,
                Device.is_active == True,
            ).order_by(Device.last_sync_at.desc())
        )
        return list(result.scalars().all())

    @staticmethod
    async def revoke_device(device_id: int, business_id: int, db: AsyncSession) -> None:
        """Revoke a device (immediate effect)."""
        result = await db.execute(
            select(Device).where(
                Device.id == device_id,
                Device.business_id == business_id,
            )
        )
        device = result.scalar_one_or_none()

        if not device:
            raise NotFoundError("Device not found")

        device.is_active = False
        await db.flush()

        logger.info("device_revoked", business_id=business_id, device_id=device_id)


# Singleton instance
device_service = DeviceService()

