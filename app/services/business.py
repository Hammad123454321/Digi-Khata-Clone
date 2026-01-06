"""Business service."""
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.exceptions import NotFoundError, ConflictError, BusinessLogicError
from app.models.business import Business
from app.models.user import User, UserMembership, UserRoleEnum
from app.core.logging import get_logger

logger = get_logger(__name__)


class BusinessService:
    """Business management service."""

    @staticmethod
    async def create_business(
        name: str,
        phone: str,
        user_id: int,
        email: Optional[str] = None,
        address: Optional[str] = None,
        language_preference: str = "en",
        max_devices: int = 3,
        db: AsyncSession = None,
    ) -> Business:
        """Create a new business and add user as owner."""
        # Check if phone already exists
        result = await db.execute(select(Business).where(Business.phone == phone))
        existing = result.scalar_one_or_none()
        if existing:
            raise ConflictError("Business with this phone number already exists")

        # Create business
        business = Business(
            name=name,
            phone=phone,
            email=email,
            address=address,
            language_preference=language_preference,
            max_devices=max_devices,
            is_active=True,
        )
        db.add(business)
        await db.flush()

        # Add user as owner
        membership = UserMembership(
            user_id=user_id,
            business_id=business.id,
            role=UserRoleEnum.OWNER,
            is_active=True,
        )
        db.add(membership)
        await db.flush()

        logger.info("business_created", business_id=business.id, user_id=user_id)

        return business

    @staticmethod
    async def get_business(business_id: int, db: AsyncSession) -> Business:
        """Get business by ID."""
        result = await db.execute(select(Business).where(Business.id == business_id))
        business = result.scalar_one_or_none()

        if not business:
            raise NotFoundError("Business not found")

        return business

    @staticmethod
    async def update_business(
        business_id: int,
        name: Optional[str] = None,
        email: Optional[str] = None,
        address: Optional[str] = None,
        language_preference: Optional[str] = None,
        max_devices: Optional[int] = None,
        db: AsyncSession = None,
    ) -> Business:
        """Update business."""
        business = await BusinessService.get_business(business_id, db)

        if name is not None:
            business.name = name
        if email is not None:
            business.email = email
        if address is not None:
            business.address = address
        if language_preference is not None:
            business.language_preference = language_preference
        if max_devices is not None:
            # Check if reducing devices below current active count
            from app.models.device import Device
            device_count_result = await db.execute(
                select(Device).where(Device.business_id == business_id, Device.is_active == True)
            )
            active_devices = len(device_count_result.scalars().all())
            if max_devices < active_devices:
                raise BusinessLogicError(
                    f"Cannot set max_devices to {max_devices}. There are {active_devices} active devices."
                )
            business.max_devices = max_devices

        await db.flush()

        logger.info("business_updated", business_id=business_id)

        return business

    @staticmethod
    async def list_user_businesses(user_id: int, db: AsyncSession) -> list[Business]:
        """List all businesses for a user."""
        result = await db.execute(
            select(Business)
            .join(UserMembership)
            .where(UserMembership.user_id == user_id, UserMembership.is_active == True)
        )
        businesses = result.scalars().all()

        return list(businesses)


# Singleton instance
business_service = BusinessService()

