-- 🔍 COMPREHENSIVE DATABASE STRUCTURE DIAGNOSTIC
-- Run this first to see what we actually have

-- 1. Check what tables exist
SELECT 'EXISTING TABLES' as section;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- 2. Check certifications table
SELECT 'CERTIFICATIONS TABLE STRUCTURE' as section;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'certifications'
ORDER BY ordinal_position;

-- 3. Check domains table structure
SELECT 'DOMAINS TABLE STRUCTURE' as section;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'domains'
ORDER BY ordinal_position;

-- 4. Check concepts table structure  
SELECT 'CONCEPTS TABLE STRUCTURE' as section;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'concepts'
ORDER BY ordinal_position;

-- 5. Check content_items table structure
SELECT 'CONTENT_ITEMS TABLE STRUCTURE' as section;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'content_items'
ORDER BY ordinal_position;

-- 6. Check answer_choices table structure
SELECT 'ANSWER_CHOICES TABLE STRUCTURE' as section;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'answer_choices'
ORDER BY ordinal_position;

-- 7. Show actual data in certifications
SELECT 'CERTIFICATIONS DATA' as section;
SELECT * FROM certifications LIMIT 5;

-- 8. Show actual data in domains
SELECT 'DOMAINS DATA' as section;
SELECT * FROM domains LIMIT 10;

-- 9. Show actual data in concepts
SELECT 'CONCEPTS DATA' as section;
SELECT * FROM concepts LIMIT 10;

-- 10. Show sample content_items
SELECT 'CONTENT_ITEMS SAMPLE' as section;
SELECT 
    id,
    concept_id,
    type,
    title,
    LEFT(content, 50) || '...' as content_preview
FROM content_items 
LIMIT 5;

-- 11. Check for 902 specific data
SELECT 'MATH 902 STRUCTURE CHECK' as section;
SELECT 
    'Looking for Math 902 certification...' as check_step;

-- First show all certifications to see what columns exist
SELECT 'ALL CERTIFICATIONS' as section;
SELECT * FROM certifications;

-- 12. Check foreign key relationships
SELECT 'FOREIGN KEY RELATIONSHIPS' as section;
SELECT 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
WHERE constraint_type = 'FOREIGN KEY' 
AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name;
