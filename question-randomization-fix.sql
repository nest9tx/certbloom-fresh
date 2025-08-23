-- 🔄 CertBloom Question Randomization Enhancement
-- Run this script in Supabase SQL editor to improve question variety

-- =============================================
-- SECTION 1: ENSURE USER_QUESTION_ATTEMPTS TABLE EXISTS
-- =============================================

-- Create user_question_attempts table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_question_attempts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id TEXT NOT NULL,
  question_id TEXT NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
  selected_answer_id TEXT,
  is_correct BOOLEAN NOT NULL DEFAULT false,
  time_spent_seconds INTEGER DEFAULT 0,
  confidence_level INTEGER DEFAULT 3,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.user_question_attempts ENABLE ROW LEVEL SECURITY;

-- Create policies for user_question_attempts
CREATE POLICY "Users can view their own question attempts" ON public.user_question_attempts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own question attempts" ON public.user_question_attempts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own question attempts" ON public.user_question_attempts
  FOR UPDATE USING (auth.uid() = user_id);

-- =============================================
-- SECTION 2: IMPROVED QUESTION RANDOMIZATION FUNCTION
-- =============================================

-- Create enhanced adaptive question function with better randomization
CREATE OR REPLACE FUNCTION get_randomized_adaptive_questions(
    session_user_id UUID, 
    certification_name TEXT,
    session_length INTEGER DEFAULT 10,
    exclude_recent_hours INTEGER DEFAULT 2
)
RETURNS TABLE(
    id TEXT,
    certification_id TEXT,
    topic_id TEXT,
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
    
    IF cert_id IS NULL THEN
        RAISE EXCEPTION 'Certification not found: %', certification_name;
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
        t.name as topic_name,
        t.description as topic_description
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    WHERE q.certification_id = cert_id
      AND q.active = true
      AND q.id NOT IN (
          SELECT DISTINCT uqa.question_id 
          FROM user_question_attempts uqa 
          WHERE uqa.user_id = session_user_id 
            AND uqa.created_at > recent_cutoff
      )
    ORDER BY RANDOM()  -- PostgreSQL's random() is more efficient than client-side shuffling
    LIMIT session_length;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- SECTION 3: SESSION COMPLETION TRACKING
-- =============================================

-- Create session completion tracking table
CREATE TABLE IF NOT EXISTS public.practice_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id TEXT NOT NULL UNIQUE,
  certification_name TEXT NOT NULL,
  session_type TEXT DEFAULT 'full', -- 'quick', 'full', 'custom'
  session_length INTEGER NOT NULL,
  questions_attempted INTEGER DEFAULT 0,
  questions_correct INTEGER DEFAULT 0,
  total_time_seconds INTEGER DEFAULT 0,
  mood TEXT,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.practice_sessions ENABLE ROW LEVEL SECURITY;

-- Create policies for practice_sessions
CREATE POLICY "Users can view their own practice sessions" ON public.practice_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own practice sessions" ON public.practice_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =============================================
-- SECTION 4: MANDALA REFRESH TRIGGER
-- =============================================

-- Function to update user progress timestamp for mandala refresh
CREATE OR REPLACE FUNCTION update_progress_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the user_progress updated_at timestamp when new attempts are recorded
    UPDATE user_progress 
    SET updated_at = NOW()
    WHERE user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to refresh mandala when new attempts are recorded
DROP TRIGGER IF EXISTS refresh_mandala_on_attempt ON user_question_attempts;
CREATE TRIGGER refresh_mandala_on_attempt
    AFTER INSERT ON user_question_attempts
    FOR EACH ROW
    EXECUTE FUNCTION update_progress_timestamp();

-- =============================================
-- SECTION 5: ANALYTICS FOR BETTER QUESTIONS
-- =============================================

-- Create view for question analytics
CREATE OR REPLACE VIEW question_analytics AS
SELECT 
    q.id,
    q.question_text,
    q.difficulty_level,
    t.name as topic_name,
    COUNT(uqa.id) as attempt_count,
    AVG(CASE WHEN uqa.is_correct THEN 1.0 ELSE 0.0 END) as success_rate,
    AVG(uqa.time_spent_seconds) as avg_time_spent,
    AVG(uqa.confidence_level) as avg_confidence
FROM questions q
JOIN topics t ON t.id = q.topic_id
LEFT JOIN user_question_attempts uqa ON uqa.question_id = q.id
WHERE q.active = true
GROUP BY q.id, q.question_text, q.difficulty_level, t.name;

-- =============================================
-- COMPLETION MESSAGE
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '🔄 Question Randomization Enhancement completed!';
    RAISE NOTICE '✨ Enhanced variety and mandala refresh mechanisms are now active.';
    RAISE NOTICE '🎯 Question attempts will be properly tracked for better adaptive learning.';
END $$;
