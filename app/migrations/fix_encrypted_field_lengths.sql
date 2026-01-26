-- Migration script to fix encrypted field column lengths
-- Encrypted values (base64 encoded) are much longer than the original values
-- Run this script to update existing database columns

-- Suppliers table
ALTER TABLE suppliers ALTER COLUMN phone TYPE VARCHAR(500);
ALTER TABLE suppliers ALTER COLUMN email TYPE VARCHAR(1000);

-- Customers table
ALTER TABLE customers ALTER COLUMN phone TYPE VARCHAR(500);
ALTER TABLE customers ALTER COLUMN email TYPE VARCHAR(1000);

-- Staff table
ALTER TABLE staff ALTER COLUMN phone TYPE VARCHAR(500);
ALTER TABLE staff ALTER COLUMN email TYPE VARCHAR(1000);

-- Business table
ALTER TABLE businesses ALTER COLUMN email TYPE VARCHAR(1000);

-- Users table
ALTER TABLE users ALTER COLUMN email TYPE VARCHAR(1000);

-- Bank accounts table
ALTER TABLE bank_accounts ALTER COLUMN account_number TYPE VARCHAR(500);
ALTER TABLE bank_accounts ALTER COLUMN account_holder_name TYPE VARCHAR(1000);




