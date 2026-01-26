"""Staff service."""
from datetime import datetime, timezone
from typing import Optional
from decimal import Decimal
from beanie import PydanticObjectId

from app.core.exceptions import NotFoundError, BusinessLogicError
from app.core.validators import validate_positive_amount
from app.models.staff import Staff, StaffSalary
from app.core.logging import get_logger

logger = get_logger(__name__)


class StaffService:
    """Staff management service."""

    @staticmethod
    async def create_staff(
        business_id: str,
        name: str,
        phone: Optional[str] = None,
        email: Optional[str] = None,
        role: Optional[str] = None,
        address: Optional[str] = None,
    ) -> Staff:
        """Create a new staff member."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        staff = Staff(
            business_id=business_obj_id,
            name=name,
            role=role,
            address=address,
            is_active=True,
        )
        if phone:
            staff.set_phone(phone)
        if email:
            staff.set_email(email)
        await staff.insert()

        logger.info("staff_created", business_id=business_id, staff_id=str(staff.id), name=name)
        return staff

    @staticmethod
    async def get_staff(staff_id: str, business_id: str) -> Staff:
        """Get staff by ID."""
        try:
            staff_obj_id = PydanticObjectId(staff_id)
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise NotFoundError("Staff not found")

        staff = await Staff.find_one(
            Staff.id == staff_obj_id,
            Staff.business_id == business_obj_id,
        )

        if not staff:
            raise NotFoundError("Staff not found")

        return staff

    @staticmethod
    async def list_staff(
        business_id: str,
        is_active: Optional[bool] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Staff]:
        """List staff."""
        try:
            business_obj_id = PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValueError(f"Invalid business ID format: {business_id}")

        query = Staff.find(Staff.business_id == business_obj_id)

        if is_active is not None:
            query = query.find(Staff.is_active == is_active)

        staff_list = await query.sort("+name").skip(offset).limit(limit).to_list()
        return staff_list

    @staticmethod
    async def record_salary(
        business_id: str,
        staff_id: str,
        amount: Decimal,
        date: datetime,
        payment_mode: str,
        remarks: Optional[str] = None,
        user_id: Optional[str] = None,
    ) -> StaffSalary:
        """Record staff salary."""
        validate_positive_amount(amount, "salary amount")
        
        try:
            business_obj_id = PydanticObjectId(business_id)
            staff_obj_id = PydanticObjectId(staff_id)
        except (ValueError, TypeError):
            raise ValueError("Invalid business or staff ID format")

        staff = await StaffService.get_staff(staff_id, business_id)

        user_obj_id = None
        if user_id:
            try:
                user_obj_id = PydanticObjectId(user_id)
            except (ValueError, TypeError):
                pass

        salary = StaffSalary(
            business_id=business_obj_id,
            staff_id=staff_obj_id,
            amount=amount,
            date=date,
            payment_mode=payment_mode,
            remarks=remarks,
            created_by_user_id=user_obj_id,
        )
        await salary.insert()

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
                reference_id=str(salary.id),
                reference_type="salary",
                user_id=user_id,
            )
        elif payment_mode == "bank":
            # Create bank transaction for bank-paid salaries
            from app.models.bank import BankAccount
            from app.services.bank import bank_service
            
            # Get first active bank account for the business
            bank_account = await BankAccount.find_one(
                BankAccount.business_id == business_obj_id,
                BankAccount.is_active == True,
            )
            
            if bank_account:
                await bank_service.create_transaction(
                    business_id=business_id,
                    bank_account_id=str(bank_account.id),
                    transaction_type="withdrawal",
                    amount=amount,
                    date=date,
                    remarks=remarks or f"Salary: {staff.name}",
                    user_id=user_id,
                )
            else:
                logger.warning(
                    "salary_bank_no_account",
                    business_id=business_id,
                    staff_id=staff_id,
                    salary_id=str(salary.id),
                    message="Bank salary created but no active bank account found",
                )

        logger.info("salary_recorded", business_id=business_id, staff_id=staff_id, amount=str(amount))
        return salary


# Singleton instance
staff_service = StaffService()
