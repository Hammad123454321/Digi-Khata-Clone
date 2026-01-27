"""Reminder service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from beanie import PydanticObjectId

from app.core.exceptions import NotFoundError, ValidationError
from app.models.reminder import Reminder
from app.models.customer import CustomerBalance
from app.models.supplier import SupplierBalance
from app.core.logging import get_logger

logger = get_logger(__name__)


class ReminderService:
    """Reminder service for credit payments."""

    @staticmethod
    async def create_reminder(
        business_id: str,
        entity_type: str,
        entity_id: str,
        amount: Decimal,
        due_date: Optional[datetime] = None,
        message: Optional[str] = None,
    ) -> Reminder:
        """Create a reminder."""
        try:
            business_obj_id = PydanticObjectId(business_id)
            entity_obj_id = PydanticObjectId(entity_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business or entity ID format",
                {
                    "business_id": [f"'{business_id}' is not a valid ObjectId"],
                    "entity_id": [f"'{entity_id}' is not a valid ObjectId"],
                },
            )

        reminder = Reminder(
            business_id=business_obj_id,
            entity_type=entity_type,
            entity_id=entity_obj_id,
            amount=amount,
            due_date=due_date,
            message=message,
            is_sent=False,
            is_resolved=False,
        )
        await reminder.insert()

        logger.info("reminder_created", business_id=business_id, entity_type=entity_type, entity_id=entity_id)
        return reminder

    @staticmethod
    async def list_reminders(
        business_id: str,
        entity_type: Optional[str] = None,
        is_resolved: Optional[bool] = None,
    ) -> list[Reminder]:
        """List reminders."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )

        query = Reminder.find(Reminder.business_id == business_obj_id)

        if entity_type:
            query = query.find(Reminder.entity_type == entity_type)
        if is_resolved is not None:
            query = query.find(Reminder.is_resolved == is_resolved)

        # Sort by due_date if available, else by created_at
        reminders = await query.to_list()
        reminders.sort(key=lambda r: (r.due_date or datetime.min.replace(tzinfo=timezone.utc), r.created_at))
        
        return reminders

    @staticmethod
    async def resolve_reminder(reminder_id: str, business_id: str) -> None:
        """Resolve a reminder."""
        try:
            reminder_obj_id = PydanticObjectId(reminder_id)
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise NotFoundError("Reminder not found")

        reminder = await Reminder.find_one(
            Reminder.id == reminder_obj_id,
            Reminder.business_id == business_obj_id,
        )

        if not reminder:
            raise NotFoundError("Reminder not found")

        reminder.is_resolved = True
        reminder.resolved_at = datetime.now(timezone.utc)
        await reminder.save()


# Singleton instance
reminder_service = ReminderService()
