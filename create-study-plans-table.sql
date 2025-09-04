-- 🏗️ CREATE MISSING STUDY_PLANS TABLE
-- This table is required for the learning path system to work

-- Create study_plans table
CREATE TABLE IF NOT EXISTS study_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    certification_id UUID NOT NULL REFERENCES certifications(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    daily_study_minutes INTEGER DEFAULT 30,
    target_exam_date DATE,
    is_active BOOLEAN DEFAULT true,
    progress_percentage DECIMAL(5,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Ensure one active study plan per user per certification
    UNIQUE(user_id, certification_id, is_active) DEFERRABLE INITIALLY DEFERRED
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_study_plans_user_id ON study_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_study_plans_certification_id ON study_plans(certification_id);
CREATE INDEX IF NOT EXISTS idx_study_plans_active ON study_plans(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_study_plans_user_active ON study_plans(user_id, is_active) WHERE is_active = true;

-- Enable RLS
ALTER TABLE study_plans ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own study plans"
    ON study_plans FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own study plans"
    ON study_plans FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own study plans"
    ON study_plans FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own study plans"
    ON study_plans FOR DELETE
    USING (auth.uid() = user_id);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_study_plans_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_study_plans_updated_at
    BEFORE UPDATE ON study_plans
    FOR EACH ROW
    EXECUTE FUNCTION update_study_plans_updated_at();

-- Verify table creation
SELECT 'study_plans table created successfully!' as status;

-- Show table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'study_plans' 
ORDER BY ordinal_position;
