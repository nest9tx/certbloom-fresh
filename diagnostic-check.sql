-- 🌸 DIAGNOSTIC: Check what tables and columns exist
-- Run this first to see the current database structure

-- Check if certifications table exists and what columns it has
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'certifications'
ORDER BY ordinal_position;

-- Check if domains table exists
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable  
FROM information_schema.columns 
WHERE table_name = 'domains'
ORDER BY ordinal_position;

-- Check if concepts table exists
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'concepts'
ORDER BY ordinal_position;

-- Check if content_items table exists
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'content_items'
ORDER BY ordinal_position;

-- List all tables in current schema
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;
