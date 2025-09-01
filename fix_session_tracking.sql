-- FIX SESSION COMPLETION AND PROGRESS TRACKING
-- Address the core issues with session completion and mastery tracking

-- 1. Check current practice_sessions table structure
SELECT 
  'PRACTICE_SESSIONS TABLE STRUCTURE' as section,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'practice_sessions'
ORDER BY ordinal_position;

-- 2. Check if we have proper session response tracking
SELECT 
  'SESSION RESPONSES TABLE CHECK' as section,
  table_name
FROM information_schema.tables 
WHERE table_name IN ('session_responses', 'practice_session_responses', 'user_answers', 'question_attempts');

-- 3. Create proper session tracking if missing
CREATE TABLE IF NOT EXISTS practice_session_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES practice_sessions(id) ON DELETE CASCADE,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  selected_answer TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  time_spent_seconds INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(session_id, question_id)
);

-- 4. Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_session_responses_session ON practice_session_responses(session_id);
CREATE INDEX IF NOT EXISTS idx_session_responses_question ON practice_session_responses(question_id);

-- 5. Create function to properly complete sessions and update progress
CREATE OR REPLACE FUNCTION complete_practice_session(
  p_session_id UUID,
  p_total_questions INTEGER,
  p_correct_answers INTEGER
) RETURNS VOID AS $$
DECLARE
  session_record practice_sessions%ROWTYPE;
  user_id_val UUID;
  certification_id_val UUID;
  mastery_threshold DECIMAL := 0.8;
  new_mastery_level DECIMAL;
BEGIN
  -- Get session details
  SELECT * INTO session_record FROM practice_sessions WHERE id = p_session_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Session not found: %', p_session_id;
  END IF;
  
  -- Calculate score and update session
  UPDATE practice_sessions 
  SET 
    score = (p_correct_answers::DECIMAL / p_total_questions) * 100,
    total_questions = p_total_questions,
    correct_answers = p_correct_answers,
    completed_at = NOW(),
    updated_at = NOW()
  WHERE id = p_session_id;
  
  -- Get user and certification info
  SELECT sp.user_id, sp.certification_id 
  INTO user_id_val, certification_id_val
  FROM study_plans sp 
  WHERE sp.id = session_record.study_plan_id;
  
  -- Update concept progress (simplified - update overall progress)
  new_mastery_level := LEAST(1.0, (p_correct_answers::DECIMAL / p_total_questions));
  
  INSERT INTO user_concept_progress (
    user_id,
    certification_area,
    domain,
    concept,
    mastery_level,
    progress_percent,
    questions_attempted,
    questions_correct,
    last_attempt_at
  ) VALUES (
    user_id_val,
    'Math EC-6', -- Will be dynamic later
    'Overall',
    'General Practice',
    new_mastery_level,
    new_mastery_level * 100,
    p_total_questions,
    p_correct_answers,
    NOW()
  ) ON CONFLICT (user_id, certification_area, domain, concept) 
  DO UPDATE SET
    mastery_level = (user_concept_progress.mastery_level + new_mastery_level) / 2,
    progress_percent = ((user_concept_progress.mastery_level + new_mastery_level) / 2) * 100,
    questions_attempted = user_concept_progress.questions_attempted + p_total_questions,
    questions_correct = user_concept_progress.questions_correct + p_correct_answers,
    last_attempt_at = NOW();
    
  RAISE NOTICE 'Session completed: % correct out of %', p_correct_answers, p_total_questions;
END;
$$ LANGUAGE plpgsql;

-- 6. Test the function (uncomment to test)
-- SELECT complete_practice_session('test-uuid', 15, 12);
