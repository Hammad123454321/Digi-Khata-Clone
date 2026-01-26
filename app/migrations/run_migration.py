"""Run migration to fix encrypted field column lengths."""
import asyncio
import sys
from pathlib import Path
from sqlalchemy import text

# Add parent directory to path to import app modules
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from app.core.database import get_engine
from app.core.config import get_settings
from app.core.logging import setup_logging, get_logger

settings = get_settings()
setup_logging()
logger = get_logger(__name__)


async def run_migration():
    """Run the migration to fix encrypted field column lengths."""
    engine = get_engine()
    
    # List of ALTER TABLE statements
    statements = [
        "ALTER TABLE suppliers ALTER COLUMN phone TYPE VARCHAR(500)",
        "ALTER TABLE suppliers ALTER COLUMN email TYPE VARCHAR(1000)",
        "ALTER TABLE customers ALTER COLUMN phone TYPE VARCHAR(500)",
        "ALTER TABLE customers ALTER COLUMN email TYPE VARCHAR(1000)",
        "ALTER TABLE staff ALTER COLUMN phone TYPE VARCHAR(500)",
        "ALTER TABLE staff ALTER COLUMN email TYPE VARCHAR(1000)",
        "ALTER TABLE businesses ALTER COLUMN email TYPE VARCHAR(1000)",
        "ALTER TABLE users ALTER COLUMN email TYPE VARCHAR(1000)",
        "ALTER TABLE bank_accounts ALTER COLUMN account_number TYPE VARCHAR(500)",
        "ALTER TABLE bank_accounts ALTER COLUMN account_holder_name TYPE VARCHAR(1000)",
    ]
    
    try:
        async with engine.begin() as conn:
            for statement in statements:
                logger.info(f"Executing: {statement}")
                await conn.execute(text(statement))
                logger.info("Success")
        
        logger.info("Migration completed successfully!")
        print("\nMigration completed successfully!")
        print("All encrypted field columns have been updated to support longer encrypted values.")
        
    except Exception as e:
        logger.error(f"Migration failed: {e}", exc_info=True)
        print(f"\nMigration failed: {e}")
        print("Please check the error message above.")
        sys.exit(1)
    finally:
        await engine.dispose()


if __name__ == "__main__":
    print("Running migration to fix encrypted field column lengths...")
    print("=" * 60)
    asyncio.run(run_migration())

