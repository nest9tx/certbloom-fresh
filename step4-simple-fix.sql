-- Step 4 - Simple Fix: Just create the study plan (keep existing certification_goal)

-- Create the study plan - this should work fine
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

-- Verify the fix - this should show your study plan is ready
SELECT 
  sp.id as study_plan_id,
  sp.name as study_plan_name,
  sp.is_active,
  c.name as certification_name,
  up.certification_goal,
  'Study plan created successfully!' as status
FROM study_plans sp
JOIN certifications c ON sp.certification_id = c.id
JOIN user_profiles up ON sp.user_id = up.id
WHERE up.id = '1c04efe6-e1b7-45ef-9d02-079eef06fd9a'::uuid;
