-- COMPREHENSIVE DATA CONNECTION FIX
-- This connects session data to dashboard placeholders and fixes data quality

-- =============================================
-- FIX 1: CREATE DASHBOARD DATA FUNCTIONS
-- =============================================

-- Function to get user's overall stats (for dashboard cards)
CREATE OR REPLACE FUNCTION get_user_stats(target_user_id UUID)
RETURNS TABLE(
    total_sessions INTEGER,
    total_questions INTEGER,
    total_correct INTEGER,
    current_streak INTEGER,
    weekly_goal_progress DECIMAL,
    overall_readiness DECIMAL
) AS $$
DECLARE
    session_data RECORD;
    streak_count INTEGER := 0;
    last_date DATE;
    current_date DATE;
BEGIN
    -- Get overall session statistics
    SELECT 
        COUNT(*)::INTEGER,
        COALESCE(SUM(questions_answered), 0)::INTEGER,
        COALESCE(SUM(correct_answers), 0)::INTEGER
    INTO total_sessions, total_questions, total_correct
    FROM practice_sessions 
    WHERE user_id = target_user_id 
    AND completed_at IS NOT NULL;
    
    -- Calculate current streak (consecutive days with sessions)
    current_streak := 0;
    last_date := NULL;
    
    FOR session_data IN
        SELECT DISTINCT DATE(completed_at) as session_date
        FROM practice_sessions 
        WHERE user_id = target_user_id 
        AND completed_at IS NOT NULL
        ORDER BY session_date DESC
    LOOP
        current_date := session_data.session_date;
        
        IF last_date IS NULL THEN
            -- First session in streak
            IF current_date = CURRENT_DATE OR current_date = CURRENT_DATE - 1 THEN
                streak_count := streak_count + 1;
                last_date := current_date;
            ELSE
                -- Streak broken
                EXIT;
            END IF;
        ELSIF current_date = last_date - 1 THEN
            -- Consecutive day
            streak_count := streak_count + 1;
            last_date := current_date;
        ELSE
            -- Gap in streak
            EXIT;
        END IF;
    END LOOP;
    
    current_streak := streak_count;
    
    -- Calculate weekly goal progress (assume goal of 5 sessions per week)
    SELECT COUNT(*)::DECIMAL / 5.0 INTO weekly_goal_progress
    FROM practice_sessions 
    WHERE user_id = target_user_id 
    AND completed_at >= CURRENT_DATE - INTERVAL '7 days'
    AND completed_at IS NOT NULL;
    
    weekly_goal_progress := LEAST(1.0, weekly_goal_progress);
    
    -- Calculate overall readiness (based on recent performance)
    SELECT 
        CASE 
            WHEN SUM(questions_answered) > 0 THEN 
                SUM(correct_answers)::DECIMAL / SUM(questions_answered)::DECIMAL
            ELSE 0.5
        END 
    INTO overall_readiness
    FROM practice_sessions 
    WHERE user_id = target_user_id 
    AND completed_at >= CURRENT_DATE - INTERVAL '30 days'
    AND completed_at IS NOT NULL;
    
    RETURN QUERY SELECT 
        total_sessions,
        total_questions,
        total_correct,
        current_streak,
        weekly_goal_progress,
        COALESCE(overall_readiness, 0.5);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get wellness/mind & spirit score
CREATE OR REPLACE FUNCTION get_user_wellness(target_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    wellness_score INTEGER;
    recent_sessions INTEGER;
    mood_variance DECIMAL;
BEGIN
    -- Calculate wellness based on consistency and mood stability
    SELECT COUNT(*) INTO recent_sessions
    FROM practice_sessions 
    WHERE user_id = target_user_id 
    AND completed_at >= CURRENT_DATE - INTERVAL '7 days'
    AND completed_at IS NOT NULL;
    
    -- Base score on recent activity (0-40 points)
    wellness_score := LEAST(40, recent_sessions * 8);
    
    -- Add points for consistency (0-30 points)
    IF recent_sessions >= 5 THEN
        wellness_score := wellness_score + 30;
    ELSIF recent_sessions >= 3 THEN
        wellness_score := wellness_score + 20;
    ELSIF recent_sessions >= 1 THEN
        wellness_score := wellness_score + 10;
    END IF;
    
    -- Add points for mood stability (0-30 points)
    -- For now, give a bonus if user has any mood data
    IF EXISTS (
        SELECT 1 FROM practice_sessions 
        WHERE user_id = target_user_id 
        AND mood_before IS NOT NULL
    ) THEN
        wellness_score := wellness_score + 15;
    END IF;
    
    RETURN LEAST(100, wellness_score);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_user_stats(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_user_wellness(UUID) TO anon, authenticated;

-- =============================================
-- FIX 2: IMPROVE SESSION DATA RECORDING
-- =============================================

-- Enhanced trigger to record more comprehensive session data
CREATE OR REPLACE FUNCTION update_user_progress_from_session()
RETURNS TRIGGER AS $$
DECLARE
    correct_rate DECIMAL;
    mastery_boost DECIMAL;
    topic_name TEXT;
    performance_category TEXT;
BEGIN
    -- Only proceed if this is a completed session
    IF NEW.completed_at IS NOT NULL AND NEW.questions_answered > 0 THEN
        
        -- Calculate overall performance for this session
        correct_rate := NEW.correct_answers::DECIMAL / NEW.questions_answered::DECIMAL;
        
        -- Categorize performance
        performance_category := CASE 
            WHEN correct_rate >= 0.8 THEN 'excellent'
            WHEN correct_rate >= 0.6 THEN 'good'
            WHEN correct_rate >= 0.4 THEN 'fair'
            ELSE 'needs_improvement'
        END;
        
        -- Determine mastery boost based on performance
        mastery_boost := CASE 
            WHEN correct_rate >= 0.8 THEN 0.08  -- Great performance: +8%
            WHEN correct_rate >= 0.6 THEN 0.04  -- Good performance: +4%
            WHEN correct_rate >= 0.4 THEN 0.02  -- Fair performance: +2%
            ELSE -0.01                           -- Poor performance: -1%
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
            streak_days,
            difficulty_preference,
            created_at,
            updated_at,
            petal_stage,
            bloom_level,
            confidence_trend,
            energy_level
        ) VALUES (
            NEW.user_id,
            topic_name,
            GREATEST(0.0, LEAST(1.0, 0.3 + mastery_boost)), -- Start at 30% and adjust
            NEW.questions_answered,
            NEW.correct_answers,
            NEW.completed_at,
            (correct_rate < 0.6), -- Needs review if less than 60%
            1, -- Will be calculated properly later
            performance_category,
            NOW(),
            NOW(),
            CASE 
                WHEN correct_rate >= 0.8 THEN 'blooming'
                WHEN correct_rate >= 0.6 THEN 'budding'
                ELSE 'dormant'
            END,
            CASE 
                WHEN correct_rate >= 0.8 THEN 'radiant'
                WHEN correct_rate >= 0.6 THEN 'bright'
                ELSE 'dim'
            END,
            correct_rate,
            LEAST(1.0, correct_rate + 0.2) -- Energy level
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
            difficulty_preference = performance_category,
            updated_at = NOW(),
            petal_stage = CASE 
                WHEN (user_progress.questions_correct + NEW.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + NEW.questions_answered)::DECIMAL >= 0.8 THEN 'blooming'
                WHEN (user_progress.questions_correct + NEW.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + NEW.questions_answered)::DECIMAL >= 0.6 THEN 'budding'
                ELSE 'dormant'
            END,
            bloom_level = CASE 
                WHEN (user_progress.questions_correct + NEW.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + NEW.questions_answered)::DECIMAL >= 0.8 THEN 'radiant'
                WHEN (user_progress.questions_correct + NEW.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + NEW.questions_answered)::DECIMAL >= 0.6 THEN 'bright'
                ELSE 'dim'
            END,
            confidence_trend = (
                (user_progress.questions_correct + NEW.correct_answers)::DECIMAL / 
                (user_progress.questions_attempted + NEW.questions_answered)::DECIMAL
            ),
            energy_level = LEAST(1.0, (
                (user_progress.questions_correct + NEW.correct_answers)::DECIMAL / 
                (user_progress.questions_attempted + NEW.questions_answered)::DECIMAL
            ) + 0.2);
        
        RAISE NOTICE 'Enhanced progress update: user=%, topic=%, performance=%, mastery_boost=%', 
                     NEW.user_id, topic_name, performance_category, mastery_boost;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- FIX 3: CREATE API FUNCTIONS FOR FRONTEND
-- =============================================

-- Single function to get all dashboard data
CREATE OR REPLACE FUNCTION get_complete_dashboard_data(target_user_id UUID)
RETURNS JSON AS $$
DECLARE
    user_stats RECORD;
    wellness_score INTEGER;
    progress_data JSON;
    result JSON;
BEGIN
    -- Get user statistics
    SELECT * INTO user_stats FROM get_user_stats(target_user_id);
    
    -- Get wellness score
    SELECT get_user_wellness(target_user_id) INTO wellness_score;
    
    -- Get progress data as JSON
    SELECT json_agg(row_to_json(up)) INTO progress_data
    FROM (
        SELECT 
            topic,
            mastery_level,
            questions_attempted,
            questions_correct,
            last_practiced,
            needs_review,
            petal_stage,
            bloom_level,
            confidence_trend,
            energy_level
        FROM user_progress 
        WHERE user_id = target_user_id
        ORDER BY last_practiced DESC
    ) up;
    
    -- Combine all data
    result := json_build_object(
        'stats', json_build_object(
            'total_sessions', user_stats.total_sessions,
            'total_questions', user_stats.total_questions,
            'total_correct', user_stats.total_correct,
            'current_streak', user_stats.current_streak,
            'weekly_goal_progress', ROUND(user_stats.weekly_goal_progress * 100),
            'overall_readiness', ROUND(user_stats.overall_readiness * 100),
            'wellness_score', wellness_score
        ),
        'progress', COALESCE(progress_data, '[]'::json)
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_complete_dashboard_data(UUID) TO anon, authenticated;

-- =============================================
-- FIX 4: TEST THE COMPLETE SYSTEM
-- =============================================

-- Test with a real user
DO $$
DECLARE
    test_user_id UUID;
    dashboard_json JSON;
BEGIN
    SELECT id INTO test_user_id FROM auth.users WHERE email_confirmed_at IS NOT NULL LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        RAISE NOTICE 'Testing complete dashboard system for user: %', test_user_id;
        
        -- Get complete dashboard data
        SELECT get_complete_dashboard_data(test_user_id) INTO dashboard_json;
        
        RAISE NOTICE 'Dashboard JSON: %', dashboard_json;
        
        RAISE NOTICE '✅ Dashboard data function working';
    ELSE
        RAISE NOTICE '❌ No confirmed users found for testing';
    END IF;
END $$;

-- Final status
SELECT 
    '🎯 Complete Data Connection Fix Applied' as status,
    'Dashboard placeholders now connected to real user data' as message;
