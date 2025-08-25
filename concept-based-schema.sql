-- 🌸 CERTBLOOM CONCEPT-BASED LEARNING SCHEMA
-- Transform from random questions to structured learning like 240tutoring
-- Run this in Supabase SQL Editor to create the new architecture

-- ============================================
-- 1. CERTIFICATION & EXAM STRUCTURE
-- ============================================

-- Texas teacher certifications (EC-12 Math, Science, etc.)
CREATE TABLE IF NOT EXISTS certifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL, -- "Elementary Mathematics (EC-6)"
    code TEXT NOT NULL UNIQUE, -- "160"
    description TEXT,
    total_concepts INTEGER DEFAULT 0, -- Auto-calculated
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Major domains within each certification
CREATE TABLE IF NOT EXISTS domains (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    certification_id UUID NOT NULL REFERENCES certifications(id) ON DELETE CASCADE,
    name TEXT NOT NULL, -- "Number Concepts & Operations"
    code TEXT NOT NULL, -- "001"
    description TEXT,
    weight_percentage DECIMAL(5,2) DEFAULT 0, -- 25.00 (25% of exam)
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT unique_domain_code_per_cert UNIQUE(certification_id, code)
);

-- Specific learning concepts (the heart of structured learning)
CREATE TABLE IF NOT EXISTS concepts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    name TEXT NOT NULL, -- "Adding & Subtracting Fractions"
    description TEXT,
    learning_objectives TEXT[], -- ["Identify common denominators", "Apply addition rules"]
    difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level BETWEEN 1 AND 5),
    estimated_study_minutes INTEGER DEFAULT 30,
    order_index INTEGER DEFAULT 0,
    prerequisites UUID[], -- Array of concept IDs that should be mastered first
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 2. MULTI-MODAL CONTENT SYSTEM
-- ============================================

-- Different types of learning content
CREATE TYPE content_type AS ENUM (
    'video_lesson',
    'text_explanation', 
    'interactive_example',
    'practice_question',
    'real_world_scenario',
    'teaching_strategy',
    'common_misconception'
);

-- Learning materials for each concept
CREATE TABLE IF NOT EXISTS content_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    concept_id UUID NOT NULL REFERENCES concepts(id) ON DELETE CASCADE,
    type content_type NOT NULL,
    title TEXT NOT NULL,
    content JSONB NOT NULL, -- Flexible content structure based on type
    order_index INTEGER DEFAULT 0,
    estimated_minutes INTEGER DEFAULT 5,
    is_required BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 3. ENHANCED QUESTIONS SYSTEM
-- ============================================

-- Enhanced questions table (extends existing)
ALTER TABLE questions ADD COLUMN IF NOT EXISTS concept_id UUID REFERENCES concepts(id);
ALTER TABLE questions ADD COLUMN IF NOT EXISTS difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level BETWEEN 1 AND 5);
ALTER TABLE questions ADD COLUMN IF NOT EXISTS question_type TEXT DEFAULT 'multiple_choice';
ALTER TABLE questions ADD COLUMN IF NOT EXISTS explanation TEXT; -- Detailed explanation for learning
ALTER TABLE questions ADD COLUMN IF NOT EXISTS teaching_notes TEXT; -- How to teach this concept

-- ============================================
-- 4. PERSONALIZED LEARNING PATHS
-- ============================================

-- User's study plan for a certification
CREATE TABLE IF NOT EXISTS study_plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    certification_id UUID NOT NULL REFERENCES certifications(id) ON DELETE CASCADE,
    target_exam_date DATE,
    daily_study_minutes INTEGER DEFAULT 30,
    current_concept_id UUID REFERENCES concepts(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT unique_active_plan UNIQUE(user_id, certification_id, is_active)
);

-- Track user progress through concepts
CREATE TABLE IF NOT EXISTS concept_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    concept_id UUID NOT NULL REFERENCES concepts(id) ON DELETE CASCADE,
    mastery_level DECIMAL(3,2) DEFAULT 0.00 CHECK (mastery_level BETWEEN 0 AND 1), -- 0.00 to 1.00
    confidence_score INTEGER DEFAULT 1 CHECK (confidence_score BETWEEN 1 AND 5),
    time_spent_minutes INTEGER DEFAULT 0,
    last_studied_at TIMESTAMPTZ,
    times_reviewed INTEGER DEFAULT 0,
    is_mastered BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT unique_user_concept UNIQUE(user_id, concept_id)
);

-- Track engagement with specific content items
CREATE TABLE IF NOT EXISTS content_engagement (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content_item_id UUID NOT NULL REFERENCES content_items(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ,
    time_spent_seconds INTEGER DEFAULT 0,
    engagement_score DECIMAL(3,2) DEFAULT 0.50, -- 0.00 to 1.00 based on interaction
    notes TEXT, -- User's personal notes
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT unique_user_content UNIQUE(user_id, content_item_id)
);

-- ============================================
-- 5. INTELLIGENT RECOMMENDATIONS
-- ============================================

-- System recommendations for next steps
CREATE TABLE IF NOT EXISTS recommendations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- 'next_concept', 'review_concept', 'practice_weak_area'
    target_concept_id UUID REFERENCES concepts(id),
    target_content_id UUID REFERENCES content_items(id),
    priority_score DECIMAL(3,2) DEFAULT 0.50,
    reason TEXT, -- Why this recommendation was made
    is_dismissed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days')
);

-- ============================================
-- 6. PERFORMANCE ANALYTICS
-- ============================================

-- Enhanced user progress (extends existing user_profiles)
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS current_study_plan_id UUID REFERENCES study_plans(id);
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS total_study_minutes INTEGER DEFAULT 0;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS concepts_mastered INTEGER DEFAULT 0;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS current_streak_days INTEGER DEFAULT 0;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS longest_streak_days INTEGER DEFAULT 0;

-- Daily study sessions
CREATE TABLE IF NOT EXISTS study_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    study_plan_id UUID REFERENCES study_plans(id),
    concepts_studied UUID[], -- Array of concept IDs
    total_minutes INTEGER DEFAULT 0,
    questions_attempted INTEGER DEFAULT 0,
    questions_correct INTEGER DEFAULT 0,
    session_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT unique_user_session_date UNIQUE(user_id, session_date)
);

-- ============================================
-- 7. INDEXES FOR PERFORMANCE
-- ============================================

-- Core learning path indexes
CREATE INDEX IF NOT EXISTS idx_concepts_domain ON concepts(domain_id);
CREATE INDEX IF NOT EXISTS idx_concepts_difficulty ON concepts(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_content_items_concept ON content_items(concept_id);
CREATE INDEX IF NOT EXISTS idx_content_items_type ON content_items(type);

-- User progress indexes
CREATE INDEX IF NOT EXISTS idx_concept_progress_user ON concept_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_concept_progress_mastery ON concept_progress(mastery_level);
CREATE INDEX IF NOT EXISTS idx_study_sessions_user_date ON study_sessions(user_id, session_date);
CREATE INDEX IF NOT EXISTS idx_recommendations_user_priority ON recommendations(user_id, priority_score);

-- ============================================
-- 8. ROW LEVEL SECURITY
-- ============================================

-- Enable RLS on all user-specific tables
ALTER TABLE study_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE concept_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_engagement ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_sessions ENABLE ROW LEVEL SECURITY;

-- Policies for user data access
CREATE POLICY "Users manage their own study plans" ON study_plans FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage their own concept progress" ON concept_progress FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage their own content engagement" ON content_engagement FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage their own recommendations" ON recommendations FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage their own study sessions" ON study_sessions FOR ALL USING (auth.uid() = user_id);

-- Public read access for content structure
ALTER TABLE certifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE concepts ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read certifications" ON certifications FOR SELECT USING (true);
CREATE POLICY "Anyone can read domains" ON domains FOR SELECT USING (true);
CREATE POLICY "Anyone can read concepts" ON concepts FOR SELECT USING (true);
CREATE POLICY "Anyone can read content items" ON content_items FOR SELECT USING (true);

-- ============================================
-- 9. SAMPLE DATA FOR TESTING
-- ============================================

-- Insert sample certification
INSERT INTO certifications (name, code, description) VALUES 
('Elementary Mathematics (EC-6)', '160', 'Mathematics content knowledge for elementary teachers')
ON CONFLICT (code) DO NOTHING;

-- Get the certification ID for sample data
DO $$
DECLARE
    cert_id UUID;
    domain_id UUID;
    concept_id UUID;
BEGIN
    -- Get certification ID
    SELECT id INTO cert_id FROM certifications WHERE code = '160';
    
    -- Insert sample domain
    INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index) 
    VALUES (cert_id, 'Number Concepts and Operations', '001', 'Fundamental number concepts and arithmetic operations', 25.00, 1)
    ON CONFLICT (certification_id, code) DO NOTHING
    RETURNING id INTO domain_id;
    
    -- If domain already exists, get its ID
    IF domain_id IS NULL THEN
        SELECT id INTO domain_id FROM domains WHERE certification_id = cert_id AND code = '001';
    END IF;
    
    -- Insert sample concept
    INSERT INTO concepts (domain_id, name, description, difficulty_level, estimated_study_minutes, order_index) 
    VALUES (
        domain_id, 
        'Adding and Subtracting Fractions',
        'Understanding fraction addition and subtraction with like and unlike denominators',
        2,
        45,
        1
    )
    RETURNING id INTO concept_id;
    
    -- Insert sample content items
    INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes) VALUES
    (concept_id, 'text_explanation', 'Understanding Fraction Basics', 
     '{"sections": ["What is a fraction?", "Parts of a fraction", "Equivalent fractions"]}', 1, 10),
    (concept_id, 'video_lesson', 'Adding Fractions with Like Denominators',
     '{"video_url": "placeholder", "transcript": "Step by step process..."}', 2, 15),
    (concept_id, 'practice_question', 'Practice: Basic Fraction Addition',
     '{"question": "What is 1/4 + 1/4?", "answers": ["1/2", "2/8", "1/8", "2/4"], "correct": 0}', 3, 5);
     
END $$;

-- ============================================
-- 10. VERIFICATION
-- ============================================

SELECT 
    '🌸 CONCEPT-BASED LEARNING SCHEMA READY! 🌸' as status,
    (SELECT COUNT(*) FROM certifications) as certifications_count,
    (SELECT COUNT(*) FROM domains) as domains_count,
    (SELECT COUNT(*) FROM concepts) as concepts_count,
    (SELECT COUNT(*) FROM content_items) as content_items_count;
