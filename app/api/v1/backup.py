"""Backup endpoints."""
from pathlib import Path
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import FileResponse

from app.api.dependencies import get_current_business
from app.models.business import Business
from app.services.backup import backup_service

router = APIRouter(prefix="/backups", tags=["Backups"])


@router.post("", status_code=201)
async def create_backup(
    current_business: Business = Depends(get_current_business),
):
    """Create a backup."""
    backup = await backup_service.create_backup(str(current_business.id))
    return backup


@router.get("", response_model=List[dict])
async def list_backups(
    current_business: Business = Depends(get_current_business),
):
    """List backups."""
    backups = await backup_service.list_backups(str(current_business.id))
    return [
        {
            "id": str(b.id),
            "backup_type": b.backup_type,
            "file_path": b.file_path,
            "file_size": str(b.file_size) if b.file_size is not None else None,
            "status": b.status,
            "error_message": b.error_message,
            "backup_date": b.backup_date,
        }
        for b in backups
    ]


@router.get("/{backup_id}/download")
async def download_backup(
    backup_id: str,
    current_business: Business = Depends(get_current_business),
):
    """Download backup file."""
    backup = await backup_service.get_backup_for_business(
        backup_id=backup_id,
        business_id=str(current_business.id),
    )
    if not backup.file_path:
        raise HTTPException(status_code=404, detail="Backup file is missing")

    backup_path = Path(backup.file_path)
    if not backup_path.exists():
        raise HTTPException(status_code=404, detail="Backup file not found")
    return FileResponse(
        path=backup_path,
        media_type="application/json",
        filename=backup_path.name,
    )


@router.post("/{backup_id}/restore", status_code=200)
async def restore_backup(
    backup_id: str,
    current_business: Business = Depends(get_current_business),
):
    """Restore from backup."""
    return await backup_service.restore_backup(backup_id, str(current_business.id))
