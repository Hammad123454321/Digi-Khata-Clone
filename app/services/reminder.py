"""Reminder service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.exceptions import NotFoundError
from app.models.reminder import Reminder
from app.models.customer import CustomerBalance
from app.models.supplier import SupplierBalance
from app.core.logging import get_logger

logger = get_logger(__name__)


class ReminderService:
    """Reminder service for credit payments."""

    @staticmethod
    async def create_reminder(
        business_id: int,
        entity_type: str,
        entity_id: int,
        amount: Decimal,
        due_date: Optional[datetime] = None,
        message: Optional[str] = None,
        db: AsyncSession = None,
    ) -> Reminder:
        """Create a reminder."""
        reminder = Reminder(
            business_id=business_id,
            entity_type=entity_type,
            entity_id=entity_id,
            amount=amount,
            due_date=due_date,
            message=message,
            is_sent=False,
            is_resolved=False,
        )
        db.add(reminder)
        await db.flush()

        logger.info("reminder_created", business_id=business_id, entity_type=entity_type, entity_id=entity_id)
        return reminder

    @staticmethod
    async def list_reminders(
        business_id: int,
        entity_type: Optional[str] = None,
        is_resolved: Optional[bool] = None,
        db: AsyncSession = None,
    ) -> list[Reminder]:
        """List reminders."""
        query = select(Reminder).where(Reminder.business_id == business_id)

        if entity_type:
            query = query.where(Reminder.entity_type == entity_type)
        if is_resolved is not None:
            query = query.where(Reminder.is_resolved == is_resolved)

        query = query.order_by(Reminder.due_date.asc() if Reminder.due_date else Reminder.created_at.desc())

        result = await db.execute(query)
        return list(result.scalars().all())

    @staticmethod
    async def resolve_reminder(reminder_id: int, business_id: int, db: AsyncSession) -> None:
        """Resolve a reminder."""
        result = await db.execute(
            select(Reminder).where(
                Reminder.id == reminder_id,
                Reminder.business_id == business_id,
            )
        )
        reminder = result.scalar_one_or_none()

        if not reminder:
            raise NotFoundError("Reminder not found")

        reminder.is_resolved = True
        reminder.resolved_at = datetime.now(timezone.utc)
        await db.flush()


# Singleton instance
reminder_service = ReminderService()

