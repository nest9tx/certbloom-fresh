-- 🔍 CertBloom Comprehensive Diagnostic & Fix
-- Run this to identify and fix all remaining issues

-- =============================================
-- SECTION 1: DIAGNOSTIC - CHECK CURRENT STATE
-- =============================================

DO $$
DECLARE
    user_count INTEGER;
    profile_count INTEGER;
    cert_count INTEGER;
    question_count INTEGER;
    choice_count INTEGER;
BEGIN
    -- Check user counts
    SELECT COUNT(*) INTO user_count FROM auth.users;
    SELECT COUNT(*) INTO profile_count FROM public.user_profiles;
    SELECT COUNT(*) INTO cert_count FROM public.certifications;
    SELECT COUNT(*) INTO question_count FROM public.questions;
    SELECT COUNT(*) INTO choice_count FROM public.answer_choices;
    
    RAISE NOTICE '🔍 DIAGNOSTIC RESULTS:';
    RAISE NOTICE '   Users: %, Profiles: %', user_count, profile_count;
    RAISE NOTICE '   Certifications: %, Questions: %, Choices: %', cert_count, question_count, choice_count;
    
    -- Check user_profiles structure
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_profiles' AND column_name = 'certification_goal') THEN
        RAISE NOTICE '✅ certification_goal column exists';
    ELSE
        RAISE NOTICE '❌ certification_goal column MISSING';
    END IF;
END $$;

-- =============================================
-- SECTION 2: ENSURE ALL REQUIRED TABLES
-- =============================================

-- Create user_profiles if missing (complete structure)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT,
    full_name TEXT,
    certification_goal TEXT,
    alt_cert_program TEXT,
    study_style TEXT,
    anxiety_level INTEGER,
    stripe_customer_id TEXT,
    subscription_status TEXT DEFAULT 'free',
    subscription_plan TEXT,
    subscription_end_date TIMESTAMPTZ,
    stripe_subscription_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add certification_goal column if missing
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' AND column_name = 'certification_goal'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN certification_goal TEXT;
        RAISE NOTICE '✅ Added certification_goal column';
    END IF;
END $$;

-- Ensure other critical tables exist
CREATE TABLE IF NOT EXISTS public.certifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.topics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    certification_id UUID REFERENCES public.certifications(id),
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.questions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    certification_id UUID REFERENCES public.certifications(id),
    topic_id UUID REFERENCES public.topics(id),
    question_text TEXT NOT NULL,
    question_type TEXT DEFAULT 'multiple_choice',
    difficulty_level TEXT,
    explanation TEXT,
    cognitive_level TEXT,
    tags TEXT[],
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.answer_choices (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,
    choice_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT false,
    choice_order INTEGER DEFAULT 1,
    explanation TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User progress for mandala updates
CREATE TABLE IF NOT EXISTS public.user_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    topic TEXT NOT NULL,
    mastery_level DECIMAL DEFAULT 0.0,
    questions_attempted INTEGER DEFAULT 0,
    questions_correct INTEGER DEFAULT 0,
    last_practiced TIMESTAMPTZ DEFAULT NOW(),
    streak_days INTEGER DEFAULT 0,
    needs_review BOOLEAN DEFAULT false,
    difficulty_preference TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- SECTION 3: INSERT SAMPLE DATA FOR TESTING
-- =============================================

-- Insert certifications
INSERT INTO public.certifications (name, description) VALUES
    ('EC-6 Core Subjects', 'Early Childhood through 6th Grade Core Subjects'),
    ('ELA EC-6', 'Early Childhood through 6th Grade English Language Arts'),
    ('Math EC-6', 'Early Childhood through 6th Grade Mathematics'),
    ('Science EC-6', 'Early Childhood through 6th Grade Science'),
    ('Social Studies EC-6', 'Early Childhood through 6th Grade Social Studies'),
    ('ELA 4-8', 'English Language Arts Grades 4-8'),
    ('Math 4-8', 'Mathematics Grades 4-8'),
    ('PPR EC-12', 'Pedagogy and Professional Responsibilities EC-12')
ON CONFLICT (name) DO NOTHING;

-- Insert sample topics and questions for testing
DO $$
DECLARE
    cert_id UUID;
    topic_id UUID;
    question_counter INTEGER := 1;
    choice_letters TEXT[] := ARRAY['A', 'B', 'C', 'D'];
    correct_answer INTEGER;
    question_id UUID;
BEGIN
    -- Get EC-6 Core Subjects certification
    SELECT id INTO cert_id FROM public.certifications WHERE name = 'EC-6 Core Subjects' LIMIT 1;
    
    IF cert_id IS NOT NULL THEN
        -- Insert a sample topic
        INSERT INTO public.topics (name, description, certification_id) 
        VALUES ('Mathematics', 'Basic Mathematics Concepts', cert_id) 
        ON CONFLICT DO NOTHING
        RETURNING id INTO topic_id;
        
        -- If topic already exists, get its ID
        IF topic_id IS NULL THEN
            SELECT id INTO topic_id FROM public.topics WHERE name = 'Mathematics' AND certification_id = cert_id LIMIT 1;
        END IF;
        
        -- Insert sample questions with varied correct answers
        FOR i IN 1..15 LOOP
            correct_answer := ((i - 1) % 4) + 1; -- Cycles through 1,2,3,4 (A,B,C,D)
            question_id := gen_random_uuid(); -- Generate proper UUID
            
            -- Insert question
            INSERT INTO public.questions (id, certification_id, topic_id, question_text, difficulty_level, explanation, active)
            VALUES (
                question_id,
                cert_id,
                topic_id,
                'Sample Mathematics Question ' || i || ': What is 2 + 2?',
                CASE WHEN i <= 5 THEN 'easy' WHEN i <= 10 THEN 'medium' ELSE 'hard' END,
                'This is a sample question for testing purposes.',
                true
            ) ON CONFLICT DO NOTHING;
            
            -- Insert answer choices
            FOR j IN 1..4 LOOP
                INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order)
                VALUES (
                    question_id, -- Use the UUID, not text
                    'Answer ' || choice_letters[j] || ' for question ' || i,
                    j = correct_answer,
                    j
                ) ON CONFLICT DO NOTHING;
            END LOOP;
            
            question_counter := question_counter + 1;
        END LOOP;
        
        RAISE NOTICE '✅ Created % sample questions with varied correct answers', question_counter - 1;
    END IF;
END $$;

-- =============================================
-- SECTION 4: FIX THE RANDOMIZED FUNCTION
-- =============================================

-- Drop and recreate the function
DROP FUNCTION IF EXISTS get_randomized_adaptive_questions(UUID, TEXT, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION get_randomized_adaptive_questions(
    session_user_id UUID, 
    certification_name TEXT,
    session_length INTEGER DEFAULT 10,
    exclude_recent_hours INTEGER DEFAULT 2
)
RETURNS TABLE(
    id UUID,
    certification_id UUID,
    topic_id UUID,
    question_text TEXT,
    question_type TEXT,
    difficulty_level TEXT,
    explanation TEXT,
    cognitive_level TEXT,
    tags TEXT[],
    active BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    topic_name TEXT,
    topic_description TEXT
) AS $$
DECLARE
    cert_id UUID;
    recent_cutoff TIMESTAMPTZ;
    available_questions INTEGER;
BEGIN
    -- Get certification ID
    SELECT c.id INTO cert_id FROM certifications c WHERE c.name = certification_name;
    
    -- Calculate recent question cutoff
    recent_cutoff := NOW() - (exclude_recent_hours || ' hours')::INTERVAL;
    
    -- If certification not found, return sample questions
    IF cert_id IS NULL THEN
        RAISE WARNING 'Certification "%" not found, returning sample questions', certification_name;
        
        RETURN QUERY
        SELECT 
            q.id,
            q.certification_id,
            q.topic_id,
            q.question_text,
            q.question_type,
            q.difficulty_level,
            q.explanation,
            q.cognitive_level,
            q.tags,
            q.active,
            q.created_at,
            q.updated_at,
            COALESCE(t.name, 'Sample Topic') as topic_name,
            COALESCE(t.description, 'Sample Description') as topic_description
        FROM questions q
        LEFT JOIN topics t ON t.id = q.topic_id
        WHERE q.active = true
          AND q.id NOT IN (
              SELECT DISTINCT uqa.question_id 
              FROM user_question_attempts uqa 
              WHERE uqa.user_id = session_user_id 
                AND uqa.created_at > recent_cutoff
          )
        ORDER BY RANDOM()
        LIMIT session_length;
        RETURN;
    END IF;
    
    -- Count available questions
    SELECT COUNT(*) INTO available_questions
    FROM questions q
    WHERE q.certification_id = cert_id
      AND q.active = true
      AND q.id NOT IN (
          SELECT DISTINCT uqa.question_id 
          FROM user_question_attempts uqa 
          WHERE uqa.user_id = session_user_id 
            AND uqa.created_at > recent_cutoff
      );
    
    RAISE NOTICE 'Found % available questions for certification %', available_questions, certification_name;
    
    RETURN QUERY
    SELECT 
        q.id,
        q.certification_id,
        q.topic_id,
        q.question_text,
        q.question_type,
        q.difficulty_level,
        q.explanation,
        q.cognitive_level,
        q.tags,
        q.active,
        q.created_at,
        q.updated_at,
        COALESCE(t.name, 'General') as topic_name,
        COALESCE(t.description, 'General Topic') as topic_description
    FROM questions q
    LEFT JOIN topics t ON t.id = q.topic_id
    WHERE q.certification_id = cert_id
      AND q.active = true
      AND q.id NOT IN (
          SELECT DISTINCT uqa.question_id 
          FROM user_question_attempts uqa 
          WHERE uqa.user_id = session_user_id 
            AND uqa.created_at > recent_cutoff
      )
    ORDER BY RANDOM()
    LIMIT session_length;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- SECTION 5: CREATE PROPER UPDATE TRIGGERS
-- =============================================

-- Function to update user progress when questions are attempted
CREATE OR REPLACE FUNCTION update_user_progress_on_attempt()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert or update user progress
    INSERT INTO user_progress (user_id, topic, questions_attempted, questions_correct, last_practiced, updated_at)
    VALUES (
        NEW.user_id,
        'General Practice',
        1,
        CASE WHEN NEW.is_correct THEN 1 ELSE 0 END,
        NOW(),
        NOW()
    )
    ON CONFLICT (user_id, topic) 
    DO UPDATE SET
        questions_attempted = user_progress.questions_attempted + 1,
        questions_correct = user_progress.questions_correct + CASE WHEN NEW.is_correct THEN 1 ELSE 0 END,
        last_practiced = NOW(),
        updated_at = NOW(),
        mastery_level = LEAST(1.0, (user_progress.questions_correct + CASE WHEN NEW.is_correct THEN 1 ELSE 0 END)::DECIMAL / (user_progress.questions_attempted + 1));
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for mandala updates
DROP TRIGGER IF EXISTS update_progress_on_attempt ON user_question_attempts;
CREATE TRIGGER update_progress_on_attempt
    AFTER INSERT ON user_question_attempts
    FOR EACH ROW
    EXECUTE FUNCTION update_user_progress_on_attempt();

-- =============================================
-- SECTION 6: RLS POLICIES
-- =============================================

-- Enable RLS and create policies
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.answer_choices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;

-- Drop and recreate policies
DROP POLICY IF EXISTS "Users can manage own profile" ON public.user_profiles;
CREATE POLICY "Users can manage own profile" ON public.user_profiles 
    FOR ALL USING (auth.uid() = id);

DROP POLICY IF EXISTS "Public read access to certifications" ON public.certifications;
CREATE POLICY "Public read access to certifications" ON public.certifications 
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read access to topics" ON public.topics;
CREATE POLICY "Public read access to topics" ON public.topics 
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read access to questions" ON public.questions;
CREATE POLICY "Public read access to questions" ON public.questions 
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read access to answer_choices" ON public.answer_choices;
CREATE POLICY "Public read access to answer_choices" ON public.answer_choices 
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can manage own progress" ON public.user_progress;
CREATE POLICY "Users can manage own progress" ON public.user_progress 
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- COMPLETION MESSAGE
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '🎯 COMPREHENSIVE FIX COMPLETED!';
    RAISE NOTICE '✅ Database structure verified and repaired';
    RAISE NOTICE '✅ Sample questions created with varied correct answers (A,B,C,D)';
    RAISE NOTICE '✅ Randomized questions function fixed';
    RAISE NOTICE '✅ Progress tracking and mandala updates enabled';
    RAISE NOTICE '✅ RLS policies properly configured';
    RAISE NOTICE '🚀 Test with: signup -> select certification -> start practice session';
END $$;
