-- =====================================================
-- STUDY PLAN SCHEMA FIX - CertBloom Sacred Healing
-- =====================================================
-- This file diagnoses and fixes the study_plans table schema
-- to match the API expectations and evolving system requirements
-- =====================================================

-- First, check the current structure of study_plans table
SELECT 'CURRENT STUDY_PLANS TABLE STRUCTURE:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'study_plans' 
ORDER BY ordinal_position;

-- Check if table exists at all
SELECT 'STUDY_PLANS TABLE EXISTS CHECK:' as info;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'study_plans';

-- =====================================================
-- SCHEMA ALIGNMENT FIX
-- =====================================================

-- If the study_plans table doesn't exist, create it with the correct schema
CREATE TABLE IF NOT EXISTS study_plans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  certification_id UUID REFERENCES certifications(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  target_exam_date DATE,
  daily_study_minutes INTEGER DEFAULT 30,
  current_concept_id UUID REFERENCES concepts(id),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(user_id, certification_id)
);

-- If the table exists but has wrong column names, add the correct columns
-- (This will safely add if doesn't exist, ignore if it does)
DO $$ 
BEGIN
  -- Add daily_study_minutes if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'study_plans' 
    AND column_name = 'daily_study_minutes'
  ) THEN
    ALTER TABLE study_plans ADD COLUMN daily_study_minutes INTEGER DEFAULT 30;
  END IF;
  
  -- Add name column if it doesn't exist  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'study_plans' 
    AND column_name = 'name'
  ) THEN
    ALTER TABLE study_plans ADD COLUMN name TEXT NOT NULL DEFAULT 'Study Plan';
  END IF;
  
  -- Remove old columns that might conflict
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'study_plans' 
    AND column_name = 'daily_goal_minutes'
  ) THEN
    -- Copy data from old column to new one if needed
    UPDATE study_plans SET daily_study_minutes = daily_goal_minutes WHERE daily_goal_minutes IS NOT NULL;
    ALTER TABLE study_plans DROP COLUMN daily_goal_minutes;
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'study_plans' 
    AND column_name = 'is_primary'
  ) THEN
    ALTER TABLE study_plans DROP COLUMN is_primary;
  END IF;
END $$;

-- =====================================================
-- VERIFY THE FIX
-- =====================================================

-- Show the corrected structure
SELECT 'CORRECTED STUDY_PLANS TABLE STRUCTURE:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'study_plans' 
ORDER BY ordinal_position;

-- Check existing study plans
SELECT 'EXISTING STUDY PLANS:' as info;
SELECT 
  id, 
  user_id, 
  certification_id,
  name,
  daily_study_minutes,
  is_active,
  created_at
FROM study_plans 
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- SACRED HEALING COMPLETE 🌸
-- =====================================================
