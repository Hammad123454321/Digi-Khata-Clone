"""Automated task scheduling service."""
import asyncio
from typing import Optional
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger
from apscheduler.triggers.cron import CronTrigger

from app.core.config import get_settings
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)

# Global scheduler instance
scheduler: Optional[AsyncIOScheduler] = None


def get_scheduler() -> AsyncIOScheduler:
    """Get or create scheduler instance."""
    global scheduler
    if scheduler is None:
        scheduler = AsyncIOScheduler()
    return scheduler


async def run_cleanup_tasks():
    """Run all cleanup tasks."""
    try:
        from app.services.cleanup import cleanup_service
        
        result = await cleanup_service.run_all_cleanups()
        logger.info("scheduled_cleanup_completed", result=result)
    except Exception as e:
        logger.error("scheduled_cleanup_error", error=str(e), exc_info=True)


async def run_automated_backups():
    """Run automated backups for all active businesses."""
    try:
        from app.services.backup import backup_service
        from app.models.business import Business
        
        # Get all active businesses
        businesses = await Business.find(Business.is_active == True).to_list()
        
        backup_count = 0
        for business in businesses:
            try:
                await backup_service.create_backup(
                    business_id=str(business.id),
                    backup_type="automated",
                )
                backup_count += 1
            except Exception as e:
                logger.error(
                    "automated_backup_error",
                    business_id=str(business.id),
                    error=str(e),
                )
        
        logger.info(
            "scheduled_backups_completed",
            total_businesses=len(businesses),
            backups_created=backup_count,
        )
    except Exception as e:
        logger.error("scheduled_backup_error", error=str(e), exc_info=True)


def start_scheduler():
    """Start the task scheduler."""
    if not settings.BACKUP_ENABLED:
        logger.info("scheduler_disabled", reason="BACKUP_ENABLED is False")
        return
    
    sched = get_scheduler()
    
    # Schedule cleanup tasks
    if settings.ENABLE_AUDIT_CLEANUP:
        cleanup_interval_hours = settings.CLEANUP_SCHEDULE_HOURS
        sched.add_job(
            run_cleanup_tasks,
            trigger=IntervalTrigger(hours=cleanup_interval_hours),
            id="cleanup_tasks",
            name="Run cleanup tasks (audit logs, backups, sync logs)",
            replace_existing=True,
        )
        logger.info(
            "cleanup_scheduled",
            interval_hours=cleanup_interval_hours,
        )
    
    # Schedule automated backups
    backup_interval_hours = settings.AUTO_BACKUP_INTERVAL_HOURS
    sched.add_job(
        run_automated_backups,
        trigger=IntervalTrigger(hours=backup_interval_hours),
        id="automated_backups",
        name="Run automated backups for all businesses",
        replace_existing=True,
    )
    logger.info(
        "backup_scheduled",
        interval_hours=backup_interval_hours,
    )
    
    # Start scheduler
    sched.start()
    logger.info("scheduler_started")


def stop_scheduler():
    """Stop the task scheduler."""
    global scheduler
    if scheduler:
        scheduler.shutdown(wait=True)
        scheduler = None
        logger.info("scheduler_stopped")
