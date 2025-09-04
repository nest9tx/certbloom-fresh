-- 🏗️ PROPER 902 QUESTION BANK STRUCTURE
-- Adding all necessary columns to content_items for comprehensive question tracking

-- Add all the missing columns we need for proper question management
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS correct_answer TEXT;
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS explanation TEXT;
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS difficulty_level INTEGER DEFAULT 1;
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS estimated_time_minutes INTEGER DEFAULT 2;
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS topic_tags TEXT[];
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS cognitive_level TEXT CHECK (cognitive_level IN ('Knowledge', 'Comprehension', 'Application', 'Analysis', 'Synthesis', 'Evaluation'));

-- Wellness and teaching-focused columns (from our earlier enhancement)
-- These should already exist from the enhance-902-with-wellness.sql but let's ensure they're there
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS detailed_explanation TEXT;
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS real_world_application TEXT;
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS confidence_building_tip TEXT;
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS common_misconceptions TEXT[];
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS memory_aids TEXT[];
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS anxiety_note TEXT;

-- Analytics and performance tracking columns
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS learning_objective TEXT;
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS prerequisite_concepts TEXT[];
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS related_standards TEXT[];
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS question_source TEXT DEFAULT 'CertBloom Original';
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS last_updated TIMESTAMPTZ DEFAULT NOW();

-- Question performance and adaptive learning support
DROP TABLE IF EXISTS question_analytics CASCADE;
CREATE TABLE question_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_item_id UUID NOT NULL REFERENCES content_items(id) ON DELETE CASCADE,
    total_attempts INTEGER DEFAULT 0,
    correct_attempts INTEGER DEFAULT 0,
    average_time_seconds DECIMAL(8,2),
    difficulty_rating DECIMAL(3,2), -- Calculated difficulty based on performance
    discrimination_index DECIMAL(3,2), -- How well question differentiates strong/weak students
    last_performance_update TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(content_item_id)
);

-- User question performance tracking
DROP TABLE IF EXISTS user_question_attempts CASCADE;
CREATE TABLE user_question_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content_item_id UUID NOT NULL REFERENCES content_items(id) ON DELETE CASCADE,
    selected_answer TEXT,
    is_correct BOOLEAN,
    time_spent_seconds INTEGER,
    confidence_level INTEGER CHECK (confidence_level BETWEEN 1 AND 5),
    hint_used BOOLEAN DEFAULT false,
    attempt_number INTEGER DEFAULT 1,
    session_id UUID, -- For grouping questions in study sessions
    attempted_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_content_items_difficulty ON content_items(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_content_items_cognitive_level ON content_items(cognitive_level);
CREATE INDEX IF NOT EXISTS idx_content_items_topic_tags ON content_items USING GIN(topic_tags);
CREATE INDEX IF NOT EXISTS idx_question_analytics_content_item ON question_analytics(content_item_id);
CREATE INDEX IF NOT EXISTS idx_user_attempts_user_content ON user_question_attempts(user_id, content_item_id);
CREATE INDEX IF NOT EXISTS idx_user_attempts_session ON user_question_attempts(session_id);

-- Enable RLS on new tables
ALTER TABLE question_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_question_attempts ENABLE ROW LEVEL SECURITY;

-- RLS policies for question analytics (admin readable, system updatable)
CREATE POLICY "Admins can view question analytics"
    ON question_analytics FOR SELECT
    USING (auth.jwt() ->> 'role' = 'admin' OR auth.jwt() ->> 'role' = 'service_role');

-- RLS policies for user attempts (users see their own)
CREATE POLICY "Users can view their own question attempts"
    ON user_question_attempts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own question attempts"
    ON user_question_attempts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Function to update question analytics automatically
CREATE OR REPLACE FUNCTION update_question_analytics()
RETURNS TRIGGER AS $$
BEGIN
    -- Update or insert question analytics
    INSERT INTO question_analytics (content_item_id, total_attempts, correct_attempts, last_performance_update)
    VALUES (NEW.content_item_id, 1, CASE WHEN NEW.is_correct THEN 1 ELSE 0 END, NOW())
    ON CONFLICT (content_item_id) DO UPDATE SET
        total_attempts = question_analytics.total_attempts + 1,
        correct_attempts = question_analytics.correct_attempts + CASE WHEN NEW.is_correct THEN 1 ELSE 0 END,
        last_performance_update = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update analytics when users attempt questions
CREATE TRIGGER trigger_update_question_analytics
    AFTER INSERT ON user_question_attempts
    FOR EACH ROW
    EXECUTE FUNCTION update_question_analytics();

-- Add trigger for content_items last_updated
CREATE OR REPLACE FUNCTION update_content_items_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_content_items_timestamp
    BEFORE UPDATE ON content_items
    FOR EACH ROW
    EXECUTE FUNCTION update_content_items_timestamp();

-- Verify the enhanced structure
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'content_items' 
AND column_name IN (
    'correct_answer', 'detailed_explanation', 'confidence_building_tip', 
    'cognitive_level', 'topic_tags', 'learning_objective'
)
ORDER BY column_name;

SELECT '✅ Comprehensive question bank structure created for 902!' as status;
SELECT '📊 Ready for analytics, adaptive learning, and wellness features!' as next_step;
