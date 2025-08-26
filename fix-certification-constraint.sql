-- Fix certification goal constraint to allow proper certification names
-- This fixes the signup issue where certification goals aren't saving

-- Drop the existing constraint
ALTER TABLE public.user_profiles DROP CONSTRAINT IF EXISTS user_profiles_certification_goal_check;

-- Add updated constraint with proper certification names
ALTER TABLE public.user_profiles ADD CONSTRAINT user_profiles_certification_goal_check 
CHECK (certification_goal IN (
    'EC-6 Core Subjects',
    'TExES Core Subjects EC-6 (391)',
    'TExES Core Subjects EC-6: English Language Arts (901)',
    'TExES Core Subjects EC-6: Mathematics (902)',
    'TExES Core Subjects EC-6: Social Studies (903)',
    'TExES Core Subjects EC-6: Science (904)',
    'ELA 4-8',
    'Math 4-8', 
    'Science 4-8',
    'Social Studies 4-8',
    'Math EC-6',
    'Elementary Mathematics',
    'PPR EC-12',
    'STR Supplemental',
    'ESL Supplemental',
    'Special Education EC-12',
    'Bilingual Education Supplemental',
    'Math 7-12',
    'English 7-12',
    'Science 7-12',
    'Social Studies 7-12',
    'Other'
) OR certification_goal IS NULL);

-- Verify the constraint is working
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE constraint_name = 'user_profiles_certification_goal_check';
