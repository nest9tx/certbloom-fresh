-- =====================================================
-- TABLE STRUCTURE DIAGNOSTIC (SIMPLIFIED)
-- =====================================================
-- Run this in Supabase SQL Editor to see actual table structures

-- Check domains table structure
SELECT 'DOMAINS TABLE STRUCTURE:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'domains' 
ORDER BY ordinal_position;

-- Check concepts table structure  
SELECT 'CONCEPTS TABLE STRUCTURE:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'concepts' 
ORDER BY ordinal_position;

-- Check content_items table structure
SELECT 'CONTENT_ITEMS TABLE STRUCTURE:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'content_items' 
ORDER BY ordinal_position;

-- Alternative: Check if tables exist at all
SELECT 'TABLE EXISTS CHECK:' as info;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('domains', 'concepts', 'content_items', 'certifications');
