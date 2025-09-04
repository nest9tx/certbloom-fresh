-- Check the constraint on certification_goal
SELECT 
  conname as constraint_name,
  pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'user_profiles'::regclass 
AND conname LIKE '%certification_goal%';
