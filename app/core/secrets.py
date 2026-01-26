"""Secrets validation and management utilities."""
from typing import List, Optional
from app.core.config import get_settings
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)


class SecretsValidator:
    """Validate required secrets and configuration."""
    
    @staticmethod
    def validate_production_secrets() -> List[str]:
        """
        Validate that all required secrets are set for production.
        Returns list of missing secrets.
        """
        missing = []
        
        if settings.is_production:
            # Critical secrets for production
            if not settings.SECRET_KEY or settings.SECRET_KEY == "development-secret-key-change-in-production-min-32-chars":
                missing.append("SECRET_KEY")
            
            if not settings.MONGODB_URL:
                missing.append("MONGODB_URL")
            
            if settings.ENCRYPTION_ENABLED and not settings.ENCRYPTION_KEY:
                missing.append("ENCRYPTION_KEY")
            
            if settings.SENTRY_DSN:
                # Sentry is optional but if enabled, should be configured
                pass
            
            # Optional but recommended
            if not settings.REDIS_URL or settings.REDIS_URL == "redis://localhost:6379/0":
                logger.warning("redis_using_default", message="Using default Redis URL in production")
        
        return missing
    
    @staticmethod
    def validate_secret_key_strength() -> bool:
        """Validate that SECRET_KEY meets minimum requirements."""
        if not settings.SECRET_KEY:
            return False
        
        # Minimum 32 characters for HS256
        if len(settings.SECRET_KEY) < 32:
            return False
        
        # Should not be the default development key
        if settings.SECRET_KEY == "development-secret-key-change-in-production-min-32-chars":
            return False
        
        return True
    
    @staticmethod
    def validate_encryption_key() -> bool:
        """Validate encryption key format."""
        if not settings.ENCRYPTION_KEY:
            return False
        
        try:
            import base64
            key_bytes = base64.b64decode(settings.ENCRYPTION_KEY)
            # Fernet requires 32 bytes
            return len(key_bytes) == 32
        except Exception:
            return False
    
    @staticmethod
    def check_all_secrets() -> dict:
        """
        Check all secrets and return validation report.
        Returns dict with validation results.
        """
        report = {
            "valid": True,
            "missing": [],
            "warnings": [],
            "errors": [],
        }
        
        # Check production secrets
        if settings.is_production:
            missing = SecretsValidator.validate_production_secrets()
            if missing:
                report["valid"] = False
                report["missing"] = missing
                report["errors"].append(f"Missing required secrets: {', '.join(missing)}")
        
        # Check secret key strength
        if not SecretsValidator.validate_secret_key_strength():
            report["valid"] = False
            report["errors"].append("SECRET_KEY is weak or uses default value")
        
        # Check encryption key if enabled
        if settings.ENCRYPTION_ENABLED:
            if not SecretsValidator.validate_encryption_key():
                report["valid"] = False
                report["errors"].append("ENCRYPTION_KEY is invalid or missing")
        
        # Warnings
        if settings.is_production:
            if not settings.SENTRY_DSN:
                report["warnings"].append("Sentry DSN not configured - error tracking disabled")
            
            if settings.CORS_ORIGINS == ["*"]:
                report["warnings"].append("CORS allows all origins - security risk")
        
        return report


def validate_startup_secrets() -> None:
    """
    Validate secrets on application startup.
    Raises ValueError if critical secrets are missing in production.
    """
    if settings.is_production:
        report = SecretsValidator.check_all_secrets()
        
        if report["errors"]:
            error_msg = "Critical secrets validation failed:\n" + "\n".join(report["errors"])
            logger.error("secrets_validation_failed", errors=report["errors"])
            raise ValueError(error_msg)
        
        if report["warnings"]:
            for warning in report["warnings"]:
                logger.warning("secrets_validation_warning", warning=warning)





