-- 🔧 FIX MISSING STUDY PLANS FOR USERS WITH CERTIFICATION GOALS

-- First, check current state
SELECT 
    'Current state check' as status,
    up.id as user_id,
    up.email,
    up.certification_goal,
    sp.id as study_plan_id,
    sp.is_active
FROM user_profiles up
LEFT JOIN study_plans sp ON up.id = sp.user_id
WHERE up.certification_goal IS NOT NULL
ORDER BY up.created_at DESC;

-- Find 902 certification ID
SELECT 
    'Find 902 certification' as status,
    id,
    name,
    test_code
FROM certifications 
WHERE test_code = '902';

-- Create missing study plans for users with certification goal but no active study plan
-- This will be the manual fix if needed
