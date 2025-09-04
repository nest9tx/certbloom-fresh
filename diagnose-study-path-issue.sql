-- 🔍 DIAGNOSE USER STUDY PATH ISSUE

-- Check current user profile
SELECT 
    'user_profiles' as table_name,
    id as user_id,
    email,
    certification_goal,
    created_at
FROM user_profiles
ORDER BY created_at DESC
LIMIT 3;

-- Check for study plans
SELECT 
    'study_plans' as table_name,
    sp.id,
    sp.user_id,
    sp.certification_id,
    sp.is_active,
    c.name as certification_name,
    c.test_code,
    sp.created_at
FROM study_plans sp
LEFT JOIN certifications c ON sp.certification_id = c.id
ORDER BY sp.created_at DESC
LIMIT 5;

-- Check for 902 certification
SELECT 
    'certifications' as table_name,
    id,
    name,
    test_code,
    description
FROM certifications
WHERE test_code = '902' OR name LIKE '%902%' OR name LIKE '%Math%';

-- Check if user has 902 but missing study plan
SELECT 
    'missing_study_plan_check' as table_name,
    up.id as user_id,
    up.email,
    up.certification_goal,
    CASE 
        WHEN sp.id IS NULL THEN 'MISSING STUDY PLAN'
        WHEN sp.is_active = false THEN 'INACTIVE STUDY PLAN'
        ELSE 'HAS ACTIVE STUDY PLAN'
    END as status
FROM user_profiles up
LEFT JOIN study_plans sp ON up.id = sp.user_id AND sp.is_active = true
WHERE up.certification_goal IS NOT NULL
ORDER BY up.created_at DESC;
