"""Database configuration and connection management for MongoDB."""
from typing import Optional
from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie
from beanie.odm.documents import Document

from app.core.config import get_settings
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)

_client: Optional[AsyncIOMotorClient] = None


def get_client() -> AsyncIOMotorClient:
    """Get or create MongoDB client."""
    global _client
    if _client is None:
        _client = AsyncIOMotorClient(
            settings.MONGODB_URL,
            serverSelectionTimeoutMS=5000,
        )
    return _client


async def init_db() -> None:
    """Initialize database connection and Beanie."""
    import asyncio
    from app.models import __all__ as models_list
    
    client = get_client()
    max_retries = 5
    retry_delay = 2
    
    # Extract database name from URL or use default
    database_name = settings.MONGODB_DATABASE
    if "/" in settings.MONGODB_URL:
        # URL format: mongodb://user:pass@host:port/database
        url_parts = settings.MONGODB_URL.split("/")
        if len(url_parts) > 1 and url_parts[-1]:
            # Check if last part is database name (not query params)
            db_part = url_parts[-1].split("?")[0]
            if db_part:
                database_name = db_part
    
    for attempt in range(1, max_retries + 1):
        try:
            await client.admin.command("ping")
            database = client[database_name]
            
            await init_beanie(
                database=database,
                document_models=models_list,
            )
            logger.info("database_initialized_successfully", database=database_name)
            return
        except Exception as e:
            if attempt < max_retries:
                logger.warning(
                    "database_connection_retry",
                    attempt=attempt,
                    max_retries=max_retries,
                    error=str(e),
                    delay=retry_delay,
                )
                await asyncio.sleep(retry_delay)
            else:
                logger.error(
                    "database_connection_failed",
                    attempts=max_retries,
                    error=str(e),
                    database_url=settings.MONGODB_URL.split("@")[-1] if "@" in settings.MONGODB_URL else "hidden",
                )
                raise ConnectionError(
                    f"Failed to connect to MongoDB after {max_retries} attempts. "
                    f"Please ensure MongoDB is running and accessible. "
                    f"Error: {str(e)}"
                ) from e


async def close_db() -> None:
    """Close database connections."""
    global _client
    if _client:
        _client.close()
        _client = None
