"""Key rotation service for encryption keys."""
from datetime import datetime, timedelta, timezone
from typing import Optional

from app.core.config import get_settings
from app.core.logging import get_logger
from app.core.security import rotate_encryption_key, generate_encryption_key
from app.models.business import Business

settings = get_settings()
logger = get_logger(__name__)


class KeyRotationService:
    """Service for managing encryption key rotation."""

    @staticmethod
    async def check_key_rotation_needed(
        last_rotation_date: Optional[datetime] = None,
    ) -> bool:
        """
        Check if key rotation is needed based on rotation interval.
        
        Args:
            last_rotation_date: Last rotation date (if known)
            
        Returns:
            True if rotation is needed
        """
        if not settings.KEY_ROTATION_ENABLED:
            return False

        if last_rotation_date is None:
            # If we don't know the last rotation date, assume rotation is needed
            # In production, this would be stored in a secure location
            return True

        rotation_interval = timedelta(days=settings.KEY_ROTATION_INTERVAL_DAYS)
        next_rotation_date = last_rotation_date + rotation_interval

        return datetime.now(timezone.utc) >= next_rotation_date

    @staticmethod
    async def rotate_key(
        new_key: Optional[str] = None,
    ) -> dict:
        """
        Rotate encryption key.
        
        Args:
            new_key: Optional new key (base64 encoded). If not provided, generates a new one.
            
        Returns:
            dict with rotation result
        """
        try:
            # Rotate the key
            rotated_key = rotate_encryption_key(new_key=new_key)

            # Log rotation
            logger.info(
                "key_rotation_completed",
                rotation_date=datetime.now(timezone.utc).isoformat(),
                key_provided=bool(new_key),
            )

            # TODO: In production, you would:
            # 1. Store the new key securely (encrypted with master key or in key management service)
            # 2. Re-encrypt all encrypted data with the new key
            # 3. Update last_rotation_date in secure storage
            # 4. Keep old key temporarily for decryption during transition period

            return {
                "success": True,
                "rotation_date": datetime.now(timezone.utc).isoformat(),
                "message": "Key rotation completed. Note: Existing encrypted data needs re-encryption.",
            }

        except Exception as e:
            logger.error("key_rotation_error", error=str(e))
            return {
                "success": False,
                "error": str(e),
            }

    @staticmethod
    async def get_rotation_status() -> dict:
        """
        Get current key rotation status.
        
        Returns:
            dict with rotation status information
        """
        return {
            "rotation_enabled": settings.KEY_ROTATION_ENABLED,
            "rotation_interval_days": settings.KEY_ROTATION_INTERVAL_DAYS,
            "encryption_enabled": settings.ENCRYPTION_ENABLED,
            # In production, you'd include last_rotation_date here
        }


# Singleton instance
key_rotation_service = KeyRotationService()
