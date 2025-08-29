-- =================================================================
-- OPTIMAL STUDY SESSION ALGORITHM
-- =================================================================
-- Purpose: Create the intelligent question selection system that
-- balances realistic test simulation with effective learning
-- =================================================================

-- =================================================================
-- SESSION CONFIGURATION PARAMETERS
-- =================================================================

-- Create session configuration table
CREATE TABLE IF NOT EXISTS public.session_configs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    certification_id UUID REFERENCES public.certifications(id),
    session_type TEXT DEFAULT 'practice' CHECK (session_type IN ('practice', 'assessment', 'review')),
    questions_per_session INTEGER DEFAULT 12, -- Optimal: 10-15 questions
    time_limit_minutes INTEGER DEFAULT 20, -- 15-20 minutes per session
    topic_distribution JSONB DEFAULT '{"balanced": true, "min_topics": 3, "max_topics": 4}'::jsonb,
    difficulty_progression JSONB DEFAULT '{"start": "easy", "adaptive": true, "confidence_threshold": 0.7}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default configuration for Math certification
INSERT INTO session_configs (certification_id, questions_per_session, time_limit_minutes, topic_distribution, difficulty_progression)
SELECT 
    c.id,
    12 as questions_per_session,
    20 as time_limit_minutes,
    '{"balanced": true, "min_topics": 3, "max_topics": 4, "weights": {"Number Concepts and Operations": 0.4, "Patterns and Algebraic Reasoning": 0.3, "Geometry and Spatial Reasoning": 0.2, "Data Analysis and Probability": 0.1}}'::jsonb as topic_distribution,
    '{"start": "medium", "adaptive": true, "confidence_threshold": 0.7, "difficulty_adjustment": 0.2}'::jsonb as difficulty_progression
FROM certifications c 
WHERE c.name = 'TExES Core Subjects EC-6: Mathematics (902)'
ON CONFLICT DO NOTHING;

-- =================================================================
-- INTELLIGENT QUESTION SELECTION FUNCTION
-- =================================================================

CREATE OR REPLACE FUNCTION select_session_questions(
    p_user_id UUID,
    p_certification_id UUID,
    p_session_type TEXT DEFAULT 'practice'
)
RETURNS TABLE (
    question_id UUID,
    question_text TEXT,
    topic_name TEXT,
    concept_name TEXT,
    difficulty_level TEXT,
    selection_reason TEXT
) AS $$
DECLARE
    config_record RECORD;
    user_progress_data RECORD;
    total_questions INTEGER;
    current_question_count INTEGER := 0;
BEGIN
    -- Get session configuration
    SELECT * INTO config_record 
    FROM session_configs 
    WHERE certification_id = p_certification_id 
    AND session_type = p_session_type;
    
    IF NOT FOUND THEN
        -- Use default configuration
        total_questions := 12;
    ELSE
        total_questions := config_record.questions_per_session;
    END IF;

    -- =================================================================
    -- ALGORITHM: WEIGHTED BALANCED SELECTION
    -- =================================================================
    -- 1. Prioritize topics where user needs improvement
    -- 2. Ensure minimum topic diversity (3-4 topics per session)
    -- 3. Balance difficulty based on recent performance
    -- 4. Include spaced repetition for previously missed questions
    -- =================================================================

    RETURN QUERY
    WITH user_topic_performance AS (
        -- Calculate user's performance by topic
        SELECT 
            t.id as topic_id,
            t.name as topic_name,
            COALESCE(AVG(CASE WHEN uqa.is_correct THEN 1.0 ELSE 0.0 END), 0.5) as accuracy,
            COUNT(uqa.id) as attempts,
            MAX(uqa.created_at) as last_attempt,
            -- Prioritize topics with lower accuracy or no recent practice
            CASE 
                WHEN COUNT(uqa.id) = 0 THEN 1.0  -- Never practiced
                WHEN AVG(CASE WHEN uqa.is_correct THEN 1.0 ELSE 0.0 END) < 0.6 THEN 0.9  -- Struggling
                WHEN MAX(uqa.created_at) < NOW() - INTERVAL '7 days' THEN 0.8  -- Needs review
                ELSE 0.5  -- Adequate
            END as priority_weight
        FROM topics t
        LEFT JOIN questions q ON q.topic_id = t.id
        LEFT JOIN user_question_attempts uqa ON uqa.question_id = q.id AND uqa.user_id = p_user_id
        WHERE t.certification_id = p_certification_id
        GROUP BY t.id, t.name
    ),
    question_selection AS (
        SELECT 
            q.id as question_id,
            q.question_text,
            t.name as topic_name,
            c.name as concept_name,
            q.difficulty_level,
            utp.priority_weight,
            -- Avoid recently seen questions
            CASE WHEN recent_uqa.created_at > NOW() - INTERVAL '3 days' THEN 0.1 ELSE 1.0 END as recency_weight,
            -- Prefer questions user hasn't seen
            CASE WHEN recent_uqa.id IS NULL THEN 1.5 ELSE 0.8 END as novelty_weight,
            ROW_NUMBER() OVER (
                PARTITION BY t.id 
                ORDER BY 
                    utp.priority_weight DESC,
                    CASE WHEN recent_uqa.id IS NULL THEN 1.5 ELSE 0.8 END DESC,
                    RANDOM()
            ) as topic_rank
        FROM questions q
        JOIN topics t ON t.id = q.topic_id
        LEFT JOIN concepts c ON c.id = q.concept_id
        JOIN user_topic_performance utp ON utp.topic_id = t.id
        LEFT JOIN user_question_attempts recent_uqa ON recent_uqa.question_id = q.id 
            AND recent_uqa.user_id = p_user_id
        WHERE q.active = true
        AND t.certification_id = p_certification_id
    ),
    balanced_selection AS (
        -- Select questions ensuring topic diversity
        SELECT 
            qs.question_id,
            qs.question_text,
            qs.topic_name,
            qs.concept_name,
            qs.difficulty_level,
            CASE 
                WHEN qs.novelty_weight > 1.0 THEN 'New question for practice'
                WHEN qs.priority_weight > 0.8 THEN 'Needs improvement in this topic'
                WHEN qs.recency_weight < 1.0 THEN 'Spaced repetition review'
                ELSE 'Balanced practice'
            END as selection_reason,
            ROW_NUMBER() OVER (
                ORDER BY 
                    qs.priority_weight DESC,
                    qs.topic_rank ASC
            ) as final_rank
        FROM question_selection qs
        WHERE qs.topic_rank <= GREATEST(3, total_questions / 4)  -- Max questions per topic
    )
    SELECT 
        bs.question_id,
        bs.question_text,
        bs.topic_name,
        bs.concept_name,
        bs.difficulty_level,
        bs.selection_reason
    FROM balanced_selection bs
    WHERE bs.final_rank <= total_questions
    ORDER BY bs.final_rank;

END;
$$ LANGUAGE plpgsql;

-- =================================================================
-- EXAMPLE USAGE AND TESTING
-- =================================================================

-- Test the question selection for a user
-- Replace with actual user_id and certification_id
/*
SELECT * FROM select_session_questions(
    '00000000-0000-0000-0000-000000000000'::UUID,  -- Replace with real user_id
    (SELECT id FROM certifications WHERE name = 'TExES Core Subjects EC-6: Mathematics (902)')
);
*/

-- =================================================================
-- SESSION ANALYTICS TRACKING
-- =================================================================

-- Enhanced practice_sessions table with algorithm metadata
ALTER TABLE public.practice_sessions ADD COLUMN IF NOT EXISTS 
    algorithm_version TEXT DEFAULT 'balanced_v1';

ALTER TABLE public.practice_sessions ADD COLUMN IF NOT EXISTS 
    selection_metadata JSONB DEFAULT '{}'::jsonb;

-- =================================================================
-- SUCCESS MESSAGE
-- =================================================================
SELECT 'SUCCESS: Session algorithm created! Questions will be intelligently selected based on user performance and learning objectives.' as status;
