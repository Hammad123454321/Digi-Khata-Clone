"""Simple Python migration script to create sync_change_logs table."""
import asyncio
import os
import sys
from pathlib import Path

# Add project root to Python path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

# Try to load from .env file
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # dotenv not installed, that's okay

# Get database URL from environment
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("ERROR: DATABASE_URL environment variable is required")
    print("Set it in .env file or as environment variable:")
    print("  DATABASE_URL=postgresql+asyncpg://digikhata:digikhata_password@localhost:5434/digikhata")
    sys.exit(1)


async def create_sync_change_log_table():
    """Create sync_change_logs table and indexes."""
    engine = create_async_engine(DATABASE_URL, echo=False)
    
    try:
        async with engine.begin() as conn:
            # Create enum type
            await conn.execute(text("""
                DO $$ BEGIN
                    CREATE TYPE syncaction AS ENUM ('CREATE', 'UPDATE', 'DELETE');
                EXCEPTION
                    WHEN duplicate_object THEN null;
                END $$;
            """))
            
            # Create table
            await conn.execute(text("""
                CREATE TABLE IF NOT EXISTS sync_change_logs (
                    id SERIAL PRIMARY KEY,
                    business_id INTEGER NOT NULL,
                    device_id VARCHAR(255),
                    entity_type VARCHAR(50) NOT NULL,
                    entity_id INTEGER NOT NULL,
                    action syncaction NOT NULL,
                    data JSONB,
                    sync_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
                    synced_devices JSONB,
                    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
                    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
                    CONSTRAINT fk_sync_change_logs_business 
                        FOREIGN KEY (business_id) 
                        REFERENCES businesses(id) 
                        ON DELETE CASCADE
                );
            """))
            
            # Create indexes
            indexes = [
            "CREATE INDEX IF NOT EXISTS ix_sync_change_logs_business_id ON sync_change_logs(business_id);",
            "CREATE INDEX IF NOT EXISTS ix_sync_change_logs_device_id ON sync_change_logs(device_id);",
            "CREATE INDEX IF NOT EXISTS ix_sync_change_logs_entity_type ON sync_change_logs(entity_type);",
            "CREATE INDEX IF NOT EXISTS ix_sync_change_logs_entity_id ON sync_change_logs(entity_id);",
            "CREATE INDEX IF NOT EXISTS ix_sync_change_logs_action ON sync_change_logs(action);",
            "CREATE INDEX IF NOT EXISTS ix_sync_change_logs_sync_timestamp ON sync_change_logs(sync_timestamp);",
            "CREATE INDEX IF NOT EXISTS ix_sync_change_logs_business_timestamp ON sync_change_logs(business_id, sync_timestamp);",
            "CREATE INDEX IF NOT EXISTS ix_sync_change_logs_business_entity ON sync_change_logs(business_id, entity_type, entity_id);",
            "CREATE INDEX IF NOT EXISTS ix_sync_change_logs_business_device ON sync_change_logs(business_id, device_id);",
            "CREATE INDEX IF NOT EXISTS ix_sync_change_logs_entity ON sync_change_logs(entity_type, entity_id, sync_timestamp);",
        ]
        
            for index_sql in indexes:
                await conn.execute(text(index_sql))
            
            print("[SUCCESS] sync_change_logs table created successfully")
    finally:
        await engine.dispose()


async def drop_sync_change_log_table():
    """Drop sync_change_logs table (for rollback)."""
    engine = create_async_engine(DATABASE_URL, echo=False)
    
    try:
        async with engine.begin() as conn:
            await conn.execute(text("DROP TABLE IF EXISTS sync_change_logs CASCADE;"))
            await conn.execute(text("DROP TYPE IF EXISTS syncaction CASCADE;"))
        
        print("[SUCCESS] sync_change_logs table dropped successfully")
    finally:
        await engine.dispose()


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "down":
        print("Dropping sync_change_logs table...")
        asyncio.run(drop_sync_change_log_table())
    else:
        print("Creating sync_change_logs table...")
        asyncio.run(create_sync_change_log_table())

