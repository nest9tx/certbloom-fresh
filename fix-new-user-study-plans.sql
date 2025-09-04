-- 🔧 FIX FOR NEW USERS - CREATE STUDY PLAN FOR CURRENT USER
-- Run this to create a study plan for your current user account

-- First, let's see the current user profiles and their certification goals
SELECT 
    id,
    email,
    certification_goal,
    created_at
FROM user_profiles 
ORDER BY created_at DESC;

-- Check if there are any study plans for the current users
SELECT 
    up.email,
    up.certification_goal,
    sp.name as study_plan_name,
    sp.id as study_plan_id
FROM user_profiles up
LEFT JOIN study_plans sp ON up.id = sp.user_id AND sp.is_active = true
ORDER BY up.created_at DESC;

-- Create study plans for users who have certification goals but no study plans
-- This includes both 902 and placeholder plans for other certifications
INSERT INTO study_plans (
    user_id,
    certification_id,
    name,
    description,
    daily_study_minutes,
    is_active,
    progress_percentage,
    created_at,
    updated_at
)
SELECT 
    up.id,
    c.id,
    CASE 
        WHEN c.test_code = '902' THEN 'Primary: ' || c.name
        ELSE 'Coming Soon: ' || c.name
    END,
    CASE 
        WHEN c.test_code = '902' THEN 'Main study plan for ' || c.name || ' certification'
        ELSE 'This certification study path is in development. Full content and adaptive learning features will be available soon.'
    END,
    30,
    true,
    0.00,
    NOW(),
    NOW()
FROM user_profiles up
JOIN certifications c ON c.test_code = up.certification_goal
LEFT JOIN study_plans sp ON sp.user_id = up.id AND sp.certification_id = c.id AND sp.is_active = true
WHERE up.certification_goal IS NOT NULL
  AND sp.id IS NULL;

-- Also create placeholder plans for other certifications for current users
-- This ensures they see "Coming Soon" instead of nothing when they switch certs
INSERT INTO study_plans (
    user_id,
    certification_id,
    name,
    description,
    daily_study_minutes,
    is_active,
    progress_percentage,
    created_at,
    updated_at
)
SELECT 
    up.id,
    c.id,
    'Coming Soon: ' || c.name,
    'This certification study path is in development. Full content and adaptive learning features will be available soon.',
    30,
    true,
    0.00,
    NOW(),
    NOW()
FROM user_profiles up
CROSS JOIN certifications c
LEFT JOIN study_plans sp ON sp.user_id = up.id AND sp.certification_id = c.id
WHERE up.certification_goal IS NOT NULL
  AND c.test_code != up.certification_goal  -- Don't create for their current goal (already done above)
  AND sp.id IS NULL;  -- Only create if doesn't exist

-- Verify the results
SELECT 
    up.email,
    up.certification_goal,
    sp.name as study_plan_name,
    c.test_code,
    CASE 
        WHEN c.test_code = up.certification_goal THEN '✅ Current Goal'
        ELSE '🚧 Placeholder'
    END as plan_type
FROM user_profiles up
JOIN study_plans sp ON up.id = sp.user_id AND sp.is_active = true
JOIN certifications c ON sp.certification_id = c.id
ORDER BY up.created_at DESC, c.test_code;

SELECT '✅ Study plans created for all current users!' as status;
