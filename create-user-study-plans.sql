-- 🎯 CREATE STUDY PLAN FOR EXISTING USER
-- Run this AFTER creating the study_plans table

-- First, let's see users with certification goals but no study plans
SELECT 
    up.id,
    up.email,
    up.certification_goal,
    c.id as cert_id,
    c.name as cert_name
FROM user_profiles up
JOIN certifications c ON c.test_code = up.certification_goal
WHERE up.certification_goal IS NOT NULL;

-- Create study plans for users who have certification goals
-- First check if study plan already exists to avoid conflicts
INSERT INTO study_plans (
    user_id,
    certification_id,
    name,
    description,
    daily_study_minutes,
    is_active,
    created_at,
    updated_at
)
SELECT 
    up.id,
    c.id,
    'Primary: ' || c.name,
    'Main study plan for ' || c.name || ' certification',
    30,
    true,
    NOW(),
    NOW()
FROM user_profiles up
JOIN certifications c ON c.test_code = up.certification_goal
LEFT JOIN study_plans sp ON sp.user_id = up.id AND sp.certification_id = c.id AND sp.is_active = true
WHERE up.certification_goal IS NOT NULL
  AND sp.id IS NULL;

-- Verify study plans were created
SELECT 
    sp.id as study_plan_id,
    sp.user_id,
    sp.name,
    sp.is_active,
    up.email,
    up.certification_goal,
    c.test_code,
    c.name as cert_name
FROM study_plans sp
JOIN user_profiles up ON sp.user_id = up.id
JOIN certifications c ON sp.certification_id = c.id
ORDER BY sp.created_at DESC;

SELECT 'Study plans created for existing users!' as status;
