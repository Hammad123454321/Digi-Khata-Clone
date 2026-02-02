"""Business model."""
from typing import Optional
import enum
from pydantic import Field
from beanie import Indexed

from app.models.base import BaseModel
from app.core.security import encrypt_data, decrypt_data


class BusinessTypeEnum(str, enum.Enum):
    RETAIL_SHOP = "retail_shop"
    WHOLESALE = "wholesale"
    DISTRIBUTOR = "distributor"
    SERVICES = "services"
    MANUFACTURING = "manufacturing"
    RESTAURANT_FOOD = "restaurant_food"
    OTHER = "other"


class Business(BaseModel):
    """Business/tenant model."""

    name: Indexed(str)
    phone: Indexed(str, unique=True)  # Keep unencrypted for lookups
    owner_name: Optional[str] = None
    email: Optional[str] = Field(default=None)  # Encrypted email
    address: Optional[str] = None
    area: Optional[str] = None
    city: Optional[str] = None
    business_category: Optional[str] = None
    is_active: bool = Field(default=True)
    language_preference: str = Field(default="en")  # en, ur, ar
    max_devices: int = Field(default=3)
    business_type: BusinessTypeEnum = Field(default=BusinessTypeEnum.OTHER)
    custom_business_type: Optional[str] = None  # For "Other" option

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
