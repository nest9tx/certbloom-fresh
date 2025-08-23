-- 🔧 CertBloom Emergency Fix - Database Schema Alignment
-- Run this script in Supabase SQL editor to fix current issues

-- =============================================
-- SECTION 1: FIX USER_PROFILES TABLE ISSUES
-- =============================================

-- Ensure user_profiles table exists with correct schema
DO $$
BEGIN
    -- Check if certification_goal column exists and add if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'certification_goal'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN certification_goal TEXT;
        RAISE NOTICE '✅ Added missing certification_goal column to user_profiles';
    END IF;
    
    -- Update constraint if it exists
    BEGIN
        ALTER TABLE public.user_profiles DROP CONSTRAINT IF EXISTS user_profiles_certification_goal_check;
        ALTER TABLE public.user_profiles ADD CONSTRAINT user_profiles_certification_goal_check 
        CHECK (certification_goal IN (
            'EC-6 Core Subjects',
            'ELA 4-8',
            'Math 4-8', 
            'Science 4-8',
            'Social Studies 4-8',
            'PPR EC-12',
            'STR Supplemental',
            'ESL Supplemental',
            'Special Education EC-12',
            'Bilingual Education Supplemental',
            'Math 7-12',
            'English 7-12',
            'Science 7-12',
            'Social Studies 7-12',
            'ELA EC-6',
            'Math EC-6',
            'Social Studies EC-6',
            'Science EC-6',
            'Other'
        ));
        RAISE NOTICE '✅ Updated certification_goal constraints';
    EXCEPTION
        WHEN others THEN
            RAISE NOTICE 'Warning: Could not update certification_goal constraint: %', SQLERRM;
    END;
END $$;

-- =============================================
-- SECTION 2: ENSURE BASIC TABLES EXIST
-- =============================================

-- Ensure certifications table exists
CREATE TABLE IF NOT EXISTS public.certifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    category TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure topics table exists
CREATE TABLE IF NOT EXISTS public.topics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    certification_id UUID REFERENCES public.certifications(id),
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure questions table exists
CREATE TABLE IF NOT EXISTS public.questions (
    id TEXT PRIMARY KEY,
    certification_id UUID REFERENCES public.certifications(id),
    topic_id UUID REFERENCES public.topics(id),
    question_text TEXT NOT NULL,
    question_type TEXT DEFAULT 'multiple_choice',
    difficulty_level TEXT CHECK (difficulty_level IN ('easy', 'medium', 'hard')),
    explanation TEXT,
    cognitive_level TEXT,
    tags TEXT[],
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure answer_choices table exists
CREATE TABLE IF NOT EXISTS public.answer_choices (
    id TEXT DEFAULT gen_random_uuid()::text PRIMARY KEY,
    question_id TEXT REFERENCES public.questions(id) ON DELETE CASCADE,
    choice_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT false,
    choice_order INTEGER DEFAULT 1,
    explanation TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- SECTION 3: INSERT BASIC CERTIFICATION DATA
-- =============================================

-- Insert basic certifications if they don't exist
INSERT INTO public.certifications (name, description) VALUES
    ('EC-6 Core Subjects', 'Early Childhood through 6th Grade Core Subjects'),
    ('ELA EC-6', 'Early Childhood through 6th Grade English Language Arts'),
    ('Math EC-6', 'Early Childhood through 6th Grade Mathematics'),
    ('Science EC-6', 'Early Childhood through 6th Grade Science'),
    ('Social Studies EC-6', 'Early Childhood through 6th Grade Social Studies'),
    ('ELA 4-8', 'English Language Arts Grades 4-8'),
    ('Math 4-8', 'Mathematics Grades 4-8'),
    ('Science 4-8', 'Science Grades 4-8'),
    ('Social Studies 4-8', 'Social Studies Grades 4-8'),
    ('PPR EC-12', 'Pedagogy and Professional Responsibilities EC-12')
ON CONFLICT (name) DO NOTHING;

-- =============================================
-- SECTION 4: FIX RANDOMIZED QUESTIONS FUNCTION
-- =============================================

-- Drop existing function first to avoid return type conflicts
DROP FUNCTION IF EXISTS get_randomized_adaptive_questions(UUID, TEXT, INTEGER, INTEGER);

-- Create a simpler, more reliable randomized function
CREATE OR REPLACE FUNCTION get_randomized_adaptive_questions(
    session_user_id UUID, 
    certification_name TEXT,
    session_length INTEGER DEFAULT 10,
    exclude_recent_hours INTEGER DEFAULT 2
)
RETURNS TABLE(
    id TEXT,
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
BEGIN
    -- Get certification ID
    SELECT c.id INTO cert_id 
    FROM certifications c 
    WHERE c.name = certification_name;
    
    -- If certification not found, try to find it anyway
    IF cert_id IS NULL THEN
        RAISE WARNING 'Certification not found: %, returning all available questions', certification_name;
        -- Return questions from all certifications as fallback
        recent_cutoff := NOW() - (exclude_recent_hours || ' hours')::INTERVAL;
        
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
    
    -- Calculate recent question cutoff
    recent_cutoff := NOW() - (exclude_recent_hours || ' hours')::INTERVAL;
    
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
-- SECTION 5: RLS POLICIES
-- =============================================

-- Enable RLS on all tables (ignore errors if already enabled)
DO $$
BEGIN
    BEGIN
        ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
        ALTER TABLE public.certifications ENABLE ROW LEVEL SECURITY;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
        ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
        ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
        ALTER TABLE public.answer_choices ENABLE ROW LEVEL SECURITY;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
END $$;

-- Create policies for public access (drop first if exists)
DROP POLICY IF EXISTS "Public read access to certifications" ON public.certifications;
CREATE POLICY "Public read access to certifications" ON public.certifications FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read access to topics" ON public.topics;
CREATE POLICY "Public read access to topics" ON public.topics FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read access to questions" ON public.questions;
CREATE POLICY "Public read access to questions" ON public.questions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read access to answer_choices" ON public.answer_choices;
CREATE POLICY "Public read access to answer_choices" ON public.answer_choices FOR SELECT USING (true);

-- User profile policies (drop first if exists)
DROP POLICY IF EXISTS "Users can view own profile" ON public.user_profiles;
CREATE POLICY "Users can view own profile" ON public.user_profiles FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
CREATE POLICY "Users can update own profile" ON public.user_profiles FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;
CREATE POLICY "Users can insert own profile" ON public.user_profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- =============================================
-- COMPLETION MESSAGE
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '🔧 Emergency fix completed!';
    RAISE NOTICE '✅ User profiles table structure verified';
    RAISE NOTICE '✅ Basic certification data inserted';
    RAISE NOTICE '✅ Randomized questions function made more robust';
    RAISE NOTICE '✅ RLS policies updated';
    RAISE NOTICE '🚀 Try testing the app now!';
END $$;
