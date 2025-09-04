-- Debug current user state to understand why study path isn't loading
-- Run this in Supabase SQL Editor

-- 1. Check your user profile
SELECT 
  id,
  email,
  certification_goal,
  created_at,
  updated_at
FROM user_profiles 
WHERE email LIKE '%@%' -- Replace with your email if needed
ORDER BY created_at DESC
LIMIT 5;

-- 2. Check for any study plans for your user
SELECT 
  sp.id,
  sp.user_id,
  sp.certification_id,
  sp.name,
  sp.is_active,
  sp.created_at,
  c.name as cert_name,
  c.test_code
FROM study_plans sp
LEFT JOIN certifications c ON sp.certification_id = c.id
WHERE sp.user_id IN (
  SELECT id FROM user_profiles 
  WHERE email LIKE '%@%' -- Replace with your email
)
ORDER BY sp.created_at DESC;

-- 3. Check available certifications with test_code = '902'
SELECT 
  id,
  name,
  test_code,
  created_at
FROM certifications 
WHERE test_code = '902'
ORDER BY created_at DESC;

-- 4. Check the mapping for Math 902
SELECT 
  'TExES Core Subjects EC-6: Mathematics (902)' as certification_goal,
  c.id as certification_id,
  c.name as certification_name,
  c.test_code
FROM certifications c
WHERE c.test_code = '902';

-- 5. Manual check: What would happen if we call getUserPrimaryLearningPath?
-- This simulates the function that should return hasStructuredPath: true

WITH user_data AS (
  SELECT id, certification_goal 
  FROM user_profiles 
  WHERE email LIKE '%@%' -- Replace with your email
  ORDER BY created_at DESC 
  LIMIT 1
)
SELECT 
  ud.id as user_id,
  ud.certification_goal,
  sp.id as study_plan_id,
  sp.certification_id,
  sp.is_active,
  c.name as certification_name,
  CASE 
    WHEN sp.id IS NOT NULL AND sp.is_active = true THEN true
    ELSE false
  END as should_have_structured_path
FROM user_data ud
LEFT JOIN study_plans sp ON ud.id = sp.user_id AND sp.is_active = true
LEFT JOIN certifications c ON sp.certification_id = c.id;
