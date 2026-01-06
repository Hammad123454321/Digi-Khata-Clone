"""Redis client configuration."""
import redis.asyncio as aioredis
from redis.asyncio import Redis

from app.core.config import get_settings

settings = get_settings()

redis_client: Redis | None = None


async def get_redis() -> Redis:
    """Get Redis client instance."""
    global redis_client
    if redis_client is None:
        redis_client = await aioredis.from_url(
            settings.REDIS_URL,
            password=settings.REDIS_PASSWORD if settings.REDIS_PASSWORD else None,
            decode_responses=settings.REDIS_DECODE_RESPONSES,
            encoding="utf-8",
        )
    return redis_client


async def close_redis() -> None:
    """Close Redis connection."""
    global redis_client
    if redis_client:
        await redis_client.close()
        redis_client = None

