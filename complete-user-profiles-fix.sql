-- 🔧 COMPLETE USER_PROFILES TABLE STRUCTURE FIX
-- This script adds ALL missing columns that the frontend code expects

-- ============================================
-- STEP 1: ADD ALL MISSING COLUMNS
-- ============================================

-- Add certification_goal column (primary fix for current issue)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS certification_goal VARCHAR(10);

-- Add full_name column (used by create-user-profile API)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS full_name TEXT;

-- Add alt_cert_program column (used for alternative certification tracking)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS alt_cert_program TEXT;

-- Add study_style column (used for personalized learning preferences)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS study_style VARCHAR(20);

-- Add anxiety_level column (used for adaptive difficulty)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS anxiety_level INTEGER;

-- ============================================
-- STEP 2: ADD CONSTRAINTS FOR DATA INTEGRITY
-- ============================================

-- Constraint for valid certification codes
ALTER TABLE user_profiles 
DROP CONSTRAINT IF EXISTS user_profiles_certification_goal_check;

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

-- Constraint for valid study styles
ALTER TABLE user_profiles 
DROP CONSTRAINT IF EXISTS user_profiles_study_style_check;

ALTER TABLE user_profiles 
ADD CONSTRAINT user_profiles_study_style_check 
CHECK (study_style IS NULL OR study_style IN ('visual', 'auditory', 'kinesthetic', 'reading'));

-- Constraint for anxiety level (1-10 scale)
ALTER TABLE user_profiles 
DROP CONSTRAINT IF EXISTS user_profiles_anxiety_level_check;

ALTER TABLE user_profiles 
ADD CONSTRAINT user_profiles_anxiety_level_check 
CHECK (anxiety_level IS NULL OR (anxiety_level >= 1 AND anxiety_level <= 10));

-- ============================================
-- STEP 3: CREATE INDEXES FOR PERFORMANCE
-- ============================================

-- Index on certification_goal for filtering users by certification
CREATE INDEX IF NOT EXISTS idx_user_profiles_certification_goal ON user_profiles(certification_goal);

-- Index on study_style for personalized content queries
CREATE INDEX IF NOT EXISTS idx_user_profiles_study_style ON user_profiles(study_style);

-- ============================================
-- STEP 4: UPDATE TRIGGER FUNCTION
-- ============================================

-- Update the trigger function to handle all columns properly
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (
    id, 
    email, 
    subscription_status, 
    certification_goal,
    full_name,
    alt_cert_program,
    study_style,
    anxiety_level,
    created_at, 
    updated_at
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.email, NEW.phone, 'user_' || NEW.id::text),
    'free',
    NULL, -- will be set when user chooses certification goal
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    NULL, -- will be set during onboarding if applicable
    NULL, -- will be set during assessment
    NULL, -- will be set during assessment
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, user_profiles.full_name),
    updated_at = NOW();
  
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

-- Show the complete table structure
SELECT 'User profiles table structure:' as check_title;
SELECT 
  column_name, 
  data_type, 
  is_nullable, 
  column_default,
  character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
ORDER BY ordinal_position;

-- Show all constraints
SELECT 'Table constraints:' as check_constraints;
SELECT 
  tc.constraint_name, 
  tc.constraint_type,
  cc.check_clause
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.check_constraints cc ON tc.constraint_name = cc.constraint_name
WHERE tc.table_name = 'user_profiles';

-- Verify Math 902 is available for selection
SELECT 'Available certifications:' as check_certs;
SELECT test_code, name 
FROM certifications 
WHERE test_code IN ('902', '901', '903', '904', '905', '391')
ORDER BY test_code;

SELECT '✅ Complete user_profiles structure ready! All frontend expectations met.' as final_status;
