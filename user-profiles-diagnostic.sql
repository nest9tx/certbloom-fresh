-- =====================================================
-- USER PROFILES TABLE INVESTIGATION 🌸
-- =====================================================
-- Let's see exactly what's in the user_profiles table
-- and understand the duplicate key issue
-- =====================================================

-- Step 1: Check the current structure of user_profiles
SELECT 'USER_PROFILES TABLE STRUCTURE:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'user_profiles' 
ORDER BY ordinal_position;

-- Step 2: Check what constraints exist
SELECT 'USER_PROFILES CONSTRAINTS:' as info;
SELECT tc.constraint_name, tc.constraint_type, kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'user_profiles' AND tc.table_schema = 'public'
ORDER BY tc.constraint_type, tc.constraint_name;

-- Step 3: Check current data in the table
SELECT 'CURRENT USER_PROFILES DATA:' as info;
SELECT 
  id, 
  email, 
  full_name, 
  certification_goal,
  created_at,
  updated_at
FROM user_profiles 
ORDER BY created_at DESC;

-- Step 4: Check if there are any users in auth.users
SELECT 'AUTH USERS COUNT:' as info;
SELECT COUNT(*) as total_auth_users FROM auth.users;

-- Step 5: Check for any orphaned profiles (profiles without corresponding auth users)
SELECT 'POTENTIAL ORPHANED PROFILES:' as info;
SELECT up.id, up.email, up.certification_goal
FROM user_profiles up
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users au WHERE au.id = up.id
);

-- =====================================================
-- DIAGNOSTIC COMPLETE 🌸
-- This will show us exactly what's causing the duplicate key error
-- =====================================================
