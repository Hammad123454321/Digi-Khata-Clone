"""Tests for authentication endpoints."""
import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_request_otp(client: AsyncClient):
    """Test OTP request endpoint."""
    response = await client.post(
        "/api/v1/auth/request-otp",
        json={"phone": "+1234567890"},
    )
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "expires_in_minutes" in data


@pytest.mark.asyncio
async def test_request_otp_invalid_phone(client: AsyncClient):
    """Test OTP request with invalid phone."""
    response = await client.post(
        "/api/v1/auth/request-otp",
        json={"phone": "invalid"},
    )
    # Should still return 200 but may fail validation
    assert response.status_code in [200, 422]


@pytest.mark.asyncio
async def test_verify_otp_invalid(client: AsyncClient):
    """Test OTP verification with invalid OTP."""
    # First request OTP
    await client.post(
        "/api/v1/auth/request-otp",
        json={"phone": "+1234567890"},
    )
    
    # Try to verify with wrong OTP
    response = await client.post(
        "/api/v1/auth/verify-otp",
        json={
            "phone": "+1234567890",
            "otp": "000000",
            "device_id": "test-device",
            "device_name": "Test Device",
        },
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_refresh_token_invalid(client: AsyncClient):
    """Test refresh token with invalid token."""
    response = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": "invalid-token"},
    )
    assert response.status_code == 401





