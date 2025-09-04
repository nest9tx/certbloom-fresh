-- Check the current structure of study_plans table and related data
-- Run this in Supabase SQL Editor

-- 1. Check table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'study_plans';

-- 2. Check if there are any existing study plans
SELECT id, user_id, certification_id, name, is_active, created_at
FROM study_plans
ORDER BY created_at DESC
LIMIT 10;

-- 3. Check certifications that have study plans
SELECT c.id, c.name, c.test_code, COUNT(sp.id) as study_plan_count
FROM certifications c
LEFT JOIN study_plans sp ON c.id = sp.certification_id
GROUP BY c.id, c.name, c.test_code
ORDER BY study_plan_count DESC;

-- 4. Check user profiles with certification goals but no study plans
SELECT up.id, up.email, up.certification_goal, sp.id as study_plan_id
FROM user_profiles up
LEFT JOIN study_plans sp ON up.id = sp.user_id AND sp.is_active = true
WHERE up.certification_goal IS NOT NULL
ORDER BY up.created_at DESC
LIMIT 10;
