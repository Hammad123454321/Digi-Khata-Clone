"""Common validation utilities."""
from decimal import Decimal
from app.core.exceptions import BusinessLogicError


def validate_positive_amount(amount: Decimal, field_name: str = "amount") -> None:
    """Validate that an amount is positive."""
    if amount <= 0:
        raise BusinessLogicError(f"{field_name.capitalize()} must be positive")





