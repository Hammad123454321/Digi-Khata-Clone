"""Custom exception classes."""
from typing import Any, Dict


class BaseAppException(Exception):
    """Base exception for application errors."""

    def __init__(self, message: str, status_code: int = 500, details: Dict[str, Any] | None = None):
        self.message = message
        self.status_code = status_code
        self.details = details or {}
        super().__init__(self.message)


class NotFoundError(BaseAppException):
    """Resource not found exception."""

    def __init__(self, message: str = "Resource not found", details: Dict[str, Any] | None = None):
        super().__init__(message, status_code=404, details=details)


class ValidationError(BaseAppException):
    """Validation error exception."""

    def __init__(self, message: str = "Validation error", details: Dict[str, Any] | None = None):
        super().__init__(message, status_code=422, details=details)


class AuthenticationError(BaseAppException):
    """Authentication error exception."""

    def __init__(self, message: str = "Authentication failed", details: Dict[str, Any] | None = None):
        super().__init__(message, status_code=401, details=details)


class AuthorizationError(BaseAppException):
    """Authorization error exception."""

    def __init__(self, message: str = "Access denied", details: Dict[str, Any] | None = None):
        super().__init__(message, status_code=403, details=details)


class BusinessLogicError(BaseAppException):
    """Business logic error exception."""

    def __init__(self, message: str = "Business logic error", details: Dict[str, Any] | None = None):
        super().__init__(message, status_code=400, details=details)


class RateLimitError(BaseAppException):
    """Rate limit exceeded exception."""

    def __init__(self, message: str = "Rate limit exceeded", details: Dict[str, Any] | None = None):
        super().__init__(message, status_code=429, details=details)


class ServiceUnavailableError(BaseAppException):
    """External service (cache, messaging, etc.) unavailable."""

    def __init__(self, message: str = "Service unavailable", details: Dict[str, Any] | None = None):
        super().__init__(message, status_code=503, details=details)


class ConflictError(BaseAppException):
    """Conflict error exception (e.g., duplicate resource)."""

    def __init__(self, message: str = "Resource conflict", details: Dict[str, Any] | None = None):
        super().__init__(message, status_code=409, details=details)

