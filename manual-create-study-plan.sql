-- 🔧 MANUALLY CREATE STUDY PLAN FOR USER WITH 902 CERTIFICATION GOAL

-- First, find the user with certification goal 902
SELECT 
    'Current user with 902 goal' as status,
    id as user_id,
    email,
    certification_goal
FROM user_profiles 
WHERE certification_goal LIKE '%902%' OR certification_goal = '902' OR certification_goal LIKE '%Math%'
ORDER BY created_at DESC
LIMIT 1;

-- Find the 902 certification ID
SELECT 
    'Find 902 certification ID' as status,
    id as cert_id,
    name,
    test_code
FROM certifications 
WHERE test_code = '902'
LIMIT 1;

-- Check if study plan already exists
SELECT 
    'Existing study plans check' as status,
    sp.id,
    sp.user_id,
    sp.certification_id,
    sp.name,
    sp.is_active,
    c.test_code
FROM study_plans sp
JOIN certifications c ON sp.certification_id = c.id
WHERE c.test_code = '902'
ORDER BY sp.created_at DESC;

-- Manual insert (replace with actual IDs from above queries)
-- We'll need to run this after we get the actual user_id and certification_id
/*
INSERT INTO study_plans (
    user_id,
    certification_id,
    name,
    daily_study_minutes,
    is_active,
    created_at,
    updated_at
) VALUES (
    'REPLACE_WITH_ACTUAL_USER_ID',
    'REPLACE_WITH_ACTUAL_CERT_ID',
    'Primary: Math EC-6 902',
    30,
    true,
    NOW(),
    NOW()
);
*/
