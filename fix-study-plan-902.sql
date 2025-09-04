-- Fix missing study plan for Math 902 certification
-- Run this in Supabase SQL Editor after running the debug script above

-- First, get your user ID and check current state
WITH user_info AS (
  SELECT 
    id as user_id,
    email,
    certification_goal
  FROM user_profiles 
  WHERE email LIKE '%@%' -- Replace with your actual email
  ORDER BY created_at DESC 
  LIMIT 1
),
cert_info AS (
  SELECT 
    id as certification_id,
    name,
    test_code
  FROM certifications 
  WHERE test_code = '902'
  LIMIT 1
)
-- Insert or update study plan
INSERT INTO study_plans (
  user_id,
  certification_id,
  name,
  daily_study_minutes,
  is_active,
  created_at,
  updated_at
)
SELECT 
  ui.user_id,
  ci.certification_id,
  'Primary: ' || COALESCE(ui.certification_goal, 'TExES Core Subjects EC-6: Mathematics (902)'),
  30,
  true,
  NOW(),
  NOW()
FROM user_info ui, cert_info ci
WHERE NOT EXISTS (
  -- Only insert if no active study plan exists
  SELECT 1 FROM study_plans sp 
  WHERE sp.user_id = ui.user_id 
  AND sp.certification_id = ci.certification_id 
  AND sp.is_active = true
);

-- Deactivate any other active study plans for this user
UPDATE study_plans 
SET is_active = false, updated_at = NOW()
WHERE user_id IN (SELECT id FROM user_profiles WHERE email LIKE '%@%') -- Replace with your email
AND certification_id != (SELECT id FROM certifications WHERE test_code = '902' LIMIT 1)
AND is_active = true;

-- Verify the fix
SELECT 
  sp.id,
  sp.name,
  sp.is_active,
  sp.created_at,
  c.name as certification_name,
  c.test_code,
  up.email
FROM study_plans sp
JOIN certifications c ON sp.certification_id = c.id
JOIN user_profiles up ON sp.user_id = up.id
WHERE up.email LIKE '%@%' -- Replace with your email
AND sp.is_active = true;
