-- Emergency fix for certification goal constraint
-- This needs to be run in Supabase SQL editor

-- First, let's see current constraint
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE constraint_name LIKE '%certification_goal%';

-- Drop the restrictive constraint
ALTER TABLE public.user_profiles DROP CONSTRAINT IF EXISTS user_profiles_certification_goal_check;

-- Add a much more permissive constraint that allows any reasonable certification name
ALTER TABLE public.user_profiles ADD CONSTRAINT user_profiles_certification_goal_check 
CHECK (
    certification_goal IS NULL 
    OR length(certification_goal) > 0
);

-- Test the fix by attempting an update
-- (Replace 'your-user-id' with an actual user ID for testing)
-- UPDATE user_profiles SET certification_goal = 'TExES Core Subjects EC-6: Mathematics (902)' WHERE id = 'your-user-id';

-- Verify the new constraint
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE constraint_name LIKE '%certification_goal%';
