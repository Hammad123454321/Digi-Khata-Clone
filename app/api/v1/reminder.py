"""Reminder endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.dependencies import get_current_business
from app.models.business import Business
from app.services.reminder import reminder_service

router = APIRouter(prefix="/reminders", tags=["Reminders"])


@router.get("", response_model=List[dict])
async def list_reminders(
    entity_type: Optional[str] = Query(None, pattern="^(customer|supplier)$"),
    is_resolved: Optional[bool] = Query(None),
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """List reminders."""
    reminders = await reminder_service.list_reminders(
        business_id=current_business.id,
        entity_type=entity_type,
        is_resolved=is_resolved,
        db=db,
    )
    return [
        {
            "id": r.id,
            "entity_type": r.entity_type,
            "entity_id": r.entity_id,
            "amount": r.amount,
            "due_date": r.due_date,
            "message": r.message,
            "is_resolved": r.is_resolved,
            "created_at": r.created_at,
        }
        for r in reminders
    ]


@router.post("/{reminder_id}/resolve", status_code=200)
async def resolve_reminder(
    reminder_id: int,
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """Resolve a reminder."""
    await reminder_service.resolve_reminder(reminder_id, current_business.id, db)
    await db.commit()
    return {"message": "Reminder resolved"}

