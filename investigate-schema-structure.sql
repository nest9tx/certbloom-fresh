-- =================================================================
-- INVESTIGATE CURRENT SCHEMA STRUCTURE
-- =================================================================
-- Purpose: Understand the actual database structure before integration
-- =================================================================

-- Check if concepts table exists and its structure
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('concepts', 'content_items', 'topics', 'questions')
ORDER BY table_name, ordinal_position;

-- Check current relationships
SELECT 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
AND tc.table_name IN ('concepts', 'content_items', 'topics', 'questions');

-- Check what concepts currently exist
SELECT 
    c.name as concept_name,
    c.id as concept_id,
    COUNT(ci.id) as content_items_count
FROM concepts c
LEFT JOIN content_items ci ON ci.concept_id = c.id
GROUP BY c.id, c.name
ORDER BY c.name;

-- Check if questions table has concept_id column
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'questions' 
AND column_name LIKE '%concept%';

-- =================================================================
-- This will show us the actual structure so we can fix the integration
-- =================================================================
