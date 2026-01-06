"""Stock management schemas."""
from datetime import datetime
from typing import Optional
from decimal import Decimal
from pydantic import BaseModel, Field


class ItemCreate(BaseModel):
    """Item creation schema."""

    name: str = Field(..., min_length=1, max_length=255)
    sku: Optional[str] = Field(None, max_length=100)
    barcode: Optional[str] = Field(None, max_length=100)
    purchase_price: Decimal = Field(..., ge=0)
    sale_price: Decimal = Field(..., ge=0)
    unit: str = Field(default="pcs", pattern="^(pcs|kg|liter|meter|box|pack)$")
    opening_stock: Decimal = Field(default=Decimal("0.000"), ge=0)
    min_stock_threshold: Optional[Decimal] = Field(None, ge=0)
    description: Optional[str] = None


class ItemUpdate(BaseModel):
    """Item update schema."""

    name: Optional[str] = Field(None, min_length=1, max_length=255)
    sku: Optional[str] = Field(None, max_length=100)
    barcode: Optional[str] = Field(None, max_length=100)
    purchase_price: Optional[Decimal] = Field(None, ge=0)
    sale_price: Optional[Decimal] = Field(None, ge=0)
    unit: Optional[str] = Field(None, pattern="^(pcs|kg|liter|meter|box|pack)$")
    min_stock_threshold: Optional[Decimal] = Field(None, ge=0)
    description: Optional[str] = None
    is_active: Optional[bool] = None


class ItemResponse(BaseModel):
    """Item response schema."""

    id: int
    name: str
    sku: Optional[str]
    barcode: Optional[str]
    purchase_price: Decimal
    sale_price: Decimal
    unit: str
    opening_stock: Decimal
    current_stock: Decimal
    min_stock_threshold: Optional[Decimal]
    is_active: bool
    description: Optional[str]

    class Config:
        from_attributes = True


class InventoryTransactionCreate(BaseModel):
    """Inventory transaction creation schema."""

    item_id: int
    transaction_type: str = Field(..., pattern="^(stock_in|stock_out|wastage|adjustment)$")
    quantity: Decimal = Field(..., gt=0)
    unit_price: Optional[Decimal] = Field(None, ge=0)
    date: datetime
    reference_id: Optional[int] = None
    reference_type: Optional[str] = Field(None, max_length=50)
    remarks: Optional[str] = None


class InventoryTransactionResponse(BaseModel):
    """Inventory transaction response schema."""

    id: int
    item_id: int
    transaction_type: str
    quantity: Decimal
    unit_price: Optional[Decimal]
    date: datetime
    reference_id: Optional[int]
    reference_type: Optional[str]
    remarks: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


class LowStockAlertResponse(BaseModel):
    """Low stock alert response schema."""

    id: int
    item_id: int
    item_name: str
    current_stock: Decimal
    threshold: Decimal
    is_resolved: bool
    created_at: datetime

    class Config:
        from_attributes = True

