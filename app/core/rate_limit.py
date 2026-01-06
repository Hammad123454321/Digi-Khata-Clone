"""Rate limiting utilities."""
from typing import Optional

from fastapi import Request
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from app.core.config import get_settings
from app.core.exceptions import RateLimitError
from app.core.redis_client import get_redis

settings = get_settings()

# Initialize limiter
limiter = Limiter(
    key_func=get_remote_address,
    storage_uri=settings.REDIS_URL,
    default_limits=[f"{settings.RATE_LIMIT_PER_HOUR}/hour"],
)


def rate_limit_exceeded_handler(request: Request, exc: RateLimitExceeded):
    """Custom rate limit exceeded handler."""
    raise RateLimitError(
        message="Rate limit exceeded. Please try again later.",
        details={"retry_after": exc.retry_after},
    )


# Register custom handler
limiter._rate_limit_exceeded_handler = rate_limit_exceeded_handler


async def check_rate_limit(identifier: str, limit: int, window: int) -> bool:
    """Check custom rate limit."""
    redis = await get_redis()
    key = f"rate_limit:{identifier}:{window}"
    current = await redis.incr(key)
    if current == 1:
        await redis.expire(key, window)
    return current <= limit

