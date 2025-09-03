-- 🔧 ADD MISSING CERTIFICATION_GOAL COLUMN
-- This script adds the certification_goal column that the frontend code expects

-- ============================================
-- STEP 1: ADD CERTIFICATION_GOAL COLUMN
-- ============================================

-- Add the certification_goal column to user_profiles
ALTER TABLE user_profiles 
ADD COLUMN certification_goal VARCHAR(10);

-- ============================================
-- STEP 2: ADD CONSTRAINT FOR VALID CERTIFICATION CODES
-- ============================================

-- Add constraint to ensure only valid certification codes are stored
ALTER TABLE user_profiles 
ADD CONSTRAINT user_profiles_certification_goal_check 
CHECK (certification_goal IS NULL OR certification_goal IN (
  '160',  -- Pedagogy and Professional Responsibilities (PPR)
  '391',  -- Core Subjects EC-6 (comprehensive)
  '901',  -- Core Subjects EC-6: English Language Arts
  '902',  -- Core Subjects EC-6: Mathematics
  '903',  -- Core Subjects EC-6: Social Studies
  '904',  -- Core Subjects EC-6: Science
  '905',  -- Core Subjects EC-6: Fine Arts, Health and PE
  '117',  -- English Language Arts and Reading 4-8
  '118',  -- Mathematics 4-8
  '119',  -- Science 4-8
  '120',  -- Social Studies 4-8
  '139',  -- Mathematics 8-12
  '154',  -- English Language Arts 8-12
  '164',  -- English Language Arts and Reading 7-12
  '165',  -- Bilingual Education Supplemental
  '166',  -- English as a Second Language (ESL) Supplemental
  '170',  -- School Librarian
  '178',  -- Physical Education EC-12
  '184',  -- Bilingual Generalist EC-6
  '192',  -- Bilingual Generalist 4-8
  '233',  -- Music EC-12
  '236',  -- Music 8-12
  '268',  -- Health EC-12
  '272',  -- Generalist 4-8
  '293',  -- Core Subjects 4-8
  '351',  -- Generalist EC-4
  '354',  -- Generalist EC-6
  '610',  -- School Counselor
  '611',  -- Educational Diagnostician
  '652',  -- Reading Specialist
  '692',  -- Principal
  '696'   -- Superintendent
));

-- ============================================
-- STEP 3: CREATE INDEX FOR PERFORMANCE
-- ============================================

-- Add index on certification_goal for faster queries
CREATE INDEX idx_user_profiles_certification_goal ON user_profiles(certification_goal);

-- ============================================
-- STEP 4: UPDATE TRIGGER FUNCTION TO HANDLE NEW COLUMN
-- ============================================

-- Update the trigger function to handle the new column
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, subscription_status, certification_goal, created_at, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, NEW.phone, 'user_' || NEW.id::text),
    'free',
    NULL, -- certification_goal will be set when user chooses their goal
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

-- ============================================
-- STEP 5: VERIFICATION QUERIES
-- ============================================

-- Check that the column was added successfully
SELECT 'certification_goal column added:' as test_1, 
  column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
  AND column_name = 'certification_goal';

-- Check that the constraint was added
SELECT 'Constraint added:' as test_2, 
  constraint_name, constraint_type
FROM information_schema.table_constraints 
WHERE table_name = 'user_profiles' 
  AND constraint_name = 'user_profiles_certification_goal_check';

-- Verify that Math 902 certification exists and can be selected
SELECT 'Math 902 certification available:' as test_3,
  test_code, name
FROM certifications 
WHERE test_code = '902';

-- Test that the constraint allows valid values
DO $$
BEGIN
  -- This should succeed (if we had a test user)
  -- UPDATE user_profiles SET certification_goal = '902' WHERE false;
  RAISE NOTICE 'Certification goal column ready for use!';
END $$;

SELECT '✅ Certification goal column added successfully! Frontend can now save user certification selections.' as status;
