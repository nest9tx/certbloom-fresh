-- CHECK ACTUAL CONTENT_ITEMS TABLE STRUCTURE
-- Let's see what columns actually exist

SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'content_items' 
ORDER BY ordinal_position;

-- Also check if we have the right table structure
\d content_items;
