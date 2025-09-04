-- 🔍 CHECK STUDY PLAN CREATION
-- Let's see if study plans are being created when certification goals are set

-- 1. Check current user profiles with certification goals
SELECT 
    id,
    email,
    certification_goal,
    created_at,
    updated_at
FROM user_profiles 
WHERE certification_goal IS NOT NULL
ORDER BY updated_at DESC;

-- 2. Check if study plans exist for these users
SELECT 
    sp.id as study_plan_id,
    sp.user_id,
    sp.certification_id,
    sp.name,
    sp.is_active,
    sp.created_at,
    up.email,
    up.certification_goal,
    c.test_code,
    c.name as cert_name
FROM study_plans sp
JOIN user_profiles up ON sp.user_id = up.id
LEFT JOIN certifications c ON sp.certification_id = c.id
ORDER BY sp.created_at DESC;

-- 3. Check for users who have certification goals but no study plans
SELECT 
    up.id,
    up.email,
    up.certification_goal,
    'Missing study plan' as issue
FROM user_profiles up
LEFT JOIN study_plans sp ON up.id = sp.user_id AND sp.is_active = true
WHERE up.certification_goal IS NOT NULL 
  AND sp.id IS NULL;

-- 4. Check certification table to see if Math 902 exists
SELECT 
    id,
    test_code,
    name,
    created_at
FROM certifications 
WHERE test_code = '902';

-- 5. Check if there are any domains for Math 902
SELECT 
    d.id,
    d.certification_id,
    d.name,
    d.order_index,
    c.test_code
FROM domains d
JOIN certifications c ON d.certification_id = c.id
WHERE c.test_code = '902'
ORDER BY d.order_index;
