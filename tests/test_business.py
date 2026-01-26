"""Tests for business endpoints."""
import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_create_business(client: AsyncClient, auth_headers, test_user):
    """Test creating a business."""
    response = await client.post(
        "/api/v1/businesses",
        headers=auth_headers,
        json={
            "name": "New Business",
            "phone": "+1234567892",
            "email": "test@example.com",
        },
    )
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "New Business"
    assert data["phone"] == "+1234567892"
    assert "id" in data


@pytest.mark.asyncio
async def test_list_businesses(client: AsyncClient, auth_headers, test_business):
    """Test listing businesses."""
    response = await client.get(
        "/api/v1/businesses",
        headers=auth_headers,
    )
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) > 0


@pytest.mark.asyncio
async def test_get_business(client: AsyncClient, auth_headers, test_business):
    """Test getting a business."""
    response = await client.get(
        f"/api/v1/businesses/{test_business.id}",
        headers={**auth_headers, "X-Business-Id": str(test_business.id)},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == test_business.id
    assert data["name"] == test_business.name


@pytest.mark.asyncio
async def test_update_business(client: AsyncClient, auth_headers, test_business):
    """Test updating a business."""
    response = await client.patch(
        f"/api/v1/businesses/{test_business.id}",
        headers={**auth_headers, "X-Business-Id": str(test_business.id)},
        json={"name": "Updated Business Name"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Updated Business Name"


@pytest.mark.asyncio
async def test_get_business_unauthorized(client: AsyncClient, auth_headers):
    """Test getting business without proper headers."""
    response = await client.get(
        "/api/v1/businesses/999",
        headers=auth_headers,
    )
    assert response.status_code in [400, 403, 404]





