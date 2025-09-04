-- 🔍 DEBUG AUTH AND PROFILE STATUS

-- Check if user_profiles table has users
SELECT 
    'user_profiles' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN certification_goal IS NOT NULL THEN 1 END) as users_with_cert_goal
FROM user_profiles;

-- Show all user profiles
SELECT 
    id,
    email,
    certification_goal,
    subscription_status,
    created_at
FROM user_profiles
ORDER BY created_at DESC
LIMIT 5;

-- Check if any users have study plans
SELECT 
    'study_plans' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT user_id) as unique_users
FROM study_plans;

-- Show recent study plans
SELECT 
    sp.id,
    sp.user_id,
    up.email,
    c.name as certification_name,
    c.test_code,
    sp.created_at
FROM study_plans sp
LEFT JOIN user_profiles up ON sp.user_id = up.id
LEFT JOIN certifications c ON sp.certification_id = c.id
ORDER BY sp.created_at DESC
LIMIT 5;
