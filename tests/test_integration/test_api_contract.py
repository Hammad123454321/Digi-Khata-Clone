"""Integration tests for API contract validation."""
import pytest
from httpx import AsyncClient
from app.main import app
from fastapi.testclient import TestClient


def test_openapi_schema():
    """Test that OpenAPI schema is valid and complete."""
    client = TestClient(app)
    response = client.get("/openapi.json")
    assert response.status_code == 200
    
    schema = response.json()
    
    # Check required OpenAPI fields
    assert "openapi" in schema
    assert "info" in schema
    assert "paths" in schema
    
    # Check API info
    assert schema["info"]["title"] == "DigiKhata Clone Backend"
    assert "version" in schema["info"]
    
    # Check that main endpoints exist
    paths = schema["paths"]
    assert "/api/v1/auth/request-otp" in paths
    assert "/api/v1/businesses" in paths
    assert "/api/v1/invoices" in paths
    assert "/health" in paths


def test_openapi_schema_endpoints_have_responses():
    """Test that all endpoints have response definitions."""
    client = TestClient(app)
    response = client.get("/openapi.json")
    schema = response.json()
    
    paths = schema["paths"]
    
    # Check a few key endpoints have proper response definitions
    for endpoint_path in [
        "/api/v1/auth/request-otp",
        "/api/v1/businesses",
        "/health",
    ]:
        if endpoint_path in paths:
            endpoint = paths[endpoint_path]
            # Check that at least one method exists
            methods = [m for m in endpoint.keys() if m in ["get", "post", "patch", "delete", "put"]]
            assert len(methods) > 0, f"{endpoint_path} has no HTTP methods"
            
            # Check that methods have responses
            for method in methods:
                assert "responses" in endpoint[method], f"{endpoint_path} {method} has no responses"


@pytest.mark.asyncio
async def test_api_versioning(client: AsyncClient):
    """Test that API versioning is properly implemented."""
    # Health endpoint should not require version
    response = await client.get("/health")
    assert response.status_code == 200
    
    # API endpoints should be under /api/v1
    response = await client.get("/api/v1/businesses")
    # Should require auth, but endpoint should exist
    assert response.status_code in [200, 401, 403]


@pytest.mark.asyncio
async def test_error_responses_format(client: AsyncClient):
    """Test that error responses follow consistent format."""
    # Test 404
    response = await client.get("/api/v1/businesses/99999")
    assert response.status_code in [400, 401, 403, 404]
    
    if response.status_code >= 400:
        data = response.json()
        assert "detail" in data
    
    # Test 422 validation error
    response = await client.post(
        "/api/v1/auth/request-otp",
        json={},  # Missing required field
    )
    if response.status_code == 422:
        data = response.json()
        assert "detail" in data





