"""Application configuration management."""
from functools import lru_cache
from typing import List

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # Environment
    ENVIRONMENT: str = Field(default="development")
    DEBUG: bool = Field(default=False)

    # Application
    APP_NAME: str = Field(default="DigiKhata Clone Backend")
    APP_VERSION: str = Field(default="1.0.0")
    API_V1_PREFIX: str = Field(default="/api/v1")
    SECRET_KEY: str = Field(default="development-secret-key-change-in-production-min-32-chars", min_length=32)
    ALGORITHM: str = Field(default="HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=30)
    REFRESH_TOKEN_EXPIRE_DAYS: int = Field(default=30)

    # Database
    MONGODB_URL: str = Field(...)
    MONGODB_DATABASE: str = Field(default="digikhata")

    # Redis
    REDIS_URL: str = Field(default="redis://localhost:6379/0")
    REDIS_PASSWORD: str = Field(default="")
    REDIS_DECODE_RESPONSES: bool = Field(default=True)

    # SendPK SMS Gateway
    SENDPK_API_KEY: str = Field(default="")
    SENDPK_SENDER_ID: str = Field(default="")
    SENDPK_BASE_URL: str = Field(default="https://sendpk.com/api")

    # Object Storage (S3-compatible)
    AWS_ACCESS_KEY_ID: str = Field(default="")
    AWS_SECRET_ACCESS_KEY: str = Field(default="")
    AWS_REGION: str = Field(default="us-east-1")
    S3_BUCKET_NAME: str = Field(default="")
    S3_ENDPOINT_URL: str = Field(default="")
    S3_USE_SSL: bool = Field(default=True)

    # Rate Limiting
    RATE_LIMIT_ENABLED: bool = Field(default=True)
    RATE_LIMIT_PER_MINUTE: int = Field(default=60)
    RATE_LIMIT_PER_HOUR: int = Field(default=1000)

    # Device Management
    MAX_DEVICES_PER_BUSINESS: int = Field(default=3)

    # OTP Settings
    OTP_LENGTH: int = Field(default=6)
    OTP_EXPIRE_MINUTES: int = Field(default=10)
    OTP_MAX_ATTEMPTS: int = Field(default=5)

    # Backup Settings
    BACKUP_ENABLED: bool = Field(default=True)
    BACKUP_RETENTION_DAYS: int = Field(default=30)
    AUTO_BACKUP_INTERVAL_HOURS: int = Field(default=24)

    # Encryption Settings
    ENCRYPTION_KEY: str = Field(default="")  # 32-byte key for AES-256, base64 encoded
    ENCRYPTION_ENABLED: bool = Field(default=True)
    KEY_ROTATION_ENABLED: bool = Field(default=True)
    KEY_ROTATION_INTERVAL_DAYS: int = Field(default=90)  # Rotate keys every 90 days

    # Data Retention Settings
    AUDIT_LOG_RETENTION_DAYS: int = Field(default=90)  # Default 90 days, extendable to 1 year
    AUDIT_LOG_MAX_RETENTION_DAYS: int = Field(default=365)  # Maximum 1 year
    ENABLE_AUDIT_CLEANUP: bool = Field(default=True)
    CLEANUP_SCHEDULE_HOURS: int = Field(default=24)  # Run cleanup daily

    # Monitoring
    SENTRY_DSN: str = Field(default="")
    SENTRY_ENVIRONMENT: str = Field(default="development")
    ENABLE_METRICS: bool = Field(default=True)
    METRICS_PORT: int = Field(default=9090)

    # Logging
    LOG_LEVEL: str = Field(default="INFO")
    LOG_FORMAT: str = Field(default="json")

    # CORS
    CORS_ORIGINS: List[str] = Field(default=["http://localhost:3000", "http://localhost:8080"])
    CORS_ALLOW_CREDENTIALS: bool = Field(default=True)

    # Server
    SERVER_HOST: str = Field(default="0.0.0.0")
    SERVER_PORT: int = Field(default=8000)

    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def parse_cors_origins(cls, v):
        """Parse CORS origins from string or list."""
        if isinstance(v, str):
            import json
            return json.loads(v)
        return v

    @property
    def is_production(self) -> bool:
        """Check if running in production."""
        return self.ENVIRONMENT.lower() == "production"



@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()

