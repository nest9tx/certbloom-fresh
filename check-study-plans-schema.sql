-- 🔍 CHECK STUDY_PLANS TABLE SCHEMA AND CONSTRAINTS

-- Check the table structure and constraints
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'study_plans' 
ORDER BY ordinal_position;

-- Check for any NOT NULL constraints that might be causing issues
SELECT
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'study_plans'
AND tc.constraint_type = 'CHECK';

-- Try a minimal insert to see what's required
-- This is just to test - we won't actually run it
-- INSERT INTO study_plans (user_id, certification_id, name, is_active) 
-- VALUES ('test-user-id', 'test-cert-id', 'Test Plan', true);
