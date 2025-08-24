-- Fix 1: Update randomization function to use real answer_choices table
-- Fix 2: Ensure mandala refresh is working
-- Fix 3: Check session data connection

-- =============================================
-- FIX 1: PROPER ANSWER CHOICES INTEGRATION
-- =============================================

-- Drop and recreate the randomization function with real answer_choices
DROP FUNCTION IF EXISTS get_randomized_adaptive_questions(UUID, TEXT, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION get_randomized_adaptive_questions(
    session_user_id UUID,
    certification_name TEXT,
    session_length INTEGER,
    exclude_recent_hours INTEGER DEFAULT 24
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
    choice_a_id UUID,
    choice_a_text TEXT,
    choice_a_correct BOOLEAN,
    choice_b_id UUID,
    choice_b_text TEXT,
    choice_b_correct BOOLEAN,
    choice_c_id UUID,
    choice_c_text TEXT,
    choice_c_correct BOOLEAN,
    choice_d_id UUID,
    choice_d_text TEXT,
    choice_d_correct BOOLEAN
) AS $$
DECLARE
    cert_id UUID;
    available_questions INTEGER;
BEGIN
    -- Get certification ID
    SELECT c.id INTO cert_id
    FROM certifications c
    WHERE c.name = certification_name
    LIMIT 1;
    
    IF cert_id IS NULL THEN
        RAISE NOTICE 'No certification found for name: %', certification_name;
        RETURN;
    END IF;
    
    -- Count available questions with answer choices
    SELECT COUNT(DISTINCT q.id) INTO available_questions
    FROM questions q
    INNER JOIN answer_choices ac ON q.id = ac.question_id
    WHERE q.certification_id = cert_id
      AND q.active = true;
    
    RAISE NOTICE 'Found % questions with answer choices for certification %', available_questions, certification_name;
    
    IF available_questions = 0 THEN
        RAISE NOTICE 'No questions with answer choices found for certification %', certification_name;
        RETURN;
    END IF;
    
    -- Return randomized questions with real answer choices
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
        'General'::TEXT as topic_name,
        ac_a.id as choice_a_id,
        ac_a.choice_text as choice_a_text,
        ac_a.is_correct as choice_a_correct,
        ac_b.id as choice_b_id,
        ac_b.choice_text as choice_b_text,
        ac_b.is_correct as choice_b_correct,
        ac_c.id as choice_c_id,
        ac_c.choice_text as choice_c_text,
        ac_c.is_correct as choice_c_correct,
        ac_d.id as choice_d_id,
        ac_d.choice_text as choice_d_text,
        ac_d.is_correct as choice_d_correct
    FROM questions q
    LEFT JOIN answer_choices ac_a ON q.id = ac_a.question_id AND ac_a.choice_order = 1
    LEFT JOIN answer_choices ac_b ON q.id = ac_b.question_id AND ac_b.choice_order = 2
    LEFT JOIN answer_choices ac_c ON q.id = ac_c.question_id AND ac_c.choice_order = 3
    LEFT JOIN answer_choices ac_d ON q.id = ac_d.question_id AND ac_d.choice_order = 4
    WHERE q.certification_id = cert_id
      AND q.active = true
      AND EXISTS (
          SELECT 1 FROM answer_choices ac 
          WHERE ac.question_id = q.id
      )
    ORDER BY RANDOM()
    LIMIT session_length;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_randomized_adaptive_questions(UUID, TEXT, INTEGER, INTEGER) TO anon, authenticated;

-- =============================================
-- FIX 2: ENHANCE SESSION TRACKING FOR MANDALA
-- =============================================

-- Updated trigger to save better session data for mandala
CREATE OR REPLACE FUNCTION update_user_progress_from_session()
RETURNS TRIGGER AS $$
DECLARE
    correct_rate DECIMAL;
    mastery_boost DECIMAL;
    topic_name TEXT;
BEGIN
    -- Only proceed if this is a completed session
    IF NEW.completed_at IS NOT NULL AND NEW.questions_answered > 0 THEN
        
        -- Calculate overall performance for this session
        correct_rate := NEW.correct_answers::DECIMAL / NEW.questions_answered::DECIMAL;
        
        -- Determine mastery boost based on performance
        mastery_boost := CASE 
            WHEN correct_rate >= 0.8 THEN 0.1  -- Great performance: +10%
            WHEN correct_rate >= 0.6 THEN 0.05 -- Good performance: +5%
            WHEN correct_rate >= 0.4 THEN 0.02 -- Fair performance: +2%
            ELSE -0.02                          -- Poor performance: -2%
        END;
        
        -- Determine topic name (use first topic from session or certification type)
        topic_name := CASE 
            WHEN array_length(NEW.topics_covered, 1) > 0 THEN NEW.topics_covered[1]
            WHEN NEW.session_type IS NOT NULL THEN NEW.session_type
            ELSE 'General Practice'
        END;
        
        -- Update user progress for mandala visualization
        INSERT INTO user_progress (
            user_id,
            topic,
            mastery_level,
            questions_attempted,
            questions_correct,
            last_practiced,
            needs_review,
            created_at,
            updated_at
        ) VALUES (
            NEW.user_id,
            topic_name,
            GREATEST(0.0, LEAST(1.0, 0.5 + mastery_boost)), -- Start at 50% and adjust
            NEW.questions_answered,
            NEW.correct_answers,
            NEW.completed_at,
            (correct_rate < 0.6), -- Needs review if less than 60%
            NOW(),
            NOW()
        ) ON CONFLICT (user_id, topic) 
        DO UPDATE SET
            mastery_level = GREATEST(0.0, LEAST(1.0, user_progress.mastery_level + mastery_boost)),
            questions_attempted = user_progress.questions_attempted + NEW.questions_answered,
            questions_correct = user_progress.questions_correct + NEW.correct_answers,
            last_practiced = NEW.completed_at,
            needs_review = (
                (user_progress.questions_correct + NEW.correct_answers)::DECIMAL / 
                (user_progress.questions_attempted + NEW.questions_answered)::DECIMAL
            ) < 0.6,
            updated_at = NOW();
        
        RAISE NOTICE 'Updated user progress for user % on topic % with mastery boost % (session performance: %/%)', 
                     NEW.user_id, topic_name, mastery_boost, NEW.correct_answers, NEW.questions_answered;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- FIX 3: CHECK AND VERIFY DATA FLOW
-- =============================================

-- Diagnostic query to check current state
DO $$
DECLARE
    user_count INTEGER;
    session_count INTEGER;
    progress_count INTEGER;
    choice_count INTEGER;
    rec RECORD;
BEGIN
    SELECT COUNT(*) INTO user_count FROM auth.users WHERE email_confirmed_at IS NOT NULL;
    SELECT COUNT(*) INTO session_count FROM practice_sessions WHERE completed_at IS NOT NULL;
    SELECT COUNT(*) INTO progress_count FROM user_progress;
    SELECT COUNT(DISTINCT question_id) INTO choice_count FROM answer_choices;
    
    RAISE NOTICE '=== SYSTEM STATUS ===';
    RAISE NOTICE 'Confirmed users: %', user_count;
    RAISE NOTICE 'Completed sessions: %', session_count;
    RAISE NOTICE 'User progress records: %', progress_count;
    RAISE NOTICE 'Questions with answer choices: %', choice_count;
    
    -- Show recent sessions
    FOR rec IN 
        SELECT user_id, session_type, questions_answered, correct_answers, completed_at
        FROM practice_sessions 
        WHERE completed_at IS NOT NULL 
        ORDER BY completed_at DESC 
        LIMIT 3
    LOOP
        RAISE NOTICE 'Recent session: user=%, type=%, score=%/%, time=%', 
                     rec.user_id, rec.session_type, rec.correct_answers, rec.questions_answered, rec.completed_at;
    END LOOP;
    
    -- Show user progress
    FOR rec IN 
        SELECT user_id, topic, mastery_level, questions_correct, questions_attempted, last_practiced
        FROM user_progress 
        ORDER BY last_practiced DESC 
        LIMIT 5
    LOOP
        RAISE NOTICE 'User progress: user=%, topic=%, mastery=%, score=%/%, last=%', 
                     rec.user_id, rec.topic, rec.mastery_level, rec.questions_correct, rec.questions_attempted, rec.last_practiced;
    END LOOP;
END $$;

-- Test the updated function
DO $$
DECLARE
    test_result RECORD;
    question_count INTEGER := 0;
    test_user_id UUID;
BEGIN
    -- Get a real user ID for testing
    SELECT id INTO test_user_id FROM auth.users WHERE email_confirmed_at IS NOT NULL LIMIT 1;
    
    IF test_user_id IS NULL THEN
        test_user_id := '00000000-0000-0000-0000-000000000000'::UUID;
        RAISE NOTICE 'Using test UUID since no real users found: %', test_user_id;
    ELSE
        RAISE NOTICE 'Testing with real user: %', test_user_id;
    END IF;
    
    -- Test the function with proper answer choices
    FOR test_result IN 
        SELECT * FROM get_randomized_adaptive_questions(
            test_user_id, 
            'EC-6 Core Subjects', 
            3, 
            24
        )
    LOOP
        question_count := question_count + 1;
        RAISE NOTICE 'Question %: % | Choices: A=%, B=%, C=%, D=%', 
                     question_count, 
                     LEFT(test_result.question_text, 30),
                     LEFT(COALESCE(test_result.choice_a_text, 'NULL'), 15),
                     LEFT(COALESCE(test_result.choice_b_text, 'NULL'), 15),
                     LEFT(COALESCE(test_result.choice_c_text, 'NULL'), 15),
                     LEFT(COALESCE(test_result.choice_d_text, 'NULL'), 15);
    END LOOP;
    
    IF question_count = 0 THEN
        RAISE NOTICE '❌ No questions with answer choices returned';
    ELSE
        RAISE NOTICE '✅ Function returned % questions with answer choices', question_count;
    END IF;
END $$;

-- Final status
SELECT 
    '🎯 Enhanced Fix Complete' as status,
    'Answer choices integrated, mandala tracking enhanced, diagnostics run' as message;
