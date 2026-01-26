"""Pytest configuration and fixtures."""
import pytest
from typing import AsyncGenerator
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.core.database import Base, get_db
from app.core.config import get_settings

settings = get_settings()

# Test database URL (in-memory SQLite for testing)
TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

# Create test engine
test_engine = create_async_engine(
    TEST_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
    echo=False,
)

TestSessionLocal = async_sessionmaker(
    test_engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)


@pytest.fixture
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    """Create a test database session."""
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    async with TestSessionLocal() as session:
        yield session
        await session.rollback()
    
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


@pytest.fixture
async def client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    """Create a test client."""
    async def override_get_db():
        yield db_session
    
    app.dependency_overrides[get_db] = override_get_db
    
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac
    
    app.dependency_overrides.clear()


@pytest.fixture
async def test_user(db_session: AsyncSession):
    """Create a test user."""
    from app.models.user import User
    from datetime import datetime, timezone
    
    user = User(
        phone="+1234567890",
        is_active=True,
        last_login_at=datetime.now(timezone.utc),
    )
    db_session.add(user)
    await db_session.flush()
    await db_session.refresh(user)
    return user


@pytest.fixture
async def test_business(db_session: AsyncSession, test_user):
    """Create a test business."""
    from app.models.business import Business
    from app.models.user import UserMembership, UserRoleEnum
    
    business = Business(
        name="Test Business",
        phone="+1234567891",
        is_active=True,
    )
    db_session.add(business)
    await db_session.flush()
    
    # Add user as owner
    membership = UserMembership(
        user_id=test_user.id,
        business_id=business.id,
        role=UserRoleEnum.OWNER,
        is_active=True,
    )
    db_session.add(membership)
    await db_session.flush()
    await db_session.refresh(business)
    return business


@pytest.fixture
def auth_headers(test_user):
    """Create auth headers for test user."""
    from app.core.security import create_access_token
    
    token = create_access_token(data={"sub": str(test_user.id), "phone": test_user.phone})
    return {"Authorization": f"Bearer {token}"}

