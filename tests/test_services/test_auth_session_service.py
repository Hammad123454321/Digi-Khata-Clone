"""Auth session lifecycle tests (device-scoped refresh/logout)."""

import json

import pytest

from app.core.exceptions import AuthenticationError
from app.core.security import verify_token as decode_access_token
from app.services import auth as auth_module
from app.services.auth import auth_service


class _FakeRedis:
    def __init__(self):
        self.store: dict[str, str] = {}

    async def get(self, key: str):
        return self.store.get(key)

    async def setex(self, key: str, _ttl: int, value: str):
        self.store[key] = value

    async def delete(self, key: str):
        self.store.pop(key, None)


class _FakeUser:
    def __init__(self, user_id: str, phone: str):
        self.id = user_id
        self.phone = phone
        self.is_active = True


@pytest.mark.asyncio
async def test_refresh_access_token_validates_device_scoped_session(monkeypatch):
    user_id = "507f1f77bcf86cd799439011"
    sid = "sid-abc"
    refresh_token = "refresh-token"
    device_id = "device-a"
    redis = _FakeRedis()
    redis.store[f"refresh_session:{user_id}:{sid}"] = json.dumps(
        {
            "refresh_token": refresh_token,
            "device_id": device_id,
        }
    )

    async def _get_redis():
        return redis

    async def _get_active_user(_user_id: str):
        return _FakeUser(user_id, "+923001112233")

    monkeypatch.setattr(auth_module, "get_redis", _get_redis)
    monkeypatch.setattr(
        auth_module,
        "verify_token",
        lambda token, token_type="access": {
            "sub": user_id,
            "sid": sid,
            "device_id": device_id,
            "type": "refresh",
        }
        if token == refresh_token and token_type == "refresh"
        else None,
    )
    monkeypatch.setattr(
        auth_module.AuthService,
        "_get_active_user",
        staticmethod(_get_active_user),
    )

    result = await auth_service.refresh_access_token(refresh_token, device_id)
    access_payload = decode_access_token(result["access_token"])

    assert result["token_type"] == "bearer"
    assert access_payload is not None
    assert access_payload["sub"] == user_id
    assert access_payload["sid"] == sid
    assert access_payload["device_id"] == device_id


@pytest.mark.asyncio
async def test_refresh_access_token_rejects_device_mismatch(monkeypatch):
    user_id = "507f1f77bcf86cd799439011"
    sid = "sid-abc"
    refresh_token = "refresh-token"
    redis = _FakeRedis()
    redis.store[f"refresh_session:{user_id}:{sid}"] = json.dumps(
        {
            "refresh_token": refresh_token,
            "device_id": "device-a",
        }
    )

    async def _get_redis():
        return redis

    async def _get_active_user(_user_id: str):
        return _FakeUser(user_id, "+923001112233")

    monkeypatch.setattr(auth_module, "get_redis", _get_redis)
    monkeypatch.setattr(
        auth_module,
        "verify_token",
        lambda token, token_type="access": {
            "sub": user_id,
            "sid": sid,
            "device_id": "device-a",
            "type": "refresh",
        }
        if token == refresh_token and token_type == "refresh"
        else None,
    )
    monkeypatch.setattr(
        auth_module.AuthService,
        "_get_active_user",
        staticmethod(_get_active_user),
    )

    with pytest.raises(AuthenticationError):
        await auth_service.refresh_access_token(refresh_token, "device-b")


@pytest.mark.asyncio
async def test_logout_revokes_only_current_session(monkeypatch):
    user_id = "507f1f77bcf86cd799439011"
    sid = "sid-abc"
    refresh_token = "refresh-token"
    redis = _FakeRedis()
    active_key = f"refresh_session:{user_id}:{sid}"
    other_key = f"refresh_session:{user_id}:sid-other"
    redis.store[active_key] = json.dumps(
        {
            "refresh_token": refresh_token,
            "device_id": "device-a",
        }
    )
    redis.store[other_key] = json.dumps(
        {
            "refresh_token": "other-token",
            "device_id": "device-b",
        }
    )

    async def _get_redis():
        return redis

    monkeypatch.setattr(auth_module, "get_redis", _get_redis)
    monkeypatch.setattr(
        auth_module,
        "verify_token",
        lambda token, token_type="access": {
            "sub": user_id,
            "sid": sid,
            "device_id": "device-a",
            "type": "refresh",
        }
        if token == refresh_token and token_type == "refresh"
        else None,
    )

    result = await auth_service.logout(user_id, refresh_token, "device-a")

    assert result["message"] == "Logged out successfully"
    assert active_key not in redis.store
    assert other_key in redis.store
