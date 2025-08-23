-- Database Trigger Solution for Automatic User Profile Creation
-- This creates a trigger that automatically creates a user_profile whenever a user signs up
-- Run this in your Supabase SQL editor

-- First, create a function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_profiles (
    id,
    email,
    full_name,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$;

-- Drop the trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create the trigger that fires when a new user is inserted into auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Test the trigger by checking if it was created successfully
SELECT 
  trigger_name, 
  event_manipulation, 
  event_object_table, 
  action_timing
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- Also, let's make sure the function has the right permissions
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO anon, authenticated;

-- Verify our setup
SELECT 
  'Trigger created successfully' as status,
  'User profiles will be created automatically on signup' as message;
