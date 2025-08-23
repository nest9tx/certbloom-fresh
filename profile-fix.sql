-- Profile Creation Fix for Existing Users
-- Run this in Supabase SQL editor to fix any existing users without profiles

-- Check for auth users without profiles
SELECT 
  au.id,
  au.email,
  au.created_at as user_created_at,
  up.id as profile_id
FROM auth.users au
LEFT JOIN public.user_profiles up ON au.id = up.id
WHERE up.id IS NULL;

-- Create profiles for existing users who don't have them
INSERT INTO public.user_profiles (
  id, 
  email, 
  full_name, 
  created_at, 
  updated_at
)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'full_name', ''),
  NOW(),
  NOW()
FROM auth.users au
LEFT JOIN public.user_profiles up ON au.id = up.id
WHERE up.id IS NULL
AND au.email_confirmed_at IS NOT NULL;

-- Verify the fix
SELECT 
  COUNT(*) as total_users,
  COUNT(up.id) as users_with_profiles,
  COUNT(*) - COUNT(up.id) as users_without_profiles
FROM auth.users au
LEFT JOIN public.user_profiles up ON au.id = up.id
WHERE au.email_confirmed_at IS NOT NULL;
