-- Mandala Data Update Fix
-- This ensures that practice session completion updates user progress for mandala visualization

-- Function to update user progress based on practice session data
CREATE OR REPLACE FUNCTION update_user_progress_from_session()
RETURNS TRIGGER AS $$
DECLARE
    topic_name TEXT;
    correct_rate DECIMAL;
    mastery_boost DECIMAL;
BEGIN
    -- Only proceed if this is a completed session
    IF NEW.completed_at IS NOT NULL AND NEW.questions_attempted > 0 THEN
        
        -- Calculate overall performance for this session
        correct_rate := NEW.questions_correct::DECIMAL / NEW.questions_attempted::DECIMAL;
        
        -- Determine mastery boost based on performance
        mastery_boost := CASE 
            WHEN correct_rate >= 0.8 THEN 0.1  -- Great performance: +10%
            WHEN correct_rate >= 0.6 THEN 0.05 -- Good performance: +5%
            WHEN correct_rate >= 0.4 THEN 0.02 -- Fair performance: +2%
            ELSE -0.02                          -- Poor performance: -2%
        END;
        
        -- For now, update a general progress entry for the certification
        -- In the future, this could be more granular per topic
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
            COALESCE(NEW.certification_name, 'General'),
            GREATEST(0.0, LEAST(1.0, 0.5 + mastery_boost)), -- Start at 50% and adjust
            NEW.questions_attempted,
            NEW.questions_correct,
            NEW.completed_at,
            (correct_rate < 0.6), -- Needs review if less than 60%
            NOW(),
            NOW()
        ) ON CONFLICT (user_id, topic) 
        DO UPDATE SET
            mastery_level = GREATEST(0.0, LEAST(1.0, user_progress.mastery_level + mastery_boost)),
            questions_attempted = user_progress.questions_attempted + NEW.questions_attempted,
            questions_correct = user_progress.questions_correct + NEW.questions_correct,
            last_practiced = NEW.completed_at,
            needs_review = (
                (user_progress.questions_correct + NEW.questions_correct)::DECIMAL / 
                (user_progress.questions_attempted + NEW.questions_attempted)::DECIMAL
            ) < 0.6,
            updated_at = NOW();
        
        -- Also ensure we have individual question attempts recorded
        -- This trigger is just for overall progress tracking
        
        RAISE NOTICE 'Updated user progress for user % on topic % with mastery boost %', 
                     NEW.user_id, COALESCE(NEW.certification_name, 'General'), mastery_boost;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_progress_from_session ON practice_sessions;

-- Create trigger for practice session completion
CREATE TRIGGER update_progress_from_session
    AFTER INSERT OR UPDATE ON practice_sessions
    FOR EACH ROW
    WHEN (NEW.completed_at IS NOT NULL)
    EXECUTE FUNCTION update_user_progress_from_session();

-- Also create a simple function to refresh mandala data manually
CREATE OR REPLACE FUNCTION refresh_mandala_data(target_user_id UUID)
RETURNS TABLE(
    topic TEXT,
    mastery_level DECIMAL,
    questions_attempted INTEGER,
    questions_correct INTEGER,
    last_practiced TIMESTAMP WITH TIME ZONE,
    needs_review BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
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
GRANT EXECUTE ON FUNCTION refresh_mandala_data(UUID) TO anon, authenticated;

-- Test the trigger setup
SELECT 
    'Mandala update trigger created successfully' as status,
    'Practice sessions will now update user progress automatically' as message;
