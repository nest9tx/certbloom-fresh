-- Add support for primary study plans and guarantee tracking
-- Run this in your Supabase SQL Editor

-- Add is_primary column to study_plans table
ALTER TABLE study_plans 
ADD COLUMN IF NOT EXISTS is_primary BOOLEAN DEFAULT FALSE;

-- Add guarantee tracking columns
ALTER TABLE study_plans 
ADD COLUMN IF NOT EXISTS guarantee_eligible BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS guarantee_start_date DATE,
ADD COLUMN IF NOT EXISTS first_attempt_date DATE,
ADD COLUMN IF NOT EXISTS guarantee_used BOOLEAN DEFAULT FALSE;

-- Create index for primary study plans
CREATE INDEX IF NOT EXISTS idx_study_plans_primary ON study_plans(user_id, is_primary) WHERE is_primary = true;

-- Ensure only one primary study plan per user
CREATE UNIQUE INDEX IF NOT EXISTS idx_study_plans_one_primary_per_user 
ON study_plans(user_id) WHERE is_primary = true;

-- Update existing study plans based on user profiles
DO $$
DECLARE
    plan_record RECORD;
BEGIN
    -- Mark the first active study plan as primary for existing users
    FOR plan_record IN 
        SELECT DISTINCT ON (user_id) id, user_id 
        FROM study_plans 
        WHERE is_active = true 
        ORDER BY user_id, created_at ASC
    LOOP
        UPDATE study_plans 
        SET is_primary = true, 
            guarantee_eligible = true,
            guarantee_start_date = CURRENT_DATE
        WHERE id = plan_record.id;
    END LOOP;
    
    RAISE NOTICE 'Updated existing study plans with primary status';
END $$;

SELECT 'Study plan enhancements complete - ready for focused learning paths! 🌱' as status;
