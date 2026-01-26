"""Tests for business service."""
import pytest
from sqlalchemy.ext.asyncio import AsyncSession
from app.services.business import business_service
from app.core.exceptions import ConflictError, NotFoundError


@pytest.mark.asyncio
async def test_create_business(db_session: AsyncSession, test_user):
    """Test creating a business."""
    business = await business_service.create_business(
        name="Test Business",
        phone="+1234567891",
        user_id=test_user.id,
        db=db_session,
    )
    assert business.id is not None
    assert business.name == "Test Business"
    assert business.phone == "+1234567891"


@pytest.mark.asyncio
async def test_create_business_duplicate_phone(db_session: AsyncSession, test_user):
    """Test creating business with duplicate phone."""
    # Create first business
    await business_service.create_business(
        name="First Business",
        phone="+1234567891",
        user_id=test_user.id,
        db=db_session,
    )
    
    # Try to create second with same phone
    with pytest.raises(ConflictError):
        await business_service.create_business(
            name="Second Business",
            phone="+1234567891",
            user_id=test_user.id,
            db=db_session,
        )


@pytest.mark.asyncio
async def test_get_business(db_session: AsyncSession, test_business):
    """Test getting a business."""
    business = await business_service.get_business(test_business.id, db_session)
    assert business.id == test_business.id
    assert business.name == test_business.name


@pytest.mark.asyncio
async def test_get_business_not_found(db_session: AsyncSession):
    """Test getting non-existent business."""
    with pytest.raises(NotFoundError):
        await business_service.get_business(99999, db_session)


@pytest.mark.asyncio
async def test_list_user_businesses(db_session: AsyncSession, test_user, test_business):
    """Test listing user businesses."""
    businesses = await business_service.list_user_businesses(test_user.id, db_session)
    assert len(businesses) > 0
    assert any(b.id == test_business.id for b in businesses)





