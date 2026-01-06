"""Staff service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.exceptions import NotFoundError
from app.models.staff import Staff, StaffSalary
from app.core.logging import get_logger

logger = get_logger(__name__)


class StaffService:
    """Staff management service."""

    @staticmethod
    async def create_staff(
        business_id: int,
        name: str,
        phone: Optional[str] = None,
        email: Optional[str] = None,
        role: Optional[str] = None,
        address: Optional[str] = None,
        db: AsyncSession = None,
    ) -> Staff:
        """Create a new staff member."""
        staff = Staff(
            business_id=business_id,
            name=name,
            phone=phone,
            email=email,
            role=role,
            address=address,
            is_active=True,
        )
        db.add(staff)
        await db.flush()

        logger.info("staff_created", business_id=business_id, staff_id=staff.id, name=name)
        return staff

    @staticmethod
    async def get_staff(staff_id: int, business_id: int, db: AsyncSession) -> Staff:
        """Get staff by ID."""
        result = await db.execute(
            select(Staff).where(Staff.id == staff_id, Staff.business_id == business_id)
        )
        staff = result.scalar_one_or_none()

        if not staff:
            raise NotFoundError("Staff not found")

        return staff

    @staticmethod
    async def list_staff(
        business_id: int,
        is_active: Optional[bool] = None,
        limit: int = 100,
        offset: int = 0,
        db: AsyncSession = None,
    ) -> list[Staff]:
        """List staff."""
        query = select(Staff).where(Staff.business_id == business_id)

        if is_active is not None:
            query = query.where(Staff.is_active == is_active)

        query = query.order_by(Staff.name).limit(limit).offset(offset)

        result = await db.execute(query)
        return list(result.scalars().all())

    @staticmethod
    async def record_salary(
        business_id: int,
        staff_id: int,
        amount: Decimal,
        date: datetime,
        payment_mode: str,
        remarks: Optional[str] = None,
        user_id: Optional[int] = None,
        db: AsyncSession = None,
    ) -> StaffSalary:
        """Record staff salary."""
        staff = await StaffService.get_staff(staff_id, business_id, db)

        salary = StaffSalary(
            business_id=business_id,
            staff_id=staff_id,
            amount=amount,
            date=date,
            payment_mode=payment_mode,
            remarks=remarks,
            created_by_user_id=user_id,
        )
        db.add(salary)
        await db.flush()

        # Create cash transaction if payment mode is cash
        if payment_mode == "cash":
            from app.services.cash import cash_service
            await cash_service.create_transaction(
                business_id=business_id,
                transaction_type="cash_out",
                amount=amount,
                date=date,
                source="salary",
                remarks=f"Salary: {staff.name}",
                reference_id=salary.id,
                reference_type="salary",
                user_id=user_id,
                db=db,
            )

        logger.info("salary_recorded", business_id=business_id, staff_id=staff_id, amount=str(amount))
        return salary


# Singleton instance
staff_service = StaffService()

