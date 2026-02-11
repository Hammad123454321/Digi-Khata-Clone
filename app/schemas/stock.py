"""Stock management schemas."""
from datetime import datetime
from typing import Optional, Any
from decimal import Decimal
from pydantic import BaseModel, Field, model_validator


class ItemCreate(BaseModel):
    """Item creation schema."""

    name: str = Field(..., min_length=1, max_length=255)
    purchase_price: Decimal = Field(..., ge=0)
    sale_price: Decimal = Field(..., ge=0)
    unit: str = Field(default="pcs", pattern="^(pcs|kg|liter|meter|box|pack)$")
    opening_stock: Decimal = Field(default=Decimal("0.000"), ge=0)
    description: Optional[str] = None

    @model_validator(mode='before')
    @classmethod
    def convert_decimal_fields(cls, data: Any) -> Any:
        """Convert numeric fields to Decimal for proper validation."""
        if isinstance(data, dict):
            decimal_fields = ['purchase_price', 'sale_price', 'opening_stock']
            converted = data.copy()
            for field in decimal_fields:
                if field in converted and converted[field] is not None:
                    try:
                        # Convert int, float, or string to Decimal
                        if isinstance(converted[field], (int, float, str)):
                            converted[field] = Decimal(str(converted[field]))
                    except (ValueError, TypeError):
                        # If conversion fails, let Pydantic handle the error
                        pass
            return converted
        return data


class ItemUpdate(BaseModel):
    """Item update schema."""

    name: Optional[str] = Field(None, min_length=1, max_length=255)
    purchase_price: Optional[Decimal] = Field(None, ge=0)
    sale_price: Optional[Decimal] = Field(None, ge=0)
    unit: Optional[str] = Field(None, pattern="^(pcs|kg|liter|meter|box|pack)$")
    description: Optional[str] = None
    is_active: Optional[bool] = None


class ItemResponse(BaseModel):
    """Item response schema."""

    id: str
    name: str
    purchase_price: Decimal
    sale_price: Decimal
    unit: str
    opening_stock: Decimal
    current_stock: Decimal
    is_active: bool
    description: Optional[str]

    class Config:
        from_attributes = True


class InventoryTransactionCreate(BaseModel):
    """Inventory transaction creation schema."""

    item_id: str
    transaction_type: str = Field(..., pattern="^(stock_in|stock_out|wastage|adjustment)$")
    quantity: Decimal = Field(..., gt=0)
    unit_price: Optional[Decimal] = Field(None, ge=0)
    date: datetime
    reference_id: Optional[str] = None
    reference_type: Optional[str] = Field(None, max_length=50)
    remarks: Optional[str] = None


class InventoryTransactionResponse(BaseModel):
    """Inventory transaction response schema."""

    id: str
    item_id: str
    transaction_type: str
    quantity: Decimal
    unit_price: Optional[Decimal]
    date: datetime
    reference_id: Optional[str]
    reference_type: Optional[str]
    remarks: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


class LowStockAlertResponse(BaseModel):
    """Low stock alert response schema."""

    id: str
    item_id: str
    item_name: str
    current_stock: Decimal
    threshold: Decimal
    is_resolved: bool
    created_at: datetime

    class Config:
        from_attributes = True
