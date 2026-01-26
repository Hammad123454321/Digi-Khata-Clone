"""Redis client configuration."""
import redis.asyncio as aioredis
from redis.asyncio import Redis
from redis.exceptions import RedisError

from app.core.config import get_settings
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)

redis_client: Redis | None = None


async def get_redis() -> Redis:
    """Get Redis client instance."""
    global redis_client
    if redis_client is None:
        try:
            redis_client = await aioredis.from_url(
                settings.REDIS_URL,
                password=settings.REDIS_PASSWORD if settings.REDIS_PASSWORD else None,
                decode_responses=settings.REDIS_DECODE_RESPONSES,
                encoding="utf-8",
                socket_connect_timeout=5,
                socket_keepalive=True,
                retry_on_timeout=True,
            )
            # Test connection
            await redis_client.ping()
        except (RedisError, Exception) as e:
            logger.error("redis_connection_failed", error=str(e))
            # In production, you might want to raise or use a fallback
            # For now, we'll raise to ensure Redis is available
            raise
    return redis_client


async def close_redis() -> None:
    """Close Redis connection."""
    global redis_client
    if redis_client:
        try:
            await redis_client.close()
        except Exception as e:
            logger.error("redis_close_error", error=str(e))
        finally:
            redis_client = None

