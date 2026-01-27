"""Device service."""
from datetime import datetime, timezone, timedelta
from typing import Optional
from beanie import PydanticObjectId

from app.core.exceptions import NotFoundError, BusinessLogicError, AuthenticationError, ValidationError
from app.models.device import Device
from app.core.security import generate_device_token
from app.core.config import get_settings
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)


class DeviceService:
    """Device management service."""

    @staticmethod
    async def generate_pairing_token(business_id: str, user_id: str) -> dict:
        """Generate QR code pairing token."""
        try:
            business_obj_id = PydanticObjectId(business_id)
            user_obj_id = PydanticObjectId(user_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business or user ID format",
                {
                    "business_id": [f"'{business_id}' is not a valid ObjectId"],
                    "user_id": [f"'{user_id}' is not a valid ObjectId"],
                },
            )

        # Check device limit
        device_count = await Device.find(
            Device.business_id == business_obj_id,
            Device.is_active == True,
        ).count()

        # Get business max_devices
        from app.models.business import Business
        business = await Business.get(business_obj_id)
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
        business_id: str,
        user_id: str,
        device_id: str,
        pairing_token: str,
        device_name: Optional[str] = None,
        device_type: Optional[str] = None,
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
        if stored_business_id != business_id or stored_user_id != user_id:
            raise AuthenticationError("Pairing token does not match business/user")

        # Delete token after use
        await redis.delete(token_key)

        try:
            business_obj_id = PydanticObjectId(business_id)
            user_obj_id = PydanticObjectId(user_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business or user ID format",
                {
                    "business_id": [f"'{business_id}' is not a valid ObjectId"],
                    "user_id": [f"'{user_id}' is not a valid ObjectId"],
                },
            )

        # Check if device already exists
        device = await Device.find_one(
            Device.device_id == device_id,
            Device.business_id == business_obj_id,
        )

        if device:
            # Reactivate existing device
            device.is_active = True
            device.last_sync_at = datetime.now(timezone.utc)
            device.user_id = user_obj_id
            if device_name:
                device.device_name = device_name
            if device_type:
                device.device_type = device_type
            await device.save()
        else:
            # Check device limit
            device_count = await Device.find(
                Device.business_id == business_obj_id,
                Device.is_active == True,
            ).count()

            from app.models.business import Business
            business = await Business.get(business_obj_id)
            max_devices = business.max_devices if business else settings.MAX_DEVICES_PER_BUSINESS

            if device_count >= max_devices:
                raise BusinessLogicError(f"Maximum device limit ({max_devices}) reached")

            # Create new device
            device = Device(
                business_id=business_obj_id,
                user_id=user_obj_id,
                device_id=device_id,
                device_name=device_name or "Unknown Device",
                device_type=device_type or "android",
                is_active=True,
                last_sync_at=datetime.now(timezone.utc),
            )
            await device.insert()

        logger.info("device_paired", business_id=business_id, user_id=user_id, device_id=device_id)
        return device

    @staticmethod
    async def list_devices(business_id: str) -> list[Device]:
        """List all devices for a business."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        devices = await Device.find(
            Device.business_id == business_obj_id,
            Device.is_active == True,
        ).sort("-last_sync_at").to_list()
        return devices

    @staticmethod
    async def revoke_device(device_id: str, business_id: str) -> None:
        """Revoke a device (immediate effect)."""
        try:
            device_obj_id = PydanticObjectId(device_id)
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise NotFoundError("Device not found")

        device = await Device.find_one(
            Device.id == device_obj_id,
            Device.business_id == business_obj_id,
        )

        if not device:
            raise NotFoundError("Device not found")

        device.is_active = False
        await device.save()

        logger.info("device_revoked", business_id=business_id, device_id=device_id)


# Singleton instance
device_service = DeviceService()
