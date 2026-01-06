"""SMS service for SendPK integration."""
import httpx
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
        self.sender_id = settings.SENDPK_SENDER_ID
        # Expected e.g. https://sendpk.com/api  (we'll append /sms.php)
        self.base_url = settings.SENDPK_BASE_URL.rstrip("/")

    async def send_otp(self, phone: str, otp: str) -> bool:
        """Send OTP via SendPK transactional/OTP route."""
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
            # SendPK API endpoint for OTP (matches official PHP example)
            # Final URL: https://sendpk.com/api/sms.php?api_key=API_KEY
            url = f"{self.base_url}/sms.php"
            message = f"Your OTP is {otp}. Valid for {settings.OTP_EXPIRE_MINUTES} minutes."

            # SendPK expects form-encoded body and api_key in query string
            params = {"api_key": self.api_key}
            data = {
                "sender": self.sender_id,
                "mobile": phone,
                "message": message,
            }

            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.post(url, params=params, data=data)
                response.raise_for_status()

            # SendPK typically returns a string like "OK" or an error code.
            logger.info("otp_sent", phone=phone, otp_length=len(otp), response_text=response.text)

            return True

        except httpx.HTTPError as e:
            logger.error("sms_send_failed", phone=phone, error=str(e))
            raise BusinessLogicError(f"Failed to send OTP: {str(e)}")
        except Exception as e:
            logger.error("sms_unexpected_error", phone=phone, error=str(e), exc_info=True)
            raise BusinessLogicError(f"Unexpected error sending OTP: {str(e)}")

    async def send_notification(self, phone: str, message: str) -> bool:
        """Send notification SMS."""
        try:
            url = f"{self.base_url}/sms.php"
            params = {"api_key": self.api_key}
            data = {
                "sender": self.sender_id,
                "mobile": phone,
                "message": message,
            }

            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.post(url, params=params, data=data)
                response.raise_for_status()

            logger.info("notification_sent", phone=phone, response_text=response.text)
            return True

        except httpx.HTTPError as e:
            logger.error("sms_notification_failed", phone=phone, error=str(e))
            return False
        except Exception as e:
            logger.error("sms_notification_error", phone=phone, error=str(e), exc_info=True)
            return False


# Singleton instance
sms_service = SMSService()

