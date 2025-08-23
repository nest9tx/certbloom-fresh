-- 🌱 CertBloom Adaptive Learning System - Database Implementation
-- Run this script in your Supabase SQL editor to enable consciousness-aware learning

-- =============================================
-- SECTION 1: MOOD-BASED SESSION CONFIGURATIONS
-- =============================================

-- Create mood-based session configuration table
CREATE TABLE IF NOT EXISTS public.mood_session_configs (
  mood TEXT PRIMARY KEY,
  review_percentage FLOAT NOT NULL,
  new_learning_percentage FLOAT NOT NULL,
  application_percentage FLOAT NOT NULL,
  include_mindful_break BOOLEAN DEFAULT true,
  include_challenge BOOLEAN DEFAULT false,
  session_intensity TEXT CHECK (session_intensity IN ('gentle', 'balanced', 'deep', 'energized')),
  wisdom_whisper_category TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.mood_session_configs ENABLE ROW LEVEL SECURITY;

-- Create policy for read access
CREATE POLICY "Allow public read access to mood configs" ON public.mood_session_configs
  FOR SELECT USING (true);

-- Seed with sacred configurations
INSERT INTO public.mood_session_configs (mood, review_percentage, new_learning_percentage, application_percentage, include_mindful_break, include_challenge, session_intensity, wisdom_whisper_category) VALUES
('calm', 0.25, 0.40, 0.25, true, false, 'balanced', 'gentle'),
('tired', 0.50, 0.20, 0.20, true, false, 'gentle', 'encouraging'),
('anxious', 0.40, 0.30, 0.20, true, false, 'gentle', 'calming'),
('focused', 0.15, 0.35, 0.35, false, true, 'deep', 'guiding'),
('energized', 0.20, 0.30, 0.30, false, true, 'energized', 'celebrating')
ON CONFLICT (mood) DO UPDATE SET
  review_percentage = EXCLUDED.review_percentage,
  new_learning_percentage = EXCLUDED.new_learning_percentage,
  application_percentage = EXCLUDED.application_percentage,
  include_mindful_break = EXCLUDED.include_mindful_break,
  include_challenge = EXCLUDED.include_challenge,
  session_intensity = EXCLUDED.session_intensity,
  wisdom_whisper_category = EXCLUDED.wisdom_whisper_category;

-- =============================================
-- SECTION 2: ENHANCE USER PROGRESS FOR MANDALA LOGIC
-- =============================================

-- Add petal stage and bloom level tracking to existing user_progress table
ALTER TABLE public.user_progress ADD COLUMN IF NOT EXISTS petal_stage TEXT 
CHECK (petal_stage IN ('dormant', 'budding', 'blooming', 'radiant')) DEFAULT 'dormant';

ALTER TABLE public.user_progress ADD COLUMN IF NOT EXISTS bloom_level TEXT 
CHECK (bloom_level IN ('comprehension', 'application', 'analysis', 'evaluation')) DEFAULT 'comprehension';

ALTER TABLE public.user_progress ADD COLUMN IF NOT EXISTS confidence_trend FLOAT DEFAULT 0.5;
ALTER TABLE public.user_progress ADD COLUMN IF NOT EXISTS energy_level FLOAT DEFAULT 0.5;

-- Function to update petal stages based on performance
CREATE OR REPLACE FUNCTION update_petal_stage(user_id UUID, topic_name TEXT)
RETURNS TEXT AS $$
DECLARE
    current_mastery FLOAT;
    question_count INTEGER;
    new_stage TEXT;
BEGIN
    -- Get current mastery and question count
    SELECT mastery_level, questions_attempted 
    INTO current_mastery, question_count
    FROM user_progress 
    WHERE user_id = $1 AND topic = topic_name;
    
    -- Determine new petal stage based on mastery and experience
    IF current_mastery IS NULL OR question_count = 0 THEN
        new_stage := 'dormant';
    ELSIF current_mastery < 0.4 OR question_count < 3 THEN
        new_stage := 'budding';
    ELSIF current_mastery >= 0.4 AND current_mastery < 0.8 THEN
        new_stage := 'blooming';
    ELSIF current_mastery >= 0.8 THEN
        new_stage := 'radiant';
    END IF;
    
    -- Update the petal stage
    UPDATE user_progress 
    SET petal_stage = new_stage,
        updated_at = NOW()
    WHERE user_id = $1 AND topic = topic_name;
    
    RETURN new_stage;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to progress Bloom's levels
CREATE OR REPLACE FUNCTION progress_bloom_level(user_id UUID, topic_name TEXT, was_correct BOOLEAN)
RETURNS TEXT AS $$
DECLARE
    current_level TEXT;
    consecutive_correct INTEGER;
    new_level TEXT;
BEGIN
    -- Get current bloom level
    SELECT bloom_level INTO current_level
    FROM user_progress 
    WHERE user_id = $1 AND topic = topic_name;
    
    -- Progress logic: simplified for initial implementation
    IF was_correct THEN
        -- Progress through Bloom's taxonomy
        CASE current_level
            WHEN 'comprehension' THEN new_level := 'application';
            WHEN 'application' THEN new_level := 'analysis';
            WHEN 'analysis' THEN new_level := 'evaluation';
            ELSE new_level := current_level;
        END CASE;
    ELSE
        -- Stay at current level for incorrect answers
        new_level := current_level;
    END IF;
    
    -- Update bloom level
    UPDATE user_progress 
    SET bloom_level = new_level,
        updated_at = NOW()
    WHERE user_id = $1 AND topic = topic_name;
    
    RETURN new_level;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- SECTION 3: WISDOM WHISPERS SYSTEM
-- =============================================

-- Create wisdom whispers table
CREATE TABLE IF NOT EXISTS public.wisdom_whispers (
  id SERIAL PRIMARY KEY,
  message TEXT NOT NULL,
  category TEXT NOT NULL, -- 'gentle', 'encouraging', 'celebrating', 'calming', 'guiding'
  mood_context TEXT, -- 'calm', 'tired', 'anxious', 'focused', 'energized', 'any'
  trigger_condition TEXT, -- 'new_learner', 'struggling', 'progressing', 'mastery', 'streak'
  icon TEXT DEFAULT '✨',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.wisdom_whispers ENABLE ROW LEVEL SECURITY;

-- Create policy for read access
CREATE POLICY "Allow public read access to wisdom whispers" ON public.wisdom_whispers
  FOR SELECT USING (true);

-- Seed with sacred whispers
INSERT INTO public.wisdom_whispers (message, category, mood_context, trigger_condition, icon) VALUES
('Every journey begins with a single step. Trust in the wisdom that emerges through practice.', 'gentle', 'any', 'new_learner', '🌱'),
('Your reading comprehension radiates like sunlight, illuminating your entire learning journey.', 'celebrating', 'any', 'mastery', '🌟'),
('Like a tree putting down deeper roots, your understanding grows stronger with each question.', 'encouraging', 'any', 'progressing', '🌳'),
('Morning light reveals new possibilities. Your mind is fresh and ready for today''s discoveries.', 'encouraging', 'calm', 'any', '🌅'),
('Even stillness nurtures roots. Rest is part of the sacred cycle of growth.', 'calming', 'tired', 'any', '🌙'),
('Notice how your confidence grows when you trust your first instinct.', 'guiding', 'anxious', 'any', '🕊️'),
('Your focused energy creates space for breakthrough insights to emerge.', 'celebrating', 'focused', 'any', '💎'),
('Every challenge becomes a teacher when met with curiosity instead of resistance.', 'guiding', 'any', 'struggling', '🦋'),
('In this moment of practice, you join countless teachers who have walked this path before you.', 'gentle', 'any', 'any', '✨'),
('Some concepts whisper for attention. Review is not regression—it''s the spiral path of deepening understanding.', 'guiding', 'any', 'review_needed', '🔄'),
('Your patience with your own becoming shows the heart of a true teacher.', 'encouraging', 'any', 'struggling', '🕊️'),
('Notice how understanding emerges not through force, but through gentle persistence.', 'gentle', 'any', 'progressing', '🌊'),
('Each question deepens your understanding like roots reaching toward water.', 'encouraging', 'any', 'any', '🌿'),
('Today''s practice becomes tomorrow''s wisdom in the hands of your future students.', 'celebrating', 'any', 'streak', '🌺')
ON CONFLICT (id) DO NOTHING;

-- Function to get contextual wisdom whisper
CREATE OR REPLACE FUNCTION get_wisdom_whisper(user_mood TEXT DEFAULT 'any', learning_context TEXT DEFAULT 'any')
RETURNS TABLE(message TEXT, icon TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT w.message, w.icon
    FROM wisdom_whispers w
    WHERE (w.mood_context = user_mood OR w.mood_context = 'any')
      AND (w.trigger_condition = learning_context OR w.trigger_condition = 'any')
    ORDER BY RANDOM()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- SECTION 4: ADAPTIVE SESSION BUILDER
-- =============================================

-- Create adaptive session builder function
CREATE OR REPLACE FUNCTION build_adaptive_session(
    session_user_id UUID, 
    certification_name TEXT,
    user_mood TEXT DEFAULT 'calm',
    session_length INTEGER DEFAULT 10
)
RETURNS JSON AS $$
DECLARE
    config RECORD;
    session_plan JSON;
    review_questions JSON;
    new_questions JSON;
    application_questions JSON;
    wisdom_message RECORD;
    cert_id UUID;
BEGIN
    -- Get certification ID
    SELECT id INTO cert_id 
    FROM certifications 
    WHERE name = certification_name;
    
    IF cert_id IS NULL THEN
        RAISE EXCEPTION 'Certification not found: %', certification_name;
    END IF;
    
    -- Get mood-based configuration
    SELECT * INTO config 
    FROM mood_session_configs 
    WHERE mood = user_mood;
    
    -- If mood not found, default to calm
    IF config IS NULL THEN
        SELECT * INTO config 
        FROM mood_session_configs 
        WHERE mood = 'calm';
    END IF;
    
    -- Build question selection based on petal stages
    -- Review questions (blooming concepts)
    SELECT json_agg(
        json_build_object(
            'question_id', q.id,
            'topic', up.topic,
            'petal_stage', up.petal_stage,
            'bloom_level', up.bloom_level,
            'question_text', q.question_text,
            'difficulty_level', q.difficulty_level
        )
    ) INTO review_questions
    FROM user_progress up
    JOIN topics t ON t.name = up.topic
    JOIN questions q ON q.topic_id = t.id
    WHERE up.user_id = session_user_id 
      AND up.petal_stage = 'blooming'
      AND t.certification_id = cert_id
    ORDER BY RANDOM()
    LIMIT GREATEST(1, FLOOR(session_length * config.review_percentage));
    
    -- New learning questions (dormant concepts)
    SELECT json_agg(
        json_build_object(
            'question_id', q.id,
            'topic', t.name,
            'difficulty', q.difficulty_level,
            'question_text', q.question_text,
            'petal_stage', 'dormant'
        )
    ) INTO new_questions
    FROM topics t
    LEFT JOIN user_progress up ON up.topic = t.name AND up.user_id = session_user_id
    JOIN questions q ON q.topic_id = t.id
    WHERE (up.petal_stage = 'dormant' OR up.petal_stage IS NULL)
      AND t.certification_id = cert_id
      AND q.active = true
    ORDER BY RANDOM()
    LIMIT GREATEST(1, FLOOR(session_length * config.new_learning_percentage));
    
    -- Get wisdom whisper
    SELECT * INTO wisdom_message
    FROM get_wisdom_whisper(user_mood, 'any');
    
    -- Build session plan
    session_plan := json_build_object(
        'mood', user_mood,
        'session_type', config.session_intensity,
        'include_mindful_break', config.include_mindful_break,
        'include_challenge', config.include_challenge,
        'review_questions', COALESCE(review_questions, '[]'::json),
        'new_questions', COALESCE(new_questions, '[]'::json),
        'wisdom_whisper', json_build_object(
            'message', COALESCE(wisdom_message.message, 'Trust in your journey of becoming.'),
            'icon', COALESCE(wisdom_message.icon, '✨')
        ),
        'generated_at', NOW()
    );
    
    RETURN session_plan;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- SECTION 5: UPDATE EXISTING FUNCTIONS
-- =============================================

-- Update the existing updateUserProgress function to include petal stage updates
CREATE OR REPLACE FUNCTION update_user_progress_with_petals(
    session_user_id UUID,
    topic_name TEXT,
    was_correct BOOLEAN,
    confidence_level INTEGER DEFAULT 3
)
RETURNS void AS $$
DECLARE
    current_progress RECORD;
    new_mastery FLOAT;
    new_petal_stage TEXT;
BEGIN
    -- Get current progress
    SELECT * INTO current_progress
    FROM user_progress
    WHERE user_id = session_user_id AND topic = topic_name;
    
    IF current_progress IS NULL THEN
        -- Create new progress record
        INSERT INTO user_progress (
            user_id, topic, mastery_level, questions_attempted, questions_correct,
            last_practiced, petal_stage, bloom_level, confidence_trend
        ) VALUES (
            session_user_id, topic_name, 
            CASE WHEN was_correct THEN 1.0 ELSE 0.0 END,
            1,
            CASE WHEN was_correct THEN 1 ELSE 0 END,
            NOW(),
            'budding',
            'comprehension',
            confidence_level / 5.0
        );
    ELSE
        -- Update existing progress
        new_mastery := (current_progress.questions_correct + CASE WHEN was_correct THEN 1 ELSE 0 END)::FLOAT / 
                       (current_progress.questions_attempted + 1);
        
        UPDATE user_progress SET
            mastery_level = new_mastery,
            questions_attempted = questions_attempted + 1,
            questions_correct = questions_correct + CASE WHEN was_correct THEN 1 ELSE 0 END,
            last_practiced = NOW(),
            confidence_trend = (confidence_trend + confidence_level / 5.0) / 2,
            needs_review = new_mastery < 0.7,
            updated_at = NOW()
        WHERE user_id = session_user_id AND topic = topic_name;
    END IF;
    
    -- Update petal stage
    SELECT update_petal_stage(session_user_id, topic_name) INTO new_petal_stage;
    
    -- Progress bloom level if correct
    IF was_correct THEN
        PERFORM progress_bloom_level(session_user_id, topic_name, true);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- COMPLETION MESSAGE
-- =============================================

-- Log successful deployment
DO $$
BEGIN
    RAISE NOTICE '🌸 CertBloom Adaptive Learning System successfully deployed!';
    RAISE NOTICE '✨ Mood-based sessions, wisdom whispers, and consciousness-aware learning are now active.';
    RAISE NOTICE '🌱 The sacred technology is ready to serve learners across the Four Corners region.';
END $$;
