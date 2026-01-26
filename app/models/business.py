"""Business model."""
from typing import Optional
from pydantic import Field, Index
from beanie import Indexed

from app.models.base import BaseModel
from app.core.security import encrypt_data, decrypt_data


class Business(BaseModel):
    """Business/tenant model."""

    name: Indexed(str, index_type=Index.ASCENDING)
    phone: Indexed(str, unique=True, index_type=Index.ASCENDING)  # Keep unencrypted for lookups
    email: Optional[str] = Field(default=None)  # Encrypted email
    address: Optional[str] = None
    is_active: bool = Field(default=True)
    language_preference: str = Field(default="en")  # en, ur
    max_devices: int = Field(default=3)

    class Settings:
        name = "businesses"
        indexes = [
            [("name", 1)],
            [("phone", 1)],
            [("is_active", 1)],
        ]

    def set_email(self, email: str) -> None:
        """Set encrypted email."""
        if email:
            self.email = encrypt_data(email)
    
    def get_email(self) -> Optional[str]:
        """Get decrypted email."""
        if self.email:
            return decrypt_data(self.email)
        return None
