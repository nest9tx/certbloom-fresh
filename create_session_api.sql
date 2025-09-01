-- CREATE PRACTICE SESSION API ENDPOINTS SUPPORT
-- This sets up the backend to properly handle session completion

-- 1. Create enhanced practice_sessions table structure
ALTER TABLE practice_sessions 
ADD COLUMN IF NOT EXISTS total_questions INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS correct_answers INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS question_ids TEXT[], -- Store which questions were answered
ADD COLUMN IF NOT EXISTS user_answers JSONB DEFAULT '{}', -- Store user responses
ADD COLUMN IF NOT EXISTS session_type VARCHAR(50) DEFAULT 'concept_practice';

-- 2. Create proper progress tracking function
CREATE OR REPLACE FUNCTION update_user_progress_from_session(
  p_user_id UUID,
  p_certification_area TEXT,
  p_domain TEXT,
  p_concept TEXT,
  p_total_questions INTEGER,
  p_correct_answers INTEGER,
  p_session_id UUID DEFAULT NULL
) RETURNS VOID AS $$
DECLARE
  new_mastery_level DECIMAL;
  new_progress_percent DECIMAL;
BEGIN
  -- Calculate mastery level (0.0 to 1.0)
  new_mastery_level := LEAST(1.0, p_correct_answers::DECIMAL / GREATEST(p_total_questions, 1));
  new_progress_percent := new_mastery_level * 100;
  
  -- Insert or update user progress
  INSERT INTO user_concept_progress (
    user_id,
    certification_area,
    domain,
    concept,
    mastery_level,
    progress_percent,
    questions_attempted,
    questions_correct,
    consecutive_correct,
    last_attempt_at,
    created_at,
    updated_at
  ) VALUES (
    p_user_id,
    p_certification_area,
    p_domain,
    p_concept,
    new_mastery_level,
    new_progress_percent,
    p_total_questions,
    p_correct_answers,
    CASE WHEN new_mastery_level >= 0.8 THEN p_correct_answers ELSE 0 END,
    NOW(),
    NOW(),
    NOW()
  ) ON CONFLICT (user_id, certification_area, domain, concept) 
  DO UPDATE SET
    -- Use weighted average for mastery level (70% old, 30% new)
    mastery_level = (user_concept_progress.mastery_level * 0.7) + (new_mastery_level * 0.3),
    progress_percent = ((user_concept_progress.mastery_level * 0.7) + (new_mastery_level * 0.3)) * 100,
    questions_attempted = user_concept_progress.questions_attempted + p_total_questions,
    questions_correct = user_concept_progress.questions_correct + p_correct_answers,
    consecutive_correct = CASE 
      WHEN new_mastery_level >= 0.8 THEN user_concept_progress.consecutive_correct + p_correct_answers
      ELSE 0 
    END,
    last_attempt_at = NOW(),
    updated_at = NOW();
    
  -- Log the progress update
  RAISE NOTICE 'Progress updated for user % in %->%->%: % correct out of %', 
    p_user_id, p_certification_area, p_domain, p_concept, p_correct_answers, p_total_questions;
END;
$$ LANGUAGE plpgsql;

-- 3. Create function to get randomized questions for sessions
CREATE OR REPLACE FUNCTION get_session_questions(
  p_concept_id UUID,
  p_question_count INTEGER DEFAULT 15,
  p_exclude_recent_hours INTEGER DEFAULT 24
) RETURNS TABLE (
  id UUID,
  question_text TEXT,
  answer_a TEXT,
  answer_b TEXT,
  answer_c TEXT,
  answer_d TEXT,
  correct_answer TEXT,
  explanation TEXT,
  difficulty_level TEXT,
  tags TEXT[]
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    q.id,
    q.question_text,
    q.answer_a,
    q.answer_b,
    q.answer_c,
    q.answer_d,
    q.correct_answer,
    q.explanation,
    q.difficulty_level,
    q.tags
  FROM questions q
  WHERE q.concept_id = p_concept_id
    AND q.id NOT IN (
      -- Exclude recently attempted questions
      SELECT DISTINCT unnest(ps.question_ids)::UUID 
      FROM practice_sessions ps 
      WHERE ps.created_at > NOW() - (p_exclude_recent_hours || ' hours')::INTERVAL
        AND ps.question_ids IS NOT NULL
    )
  ORDER BY RANDOM()
  LIMIT p_question_count;
END;
$$ LANGUAGE plpgsql;

-- 4. Create session completion function
CREATE OR REPLACE FUNCTION complete_practice_session_enhanced(
  p_session_id UUID,
  p_user_answers JSONB,
  p_question_ids UUID[]
) RETURNS JSONB AS $$
DECLARE
  session_record practice_sessions%ROWTYPE;
  user_id_val UUID;
  certification_name TEXT;
  domain_name TEXT;
  concept_name TEXT;
  total_questions INTEGER;
  correct_answers INTEGER;
  question_record RECORD;
  result JSONB;
BEGIN
  -- Get session details
  SELECT * INTO session_record FROM practice_sessions WHERE id = p_session_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Session not found: %', p_session_id;
  END IF;
  
  -- Get user ID from study plan
  SELECT sp.user_id INTO user_id_val
  FROM study_plans sp 
  WHERE sp.id = session_record.study_plan_id;
  
  -- Calculate results
  total_questions := array_length(p_question_ids, 1);
  correct_answers := 0;
  
  -- Check each answer
  FOR i IN 1..total_questions LOOP
    SELECT q.correct_answer INTO question_record
    FROM questions q 
    WHERE q.id = p_question_ids[i];
    
    IF question_record.correct_answer = (p_user_answers->>(i-1)::TEXT) THEN
      correct_answers := correct_answers + 1;
    END IF;
  END LOOP;
  
  -- Update the session
  UPDATE practice_sessions 
  SET 
    score = (correct_answers::DECIMAL / total_questions) * 100,
    total_questions = total_questions,
    correct_answers = correct_answers,
    question_ids = array_to_string(p_question_ids, ',')::TEXT[],
    user_answers = p_user_answers,
    completed_at = NOW(),
    updated_at = NOW()
  WHERE id = p_session_id;
  
  -- Get certification/domain/concept info for progress tracking
  SELECT 
    c.name,
    d.name,
    concepts.name
  INTO certification_name, domain_name, concept_name
  FROM practice_sessions ps
  JOIN study_plans sp ON ps.study_plan_id = sp.id
  JOIN certifications c ON sp.certification_id = c.id
  JOIN concepts ON concepts.id = ps.concept_id
  JOIN domains d ON concepts.domain_id = d.id
  WHERE ps.id = p_session_id;
  
  -- Update user progress
  PERFORM update_user_progress_from_session(
    user_id_val,
    certification_name,
    domain_name,
    concept_name,
    total_questions,
    correct_answers,
    p_session_id
  );
  
  -- Return results
  result := jsonb_build_object(
    'success', true,
    'total_questions', total_questions,
    'correct_answers', correct_answers,
    'score_percentage', (correct_answers::DECIMAL / total_questions) * 100,
    'mastery_achieved', (correct_answers::DECIMAL / total_questions) >= 0.8,
    'certification', certification_name,
    'domain', domain_name,
    'concept', concept_name
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 5. Test the functions (uncomment to test)
-- SELECT * FROM get_session_questions('your-concept-id'::UUID, 5);
