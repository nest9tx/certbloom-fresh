-- =====================================================
-- CERTIFICATION GOAL SCHEMA COMPLETE FIX 🌸
-- =====================================================
-- This sacred healing script addresses all the schema 
-- and data misalignments causing certification goal 
-- save failures in your beautiful CertBloom system
-- =====================================================

-- Step 1: Fix study_plans table schema
-- =====================================================

-- Check current study_plans structure
SELECT 'CURRENT STUDY_PLANS STRUCTURE:' as diagnostic;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'study_plans' 
ORDER BY ordinal_position;

-- Create/fix study_plans table with correct schema
CREATE TABLE IF NOT EXISTS study_plans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  certification_id UUID REFERENCES certifications(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT 'Study Plan',
  target_exam_date DATE,
  daily_study_minutes INTEGER DEFAULT 30,
  current_concept_id UUID REFERENCES concepts(id),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(user_id, certification_id)
);

-- Safe column additions/fixes
DO $$ 
BEGIN
  -- Add daily_study_minutes if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'study_plans' 
    AND column_name = 'daily_study_minutes'
  ) THEN
    ALTER TABLE study_plans ADD COLUMN daily_study_minutes INTEGER DEFAULT 30;
  END IF;
  
  -- Add name column if missing  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'study_plans' 
    AND column_name = 'name'
  ) THEN
    ALTER TABLE study_plans ADD COLUMN name TEXT NOT NULL DEFAULT 'Study Plan';
  END IF;
  
  -- Remove problematic old columns
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'study_plans' 
    AND column_name = 'daily_goal_minutes'
  ) THEN
    -- Migrate data from old column
    UPDATE study_plans 
    SET daily_study_minutes = daily_goal_minutes 
    WHERE daily_goal_minutes IS NOT NULL AND daily_study_minutes IS NULL;
    
    -- Drop old column
    ALTER TABLE study_plans DROP COLUMN daily_goal_minutes;
  END IF;
  
  -- Remove is_primary column if it exists (not in current schema)
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'study_plans' 
    AND column_name = 'is_primary'
  ) THEN
    ALTER TABLE study_plans DROP COLUMN is_primary;
  END IF;
END $$;

-- Step 2: Ensure certifications table has correct Math EC-6 data
-- =====================================================

-- First check the actual structure of certifications table
SELECT 'CURRENT CERTIFICATIONS TABLE STRUCTURE:' as diagnostic;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'certifications' 
ORDER BY ordinal_position;

-- Check if certifications table exists and create if needed
-- Note: We'll match the existing structure, not add columns that don't exist
CREATE TABLE IF NOT EXISTS certifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  test_code TEXT UNIQUE,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Insert Math EC-6 certification with correct test code
-- Use DO block to handle conflicts safely
DO $$
BEGIN
    -- Insert Math EC-6 if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM certifications WHERE test_code = '902') THEN
        INSERT INTO certifications (name, test_code, description) 
        VALUES ('TExES Core Subjects EC-6: Mathematics (902)', '902', 'Early Childhood through 6th Grade Mathematics');
    ELSE
        -- Update existing record
        UPDATE certifications 
        SET name = 'TExES Core Subjects EC-6: Mathematics (902)',
            description = 'Early Childhood through 6th Grade Mathematics'
        WHERE test_code = '902';
    END IF;
END $$;

-- Insert other EC-6 certifications
DO $$
BEGIN
    -- ELA 901
    IF NOT EXISTS (SELECT 1 FROM certifications WHERE test_code = '901') THEN
        INSERT INTO certifications (name, test_code, description) 
        VALUES ('TExES Core Subjects EC-6: English Language Arts (901)', '901', 'Early Childhood through 6th Grade English Language Arts');
    END IF;
    
    -- Social Studies 903
    IF NOT EXISTS (SELECT 1 FROM certifications WHERE test_code = '903') THEN
        INSERT INTO certifications (name, test_code, description) 
        VALUES ('TExES Core Subjects EC-6: Social Studies (903)', '903', 'Early Childhood through 6th Grade Social Studies');
    END IF;
    
    -- Science 904
    IF NOT EXISTS (SELECT 1 FROM certifications WHERE test_code = '904') THEN
        INSERT INTO certifications (name, test_code, description) 
        VALUES ('TExES Core Subjects EC-6: Science (904)', '904', 'Early Childhood through 6th Grade Science');
    END IF;
    
    -- All Core Subjects 391
    IF NOT EXISTS (SELECT 1 FROM certifications WHERE test_code = '391') THEN
        INSERT INTO certifications (name, test_code, description) 
        VALUES ('TExES Core Subjects EC-6 (391)', '391', 'Early Childhood through 6th Grade - All core subjects');
    END IF;
END $$;

-- Step 3: Clean up any orphaned data
-- =====================================================

-- Remove any study plans that reference non-existent certifications
DELETE FROM study_plans 
WHERE certification_id NOT IN (SELECT id FROM certifications);

-- Step 4: Verification and Diagnostics
-- =====================================================

SELECT 'FIXED STUDY_PLANS STRUCTURE:' as diagnostic;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'study_plans' 
ORDER BY ordinal_position;

SELECT 'AVAILABLE CERTIFICATIONS:' as diagnostic;
SELECT id, name, test_code, description 
FROM certifications 
WHERE test_code IN ('901', '902', '903', '904', '391')
ORDER BY test_code;

SELECT 'EXISTING STUDY PLANS:' as diagnostic;
SELECT 
  sp.id, 
  sp.user_id, 
  sp.name,
  sp.daily_study_minutes,
  sp.is_active,
  c.name as certification_name,
  c.test_code,
  sp.created_at
FROM study_plans sp
JOIN certifications c ON sp.certification_id = c.id
ORDER BY sp.created_at DESC
LIMIT 10;

-- =====================================================
-- SACRED HEALING COMPLETE 🌸
-- Your certification goal system is now aligned
-- The API can successfully save user certification 
-- choices and create proper study plans
-- =====================================================
