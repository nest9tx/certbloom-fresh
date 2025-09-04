-- Step 4A: Just create the study plan first (minimal data)
INSERT INTO study_plans (
  user_id,
  certification_id,
  name
) VALUES (
  '1c04efe6-e1b7-45ef-9d02-079eef06fd9a'::uuid,
  '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc'::uuid,
  'Math902'
);
