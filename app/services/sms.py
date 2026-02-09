"""SMS service for SendPK integration."""
import httpx
import json
from typing import Optional

from app.core.config import get_settings
from app.core.logging import get_logger
from app.core.exceptions import BusinessLogicError

settings = get_settings()
logger = get_logger(__name__)


class SMSService:
    """SMS service using SendPK API."""

    def __init__(self):
        self.api_key = settings.SENDPK_API_KEY
        self.username = settings.SENDPK_USERNAME
        self.password = settings.SENDPK_PASSWORD
        self.sender_id = settings.SENDPK_SENDER_ID
        # Expected e.g. https://sendpk.com/api  (we'll append /sms.php)
        self.base_url = settings.SENDPK_BASE_URL.rstrip("/")

    async def send_otp(self, phone: str, otp: str) -> bool:
        """Send OTP via SendPK."""
        # Bypass SMS sending in development mode
        if settings.ENVIRONMENT.lower() == "development" or settings.DEBUG:
            logger.info(
                "otp_bypassed_dev_mode",
                phone=phone,
                otp=otp,
                message="OTP sending bypassed in development mode. Use this OTP to verify."
            )
            print(f"\n{'='*60}")
            print(f"🔐 DEVELOPMENT MODE: OTP BYPASSED")
            print(f"📱 Phone: {phone}")
            print(f"🔑 OTP: {otp}")
            print(f"⏱️  Valid for: {settings.OTP_EXPIRE_MINUTES} minutes")
            print(f"{'='*60}\n")
            return True

        try:
            # SendPK API endpoint
            url = f"{self.base_url}/sms.php"
            message = f"Your OTP is {otp}. Valid for {settings.OTP_EXPIRE_MINUTES} minutes."

            params = self._build_message_params(phone=phone, message=message)
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(url, params=params)
                response.raise_for_status()

            if not self._is_success_response(response.text):
                raise BusinessLogicError(
                    f"SendPK returned error: {response.text.strip() or 'Unknown error'}"
                )

            logger.info("otp_sent", phone=phone, otp_length=len(otp), response_text=response.text)
            return True

        except httpx.HTTPError as e:
            logger.error("sms_send_failed", phone=phone, error=str(e))
            raise BusinessLogicError(f"Failed to send OTP: {str(e)}")
        except Exception as e:
            logger.error("sms_unexpected_error", phone=phone, error=str(e), exc_info=True)
            raise BusinessLogicError(f"Unexpected error sending OTP: {str(e)}")

    async def send_notification(
        self,
        phone: str,
        message: str,
        template_id: Optional[str] = None,
    ) -> bool:
        """Send notification SMS."""
        try:
            url = f"{self.base_url}/sms.php"
            params = self._build_message_params(
                phone=phone,
                message=message,
                template_id=template_id,
            )

            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(url, params=params)
                response.raise_for_status()

            if not self._is_success_response(response.text):
                logger.error(
                    "sms_notification_failed",
                    phone=phone,
                    response_text=response.text,
                )
                return False

            logger.info("notification_sent", phone=phone, response_text=response.text)
            return True

        except httpx.HTTPError as e:
            logger.error("sms_notification_failed", phone=phone, error=str(e))
            return False
        except Exception as e:
            logger.error("sms_notification_error", phone=phone, error=str(e), exc_info=True)
            return False

    def _build_auth_params(self) -> dict:
        """Build SMS provider auth params."""
        if self.api_key:
            return {"api_key": self.api_key}
        if self.username and self.password:
            return {"username": self.username, "password": self.password}
        return {}

    def _build_message_params(
        self,
        *,
        phone: str,
        message: str,
        template_id: Optional[str] = None,
    ) -> dict:
        params = self._build_auth_params()
        if not params:
            raise BusinessLogicError("SMS credentials are not configured.")
        if not self.sender_id:
            raise BusinessLogicError("SMS sender ID is not configured.")

        params.update(
            {
                "sender": self.sender_id,
                "mobile": phone,
                "message": message,
            }
        )

        if template_id:
            params["template_id"] = template_id

        if self._is_unicode(message):
            params["type"] = "unicode"

        return params

    @staticmethod
    def _is_unicode(message: str) -> bool:
        return any(ord(char) > 127 for char in message)

    @staticmethod
    def _is_success_response(response_text: str) -> bool:
        text = response_text.strip()
        if not text:
            return False
        if text.upper().startswith("OK"):
            return True
        if text.startswith("{") or text.startswith("["):
            try:
                payload = json.loads(text)
                if isinstance(payload, dict):
                    status = str(payload.get("status") or payload.get("response") or "").upper()
                    return status == "OK" or payload.get("success") is True
            except json.JSONDecodeError:
                return False
        return False


# Singleton instance
sms_service = SMSService()
