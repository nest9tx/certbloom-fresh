-- 🔧 ALTERNATIVE USER PROFILE FIX
-- This handles cases where email might be null or missing

-- First, let's make email nullable in case of edge cases
ALTER TABLE user_profiles ALTER COLUMN email DROP NOT NULL;

-- Updated trigger function that handles null emails
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, subscription_status, created_at, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, NEW.phone, 'user_' || NEW.id::text),
    'free',
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING; -- Prevent duplicate key errors
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the user creation
    RAISE LOG 'Error creating user profile for %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Test query to see if there are any existing auth users without profiles
SELECT 'Existing auth users without profiles:' as check_orphaned,
  COUNT(*) as orphaned_users
FROM auth.users au
LEFT JOIN user_profiles up ON au.id = up.id
WHERE up.id IS NULL;

SELECT '✅ Alternative user signup fix applied with error handling!' as status;
