"""Data archival API endpoints."""
from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, status

from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.services.archival import archival_service
from app.core.logging import get_logger

router = APIRouter(prefix="/archival", tags=["archival"])
logger = get_logger(__name__)


@router.post("/archive/{entity_type}")
async def archive_old_records(
    entity_type: str,
    archive_before_days: int = 365,
    batch_size: int = 1000,
    current_user: User = Depends(get_current_user),
    current_business: Business = Depends(get_current_business),
):
    """
    Archive old records for a specific entity type.
    
    Args:
        entity_type: Type of entity to archive
        archive_before_days: Archive records older than this many days
        batch_size: Number of records to process per batch
    """
    result = await archival_service.archive_old_records(
        entity_type=entity_type,
        business_id=str(current_business.id),
        archive_before_days=archive_before_days,
        batch_size=batch_size,
    )
    return result


@router.get("/recommendations")
async def get_archival_recommendations(
    current_user: User = Depends(get_current_user),
    current_business: Business = Depends(get_current_business),
):
    """
    Get recommendations for which records should be archived.
    """
    recommendations = await archival_service.get_archival_recommendations(
        business_id=str(current_business.id)
    )
    return {"recommendations": recommendations}


@router.post("/restore/{archive_id}")
async def restore_from_archive(
    archive_id: str,
    current_user: User = Depends(get_current_user),
    current_business: Business = Depends(get_current_business),
):
    """
    Restore archived records back to main tables.
    
    Args:
        archive_id: Archive record ID
    """
    result = await archival_service.restore_from_archive(
        archive_id=archive_id, business_id=str(current_business.id)
    )
    return result
