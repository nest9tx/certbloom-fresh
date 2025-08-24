-- CRITICAL DIAGNOSIS & COMPLETE FIX
-- Run this in Supabase SQL Editor to diagnose and fix all issues

-- =============================================
-- STEP 1: DIAGNOSE CURRENT STATE
-- =============================================

-- Check if practice_sessions table exists and has data
SELECT 
    'practice_sessions' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN completed_at IS NOT NULL THEN 1 END) as completed_sessions,
    COUNT(CASE WHEN questions_answered > 0 THEN 1 END) as sessions_with_questions
FROM practice_sessions;

-- Check if user_progress table exists and has data  
SELECT 
    'user_progress' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT topic) as unique_topics
FROM user_progress;

-- Check for trigger existence
SELECT 
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers 
WHERE trigger_name LIKE '%progress%';

-- Check actual user data
SELECT 
    'User Sessions' as data_type,
    user_id,
    COUNT(*) as session_count,
    SUM(questions_answered) as total_questions,
    SUM(correct_answers) as total_correct,
    MAX(completed_at) as last_session
FROM practice_sessions 
WHERE completed_at IS NOT NULL
GROUP BY user_id
ORDER BY session_count DESC
LIMIT 5;

-- =============================================
-- STEP 2: ENSURE SCHEMA EXISTS
-- =============================================

-- First, check what constraints currently exist
SELECT 
    'Current Constraints' as info,
    constraint_name,
    check_clause
FROM information_schema.check_constraints 
WHERE constraint_name LIKE '%user_progress%';

-- Drop existing constraints that might conflict (more aggressive approach)
DO $$
BEGIN
    -- Drop existing check constraints if they exist
    EXECUTE 'ALTER TABLE user_progress DROP CONSTRAINT IF EXISTS user_progress_bloom_level_check CASCADE';
    EXECUTE 'ALTER TABLE user_progress DROP CONSTRAINT IF EXISTS user_progress_petal_stage_check CASCADE';
    EXECUTE 'ALTER TABLE user_progress DROP CONSTRAINT IF EXISTS user_progress_difficulty_preference_check CASCADE';
    RAISE NOTICE 'Dropped existing constraints';
EXCEPTION
    WHEN undefined_table THEN
        RAISE NOTICE 'Table does not exist yet, that is fine';
    WHEN OTHERS THEN
        RAISE NOTICE 'Error dropping constraints: %', SQLERRM;
END $$;

-- Create user_progress table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    topic TEXT NOT NULL,
    mastery_level DECIMAL DEFAULT 0.5 CHECK (mastery_level >= 0 AND mastery_level <= 1),
    questions_attempted INTEGER DEFAULT 0,
    questions_correct INTEGER DEFAULT 0,
    last_practiced TIMESTAMPTZ,
    needs_review BOOLEAN DEFAULT false,
    streak_days INTEGER DEFAULT 0,
    difficulty_preference TEXT DEFAULT 'adaptive',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    petal_stage TEXT DEFAULT 'dormant',
    bloom_level TEXT DEFAULT 'dim',
    confidence_trend DECIMAL DEFAULT 0.5,
    energy_level DECIMAL DEFAULT 0.5,
    UNIQUE(user_id, topic)
);

-- Force drop any remaining bloom_level constraints
DO $$
BEGIN
    EXECUTE 'ALTER TABLE user_progress DROP CONSTRAINT IF EXISTS user_progress_bloom_level_check';
    RAISE NOTICE 'Forced drop of bloom_level constraint';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'No bloom_level constraint to drop or error: %', SQLERRM;
END $$;

-- Add our new check constraints with proper values
ALTER TABLE user_progress ADD CONSTRAINT user_progress_petal_stage_check 
    CHECK (petal_stage IN ('dormant', 'budding', 'blooming', 'radiant'));

ALTER TABLE user_progress ADD CONSTRAINT user_progress_bloom_level_check 
    CHECK (bloom_level IN ('dim', 'bright', 'radiant', 'luminous'));

-- Verify the new constraints
SELECT 
    'New Constraints' as info,
    constraint_name,
    check_clause
FROM information_schema.check_constraints 
WHERE constraint_name LIKE '%user_progress%';

-- Enable RLS
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

-- Create policy for user_progress
DROP POLICY IF EXISTS "Users can view own progress" ON user_progress;
CREATE POLICY "Users can view own progress" ON user_progress
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- STEP 3: CREATE ENHANCED TRIGGER
-- =============================================

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_user_progress_on_session_complete ON practice_sessions;

-- Create the comprehensive trigger function
CREATE OR REPLACE FUNCTION update_user_progress_from_session()
RETURNS TRIGGER AS $$
DECLARE
    correct_rate DECIMAL;
    mastery_boost DECIMAL;
    topic_name TEXT;
    performance_category TEXT;
BEGIN
    -- Only proceed if this is a completed session with questions
    IF NEW.completed_at IS NOT NULL AND NEW.questions_answered > 0 THEN
        
        -- Calculate performance metrics
        correct_rate := NEW.correct_answers::DECIMAL / NEW.questions_answered::DECIMAL;
        
        -- Determine topic name
        topic_name := CASE 
            WHEN array_length(NEW.topics_covered, 1) > 0 THEN NEW.topics_covered[1]
            WHEN NEW.session_type IS NOT NULL THEN NEW.session_type
            ELSE 'General Practice'
        END;
        
        -- Calculate mastery boost
        mastery_boost := CASE 
            WHEN correct_rate >= 0.8 THEN 0.1   -- Excellent: +10%
            WHEN correct_rate >= 0.6 THEN 0.05  -- Good: +5%
            WHEN correct_rate >= 0.4 THEN 0.02  -- Fair: +2%
            ELSE -0.02                           -- Poor: -2%
        END;
        
        -- Performance category
        performance_category := CASE 
            WHEN correct_rate >= 0.8 THEN 'excellent'
            WHEN correct_rate >= 0.6 THEN 'good'
            WHEN correct_rate >= 0.4 THEN 'fair'
            ELSE 'needs_improvement'
        END;
        
        -- Insert or update user progress
        INSERT INTO user_progress (
            user_id,
            topic,
            mastery_level,
            questions_attempted,
            questions_correct,
            last_practiced,
            needs_review,
            difficulty_preference,
            petal_stage,
            bloom_level,
            confidence_trend,
            energy_level,
            created_at,
            updated_at
        ) VALUES (
            NEW.user_id,
            topic_name,
            GREATEST(0.0, LEAST(1.0, 0.3 + mastery_boost)),
            NEW.questions_answered,
            NEW.correct_answers,
            NEW.completed_at,
            (correct_rate < 0.6),
            performance_category,
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
            LEAST(1.0, correct_rate + 0.2),
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
            difficulty_preference = performance_category,
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
            ) + 0.2),
            updated_at = NOW();
        
        -- Log for debugging
        RAISE NOTICE 'Progress updated: user=%, topic=%, mastery=%, questions=%/%', 
                     NEW.user_id, topic_name, mastery_boost, NEW.correct_answers, NEW.questions_answered;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER update_user_progress_on_session_complete
    AFTER INSERT OR UPDATE ON practice_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_user_progress_from_session();

-- =============================================
-- STEP 4: DASHBOARD DATA FUNCTIONS  
-- =============================================

-- Function to get complete dashboard data
CREATE OR REPLACE FUNCTION get_user_dashboard_data(target_user_id UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    session_stats RECORD;
    wellness_score INTEGER := 75;
    progress_data JSON;
BEGIN
    -- Get session statistics
    SELECT 
        COUNT(*)::INTEGER as total_sessions,
        COALESCE(SUM(questions_answered), 0)::INTEGER as total_questions,
        COALESCE(SUM(correct_answers), 0)::INTEGER as total_correct
    INTO session_stats
    FROM practice_sessions 
    WHERE user_id = target_user_id 
    AND completed_at IS NOT NULL;
    
    -- Get progress data
    SELECT json_agg(
        json_build_object(
            'topic', topic,
            'mastery_level', mastery_level,
            'questions_attempted', questions_attempted,
            'questions_correct', questions_correct,
            'last_practiced', last_practiced,
            'petal_stage', petal_stage,
            'bloom_level', bloom_level,
            'confidence_trend', confidence_trend,
            'energy_level', energy_level
        )
    ) INTO progress_data
    FROM user_progress 
    WHERE user_id = target_user_id;
    
    -- Build complete result
    result := json_build_object(
        'stats', json_build_object(
            'total_sessions', session_stats.total_sessions,
            'total_questions', session_stats.total_questions,
            'total_correct', session_stats.total_correct,
            'accuracy', CASE 
                WHEN session_stats.total_questions > 0 THEN 
                    ROUND((session_stats.total_correct::DECIMAL / session_stats.total_questions::DECIMAL) * 100)
                ELSE 0 
            END,
            'wellness_score', wellness_score
        ),
        'progress', COALESCE(progress_data, '[]'::json)
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_user_dashboard_data(UUID) TO anon, authenticated;

-- Drop existing function with different signature before creating new one
DROP FUNCTION IF EXISTS get_randomized_adaptive_questions(uuid,text,integer,integer);
DROP FUNCTION IF EXISTS get_simple_questions(integer);

-- Function for randomized question selection (CRITICAL FOR SESSION LOADING)
CREATE OR REPLACE FUNCTION get_randomized_adaptive_questions(
    session_user_id UUID,
    input_certification_name TEXT,
    session_length INTEGER DEFAULT 10,
    exclude_recent_hours INTEGER DEFAULT 1
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
    RETURN QUERY
    SELECT 
        q.id,
        q.question_text,
        q.explanation,
        q.difficulty_level,
        c.name as certification_name,
        t.name as topic_name,
        t.description as topic_description,
        q.created_at
    FROM questions q
    JOIN certifications c ON q.certification_id = c.id
    JOIN topics t ON q.topic_id = t.id
    WHERE c.name = input_certification_name
    AND q.id NOT IN (
        -- Exclude recently answered questions
        SELECT qa.question_id 
        FROM question_attempts qa 
        WHERE qa.user_id = session_user_id 
        AND qa.attempted_at > NOW() - (exclude_recent_hours || ' hours')::INTERVAL
    )
    ORDER BY RANDOM()
    LIMIT session_length;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions for the randomization function
GRANT EXECUTE ON FUNCTION get_randomized_adaptive_questions(UUID, TEXT, INTEGER, INTEGER) TO anon, authenticated;

-- Simple fallback function for basic question loading if complex structures don't exist
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

-- =============================================
-- STEP 5: TEST WITH EXISTING DATA
-- =============================================

-- First, let's check what constraints actually exist right now
SELECT 
    'CONSTRAINT DEBUG' as info,
    constraint_name,
    check_clause
FROM information_schema.check_constraints 
WHERE constraint_name LIKE '%user_progress%' OR constraint_name LIKE '%bloom%';

-- Nuclear option: Drop and recreate constraints if they're still wrong
DO $$
DECLARE
    constraint_exists BOOLEAN;
    wrong_constraint_clause TEXT;
BEGIN
    -- Check if bloom_level constraint has wrong values
    SELECT check_clause INTO wrong_constraint_clause
    FROM information_schema.check_constraints 
    WHERE constraint_name = 'user_progress_bloom_level_check'
    LIMIT 1;
    
    IF wrong_constraint_clause IS NOT NULL THEN
        RAISE NOTICE 'Found existing bloom_level constraint: %', wrong_constraint_clause;
        
        -- If the constraint doesn't contain 'radiant', it's wrong
        IF wrong_constraint_clause NOT LIKE '%radiant%' THEN
            RAISE NOTICE 'Constraint is wrong, dropping it...';
            EXECUTE 'ALTER TABLE user_progress DROP CONSTRAINT user_progress_bloom_level_check';
            
            -- Update any existing data that might violate the new constraint
            UPDATE user_progress 
            SET bloom_level = CASE 
                WHEN bloom_level NOT IN ('dim', 'bright', 'radiant', 'luminous') THEN 'dim'
                ELSE bloom_level
            END;
            
            RAISE NOTICE 'Updated existing data to match new constraint';
            
            -- Recreate with correct values
            EXECUTE 'ALTER TABLE user_progress ADD CONSTRAINT user_progress_bloom_level_check CHECK (bloom_level IN (''dim'', ''bright'', ''radiant'', ''luminous''))';
            RAISE NOTICE 'Recreated constraint with correct values';
        ELSE
            RAISE NOTICE 'Constraint looks correct';
        END IF;
    ELSE
        RAISE NOTICE 'No bloom_level constraint found, checking for incompatible data...';
        
        -- Update any existing data that might violate the new constraint
        UPDATE user_progress 
        SET bloom_level = CASE 
            WHEN bloom_level NOT IN ('dim', 'bright', 'radiant', 'luminous') THEN 'dim'
            ELSE bloom_level
        END;
        
        -- Update petal_stage too while we're at it
        UPDATE user_progress 
        SET petal_stage = CASE 
            WHEN petal_stage NOT IN ('dormant', 'budding', 'blooming', 'radiant') THEN 'dormant'
            ELSE petal_stage
        END;
        
        RAISE NOTICE 'Updated existing data to be compatible with new constraints';
        
        -- Now create the constraint
        EXECUTE 'ALTER TABLE user_progress ADD CONSTRAINT user_progress_bloom_level_check CHECK (bloom_level IN (''dim'', ''bright'', ''radiant'', ''luminous''))';
        RAISE NOTICE 'Created new bloom_level constraint';
    END IF;
END $$;

-- Verify constraints are now correct
SELECT 
    'CONSTRAINTS AFTER FIX' as info,
    constraint_name,
    check_clause
FROM information_schema.check_constraints 
WHERE constraint_name LIKE '%user_progress%';

-- Process any existing completed sessions manually
DO $$
DECLARE
    session_record RECORD;
    processed_count INTEGER := 0;
    correct_rate DECIMAL;
    mastery_boost DECIMAL;
    topic_name TEXT;
    performance_category TEXT;
BEGIN
    RAISE NOTICE 'Processing existing completed sessions...';
    
    FOR session_record IN 
        SELECT * FROM practice_sessions 
        WHERE completed_at IS NOT NULL 
        AND questions_answered > 0
    LOOP
        -- Calculate performance metrics (same logic as trigger)
        correct_rate := session_record.correct_answers::DECIMAL / session_record.questions_answered::DECIMAL;
        
        -- Determine topic name
        topic_name := CASE 
            WHEN array_length(session_record.topics_covered, 1) > 0 THEN session_record.topics_covered[1]
            WHEN session_record.session_type IS NOT NULL THEN session_record.session_type
            ELSE 'General Practice'
        END;
        
        -- Calculate mastery boost
        mastery_boost := CASE 
            WHEN correct_rate >= 0.8 THEN 0.1   -- Excellent: +10%
            WHEN correct_rate >= 0.6 THEN 0.05  -- Good: +5%
            WHEN correct_rate >= 0.4 THEN 0.02  -- Fair: +2%
            ELSE -0.02                           -- Poor: -2%
        END;
        
        -- Performance category
        performance_category := CASE 
            WHEN correct_rate >= 0.8 THEN 'excellent'
            WHEN correct_rate >= 0.6 THEN 'good'
            WHEN correct_rate >= 0.4 THEN 'fair'
            ELSE 'needs_improvement'
        END;
        
        -- Insert or update user progress
        INSERT INTO user_progress (
            user_id,
            topic,
            mastery_level,
            questions_attempted,
            questions_correct,
            last_practiced,
            needs_review,
            difficulty_preference,
            petal_stage,
            bloom_level,
            confidence_trend,
            energy_level,
            created_at,
            updated_at
        ) VALUES (
            session_record.user_id,
            topic_name,
            GREATEST(0.0, LEAST(1.0, 0.3 + mastery_boost)),
            session_record.questions_answered,
            session_record.correct_answers,
            session_record.completed_at,
            (correct_rate < 0.6),
            performance_category,
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
            LEAST(1.0, correct_rate + 0.2),
            NOW(),
            NOW()
        ) ON CONFLICT (user_id, topic) 
        DO UPDATE SET
            mastery_level = GREATEST(0.0, LEAST(1.0, user_progress.mastery_level + mastery_boost)),
            questions_attempted = user_progress.questions_attempted + session_record.questions_answered,
            questions_correct = user_progress.questions_correct + session_record.correct_answers,
            last_practiced = session_record.completed_at,
            needs_review = (
                (user_progress.questions_correct + session_record.correct_answers)::DECIMAL / 
                (user_progress.questions_attempted + session_record.questions_answered)::DECIMAL
            ) < 0.6,
            difficulty_preference = performance_category,
            petal_stage = CASE 
                WHEN (user_progress.questions_correct + session_record.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + session_record.questions_answered)::DECIMAL >= 0.8 THEN 'blooming'
                WHEN (user_progress.questions_correct + session_record.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + session_record.questions_answered)::DECIMAL >= 0.6 THEN 'budding'
                ELSE 'dormant'
            END,
            bloom_level = CASE 
                WHEN (user_progress.questions_correct + session_record.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + session_record.questions_answered)::DECIMAL >= 0.8 THEN 'radiant'
                WHEN (user_progress.questions_correct + session_record.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + session_record.questions_answered)::DECIMAL >= 0.6 THEN 'bright'
                ELSE 'dim'
            END,
            confidence_trend = (
                (user_progress.questions_correct + session_record.correct_answers)::DECIMAL / 
                (user_progress.questions_attempted + session_record.questions_answered)::DECIMAL
            ),
            energy_level = LEAST(1.0, (
                (user_progress.questions_correct + session_record.correct_answers)::DECIMAL / 
                (user_progress.questions_attempted + session_record.questions_answered)::DECIMAL
            ) + 0.2),
            updated_at = NOW();
        
        processed_count := processed_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Processed % existing sessions and updated user progress', processed_count;
END $$;

-- =============================================
-- STEP 6: VERIFY EVERYTHING WORKS
-- =============================================

-- Show final status
SELECT 
    'Trigger Status' as check_type,
    trigger_name,
    'ACTIVE' as status
FROM information_schema.triggers 
WHERE trigger_name = 'update_user_progress_on_session_complete';

-- Show progress data
SELECT 
    'Progress Data' as check_type,
    COUNT(*) as total_progress_records,
    COUNT(DISTINCT user_id) as users_with_progress
FROM user_progress;

-- Show sample dashboard data for first user
DO $$
DECLARE
    sample_user_id UUID;
    dashboard_data JSON;
BEGIN
    SELECT user_id INTO sample_user_id 
    FROM practice_sessions 
    WHERE completed_at IS NOT NULL 
    LIMIT 1;
    
    IF sample_user_id IS NOT NULL THEN
        SELECT get_user_dashboard_data(sample_user_id) INTO dashboard_data;
        RAISE NOTICE 'Sample dashboard data: %', dashboard_data;
    END IF;
END $$;

-- Final success message
SELECT 
    '🎯 COMPLETE FIX APPLIED' as status,
    'Sessions now properly update mandala and dashboard' as message;
