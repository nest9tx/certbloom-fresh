-- Check user profiles and certification goals
SELECT 
  'USER PROFILES STATUS' as status,
  COUNT(*) as total_users,
  COUNT(certification_goal) as users_with_goals
FROM user_profiles;

-- Show recent user profiles
SELECT 
  'RECENT USER PROFILES' as status,
  id,
  email,
  certification_goal,
  created_at
FROM user_profiles 
ORDER BY created_at DESC 
LIMIT 5;
