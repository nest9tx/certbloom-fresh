-- =====================================================
-- CHECK CURRENT USER DATA 🌸
-- =====================================================
-- Quick check to see what's in the database after the failed signup
-- =====================================================

-- Step 1: Check current auth users
SELECT 'AUTH USERS:' as info;
SELECT id, email, email_confirmed_at, created_at FROM auth.users 
ORDER BY created_at DESC LIMIT 5;

-- Step 2: Check current user profiles  
SELECT 'USER PROFILES:' as info;
SELECT id, email, full_name, certification_goal, created_at FROM user_profiles 
ORDER BY created_at DESC LIMIT 5;

-- Step 3: Check for the specific user from the error (fixed UUID format)
SELECT 'SPECIFIC USER CHECK:' as info;
SELECT 
  au.id as auth_id,
  au.email as auth_email,
  au.email_confirmed_at,
  up.id as profile_id,
  up.email as profile_email,
  up.certification_goal
FROM auth.users au
LEFT JOIN user_profiles up ON au.id = up.id
WHERE au.id = 'c32370a9-836e-48ce-9954-09e399000042'
   OR up.id = 'c32370a9-836e-48ce-9954-09e399000042';

-- =====================================================
-- QUICK DIAGNOSIS COMPLETE 🌸
-- =====================================================
