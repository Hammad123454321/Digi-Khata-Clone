"""Encrypted field utilities for Beanie/Pydantic models."""
from typing import Any
from pydantic import field_validator, Field
from app.core.security import encrypt_data, decrypt_data


def EncryptedStr(default: Any = None, **kwargs) -> Any:
    """
    Create an encrypted string field.
    Values are encrypted before storage and decrypted when accessed.
    """
    def encrypt_before_save(value: Any) -> Any:
        """Encrypt value before saving to database."""
        if value is None:
            return default
        if isinstance(value, str) and value:
            return encrypt_data(value)
        return value
    
    return Field(
        default=default,
        json_schema_extra={"encrypted": True},
        **kwargs
    )
