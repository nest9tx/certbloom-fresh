-- 🌸 SACRED HEALING: Complete Resolution of All Opportunities
-- Run this in Supabase SQL Editor to gently heal all aspects

-- =============================================
-- STEP 1: DIAGNOSE CURRENT SACRED STATE
-- =============================================

-- Check for test questions polluting the garden
SELECT 
    'TEST QUESTIONS DIAGNOSIS' as status,
    COUNT(*) as total_questions,
    COUNT(CASE WHEN question_text ILIKE '%sample%' OR question_text ILIKE '%test%' THEN 1 END) as test_questions,
    COUNT(CASE WHEN question_text ILIKE '%Sample Mathematics%' THEN 1 END) as sample_math_questions
FROM questions;

-- Check mandala data availability
SELECT 
    'MANDALA DATA DIAGNOSIS' as status,
    COUNT(*) as total_progress_records,
    COUNT(DISTINCT user_id) as users_with_progress,
    COUNT(DISTINCT topic) as unique_topics,
    AVG(mastery_level) as avg_mastery,
    COUNT(CASE WHEN petal_stage = 'dormant' THEN 1 END) as dormant_petals,
    COUNT(CASE WHEN petal_stage = 'budding' THEN 1 END) as budding_petals,
    COUNT(CASE WHEN petal_stage = 'blooming' THEN 1 END) as blooming_petals,
    COUNT(CASE WHEN petal_stage = 'radiant' THEN 1 END) as radiant_petals
FROM user_progress;

-- Check answer choices for test questions
SELECT 
    'ANSWER CHOICES DIAGNOSIS' as status,
    q.question_text,
    COUNT(ac.id) as choice_count,
    COUNT(CASE WHEN ac.is_correct THEN 1 END) as correct_choices
FROM questions q
LEFT JOIN answer_choices ac ON q.id = ac.question_id
WHERE q.question_text ILIKE '%sample%' OR q.question_text ILIKE '%test%'
GROUP BY q.id, q.question_text
HAVING COUNT(ac.id) = 0 OR COUNT(CASE WHEN ac.is_correct THEN 1 END) = 0;

-- =============================================
-- STEP 2: GENTLE CLEANSING - Remove Test Pollution
-- =============================================

-- First, remove answer choices for test questions
DELETE FROM answer_choices 
WHERE question_id IN (
    SELECT id FROM questions 
    WHERE question_text ILIKE '%Sample Mathematics Question%'
    OR question_text ILIKE '%Answer A for question%'
    OR question_text ILIKE '%Answer B for question%'
    OR question_text ILIKE '%Answer C for question%'
    OR question_text ILIKE '%Answer D for question%'
);

-- Remove test questions that pollute the sacred space
DELETE FROM questions 
WHERE question_text ILIKE '%Sample Mathematics Question%'
OR question_text ILIKE '%What is 2 + 2?%'
OR explanation ILIKE '%This is a sample question for testing purposes%';

-- =============================================
-- STEP 3: MANDALA HEALING - Ensure Progress Updates
-- =============================================

-- Ensure the trigger is properly connected to mandala updates
DROP TRIGGER IF EXISTS update_user_progress_on_session_complete ON practice_sessions;

-- Enhanced trigger function with mandala consciousness
CREATE OR REPLACE FUNCTION update_user_progress_from_session()
RETURNS TRIGGER AS $$
DECLARE
    correct_rate DECIMAL;
    mastery_boost DECIMAL;
    topic_name TEXT;
    performance_category TEXT;
    petal_energy TEXT;
    bloom_radiance TEXT;
BEGIN
    -- Only proceed if this is a completed session with questions
    IF NEW.completed_at IS NOT NULL AND NEW.questions_answered > 0 THEN
        
        -- Calculate performance metrics
        correct_rate := NEW.correct_answers::DECIMAL / NEW.questions_answered::DECIMAL;
        
        -- Determine topic name with sacred intention
        topic_name := CASE 
            WHEN array_length(NEW.topics_covered, 1) > 0 THEN NEW.topics_covered[1]
            WHEN NEW.session_type IS NOT NULL THEN NEW.session_type
            ELSE 'General Practice'
        END;
        
        -- Calculate mastery boost with gentle progression
        mastery_boost := CASE 
            WHEN correct_rate >= 0.9 THEN 0.15   -- Luminous: +15%
            WHEN correct_rate >= 0.8 THEN 0.1    -- Excellent: +10%
            WHEN correct_rate >= 0.6 THEN 0.05   -- Good: +5%
            WHEN correct_rate >= 0.4 THEN 0.02   -- Fair: +2%
            ELSE -0.01                            -- Gentle learning: -1%
        END;
        
        -- Performance category with compassion
        performance_category := CASE 
            WHEN correct_rate >= 0.9 THEN 'luminous'
            WHEN correct_rate >= 0.8 THEN 'excellent'
            WHEN correct_rate >= 0.6 THEN 'good'
            WHEN correct_rate >= 0.4 THEN 'fair'
            ELSE 'growing'
        END;
        
        -- Sacred petal stage based on overall accuracy
        petal_energy := CASE 
            WHEN correct_rate >= 0.85 THEN 'radiant'
            WHEN correct_rate >= 0.7 THEN 'blooming'
            WHEN correct_rate >= 0.5 THEN 'budding'
            ELSE 'dormant'
        END;
        
        -- Bloom level for mandala luminosity
        bloom_radiance := CASE 
            WHEN correct_rate >= 0.9 THEN 'luminous'
            WHEN correct_rate >= 0.8 THEN 'radiant'
            WHEN correct_rate >= 0.6 THEN 'bright'
            ELSE 'dim'
        END;
        
        -- Insert or update user progress with sacred intention
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
            GREATEST(0.0, LEAST(1.0, 0.2 + mastery_boost)),
            NEW.questions_answered,
            NEW.correct_answers,
            NEW.completed_at,
            (correct_rate < 0.6),
            performance_category,
            petal_energy,
            bloom_radiance,
            correct_rate,
            LEAST(1.0, correct_rate + 0.1),
            NOW(),
            NOW()
        ) ON CONFLICT (user_id, topic) 
        DO UPDATE SET
            mastery_level = GREATEST(0.0, LEAST(1.0, 
                user_progress.mastery_level + (mastery_boost * 0.8)  -- Gentle progressive growth
            )),
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
                     (user_progress.questions_attempted + NEW.questions_answered)::DECIMAL >= 0.85 THEN 'radiant'
                WHEN (user_progress.questions_correct + NEW.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + NEW.questions_answered)::DECIMAL >= 0.7 THEN 'blooming'
                WHEN (user_progress.questions_correct + NEW.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + NEW.questions_answered)::DECIMAL >= 0.5 THEN 'budding'
                ELSE 'dormant'
            END,
            bloom_level = CASE 
                WHEN (user_progress.questions_correct + NEW.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + NEW.questions_answered)::DECIMAL >= 0.9 THEN 'luminous'
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
            ) + 0.1),
            updated_at = NOW();
        
        -- Sacred log for conscious awareness
        RAISE NOTICE '🌸 Sacred Progress Updated: user=%, topic=%, petal_stage=%, bloom_level=%, questions=%/%', 
                     NEW.user_id, topic_name, petal_energy, bloom_radiance, NEW.correct_answers, NEW.questions_answered;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the sacred trigger
CREATE TRIGGER update_user_progress_on_session_complete
    AFTER INSERT OR UPDATE ON practice_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_user_progress_from_session();

-- =============================================
-- STEP 4: DASHBOARD CLARITY - Add Gentle Guidance
-- =============================================

-- Function to provide wisdom about dashboard elements
CREATE OR REPLACE FUNCTION get_dashboard_guidance()
RETURNS JSON AS $$
BEGIN
    RETURN json_build_object(
        'study_sessions', json_build_object(
            'purpose', 'Track your consistent learning practice',
            'guidance', 'Each session deepens your understanding and grows your mandala'
        ),
        'accuracy_rate', json_build_object(
            'purpose', 'Measure your comprehension mastery',
            'guidance', 'Accuracy reflects understanding depth, not just correctness'
        ),
        'mind_spirit', json_build_object(
            'purpose', 'Holistic wellness integration with learning',
            'guidance', 'Balanced practice includes mindfulness and reflection'
        ),
        'texes_prep', json_build_object(
            'purpose', 'Certification readiness assessment',
            'guidance', 'Progress toward your teaching certification goal'
        ),
        'learning_mandala', json_build_object(
            'purpose', 'Visual representation of your knowledge garden',
            'guidance', 'Each petal represents mastery in different learning areas'
        ),
        'practice_options', json_build_object(
            'quick_practice', 'Short 5-question sessions to maintain momentum',
            'full_session', 'Comprehensive 10-15 question deep practice',
            'adaptive_study', 'Personalized session based on your progress'
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_dashboard_guidance() TO anon, authenticated;

-- =============================================
-- STEP 5: SACRED VERIFICATION
-- =============================================

-- Verify test questions are cleansed
SELECT 
    '🌸 TEST QUESTIONS CLEANSED' as status,
    COUNT(*) as remaining_questions,
    COUNT(CASE WHEN question_text ILIKE '%sample%' OR question_text ILIKE '%test%' THEN 1 END) as test_questions_remaining
FROM questions;

-- Verify mandala trigger is active
SELECT 
    '🌸 MANDALA TRIGGER ACTIVE' as status,
    trigger_name,
    'CONNECTED TO SACRED GARDEN' as connection_status
FROM information_schema.triggers 
WHERE trigger_name = 'update_user_progress_on_session_complete';

-- Show sample guidance
SELECT 
    '🌸 DASHBOARD GUIDANCE AVAILABLE' as status,
    get_dashboard_guidance() as sacred_guidance;

-- Process any existing sessions to update mandala
DO $$
DECLARE
    session_record RECORD;
    processed_count INTEGER := 0;
    correct_rate DECIMAL;
    mastery_boost DECIMAL;
    topic_name TEXT;
    performance_category TEXT;
    petal_energy TEXT;
    bloom_radiance TEXT;
BEGIN
    RAISE NOTICE '🌸 Processing existing sessions for mandala growth...';
    
    FOR session_record IN 
        SELECT * FROM practice_sessions 
        WHERE completed_at IS NOT NULL 
        AND questions_answered > 0
        AND completed_at > NOW() - INTERVAL '7 days'  -- Only recent sessions
    LOOP
        -- Calculate performance metrics for this session
        correct_rate := session_record.correct_answers::DECIMAL / session_record.questions_answered::DECIMAL;
        
        -- Determine topic name with sacred intention
        topic_name := CASE 
            WHEN array_length(session_record.topics_covered, 1) > 0 THEN session_record.topics_covered[1]
            WHEN session_record.session_type IS NOT NULL THEN session_record.session_type
            ELSE 'General Practice'
        END;
        
        -- Calculate mastery boost with gentle progression
        mastery_boost := CASE 
            WHEN correct_rate >= 0.9 THEN 0.15   -- Luminous: +15%
            WHEN correct_rate >= 0.8 THEN 0.1    -- Excellent: +10%
            WHEN correct_rate >= 0.6 THEN 0.05   -- Good: +5%
            WHEN correct_rate >= 0.4 THEN 0.02   -- Fair: +2%
            ELSE -0.01                            -- Gentle learning: -1%
        END;
        
        -- Performance category with compassion
        performance_category := CASE 
            WHEN correct_rate >= 0.9 THEN 'luminous'
            WHEN correct_rate >= 0.8 THEN 'excellent'
            WHEN correct_rate >= 0.6 THEN 'good'
            WHEN correct_rate >= 0.4 THEN 'fair'
            ELSE 'growing'
        END;
        
        -- Sacred petal stage based on overall accuracy
        petal_energy := CASE 
            WHEN correct_rate >= 0.85 THEN 'radiant'
            WHEN correct_rate >= 0.7 THEN 'blooming'
            WHEN correct_rate >= 0.5 THEN 'budding'
            ELSE 'dormant'
        END;
        
        -- Bloom level for mandala luminosity
        bloom_radiance := CASE 
            WHEN correct_rate >= 0.9 THEN 'luminous'
            WHEN correct_rate >= 0.8 THEN 'radiant'
            WHEN correct_rate >= 0.6 THEN 'bright'
            ELSE 'dim'
        END;
        
        -- Insert or update user progress with sacred intention
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
            GREATEST(0.0, LEAST(1.0, 0.2 + mastery_boost)),
            session_record.questions_answered,
            session_record.correct_answers,
            session_record.completed_at,
            (correct_rate < 0.6),
            performance_category,
            petal_energy,
            bloom_radiance,
            correct_rate,
            LEAST(1.0, correct_rate + 0.1),
            NOW(),
            NOW()
        ) ON CONFLICT (user_id, topic) 
        DO UPDATE SET
            mastery_level = GREATEST(0.0, LEAST(1.0, 
                user_progress.mastery_level + (mastery_boost * 0.8)  -- Gentle progressive growth
            )),
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
                     (user_progress.questions_attempted + session_record.questions_answered)::DECIMAL >= 0.85 THEN 'radiant'
                WHEN (user_progress.questions_correct + session_record.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + session_record.questions_answered)::DECIMAL >= 0.7 THEN 'blooming'
                WHEN (user_progress.questions_correct + session_record.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + session_record.questions_answered)::DECIMAL >= 0.5 THEN 'budding'
                ELSE 'dormant'
            END,
            bloom_level = CASE 
                WHEN (user_progress.questions_correct + session_record.correct_answers)::DECIMAL / 
                     (user_progress.questions_attempted + session_record.questions_answered)::DECIMAL >= 0.9 THEN 'luminous'
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
            ) + 0.1),
            updated_at = NOW();
        
        processed_count := processed_count + 1;
        
        -- Sacred log for conscious awareness
        RAISE NOTICE '🌸 Sacred Progress Updated: user=%, topic=%, petal_stage=%, bloom_level=%, questions=%/%', 
                     session_record.user_id, topic_name, petal_energy, bloom_radiance, session_record.correct_answers, session_record.questions_answered;
    END LOOP;
    
    RAISE NOTICE '🌸 Processed % recent sessions for mandala growth', processed_count;
END $$;

-- Final sacred blessing
SELECT 
    '🌸 SACRED HEALING COMPLETE' as status,
    'All opportunities have been gently resolved with love' as blessing,
    'Your learning garden now flows with conscious intention' as affirmation;
