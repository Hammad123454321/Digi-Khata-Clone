"""Stock management endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Depends, Query

from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.models.item import Item
from app.schemas.stock import (
    ItemCreate,
    ItemUpdate,
    ItemResponse,
    InventoryTransactionCreate,
    InventoryTransactionResponse,
    LowStockAlertResponse,
)
from app.services.stock import stock_service

router = APIRouter(prefix="/stock", tags=["Stock Management"])


@router.post("/items", response_model=ItemResponse, status_code=201)
async def create_item(
    data: ItemCreate,
    current_business: Business = Depends(get_current_business),
):
    """Create a new item."""
    item = await stock_service.create_item(
        business_id=str(current_business.id),
        name=data.name,
        purchase_price=data.purchase_price,
        sale_price=data.sale_price,
        unit=data.unit,
        opening_stock=data.opening_stock,
        sku=data.sku,
        barcode=data.barcode,
        min_stock_threshold=data.min_stock_threshold,
        description=data.description,
    )
    return item


@router.get("/items", response_model=List[ItemResponse])
async def list_items(
    is_active: Optional[bool] = Query(None),
    search: Optional[str] = Query(None),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
):
    """List items."""
    items = await stock_service.list_items(
        business_id=str(current_business.id),
        is_active=is_active,
        search=search,
        limit=limit,
        offset=offset,
    )
    return items


@router.get("/items/{item_id}", response_model=ItemResponse)
async def get_item(
    item_id: str,
    current_business: Business = Depends(get_current_business),
):
    """Get item details."""
    return await stock_service.get_item(item_id, str(current_business.id))


@router.patch("/items/{item_id}", response_model=ItemResponse)
async def update_item(
    item_id: str,
    data: ItemUpdate,
    current_business: Business = Depends(get_current_business),
):
    """Update an item."""
    item = await stock_service.update_item(
        item_id=item_id,
        business_id=str(current_business.id),
        name=data.name,
        sku=data.sku,
        barcode=data.barcode,
        purchase_price=data.purchase_price,
        sale_price=data.sale_price,
        unit=data.unit,
        min_stock_threshold=data.min_stock_threshold,
        description=data.description,
        is_active=data.is_active,
    )
    return item


@router.post("/transactions", response_model=InventoryTransactionResponse, status_code=201)
async def create_inventory_transaction(
    data: InventoryTransactionCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
):
    """Create an inventory transaction."""
    transaction = await stock_service.create_inventory_transaction(
        business_id=str(current_business.id),
        item_id=str(data.item_id),
        transaction_type=data.transaction_type,
        quantity=data.quantity,
        date=data.date,
        unit_price=data.unit_price,
        reference_id=str(data.reference_id) if data.reference_id else None,
        reference_type=data.reference_type,
        remarks=data.remarks,
        user_id=str(current_user.id),
    )
    return transaction


@router.get("/alerts", response_model=List[LowStockAlertResponse])
async def list_low_stock_alerts(
    is_resolved: Optional[bool] = Query(None),
    current_business: Business = Depends(get_current_business),
):
    """List low stock alerts."""
    alerts = await stock_service.list_low_stock_alerts(
        business_id=str(current_business.id),
        is_resolved=is_resolved,
    )
    # Load all items in one query
    result = []
    if alerts:
        item_ids = [alert.item_id for alert in alerts]
        items = await Item.find(Item.id.in_(item_ids)).to_list()
        items_dict = {item.id: item.name for item in items}
        
        for alert in alerts:
            result.append({
                "id": str(alert.id),
                "item_id": str(alert.item_id),
                "item_name": items_dict.get(alert.item_id, "Unknown"),
                "current_stock": alert.current_stock,
                "threshold": alert.threshold,
                "is_resolved": alert.is_resolved,
                "created_at": alert.created_at,
            })
    return result


@router.post("/alerts/{alert_id}/resolve", status_code=200)
async def resolve_low_stock_alert(
    alert_id: str,
    current_business: Business = Depends(get_current_business),
):
    """Resolve a low stock alert."""
    await stock_service.resolve_low_stock_alert(alert_id, str(current_business.id))
    return {"message": "Alert resolved"}
