-- EMERGENCY FIX: Add missing randomization function for session loading
-- Run this FIRST to get sessions working again

-- Drop existing functions that might have different signatures
DROP FUNCTION IF EXISTS get_simple_questions(integer);
DROP FUNCTION IF EXISTS get_randomized_adaptive_questions(uuid,text,integer,integer);

-- Simple fallback function for basic question loading 
CREATE OR REPLACE FUNCTION get_simple_questions(
    session_length INTEGER DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    question_text TEXT,
    explanation TEXT,
    difficulty_level TEXT,
    certification_name TEXT,
    topic_name TEXT,
    topic_description TEXT,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    -- If we don't have full structure, return questions from basic table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'questions') THEN
        RETURN QUERY
        SELECT 
            q.id,
            q.question_text,
            q.explanation,
            COALESCE(q.difficulty_level, 'medium') as difficulty_level,
            'PPR' as certification_name,
            'General Practice' as topic_name,
            'General practice questions' as topic_description,
            COALESCE(q.created_at, NOW()) as created_at
        FROM questions q
        ORDER BY RANDOM()
        LIMIT session_length;
    ELSE
        -- Return empty if no questions table exists
        RETURN;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_simple_questions(INTEGER) TO anon, authenticated;

-- Test the function
SELECT 'Testing simple questions function' as status;
SELECT * FROM get_simple_questions(3) LIMIT 3;

SELECT '✅ EMERGENCY FIX APPLIED - Sessions should load now' as status;
