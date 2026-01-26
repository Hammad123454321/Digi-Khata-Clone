"""Key rotation API endpoints."""
from fastapi import APIRouter, Depends, HTTPException, status
from typing import Optional

from app.api.dependencies import get_current_user
from app.models.user import User
from app.services.key_rotation import key_rotation_service
from app.core.logging import get_logger

router = APIRouter(prefix="/key-rotation", tags=["key-rotation"])
logger = get_logger(__name__)


@router.post("/rotate")
async def rotate_key(
    new_key: Optional[str] = None,
    current_user: User = Depends(get_current_user),
):
    """
    Rotate encryption key.
    
    Note: This is a sensitive operation. In production, this should be:
    - Restricted to admin users only
    - Require additional authentication
    - Trigger re-encryption of all encrypted data
    
    Args:
        new_key: Optional new key (base64 encoded). If not provided, generates a new one.
    """
    # TODO: Add admin-only check
    # if not current_user.is_admin:
    #     raise HTTPException(
    #         status_code=status.HTTP_403_FORBIDDEN,
    #         detail="Only administrators can rotate keys",
    #     )

    result = await key_rotation_service.rotate_key(new_key=new_key)

    if not result.get("success"):
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=result.get("error", "Key rotation failed"),
        )

    return result


@router.get("/status")
async def get_rotation_status(
    current_user: User = Depends(get_current_user),
):
    """
    Get key rotation status.
    """
    return await key_rotation_service.get_rotation_status()
