"""Backup endpoints."""
from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.api.dependencies import get_current_business
from app.models.business import Business
from app.services.backup import backup_service

router = APIRouter(prefix="/backups", tags=["Backups"])


@router.post("", status_code=201)
async def create_backup(
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """Create a backup."""
    backup = await backup_service.create_backup(current_business.id, db=db)
    await db.commit()
    return backup


@router.get("", response_model=List[dict])
async def list_backups(
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """List backups."""
    backups = await backup_service.list_backups(current_business.id, db=db)
    return [
        {
            "id": b.id,
            "backup_type": b.backup_type,
            "file_path": b.file_path,
            "status": b.status,
            "backup_date": b.backup_date,
        }
        for b in backups
    ]


@router.post("/{backup_id}/restore", status_code=200)
async def restore_backup(
    backup_id: int,
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """Restore from backup."""
    return await backup_service.restore_backup(backup_id, current_business.id, db=db)

