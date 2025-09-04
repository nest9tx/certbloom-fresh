-- Step 4 - Workaround: Create study plan with valid certification goal

-- 1. First, let's see what the current certification_goal constraints allow
-- Check existing valid certification goals in the database
SELECT DISTINCT certification_goal 
FROM user_profiles 
WHERE certification_goal IS NOT NULL
ORDER BY certification_goal;

-- 2. Create the study plan (this should work fine)
INSERT INTO study_plans (
  user_id,
  certification_id,
  name,
  daily_study_minutes,
  is_active,
  created_at,
  updated_at
) VALUES (
  '1c04efe6-e1b7-45ef-9d02-079eef06fd9a'::uuid,
  '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc'::uuid,
  'Primary: Math 902',
  30,
  true,
  NOW(),
  NOW()
);

-- 3. Try updating with a shorter value that might be allowed
UPDATE user_profiles 
SET 
  certification_goal = 'Math EC-6',
  updated_at = NOW()
WHERE id = '1c04efe6-e1b7-45ef-9d02-079eef06fd9a'::uuid;

-- 4. Verify everything worked
SELECT 
  sp.id as study_plan_id,
  sp.name as study_plan_name,
  sp.is_active,
  c.name as certification_name,
  up.certification_goal,
  up.certification_goal as current_goal_length
FROM study_plans sp
JOIN certifications c ON sp.certification_id = c.id
JOIN user_profiles up ON sp.user_id = up.id
WHERE up.id = '1c04efe6-e1b7-45ef-9d02-079eef06fd9a'::uuid;
