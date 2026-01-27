"""Business service."""
from typing import Optional
from beanie import PydanticObjectId

from app.core.exceptions import NotFoundError, ConflictError, BusinessLogicError, ValidationError
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
        user_id: str,  # ObjectId string
        email: Optional[str] = None,
        address: Optional[str] = None,
        language_preference: str = "en",
        max_devices: int = 3,
    ) -> Business:
        """Create a new business and add user as owner."""
        # Check if phone already exists
        existing = await Business.find_one(Business.phone == phone)
        if existing:
            raise ConflictError("Business with this phone number already exists")

        # Create business
        business = Business(
            name=name,
            phone=phone,
            address=address,
            language_preference=language_preference,
            max_devices=max_devices,
            is_active=True,
        )
        if email:
            business.set_email(email)
        await business.insert()

        # Add user as owner
        try:
            user_obj_id = PydanticObjectId(user_id)
            membership = UserMembership(
                user_id=user_obj_id,
                business_id=business.id,
                role=UserRoleEnum.OWNER,
                is_active=True,
            )
            await membership.insert()
        except (ValueError, TypeError) as e:
            logger.error("invalid_user_id", user_id=user_id, error=str(e))
            raise ValidationError(
                "Invalid user ID format",
                {"user_id": [f"'{user_id}' is not a valid ObjectId"]},
            )

        logger.info("business_created", business_id=str(business.id), user_id=user_id)

        return business

    @staticmethod
    async def get_business(business_id: str) -> Business:
        """Get business by ID."""
        try:
            business = await Business.get(PydanticObjectId(business_id))
        except (ValueError, TypeError):
            raise NotFoundError("Business not found")

        if not business:
            raise NotFoundError("Business not found")

        return business

    @staticmethod
    async def update_business(
        business_id: str,
        name: Optional[str] = None,
        email: Optional[str] = None,
        address: Optional[str] = None,
        language_preference: Optional[str] = None,
        max_devices: Optional[int] = None,
    ) -> Business:
        """Update business."""
        business = await BusinessService.get_business(business_id)

        if name is not None:
            business.name = name
        if email is not None:
            business.set_email(email)
        if address is not None:
            business.address = address
        if language_preference is not None:
            business.language_preference = language_preference
        if max_devices is not None:
            # Check if reducing devices below current active count
            from app.models.device import Device
            active_devices = await Device.find(
                Device.business_id == business.id,
                Device.is_active == True,
            ).count()
            if max_devices < active_devices:
                raise BusinessLogicError(
                    f"Cannot set max_devices to {max_devices}. There are {active_devices} active devices."
                )
            business.max_devices = max_devices

        await business.save()

        logger.info("business_updated", business_id=business_id)

        return business

    @staticmethod
    async def list_user_businesses(user_id: str) -> list[Business]:
        """List all businesses for a user."""
        try:
            user_obj_id = PydanticObjectId(user_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid user ID format",
                {"user_id": [f"'{user_id}' is not a valid ObjectId"]},
            )

        memberships = await UserMembership.find(
            UserMembership.user_id == user_obj_id,
            UserMembership.is_active == True,
        ).to_list()

        # Get businesses
        businesses = []
        for membership in memberships:
            business = await Business.get(membership.business_id)
            if business:
                businesses.append(business)

        return businesses


# Singleton instance
business_service = BusinessService()
