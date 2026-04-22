"""Twilio Verify integration for OTP."""
from __future__ import annotations

from typing import Optional

from twilio.base.exceptions import TwilioRestException
from twilio.rest import Client

from app.core.config import get_settings
from app.core.exceptions import AuthenticationError, ServiceUnavailableError
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)


class TwilioVerifyService:
    """Twilio Verify v2 service wrapper."""

    def __init__(self) -> None:
        self.account_sid = settings.TWILIO_ACCOUNT_SID
        self.auth_token = settings.TWILIO_AUTH_TOKEN
        self.api_key_sid = settings.TWILIO_API_KEY_SID
        self.api_key_secret = settings.TWILIO_API_KEY_SECRET
        self.verify_service_sid = settings.TWILIO_VERIFY_SERVICE_SID
        self.primary_channel = (settings.TWILIO_VERIFY_PRIMARY_CHANNEL or "whatsapp").strip().lower()
        self.fallback_channel = (settings.TWILIO_VERIFY_FALLBACK_CHANNEL or "sms").strip().lower()
        self._client: Optional[Client] = None

    def _get_client(self) -> Client:
        if self._client is not None:
            return self._client

        # Prefer API Keys in production as recommended by Twilio docs.
        if self.api_key_sid and self.api_key_secret and self.account_sid:
            self._client = Client(
                username=self.api_key_sid,
                password=self.api_key_secret,
                account_sid=self.account_sid,
            )
            return self._client

        self._client = Client(self.account_sid, self.auth_token)
        return self._client

    async def start_verification(self, phone: str) -> dict:
        client = self._get_client()
        channels = [self.primary_channel]
        if self.fallback_channel and self.fallback_channel not in channels:
            channels.append(self.fallback_channel)

        last_error: Optional[Exception] = None
        for channel in channels:
            try:
                verification = client.verify.v2.services(self.verify_service_sid).verifications.create(
                    to=phone,
                    channel=channel,
                )
                logger.info(
                    "otp_verification_started",
                    provider="twilio_verify",
                    phone=phone,
                    channel=channel,
                    sid=verification.sid,
                    status=verification.status,
                )
                return {
                    "sid": verification.sid,
                    "status": verification.status,
                    "channel": channel,
                }
            except TwilioRestException as exc:
                last_error = exc
                logger.warning(
                    "otp_verification_start_failed",
                    provider="twilio_verify",
                    phone=phone,
                    channel=channel,
                    status_code=exc.status,
                    code=exc.code,
                    error=str(exc),
                )

        if last_error is not None:
            raise ServiceUnavailableError("Unable to deliver OTP at the moment. Please try again.")
        raise ServiceUnavailableError("Unable to deliver OTP at the moment. Please try again.")

    async def check_verification(self, phone: str, otp: str) -> None:
        client = self._get_client()
        try:
            check = client.verify.v2.services(self.verify_service_sid).verification_checks.create(
                to=phone,
                code=otp,
            )
        except TwilioRestException as exc:
            logger.warning(
                "otp_verification_check_failed",
                provider="twilio_verify",
                phone=phone,
                status_code=exc.status,
                code=exc.code,
                error=str(exc),
            )
            if exc.status in (400, 404):
                raise AuthenticationError("Invalid or expired OTP")
            raise ServiceUnavailableError("OTP verification service is temporarily unavailable")

        if check.status != "approved":
            raise AuthenticationError("Invalid or expired OTP")


twilio_verify_service = TwilioVerifyService()

