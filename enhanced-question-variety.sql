-- Enhanced Question Rotation Strategy for Better Session Variety
-- This addresses the "same session 5x" issue by improving question selection

-- Create smarter question selection with micro-variety
CREATE OR REPLACE FUNCTION get_varied_session_questions(
    p_user_id UUID,
    p_certification_name TEXT,
    p_session_length INTEGER DEFAULT 12,
    p_exclude_hours INTEGER DEFAULT 4  -- Reduced from 24 to 4 hours
)
RETURNS TABLE(
    question_id UUID,
    question_text TEXT,
    concept_name TEXT,
    difficulty_level TEXT,
    tags TEXT[],
    selection_strategy TEXT
) AS $$
DECLARE
    total_questions INTEGER;
    questions_per_concept INTEGER;
BEGIN
    -- Calculate how many questions we need per concept for good distribution
    questions_per_concept := GREATEST(1, p_session_length / 8);  -- Spread across ~8 concepts
    
    RETURN QUERY
    WITH user_weak_areas AS (
        -- Identify concepts where user needs more practice
        SELECT 
            c.id as concept_id,
            c.name as concept_name,
            COALESCE(
                AVG(CASE WHEN uqa.is_correct THEN 1.0 ELSE 0.0 END), 
                0.5
            ) as success_rate,
            COUNT(uqa.id) as attempt_count,
            -- Priority weight: lower success rate = higher priority
            CASE 
                WHEN COUNT(uqa.id) = 0 THEN 1.0  -- Never practiced
                WHEN AVG(CASE WHEN uqa.is_correct THEN 1.0 ELSE 0.0 END) < 0.6 THEN 0.9
                WHEN AVG(CASE WHEN uqa.is_correct THEN 1.0 ELSE 0.0 END) < 0.8 THEN 0.7
                ELSE 0.5
            END as priority_weight
        FROM concepts c
        JOIN domains d ON d.id = c.domain_id
        JOIN certifications cert ON cert.id = d.certification_id
        LEFT JOIN questions q ON q.concept_id = c.id
        LEFT JOIN user_question_attempts uqa ON uqa.question_id = q.id 
            AND uqa.user_id = p_user_id
        WHERE cert.name = p_certification_name
        GROUP BY c.id, c.name
    ),
    available_questions AS (
        -- Get questions with variety filters
        SELECT 
            q.id,
            q.question_text,
            c.name as concept_name,
            q.difficulty_level,
            q.tags,
            uwa.priority_weight,
            -- Add variety strategies
            CASE 
                WHEN uqa.created_at IS NULL THEN 'new_question'
                WHEN uwa.success_rate < 0.6 THEN 'remediation_focus'
                WHEN uqa.created_at < NOW() - INTERVAL '3 days' THEN 'spaced_repetition'
                ELSE 'reinforcement'
            END as selection_strategy,
            -- Ranking for selection
            ROW_NUMBER() OVER (
                PARTITION BY c.id 
                ORDER BY 
                    uwa.priority_weight DESC,
                    CASE WHEN uqa.created_at IS NULL THEN 1 ELSE 0 END DESC,  -- Prefer new
                    ABS(EXTRACT(EPOCH FROM (NOW() - COALESCE(uqa.created_at, NOW() - INTERVAL '30 days')))) DESC, -- Spaced repetition
                    RANDOM()
            ) as concept_rank
        FROM questions q
        JOIN concepts c ON c.id = q.concept_id
        JOIN user_weak_areas uwa ON uwa.concept_id = c.id
        LEFT JOIN user_question_attempts uqa ON uqa.question_id = q.id 
            AND uqa.user_id = p_user_id
            AND uqa.created_at > NOW() - (p_exclude_hours || ' hours')::INTERVAL
        WHERE q.active = true
        AND EXISTS (
            SELECT 1 FROM answer_choices ac WHERE ac.question_id = q.id
        )
        -- Only exclude if recently attempted within exclusion window
        AND (uqa.id IS NULL OR uqa.created_at <= NOW() - (p_exclude_hours || ' hours')::INTERVAL)
    ),
    balanced_selection AS (
        -- Select questions ensuring variety and concept distribution
        SELECT 
            aq.id as question_id,
            aq.question_text,
            aq.concept_name,
            aq.difficulty_level,
            aq.tags,
            aq.selection_strategy,
            ROW_NUMBER() OVER (
                ORDER BY 
                    aq.priority_weight DESC,
                    aq.concept_rank ASC
            ) as final_rank
        FROM available_questions aq
        WHERE aq.concept_rank <= questions_per_concept  -- Limit per concept for variety
    )
    SELECT 
        bs.question_id,
        bs.question_text,
        bs.concept_name,
        bs.difficulty_level,
        bs.tags,
        bs.selection_strategy
    FROM balanced_selection bs
    WHERE bs.final_rank <= p_session_length
    ORDER BY bs.final_rank;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_varied_session_questions(UUID, TEXT, INTEGER, INTEGER) TO anon, authenticated;

-- Test the enhanced function
SELECT 'Enhanced question variety algorithm created!' as status;
SELECT 'Use get_varied_session_questions() for better session variety' as usage;
