"""Authentication service."""
import json
import uuid
import re
from datetime import datetime, timezone
from typing import Optional, Dict, Any

from beanie.operators import In

from app.core.security import (
    generate_otp,
    create_access_token,
    create_refresh_token,
    verify_token,
    verify_password,
    get_password_hash,
)
from app.core.config import get_settings
from app.core.redis_client import get_redis
from app.core.exceptions import AuthenticationError, BusinessLogicError, NotFoundError, ValidationError
from app.core.translations import translate
from app.models.user import User, UserMembership
from app.models.business import Business
from app.services.sms import sms_service
from app.services.twilio_verify import twilio_verify_service
from app.services.rbac import rbac_service
from app.core.phone import normalize_phone_number
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)


class AuthService:
    """Authentication service."""

    @staticmethod
    def _legacy_refresh_key(user_id: str) -> str:
        return f"refresh_token:{user_id}"

    @staticmethod
    def _session_key(user_id: str, sid: str) -> str:
        return f"refresh_session:{user_id}:{sid}"

    @staticmethod
    def _build_session_payload(
        refresh_token: str,
        device_id: Optional[str],
    ) -> str:
        return json.dumps(
            {
                "refresh_token": refresh_token,
                "device_id": device_id,
                "created_at": datetime.now(timezone.utc).isoformat(),
            }
        )

    @staticmethod
    def _parse_session_payload(raw_payload: Optional[str]) -> Dict[str, Any]:
        if not raw_payload:
            return {}
        try:
            parsed = json.loads(raw_payload)
            if isinstance(parsed, dict):
                return parsed
        except (TypeError, ValueError):
            # Backward compatibility in case a plain token string was stored.
            return {"refresh_token": raw_payload}
        return {}

    @staticmethod
    def _build_phone_lookup_candidates(raw_phone: str, normalized_phone: str) -> set[str]:
        """Build backward-compatible lookup candidates for legacy stored phones."""
        candidates: set[str] = set()

        def _add(value: Optional[str]) -> None:
            if not value:
                return
            trimmed = value.strip()
            if trimmed:
                candidates.add(trimmed)

        _add(normalized_phone)

        raw = (raw_phone or "").strip()
        compact = re.sub(r"[\s\-\(\)]", "", raw)
        _add(raw)
        _add(compact)

        if compact.startswith("00"):
            _add(f"+{compact[2:]}")
        if compact.startswith("+"):
            _add(compact[1:])
        digits_only = re.sub(r"\D", "", compact)
        _add(digits_only)
        _add(digits_only.lstrip("0"))

        normalized_digits = normalized_phone[1:] if normalized_phone.startswith("+") else normalized_phone
        normalized_digits = re.sub(r"\D", "", normalized_digits)
        _add(normalized_digits)
        _add(normalized_digits.lstrip("0"))

        # Common South-Asia legacy storage variants.
        # Example: +92312xxxxxxx <-> 0312xxxxxxx <-> 312xxxxxxx
        if normalized_digits.startswith("92") and len(normalized_digits) >= 12:
            national = normalized_digits[2:]
            _add(national)
            _add(f"0{national}")

        return candidates

    @staticmethod
    async def _get_active_user(user_id: str) -> Optional[User]:
        user: Optional[User] = None
        try:
            from beanie import PydanticObjectId

            user = await User.get(PydanticObjectId(user_id))
        except (ValueError, TypeError):
            user = None

        if user is None:
            try:
                user = await User.find_one(
                    User.id == int(user_id), User.is_active == True
                )
            except (ValueError, TypeError):
                user = None

        if not user or not user.is_active:
            return None

        return user

    @staticmethod
    async def request_otp(phone: str, language: str = "en") -> Dict[str, Any]:
        """Request OTP for phone number."""
        try:
            phone = normalize_phone_number(
                phone,
                default_region=settings.OTP_DEFAULT_REGION,
            )
        except ValidationError as exc:
            raise BusinessLogicError(str(exc)) from exc

        # Check rate limiting
        redis = await get_redis()
        rate_limit_key = f"otp_rate_limit:{phone}"
        attempts = await redis.get(rate_limit_key)
        if attempts and int(attempts) >= settings.OTP_MAX_ATTEMPTS:
            raise BusinessLogicError(
                translate("max_otp_attempts", language, minutes=settings.OTP_EXPIRE_MINUTES)
            )

        is_dev = settings.ENVIRONMENT.lower() == "development" or settings.DEBUG
        if is_dev:
            otp = generate_otp()
            otp_key = f"otp:{phone}"
            await redis.setex(otp_key, settings.OTP_EXPIRE_MINUTES * 60, otp)
            await sms_service.send_otp(phone, otp)
        else:
            await twilio_verify_service.start_verification(phone)

        # Increment rate limit counter
        await redis.incr(rate_limit_key)
        await redis.expire(rate_limit_key, settings.OTP_EXPIRE_MINUTES * 60)

        logger.info("otp_requested", phone=phone)

        return {
            "message": translate("otp_sent_successfully", language) if language != "en" else "OTP sent successfully",
            "expires_in_minutes": settings.OTP_EXPIRE_MINUTES
        }

    @staticmethod
    async def verify_otp(phone: str, otp: str, device_id: Optional[str], device_name: Optional[str], language: str = "en") -> Dict[str, Any]:
        """Verify OTP and return tokens."""
        raw_phone = phone
        try:
            phone = normalize_phone_number(
                phone,
                default_region=settings.OTP_DEFAULT_REGION,
            )
        except ValidationError as exc:
            raise AuthenticationError(str(exc)) from exc
        normalized_device_id = (
            device_id.strip() if device_id and device_id.strip() else None
        )

        # Verify OTP from Redis (dev mode accepts any valid-length numeric OTP)
        redis = await get_redis()
        otp_key = f"otp:{phone}"
        is_dev = settings.ENVIRONMENT.lower() == "development" or settings.DEBUG
        is_valid_dev_otp = otp.isdigit() and len(otp) == settings.OTP_LENGTH

        if is_dev and is_valid_dev_otp:
            logger.info("otp_bypass_used_dev_any", phone=phone)
            await redis.delete(otp_key)
        else:
            await twilio_verify_service.check_verification(phone, otp)

        # Get or create user (with backward-compatible lookup for legacy stored phone formats).
        lookup_candidates = AuthService._build_phone_lookup_candidates(raw_phone, phone)
        matched_users = await User.find(In(User.phone, list(lookup_candidates))).to_list()

        user: Optional[User] = None
        if matched_users:
            if len(matched_users) == 1:
                user = matched_users[0]
            else:
                user_ids = [matched.id for matched in matched_users]
                memberships = await UserMembership.find(
                    In(UserMembership.user_id, user_ids),
                    UserMembership.is_active == True,
                ).to_list()
                membership_counts: dict[str, int] = {}
                for membership in memberships:
                    key = str(membership.user_id)
                    membership_counts[key] = membership_counts.get(key, 0) + 1

                matched_users.sort(
                    key=lambda matched: (
                        membership_counts.get(str(matched.id), 0),
                        1 if matched.phone == phone else 0,
                        matched.last_login_at or datetime.min.replace(tzinfo=timezone.utc),
                    ),
                    reverse=True,
                )
                user = matched_users[0]

            # Normalize stored phone if there is no conflicting normalized record.
            if user.phone != phone and not any(m.phone == phone for m in matched_users):
                user.phone = phone

        if not user:
            # Create new user
            user = User(phone=phone, is_active=True)
            await user.insert()
            logger.info("user_created", user_id=str(user.id), phone=phone)

        # Update last login
        user.last_login_at = datetime.now(timezone.utc)
        await rbac_service.activate_pending_invites_for_user(user)
        await user.save()

        # Get user's businesses
        memberships = await UserMembership.find(
            UserMembership.user_id == user.id,
            UserMembership.is_active == True,
        ).to_list()

        # Load businesses for memberships
        businesses = []
        for membership in memberships:
            business = await Business.get(membership.business_id)
            if business:
                businesses.append(business)

        # Create tokens - use string id for ObjectId compatibility.
        sid = uuid.uuid4().hex
        token_payload: Dict[str, Any] = {
            "sub": str(user.id),
            "phone": user.phone,
            "sid": sid,
        }
        if normalized_device_id:
            token_payload["device_id"] = normalized_device_id

        access_token = create_access_token(data=token_payload)
        refresh_token = create_refresh_token(data=token_payload)

        # Store refresh session in Redis (device-scoped).
        session_key = AuthService._session_key(str(user.id), sid)
        await redis.setex(
            session_key,
            settings.REFRESH_TOKEN_EXPIRE_DAYS * 24 * 60 * 60,
            AuthService._build_session_payload(refresh_token, normalized_device_id),
        )

        # Handle device registration if provided
        # Note: Device registration requires at least one business.
        # If user has no businesses, device registration is skipped.
        # User should create a business first, then register device.
        device_info = None
        if normalized_device_id and businesses:
            from app.models.device import Device

            # Use first business for device registration (user can add more businesses later)
            business = businesses[0]

            # Check if device already exists
            device = await Device.find_one(
                Device.device_id == normalized_device_id,
                Device.business_id == business.id,
            )

            if device:
                device.is_active = True
                device.last_sync_at = datetime.now(timezone.utc)
                await device.save()
            else:
                device = Device(
                    business_id=business.id,
                    user_id=user.id,
                    device_id=normalized_device_id,
                    device_name=device_name or "Unknown Device",
                    is_active=True,
                    last_sync_at=datetime.now(timezone.utc),
                )
                await device.insert()

            device_info = {"device_id": device.device_id, "business_id": str(business.id)}
        elif normalized_device_id and not businesses:
            # Log that device registration was skipped due to no businesses
            logger.info(
                "device_registration_skipped_no_business",
                user_id=str(user.id),
                device_id=normalized_device_id,
                message="User has no businesses. Device registration skipped. Create a business first."
            )

        logger.info("user_authenticated", user_id=str(user.id), phone=phone)

        membership_by_business_id = {
            str(membership.business_id): membership for membership in memberships
        }
        business_payloads = []
        for business in businesses:
            membership = membership_by_business_id.get(str(business.id))
            access_payload = (
                await rbac_service.build_business_access_payload(membership)
                if membership is not None
                else {}
            )
            business_payloads.append(
                {
                    "id": str(business.id),
                    "name": business.name,
                    "role": membership.role.value if membership else "staff",
                    **access_payload,
                }
            )

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "user": {
                "id": str(user.id),
                "phone": user.phone,
                "name": user.name,
                "email": user.get_email() if hasattr(user, 'get_email') else user.email,
                "language_preference": user.language_preference,
                "default_business_id": str(user.default_business_id) if user.default_business_id else None,
            },
            "businesses": business_payloads,
            "device": device_info,
            "language_preference": user.language_preference,
            "default_business_id": str(user.default_business_id) if user.default_business_id else None,
        }

    @staticmethod
    async def refresh_access_token(
        refresh_token: str, device_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """Refresh access token using refresh token."""
        payload = verify_token(refresh_token, token_type="refresh")
        if not payload:
            raise AuthenticationError("Invalid or expired refresh token")

        user_id = payload.get("sub")
        sid = payload.get("sid")
        token_device_id = payload.get("device_id")
        normalized_device_id = (
            device_id.strip() if device_id and device_id.strip() else None
        )
        if not user_id:
            raise AuthenticationError("Invalid token payload")

        # Verify refresh token in Redis
        redis = await get_redis()
        effective_device_id = normalized_device_id or token_device_id

        if sid:
            # Device-scoped session validation.
            session_key = AuthService._session_key(user_id, sid)
            session_payload = AuthService._parse_session_payload(
                await redis.get(session_key)
            )
            stored_token = session_payload.get("refresh_token")
            session_device_id = session_payload.get("device_id") or token_device_id
            if (
                session_device_id
                and normalized_device_id
                and session_device_id != normalized_device_id
            ):
                raise AuthenticationError("Invalid refresh token")
            if session_device_id:
                effective_device_id = session_device_id
        else:
            # Legacy fallback (pre-session-scoped refresh tokens).
            refresh_key = AuthService._legacy_refresh_key(user_id)
            stored_token = await redis.get(refresh_key)

        if not stored_token or stored_token != refresh_token:
            raise AuthenticationError("Invalid refresh token")

        user = await AuthService._get_active_user(user_id)
        if not user or not user.is_active:
            raise AuthenticationError("User not found or inactive")

        # Create new access token
        access_payload: Dict[str, Any] = {
            "sub": str(user.id),
            "phone": user.phone,
        }
        if sid:
            access_payload["sid"] = sid
        if effective_device_id:
            access_payload["device_id"] = effective_device_id

        access_token = create_access_token(data=access_payload)

        return {
            "access_token": access_token,
            "token_type": "bearer",
        }

    @staticmethod
    async def logout(
        user_id: str,
        refresh_token: str,
        device_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Revoke current refresh session/device."""
        payload = verify_token(refresh_token, token_type="refresh")
        if not payload:
            # Idempotent success to keep client logout deterministic.
            return {"message": "Logged out successfully"}

        token_user_id = payload.get("sub")
        sid = payload.get("sid")
        token_device_id = payload.get("device_id")
        normalized_device_id = (
            device_id.strip() if device_id and device_id.strip() else None
        )

        if not token_user_id or token_user_id != user_id:
            raise AuthenticationError("Invalid refresh token")

        redis = await get_redis()

        if sid:
            session_key = AuthService._session_key(user_id, sid)
            session_payload = AuthService._parse_session_payload(
                await redis.get(session_key)
            )
            session_device_id = session_payload.get("device_id") or token_device_id
            if (
                session_device_id
                and normalized_device_id
                and session_device_id != normalized_device_id
            ):
                raise AuthenticationError("Invalid refresh token")
            await redis.delete(session_key)
        else:
            # Legacy fallback: old refresh storage was user-scoped.
            refresh_key = AuthService._legacy_refresh_key(user_id)
            stored_token = await redis.get(refresh_key)
            if stored_token and stored_token == refresh_token:
                await redis.delete(refresh_key)

        logger.info("user_logged_out", user_id=user_id, sid=sid)
        return {"message": "Logged out successfully"}

    @staticmethod
    async def set_pin(user_id: str, pin: str) -> Dict[str, Any]:
        """Set PIN for user."""
        try:
            from beanie import PydanticObjectId
            user = await User.get(PydanticObjectId(user_id))
        except (ValueError, TypeError):
            user = await User.find_one(User.id == int(user_id))

        if not user:
            raise NotFoundError("User not found")

        user.pin_hash = get_password_hash(pin)
        await user.save()

        logger.info("pin_set", user_id=user_id)

        return {"message": "PIN set successfully"}

    @staticmethod
    async def verify_pin(user_id: str, pin: str) -> bool:
        """Verify PIN for user."""
        try:
            from beanie import PydanticObjectId
            user = await User.get(PydanticObjectId(user_id))
        except (ValueError, TypeError):
            user = await User.find_one(User.id == int(user_id))

        if not user or not user.pin_hash:
            return False

        return verify_password(pin, user.pin_hash)


# Singleton instance
auth_service = AuthService()
