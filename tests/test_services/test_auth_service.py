"""Tests for authentication service."""
import pytest
from sqlalchemy.ext.asyncio import AsyncSession
from app.services.auth import auth_service
from app.core.redis_client import get_redis


@pytest.mark.asyncio
async def test_generate_otp(db_session: AsyncSession):
    """Test OTP generation and storage."""
    phone = "+1234567890"
    
    # Request OTP
    result = await auth_service.request_otp(phone, db_session)
    assert "message" in result
    assert "expires_in_minutes" in result
    
    # Verify OTP exists in Redis
    redis = await get_redis()
    otp_key = f"otp:{phone}"
    stored_otp = await redis.get(otp_key)
    assert stored_otp is not None
    assert len(stored_otp) == 6  # OTP length


@pytest.mark.asyncio
async def test_verify_otp_success(db_session: AsyncSession):
    """Test successful OTP verification."""
    phone = "+1234567890"
    
    # Request OTP
    await auth_service.request_otp(phone, db_session)
    
    # Get OTP from Redis
    redis = await get_redis()
    otp_key = f"otp:{phone}"
    otp = await redis.get(otp_key)
    
    # Verify OTP
    result = await auth_service.verify_otp(phone, otp, None, None, db_session)
    assert "access_token" in result
    assert "refresh_token" in result
    assert "user" in result


@pytest.mark.asyncio
async def test_verify_otp_invalid(db_session: AsyncSession):
    """Test OTP verification with invalid OTP."""
    phone = "+1234567890"
    
    # Request OTP
    await auth_service.request_otp(phone, db_session)
    
    # Try to verify with wrong OTP
    from app.core.exceptions import AuthenticationError
    
    with pytest.raises(AuthenticationError):
        await auth_service.verify_otp(phone, "000000", None, None, db_session)





