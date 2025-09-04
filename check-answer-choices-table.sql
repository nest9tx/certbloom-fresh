-- 🔍 CHECK ANSWER_CHOICES TABLE STRUCTURE
-- Let's see what columns actually exist

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'answer_choices'
ORDER BY ordinal_position;

-- Also check a sample record to see the actual data structure
SELECT * FROM answer_choices LIMIT 3;
