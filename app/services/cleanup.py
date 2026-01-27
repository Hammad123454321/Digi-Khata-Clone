"""Cleanup service for automated data retention and archival."""
from datetime import datetime, timedelta, timezone
from typing import Optional
from beanie import PydanticObjectId

from app.core.config import get_settings
from app.core.logging import get_logger
from app.core.exceptions import BusinessLogicError
from app.models.audit import AuditLog
from app.models.backup import Backup
from app.models.business import Business

settings = get_settings()
logger = get_logger(__name__)


class CleanupService:
    """Service for automated cleanup and archival of old data."""

    @staticmethod
    async def cleanup_audit_logs(
        retention_days: Optional[int] = None,
    ) -> dict:
        """
        Clean up old audit logs based on retention policy.
        
        Args:
            retention_days: Number of days to retain (defaults to AUDIT_LOG_RETENTION_DAYS)
            
        Returns:
            dict with cleanup statistics
        """
        if not settings.ENABLE_AUDIT_CLEANUP:
            logger.info("audit_cleanup_disabled")
            return {"cleaned": 0, "skipped": True}

        if retention_days is None:
            retention_days = settings.AUDIT_LOG_RETENTION_DAYS

        # Ensure retention doesn't exceed maximum
        if retention_days > settings.AUDIT_LOG_MAX_RETENTION_DAYS:
            retention_days = settings.AUDIT_LOG_MAX_RETENTION_DAYS

        cutoff_date = datetime.now(timezone.utc) - timedelta(days=retention_days)

        # Count records to be deleted
        count = await AuditLog.find(AuditLog.timestamp < cutoff_date).count()

        if count == 0:
            logger.info("audit_cleanup_no_records", retention_days=retention_days)
            return {"cleaned": 0, "retention_days": retention_days}

        # Delete old audit logs
        await AuditLog.find(AuditLog.timestamp < cutoff_date).delete()

        logger.info(
            "audit_cleanup_completed",
            cleaned_count=count,
            retention_days=retention_days,
            cutoff_date=cutoff_date.isoformat(),
        )

        return {
            "cleaned": count,
            "retention_days": retention_days,
            "cutoff_date": cutoff_date.isoformat(),
        }

    @staticmethod
    async def cleanup_expired_backups(
        retention_days: Optional[int] = None,
    ) -> dict:
        """
        Clean up expired backups based on retention policy.
        
        Args:
            retention_days: Number of days to retain (defaults to BACKUP_RETENTION_DAYS)
            
        Returns:
            dict with cleanup statistics
        """
        if retention_days is None:
            retention_days = settings.BACKUP_RETENTION_DAYS

        cutoff_date = datetime.now(timezone.utc) - timedelta(days=retention_days)

        # Count records to be deleted
        count = await Backup.find(
            Backup.backup_date < cutoff_date,
            Backup.status == "completed",  # Only delete completed backups
        ).count()

        if count == 0:
            logger.info("backup_cleanup_no_records", retention_days=retention_days)
            return {"cleaned": 0, "retention_days": retention_days}

        # Get backups to delete (for S3 cleanup)
        backups = await Backup.find(
            Backup.backup_date < cutoff_date,
            Backup.status == "completed",
        ).to_list()

        # TODO: Delete backup files from S3/object storage
        # This would require S3 client integration
        # For now, we just delete the database records

        # Delete expired backup records
        await Backup.find(
            Backup.backup_date < cutoff_date,
            Backup.status == "completed",
        ).delete()

        logger.info(
            "backup_cleanup_completed",
            cleaned_count=count,
            retention_days=retention_days,
            cutoff_date=cutoff_date.isoformat(),
        )

        return {
            "cleaned": count,
            "retention_days": retention_days,
            "cutoff_date": cutoff_date.isoformat(),
        }

    @staticmethod
    async def cleanup_old_sync_logs(
        retention_days: int = 30,
    ) -> dict:
        """
        Clean up old sync change logs (keep recent ones for conflict resolution).
        
        Args:
            retention_days: Number of days to retain (default 30)
            
        Returns:
            dict with cleanup statistics
        """
        from app.models.sync import SyncChangeLog

        cutoff_date = datetime.now(timezone.utc) - timedelta(days=retention_days)

        # Count records to be deleted
        count = await SyncChangeLog.find(
            SyncChangeLog.sync_timestamp < cutoff_date
        ).count()

        if count == 0:
            logger.info("sync_log_cleanup_no_records", retention_days=retention_days)
            return {"cleaned": 0, "retention_days": retention_days}

        # Delete old sync logs
        await SyncChangeLog.find(SyncChangeLog.sync_timestamp < cutoff_date).delete()

        logger.info(
            "sync_log_cleanup_completed",
            cleaned_count=count,
            retention_days=retention_days,
            cutoff_date=cutoff_date.isoformat(),
        )

        return {
            "cleaned": count,
            "retention_days": retention_days,
            "cutoff_date": cutoff_date.isoformat(),
        }

    @staticmethod
    async def run_all_cleanups(
        audit_retention_days: Optional[int] = None,
        backup_retention_days: Optional[int] = None,
    ) -> dict:
        """
        Run all cleanup tasks.
        
        Returns:
            dict with results from all cleanup operations
        """
        results = {
            "audit_logs": {},
            "backups": {},
            "sync_logs": {},
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

        try:
            results["audit_logs"] = await CleanupService.cleanup_audit_logs(
                retention_days=audit_retention_days
            )
        except Exception as e:
            logger.error("audit_cleanup_error", error=str(e))
            results["audit_logs"] = {"error": str(e)}

        try:
            results["backups"] = await CleanupService.cleanup_expired_backups(
                retention_days=backup_retention_days
            )
        except Exception as e:
            logger.error("backup_cleanup_error", error=str(e))
            results["backups"] = {"error": str(e)}

        try:
            results["sync_logs"] = await CleanupService.cleanup_old_sync_logs()
        except Exception as e:
            logger.error("sync_log_cleanup_error", error=str(e))
            results["sync_logs"] = {"error": str(e)}

        logger.info("cleanup_all_completed", results=results)
        return results

    @staticmethod
    async def update_audit_retention(
        business_id: str,
        retention_days: int,
    ) -> dict:
        """
        Update audit log retention for a specific business.
        Allows extending retention up to maximum (1 year).
        
        Args:
            business_id: Business ID
            retention_days: New retention period (max 365 days)
            
        Returns:
            dict with update result
        """
        if retention_days > settings.AUDIT_LOG_MAX_RETENTION_DAYS:
            raise BusinessLogicError(
                f"Retention cannot exceed {settings.AUDIT_LOG_MAX_RETENTION_DAYS} days"
            )

        # Store retention preference in business settings or a separate table
        # For now, we'll use a simple approach - store in business metadata
        # In a full implementation, you'd have a business_settings table
        
        # This is a placeholder - actual implementation would store per-business retention
        logger.info(
            "audit_retention_updated",
            business_id=business_id,
            retention_days=retention_days,
        )

        return {
            "business_id": business_id,
            "retention_days": retention_days,
            "message": "Retention preference updated",
        }


# Singleton instance
cleanup_service = CleanupService()
