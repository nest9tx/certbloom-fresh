-- CHECK ACTUAL CONTENT_ITEMS SCHEMA
-- Let's see what columns exist in the table

SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'content_items' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Show a sample row to understand the structure
SELECT * FROM content_items LIMIT 1;
