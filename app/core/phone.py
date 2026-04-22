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
    parse_attempts: list[tuple[str, str | None]] = []
    parse_attempts.append((cleaned, default_region if not cleaned.startswith("+") else None))
    if not cleaned.startswith("+") and cleaned.isdigit():
        parse_attempts.append((f"+{cleaned}", None))

    for candidate, region in parse_attempts:
        try:
            parsed = phonenumbers.parse(candidate, region)
        except phonenumbers.NumberParseException:
            continue
        if phonenumbers.is_possible_number(parsed) and phonenumbers.is_valid_number(parsed):
            return phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164)

    raise ValidationError("Invalid phone number format")
