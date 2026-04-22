"""Phone-number normalization helpers."""
from __future__ import annotations

import re

import phonenumbers

from app.core.exceptions import ValidationError

DEFAULT_REGION = "SA"


def normalize_phone_number(
    phone: str,
    *,
    default_region: str = DEFAULT_REGION,
) -> str:
    """Normalize user-provided phone into E.164."""
    if not isinstance(phone, str):
        raise ValidationError("Phone number is required")

    cleaned = re.sub(r"[\s\-\(\)]", "", phone).strip()
    if not cleaned:
        raise ValidationError("Phone number is required")
    if cleaned.startswith("00"):
        cleaned = f"+{cleaned[2:]}"

    try:
        parsed = phonenumbers.parse(cleaned, default_region)
    except phonenumbers.NumberParseException as exc:
        raise ValidationError("Invalid phone number format") from exc

    if not phonenumbers.is_possible_number(parsed) or not phonenumbers.is_valid_number(parsed):
        raise ValidationError("Invalid phone number format")

    return phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164)

