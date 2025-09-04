-- 🔍 CHECK CONTENT_ITEMS TABLE STRUCTURE
-- Let's see what columns actually exist in the content_items table

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'content_items' 
ORDER BY ordinal_position;

-- Also check a sample of existing content_items to understand the structure
SELECT 
    id,
    concept_id,
    type,
    created_at
FROM content_items 
LIMIT 5;
