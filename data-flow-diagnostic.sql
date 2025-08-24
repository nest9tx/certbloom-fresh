-- COMPREHENSIVE DATA FLOW DIAGNOSTIC
-- This will help us understand what's happening with session data and mandala updates

-- =============================================
-- STEP 1: CHECK ACTUAL DATA AFTER YOUR SESSIONS
-- =============================================

-- Check what sessions were actually saved
SELECT 
    'PRACTICE SESSIONS' as table_name,
    user_id,
    session_type,
    questions_answered,
    correct_answers,
    topics_covered,
    completed_at,
    created_at
FROM practice_sessions 
WHERE completed_at IS NOT NULL 
ORDER BY completed_at DESC 
LIMIT 10;

-- Check what user progress was created
SELECT 
    'USER PROGRESS' as table_name,
    user_id,
    topic,
    mastery_level,
    questions_attempted,
    questions_correct,
    last_practiced,
    created_at,
    updated_at
FROM user_progress 
ORDER BY updated_at DESC 
LIMIT 10;

-- =============================================
-- STEP 2: CHECK QUESTION QUALITY ISSUES
-- =============================================

-- Find questions without correct answers (data quality issue)
SELECT 
    'QUESTIONS WITHOUT CORRECT ANSWERS' as issue_type,
    q.id,
    q.question_text,
    COUNT(ac.id) as total_choices,
    COUNT(CASE WHEN ac.is_correct = true THEN 1 END) as correct_choices
FROM questions q
LEFT JOIN answer_choices ac ON q.id = ac.question_id
WHERE q.active = true
GROUP BY q.id, q.question_text
HAVING COUNT(CASE WHEN ac.is_correct = true THEN 1 END) = 0
ORDER BY q.question_text
LIMIT 5;

-- Find questions with incomplete choice sets
SELECT 
    'QUESTIONS WITH INCOMPLETE CHOICES' as issue_type,
    q.id,
    q.question_text,
    COUNT(ac.id) as total_choices
FROM questions q
LEFT JOIN answer_choices ac ON q.id = ac.question_id
WHERE q.active = true
GROUP BY q.id, q.question_text
HAVING COUNT(ac.id) < 4
ORDER BY COUNT(ac.id), q.question_text
LIMIT 5;

-- =============================================
-- STEP 3: TEST TRIGGER MANUALLY
-- =============================================

-- Insert a test session to see if trigger fires
DO $$
DECLARE
    test_user_id UUID;
    test_session_id UUID;
BEGIN
    -- Get a real user ID
    SELECT id INTO test_user_id FROM auth.users WHERE email_confirmed_at IS NOT NULL LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        -- Insert a test session
        INSERT INTO practice_sessions (
            user_id,
            session_type,
            questions_answered,
            correct_answers,
            topics_covered,
            mood_before,
            completed_at
        ) VALUES (
            test_user_id,
            'manual_test',
            5,
            4,
            ARRAY['Test Topic'],
            'focused',
            NOW()
        ) RETURNING id INTO test_session_id;
        
        RAISE NOTICE 'Inserted test session % for user %', test_session_id, test_user_id;
        
        -- Check if user_progress was updated
        IF EXISTS (
            SELECT 1 FROM user_progress 
            WHERE user_id = test_user_id 
            AND topic = 'Test Topic'
        ) THEN
            RAISE NOTICE '✅ Trigger worked - user_progress was updated';
        ELSE
            RAISE NOTICE '❌ Trigger failed - no user_progress created';
        END IF;
    ELSE
        RAISE NOTICE '❌ No confirmed users found for testing';
    END IF;
END $$;

-- =============================================
-- STEP 4: CHECK FRONTEND DATA ACCESS
-- =============================================

-- Create a function that mimics what the frontend should call
CREATE OR REPLACE FUNCTION get_user_dashboard_data(target_user_id UUID)
RETURNS TABLE(
    -- Session stats
    total_sessions INTEGER,
    total_questions INTEGER,
    total_correct INTEGER,
    overall_score DECIMAL,
    
    -- Progress data for mandala
    topic TEXT,
    mastery_level DECIMAL,
    questions_attempted INTEGER,
    questions_correct INTEGER,
    last_practiced TIMESTAMPTZ,
    needs_review BOOLEAN
) AS $$
BEGIN
    -- First return session summary
    RETURN QUERY
    SELECT 
        COUNT(*)::INTEGER as total_sessions,
        SUM(questions_answered)::INTEGER as total_questions,
        SUM(correct_answers)::INTEGER as total_correct,
        CASE 
            WHEN SUM(questions_answered) > 0 THEN 
                (SUM(correct_answers)::DECIMAL / SUM(questions_answered)::DECIMAL)
            ELSE 0
        END as overall_score,
        'SUMMARY'::TEXT as topic,
        0::DECIMAL as mastery_level,
        0::INTEGER as questions_attempted,
        0::INTEGER as questions_correct,
        NULL::TIMESTAMPTZ as last_practiced,
        false as needs_review
    FROM practice_sessions 
    WHERE user_id = target_user_id 
    AND completed_at IS NOT NULL;
    
    -- Then return progress data
    RETURN QUERY
    SELECT 
        0::INTEGER as total_sessions,
        0::INTEGER as total_questions, 
        0::INTEGER as total_correct,
        0::DECIMAL as overall_score,
        up.topic,
        up.mastery_level,
        up.questions_attempted,
        up.questions_correct,
        up.last_practiced,
        up.needs_review
    FROM user_progress up
    WHERE up.user_id = target_user_id
    ORDER BY up.last_practiced DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_user_dashboard_data(UUID) TO anon, authenticated;

-- Test the dashboard function
DO $$
DECLARE
    test_user_id UUID;
    dashboard_rec RECORD;
BEGIN
    SELECT id INTO test_user_id FROM auth.users WHERE email_confirmed_at IS NOT NULL LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        RAISE NOTICE 'Dashboard data for user %:', test_user_id;
        
        FOR dashboard_rec IN 
            SELECT * FROM get_user_dashboard_data(test_user_id)
        LOOP
            IF dashboard_rec.topic = 'SUMMARY' THEN
                RAISE NOTICE 'SUMMARY: % sessions, %/% correct (%%)', 
                    dashboard_rec.total_sessions,
                    dashboard_rec.total_correct,
                    dashboard_rec.total_questions,
                    ROUND(dashboard_rec.overall_score * 100, 1);
            ELSE
                RAISE NOTICE 'PROGRESS: % - %% mastery, %/% correct, last: %',
                    dashboard_rec.topic,
                    ROUND(dashboard_rec.mastery_level * 100, 1),
                    dashboard_rec.questions_correct,
                    dashboard_rec.questions_attempted,
                    dashboard_rec.last_practiced;
            END IF;
        END LOOP;
    END IF;
END $$;

-- =============================================
-- STEP 5: FIX QUESTION QUALITY ISSUES
-- =============================================

-- Update questions without correct answers to have at least one correct choice
UPDATE answer_choices 
SET is_correct = true 
WHERE question_id IN (
    SELECT q.id 
    FROM questions q
    LEFT JOIN answer_choices ac ON q.id = ac.question_id
    WHERE q.active = true
    GROUP BY q.id
    HAVING COUNT(CASE WHEN ac.is_correct = true THEN 1 END) = 0
)
AND choice_order = 1; -- Make the first choice correct for these broken questions

-- Report what was fixed
SELECT 
    '✅ QUESTIONS FIXED' as status,
    COUNT(*) as questions_fixed
FROM (
    SELECT DISTINCT ac.question_id
    FROM answer_choices ac
    INNER JOIN questions q ON ac.question_id = q.id
    WHERE ac.is_correct = true 
    AND ac.choice_order = 1
    AND q.active = true
) fixed_questions;

-- Final diagnostic summary
SELECT 
    'DIAGNOSTIC COMPLETE' as status,
    'Check the output above to understand data flow issues' as message;
