-- Step 4B: Just update the user profile (separate operation)
UPDATE user_profiles 
SET certification_goal = 'Math902'
WHERE id = '1c04efe6-e1b7-45ef-9d02-079eef06fd9a'::uuid;
