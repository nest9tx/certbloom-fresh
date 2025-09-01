-- CHECK DOMAINS TABLE STRUCTURE
-- Run this to see exact column requirements

-- 1. Check domains table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'domains' 
ORDER BY ordinal_position;

-- 2. Look at existing domains from Math 902 to see the pattern
SELECT 
    id,
    certification_id,
    name,
    code,
    description,
    weight,
    order_index
FROM domains d
JOIN certifications c ON d.certification_id = c.id
WHERE c.test_code = '902'
ORDER BY d.order_index
LIMIT 5;

-- 3. Check constraints on domains table
SELECT 
    conname AS constraint_name,
    contype AS constraint_type,
    conkey AS constrained_columns
FROM pg_constraint 
WHERE conrelid = 'domains'::regclass;
