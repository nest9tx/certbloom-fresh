-- Find your actual user ID
SELECT id, email, full_name, certification_goal, created_at 
FROM user_profiles 
ORDER BY created_at DESC 
LIMIT 5;

-- Also check the users table if it exists
SELECT id, email, created_at 
FROM auth.users 
ORDER BY created_at DESC 
LIMIT 5;
