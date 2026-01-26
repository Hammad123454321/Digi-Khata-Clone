"""Reminder endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Depends, Query

from app.api.dependencies import get_current_business
from app.models.business import Business
from app.services.reminder import reminder_service

router = APIRouter(prefix="/reminders", tags=["Reminders"])


@router.get("", response_model=List[dict])
async def list_reminders(
    entity_type: Optional[str] = Query(None, pattern="^(customer|supplier)$"),
    is_resolved: Optional[bool] = Query(None),
    current_business: Business = Depends(get_current_business),
):
    """List reminders."""
    reminders = await reminder_service.list_reminders(
        business_id=str(current_business.id),
        entity_type=entity_type,
        is_resolved=is_resolved,
    )
    return [
        {
            "id": str(r.id),
            "entity_type": r.entity_type,
            "entity_id": str(r.entity_id),
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
    reminder_id: str,
    current_business: Business = Depends(get_current_business),
):
    """Resolve a reminder."""
    await reminder_service.resolve_reminder(reminder_id, str(current_business.id))
    return {"message": "Reminder resolved"}
