-- =====================================================
-- USER PROFILES CHECK CONSTRAINT FIX 🌸
-- =====================================================
-- This fixes the foreign key constraint error during signup
-- by updating the certification_goal CHECK constraint to include
-- the actual certification names being used in the system
-- =====================================================

-- Step 1: Remove the old restrictive CHECK constraint
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_certification_goal_check;

-- Step 2: Add new CHECK constraint with all the certification IDs we actually use
ALTER TABLE user_profiles ADD CONSTRAINT user_profiles_certification_goal_check 
CHECK (certification_goal IN (
  -- Original values (for backward compatibility)
  'EC-6 Core Subjects',
  'ELA 4-8',
  'Math 4-8', 
  'Science 4-8',
  'Social Studies 4-8',
  'PPR EC-12',
  'STR Supplemental',
  'ESL Supplemental',
  'Special Education EC-12',
  'Bilingual Education Supplemental',
  'Math 7-12',
  'English 7-12',
  'Science 7-12',
  'Social Studies 7-12',
  'Other',
  
  -- New certification IDs that are actually being used in the system
  'Math EC-6',
  'ELA EC-6',
  'Social Studies EC-6',
  'Science EC-6',
  'Fine Arts EC-6',
  'Core Subjects 4-8',
  'Math Science 4-8',
  'ESL',
  'Bilingual Education',
  'Special Education',
  'Principal',
  'Reading Specialist',
  'School Counselor'
));

-- Step 3: Verify the constraint was updated
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE constraint_name = 'user_profiles_certification_goal_check';

-- Step 4: Test that we can now insert the problematic certification
-- First, let's check if there are any existing users to test with
SELECT 'EXISTING AUTH USERS:' as info;
SELECT id, email, created_at FROM auth.users ORDER BY created_at DESC LIMIT 5;

-- Test with an existing user ID if available, otherwise skip the test
DO $$
DECLARE
    test_user_id UUID;
BEGIN
    -- Get an existing user ID from auth.users
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        -- Test with existing user ID
        INSERT INTO user_profiles (id, email, full_name, certification_goal) 
        VALUES (
            test_user_id, 
            'test@example.com', 
            'Test User', 
            'Math EC-6'
        ) ON CONFLICT (id) DO UPDATE SET
            certification_goal = EXCLUDED.certification_goal;
            
        RAISE NOTICE 'Test successful: Math EC-6 certification can be inserted!';
        
        -- Clean up test data
        DELETE FROM user_profiles WHERE id = test_user_id AND email = 'test@example.com';
    ELSE
        RAISE NOTICE 'No existing users found - skipping test. The constraint fix should work when users sign up.';
    END IF;
END $$;

-- =====================================================
-- CONSTRAINT FIXED! 🌸
-- Signup flow should now work properly
-- =====================================================
