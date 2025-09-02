-- CHECK ACTUAL CONTENT_ITEMS TABLE SCHEMA
-- Let's see exactly what columns exist

\d content_items;

-- Also check with information_schema
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'content_items' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Show a few sample rows to understand the structure
SELECT * FROM content_items LIMIT 3;
