-- =====================================================
-- CHECK ACTUAL AUTH USERS NOW 🌸
-- =====================================================
-- Let's see if the signup actually created a user
-- even though the profile creation failed
-- =====================================================

-- Check if we have any auth users from the recent signup
SELECT 'RECENT AUTH USERS:' as info;
SELECT 
  id, 
  email, 
  email_confirmed_at,
  created_at,
  CASE 
    WHEN email_confirmed_at IS NULL THEN 'UNCONFIRMED'
    ELSE 'CONFIRMED'
  END as confirmation_status
FROM auth.users 
ORDER BY created_at DESC LIMIT 3;

-- Check user profiles
SELECT 'CURRENT USER PROFILES:' as info;
SELECT 
  id, 
  email, 
  certification_goal,
  created_at
FROM user_profiles 
ORDER BY created_at DESC LIMIT 3;

-- =====================================================
-- AUTH STATUS CHECK COMPLETE 🌸
-- =====================================================
