-- 🌸 STEP 1: CORE SCHEMA ONLY
-- Run this first in Supabase SQL Editor

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

-- Different types of learning content (focused on what we can do well)
DO $$ BEGIN
    CREATE TYPE content_type AS ENUM (
        'text_explanation',         -- Clear written explanations
        'interactive_example',      -- Step-by-step worked examples  
        'practice_question',        -- Quiz questions with detailed feedback
        'real_world_scenario',      -- Practical classroom applications
        'teaching_strategy',        -- How to teach this concept effectively
        'common_misconception',     -- What students typically get wrong
        'memory_technique'          -- Mnemonics and memory aids
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

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

-- Policies for user data access (drop and recreate to ensure consistency)
DROP POLICY IF EXISTS "Users manage their own study plans" ON study_plans;
CREATE POLICY "Users manage their own study plans" ON study_plans FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users manage their own concept progress" ON concept_progress;
CREATE POLICY "Users manage their own concept progress" ON concept_progress FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users manage their own content engagement" ON content_engagement;
CREATE POLICY "Users manage their own content engagement" ON content_engagement FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users manage their own recommendations" ON recommendations;
CREATE POLICY "Users manage their own recommendations" ON recommendations FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users manage their own study sessions" ON study_sessions;
CREATE POLICY "Users manage their own study sessions" ON study_sessions FOR ALL USING (auth.uid() = user_id);

-- Public read access for content structure
ALTER TABLE certifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE concepts ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_items ENABLE ROW LEVEL SECURITY;

-- Public read access for content structure (drop and recreate to ensure consistency)
DROP POLICY IF EXISTS "Anyone can read certifications" ON certifications;
CREATE POLICY "Anyone can read certifications" ON certifications FOR SELECT USING (true);

DROP POLICY IF EXISTS "Anyone can read domains" ON domains;
CREATE POLICY "Anyone can read domains" ON domains FOR SELECT USING (true);

DROP POLICY IF EXISTS "Anyone can read concepts" ON concepts;
CREATE POLICY "Anyone can read concepts" ON concepts FOR SELECT USING (true);

DROP POLICY IF EXISTS "Anyone can read content items" ON content_items;
CREATE POLICY "Anyone can read content items" ON content_items FOR SELECT USING (true);

-- Verify core schema is ready
SELECT 
    '🌸 CORE SCHEMA CREATED! 🌸' as status,
    'Ready for sample data' as next_step;
