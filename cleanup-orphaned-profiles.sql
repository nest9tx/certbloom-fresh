-- =====================================================
-- CLEANUP ORPHANED PROFILES 🌸
-- =====================================================
-- This script will clean up any user profiles that don't
-- have corresponding users in the auth.users table
-- Run this ONLY if the diagnostic shows orphaned profiles
-- =====================================================

-- Step 1: Show what we're about to clean up
SELECT 'PROFILES TO BE CLEANED UP:' as info;
SELECT up.id, up.email, up.certification_goal, up.created_at
FROM user_profiles up
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users au WHERE au.id = up.id
);

-- Step 2: Clean up orphaned profiles (UNCOMMENT IF NEEDED)
-- DELETE FROM user_profiles 
-- WHERE NOT EXISTS (
--   SELECT 1 FROM auth.users au WHERE au.id = user_profiles.id
-- );

-- Step 3: Verify cleanup
SELECT 'REMAINING PROFILES AFTER CLEANUP:' as info;
SELECT COUNT(*) as total_profiles FROM user_profiles;

-- =====================================================
-- CLEANUP COMPLETE 🌸
-- Now try the signup flow again
-- =====================================================
