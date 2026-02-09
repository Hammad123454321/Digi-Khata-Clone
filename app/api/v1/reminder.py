"""Reminder endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Depends, Query, HTTPException

from app.api.dependencies import get_current_business
from app.models.business import Business
from app.services.reminder import reminder_service
from app.services.customer import customer_service
from app.services.supplier import supplier_service
from app.services.sms import sms_service
from app.schemas.reminder import ReminderCreate, ReminderResponse

router = APIRouter(prefix="/reminders", tags=["Reminders"])


async def _get_entity_details(entity_type: str, entity_id: str, business_id: str):
    if entity_type == "customer":
        customer = await customer_service.get_customer(entity_id, business_id)
        phone = customer.get_phone() if hasattr(customer, "get_phone") else customer.phone
        return customer.name, phone
    if entity_type == "supplier":
        supplier = await supplier_service.get_supplier(entity_id, business_id)
        phone = supplier.get_phone() if hasattr(supplier, "get_phone") else supplier.phone
        return supplier.name, phone
    return None, None


@router.get("", response_model=List[ReminderResponse])
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
    response: list[ReminderResponse] = []
    for r in reminders:
        name, phone = await _get_entity_details(
            r.entity_type, str(r.entity_id), str(current_business.id)
        )
        response.append(
            ReminderResponse(
                id=str(r.id),
                entity_type=r.entity_type,
                entity_id=str(r.entity_id),
                entity_name=name,
                entity_phone=phone,
                amount=r.amount,
                due_date=r.due_date,
                message=r.message,
                is_sent=r.is_sent,
                sent_at=r.sent_at,
                is_resolved=r.is_resolved,
                resolved_at=r.resolved_at,
                created_at=r.created_at,
            )
        )
    return response


@router.post("", response_model=ReminderResponse, status_code=201)
async def create_reminder(
    data: ReminderCreate,
    current_business: Business = Depends(get_current_business),
):
    """Create a reminder (optionally send SMS)."""
    reminder = await reminder_service.create_reminder(
        business_id=str(current_business.id),
        entity_type=data.entity_type,
        entity_id=data.entity_id,
        amount=data.amount,
        due_date=data.due_date,
        message=data.message,
    )

    name, phone = await _get_entity_details(
        data.entity_type, data.entity_id, str(current_business.id)
    )

    if data.send_sms:
        if not phone:
            raise HTTPException(status_code=400, detail="Entity phone number is missing")
        message = data.message or _build_default_message(name, data.amount, data.due_date)
        sent = await sms_service.send_notification(phone, message)
        if sent:
            await reminder_service.mark_sent(reminder)
        else:
            raise HTTPException(status_code=502, detail="Failed to send SMS")

    return ReminderResponse(
        id=str(reminder.id),
        entity_type=reminder.entity_type,
        entity_id=str(reminder.entity_id),
        entity_name=name,
        entity_phone=phone,
        amount=reminder.amount,
        due_date=reminder.due_date,
        message=reminder.message,
        is_sent=reminder.is_sent,
        sent_at=reminder.sent_at,
        is_resolved=reminder.is_resolved,
        resolved_at=reminder.resolved_at,
        created_at=reminder.created_at,
    )


@router.post("/{reminder_id}/send", response_model=ReminderResponse)
async def send_reminder_sms(
    reminder_id: str,
    current_business: Business = Depends(get_current_business),
):
    """Send reminder SMS."""
    reminder = await reminder_service.get_reminder(
        reminder_id, str(current_business.id)
    )
    name, phone = await _get_entity_details(
        reminder.entity_type, str(reminder.entity_id), str(current_business.id)
    )
    if not phone:
        raise HTTPException(status_code=400, detail="Entity phone number is missing")
    message = reminder.message or _build_default_message(name, reminder.amount, reminder.due_date)
    sent = await sms_service.send_notification(phone, message)
    if not sent:
        raise HTTPException(status_code=502, detail="Failed to send SMS")
    await reminder_service.mark_sent(reminder)
    return ReminderResponse(
        id=str(reminder.id),
        entity_type=reminder.entity_type,
        entity_id=str(reminder.entity_id),
        entity_name=name,
        entity_phone=phone,
        amount=reminder.amount,
        due_date=reminder.due_date,
        message=reminder.message,
        is_sent=reminder.is_sent,
        sent_at=reminder.sent_at,
        is_resolved=reminder.is_resolved,
        resolved_at=reminder.resolved_at,
        created_at=reminder.created_at,
    )


@router.post("/{reminder_id}/resolve", status_code=200)
async def resolve_reminder(
    reminder_id: str,
    current_business: Business = Depends(get_current_business),
):
    """Resolve a reminder."""
    await reminder_service.resolve_reminder(reminder_id, str(current_business.id))
    return {"message": "Reminder resolved"}


def _build_default_message(name: Optional[str], amount, due_date) -> str:
    parts = ["Payment reminder"]
    if name:
        parts.append(f"for {name}")
    parts.append(f"amount {amount}")
    if due_date:
        parts.append(f"due on {due_date.date().isoformat()}")
    return " ".join(parts)
