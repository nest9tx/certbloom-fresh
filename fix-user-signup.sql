-- 🔧 USER PROFILE SIGNUP FIX
-- This script fixes user signup issues by adding proper triggers and policies

-- ============================================
-- STEP 1: CREATE USER PROFILE TRIGGER FUNCTION
-- ============================================

-- Function to automatically create user_profile when auth.users record is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, subscription_status, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    'free',
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- STEP 2: CREATE TRIGGER ON AUTH.USERS
-- ============================================

-- Trigger to automatically create user_profile when user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- STEP 3: ENABLE ROW LEVEL SECURITY
-- ============================================

-- Enable RLS on user_profiles table
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own profile
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);

-- Allow the trigger function to insert new profiles
CREATE POLICY "Enable insert for authenticated users during signup" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================
-- STEP 4: ENABLE RLS ON OTHER TABLES
-- ============================================

-- Enable RLS on practice_sessions
ALTER TABLE practice_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own practice sessions" ON practice_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own practice sessions" ON practice_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own practice sessions" ON practice_sessions
  FOR UPDATE USING (auth.uid() = user_id);

-- Enable RLS on concept_progress
ALTER TABLE concept_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own concept progress" ON concept_progress
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own concept progress" ON concept_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own concept progress" ON concept_progress
  FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- STEP 5: ALLOW PUBLIC READ ACCESS TO CONTENT
-- ============================================

-- Allow everyone to read certifications, domains, concepts, content_items, and answer_choices
ALTER TABLE certifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access to certifications" ON certifications
  FOR SELECT USING (true);

ALTER TABLE domains ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access to domains" ON domains
  FOR SELECT USING (true);

ALTER TABLE concepts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access to concepts" ON concepts
  FOR SELECT USING (true);

ALTER TABLE content_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access to content_items" ON content_items
  FOR SELECT USING (true);

ALTER TABLE answer_choices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access to answer_choices" ON answer_choices
  FOR SELECT USING (true);

-- ============================================
-- STEP 6: TEST THE SETUP
-- ============================================

-- Verify the trigger function exists
SELECT 'Trigger function created:' as test_1, EXISTS(
  SELECT 1 FROM pg_proc WHERE proname = 'handle_new_user'
) as function_exists;

-- Verify the trigger exists
SELECT 'Trigger created:' as test_2, EXISTS(
  SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created'
) as trigger_exists;

-- Verify RLS is enabled
SELECT 'RLS enabled on user_profiles:' as test_3, relrowsecurity 
FROM pg_class WHERE relname = 'user_profiles';

SELECT '✅ User signup fix applied! New users will automatically get profiles created.' as status;
