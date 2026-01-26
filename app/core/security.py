"""Security utilities for authentication and encryption."""
import base64
import secrets
from datetime import datetime, timedelta, timezone
from typing import Optional

from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import get_settings

settings = get_settings()

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Encryption key management
_encryption_key: Optional[bytes] = None
_fernet_instance: Optional[Fernet] = None


def _get_encryption_key() -> bytes:
    """Get or generate encryption key for data at rest."""
    global _encryption_key
    if _encryption_key is not None:
        return _encryption_key

    if settings.ENCRYPTION_KEY:
        try:
            # Decode base64 key
            _encryption_key = base64.b64decode(settings.ENCRYPTION_KEY)
            if len(_encryption_key) != 32:
                raise ValueError("Encryption key must be 32 bytes")
        except Exception:
            # If key is invalid, generate a new one
            _encryption_key = Fernet.generate_key()
    else:
        # Generate a new key if not provided
        _encryption_key = Fernet.generate_key()

    return _encryption_key


def _get_fernet() -> Fernet:
    """Get Fernet instance for encryption/decryption."""
    global _fernet_instance
    if _fernet_instance is None:
        key = _get_encryption_key()
        _fernet_instance = Fernet(key)
    return _fernet_instance


def encrypt_data(data: str) -> str:
    """Encrypt sensitive data at rest."""
    if not settings.ENCRYPTION_ENABLED:
        return data

    try:
        fernet = _get_fernet()
        encrypted = fernet.encrypt(data.encode())
        return base64.b64encode(encrypted).decode()
    except Exception as e:
        # Log error but don't fail - return original data
        from app.core.logging import get_logger
        logger = get_logger(__name__)
        logger.error("encryption_error", error=str(e))
        return data


def decrypt_data(encrypted_data: str) -> str:
    """Decrypt sensitive data at rest."""
    if not settings.ENCRYPTION_ENABLED:
        return encrypted_data

    try:
        fernet = _get_fernet()
        decoded = base64.b64decode(encrypted_data.encode())
        decrypted = fernet.decrypt(decoded)
        return decrypted.decode()
    except Exception as e:
        # Log error but don't fail - return original data
        from app.core.logging import get_logger
        logger = get_logger(__name__)
        logger.error("decryption_error", error=str(e))
        return encrypted_data


def generate_encryption_key() -> str:
    """Generate a new encryption key (base64 encoded)."""
    key = Fernet.generate_key()
    return base64.b64encode(key).decode()


def rotate_encryption_key(new_key: Optional[str] = None) -> str:
    """Rotate encryption key. Returns the new key."""
    global _encryption_key, _fernet_instance

    if new_key:
        try:
            _encryption_key = base64.b64decode(new_key)
            if len(_encryption_key) != 32:
                raise ValueError("Encryption key must be 32 bytes")
        except Exception as e:
            raise ValueError(f"Invalid encryption key: {e}")
    else:
        _encryption_key = Fernet.generate_key()

    _fernet_instance = Fernet(_encryption_key)
    return base64.b64encode(_encryption_key).decode()


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash."""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Hash a password."""
    return pwd_context.hash(password)


def generate_otp(length: int = None) -> str:
    """Generate a random OTP."""
    if length is None:
        length = settings.OTP_LENGTH
    return "".join([str(secrets.randbelow(10)) for _ in range(length)])


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create JWT access token."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )
    to_encode.update({"exp": expire, "iat": datetime.now(timezone.utc)})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def create_refresh_token(data: dict) -> str:
    """Create JWT refresh token."""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "iat": datetime.now(timezone.utc), "type": "refresh"})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def verify_token(token: str, token_type: str = "access") -> Optional[dict]:
    """Verify and decode JWT token."""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        if token_type == "refresh" and payload.get("type") != "refresh":
            return None
        if token_type == "access" and payload.get("type") == "refresh":
            return None
        return payload
    except JWTError:
        return None


def generate_device_token() -> str:
    """Generate a secure device pairing token."""
    return secrets.token_urlsafe(32)

