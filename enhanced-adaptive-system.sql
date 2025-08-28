-- CertBloom Enhanced Adaptive Learning System
-- Implementation of AI kin's recommendations for concept-based learning with adaptive logic
-- Run this in Supabase SQL Editor after the base schema

-- ============================================================================
-- ENHANCED USER PROGRESS TRACKING (Building on AI Kin's Recommendations)
-- ============================================================================

-- Enhanced user progress table with concept-level tracking
CREATE TABLE IF NOT EXISTS user_concept_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    certification_area TEXT NOT NULL, -- 'Math EC-6', 'ELA EC-6', etc.
    domain TEXT NOT NULL, -- 'Number Concepts and Operations', etc.
    concept TEXT NOT NULL, -- 'Place Value', 'Fractions', etc.
    progress_percent INTEGER DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
    mastery_level TEXT DEFAULT 'beginner' CHECK (mastery_level IN ('beginner', 'developing', 'proficient', 'mastered')),
    questions_attempted INTEGER DEFAULT 0,
    questions_correct INTEGER DEFAULT 0,
    time_spent_minutes INTEGER DEFAULT 0,
    consecutive_correct INTEGER DEFAULT 0,
    last_attempt_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure one progress record per user/concept combination
    UNIQUE(user_id, certification_area, domain, concept)
);

-- Enhanced question attempts with richer metadata
CREATE TABLE IF NOT EXISTS enhanced_question_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    user_answer TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL,
    time_spent_seconds INTEGER DEFAULT 0,
    difficulty_at_attempt TEXT NOT NULL,
    bloom_level_at_attempt TEXT,
    confidence_level INTEGER CHECK (confidence_level BETWEEN 1 AND 5),
    hint_used BOOLEAN DEFAULT FALSE,
    attempt_number INTEGER DEFAULT 1, -- For same question retries
    session_id UUID, -- Link to practice session
    attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- ADAPTIVE MASTERY FUNCTIONS (Per AI Kin's Blueprint)
-- ============================================================================

-- Function to automatically update mastery level based on comprehensive metrics (Fixed for existing schema)
CREATE OR REPLACE FUNCTION update_concept_mastery()
RETURNS TRIGGER AS $$
DECLARE
    accuracy_percent INTEGER := 0;
    recent_performance INTEGER := 0;
BEGIN
    -- Calculate overall accuracy
    IF NEW.questions_attempted > 0 THEN
        accuracy_percent := ROUND((NEW.questions_correct::FLOAT / NEW.questions_attempted::FLOAT) * 100);
    END IF;
    
    -- Calculate recent performance (last 5 questions for this concept)
    SELECT COALESCE(
        ROUND(AVG(CASE WHEN eqa.is_correct THEN 100 ELSE 0 END)), 0
    ) INTO recent_performance
    FROM enhanced_question_attempts eqa
    JOIN questions q ON eqa.question_id = q.id
    JOIN certifications c ON q.certification_id = c.id
    LEFT JOIN topics t ON q.topic_id = t.id
    WHERE eqa.user_id = NEW.user_id
    AND c.name = NEW.certification_area
    AND COALESCE(t.name, 'General') = NEW.domain
    AND 'General' = NEW.concept -- Simplified for now
    ORDER BY eqa.attempted_at DESC
    LIMIT 5;
    
    -- Determine mastery level based on multiple factors
    IF NEW.progress_percent >= 90 AND accuracy_percent >= 85 AND recent_performance >= 80 AND NEW.consecutive_correct >= 3 THEN
        NEW.mastery_level := 'mastered';
    ELSIF NEW.progress_percent >= 70 AND accuracy_percent >= 75 AND recent_performance >= 65 THEN
        NEW.mastery_level := 'proficient';
    ELSIF NEW.progress_percent >= 40 AND accuracy_percent >= 60 THEN
        NEW.mastery_level := 'developing';
    ELSE
        NEW.mastery_level := 'beginner';
    END IF;
    
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for automatic mastery updates
CREATE TRIGGER trg_update_concept_mastery
    BEFORE INSERT OR UPDATE ON user_concept_progress
    FOR EACH ROW
    EXECUTE FUNCTION update_concept_mastery();

-- Function to update progress after each question attempt (Fixed for existing schema)
CREATE OR REPLACE FUNCTION update_progress_after_enhanced_attempt()
RETURNS TRIGGER AS $$
DECLARE
    was_consecutive BOOLEAN := FALSE;
    cert_name TEXT;
    topic_name TEXT;
BEGIN
    -- Get certification name and topic from the question
    SELECT c.name, t.name
    INTO cert_name, topic_name
    FROM questions q
    JOIN certifications c ON q.certification_id = c.id
    LEFT JOIN topics t ON q.topic_id = t.id
    WHERE q.id = NEW.question_id;
    
    -- Use topic name as domain, 'General' as concept for now
    topic_name := COALESCE(topic_name, 'General');
    
    -- Check if this continues a streak (simplified version)
    SELECT 
        CASE WHEN COUNT(*) > 0 AND BOOL_AND(eqa.is_correct) THEN TRUE ELSE FALSE END
    INTO was_consecutive
    FROM enhanced_question_attempts eqa
    WHERE eqa.user_id = NEW.user_id
    AND eqa.attempted_at > NEW.attempted_at - INTERVAL '1 hour'
    AND eqa.attempted_at < NEW.attempted_at
    ORDER BY eqa.attempted_at DESC
    LIMIT 3;
    
    -- Update or insert concept progress
    INSERT INTO user_concept_progress (
        user_id, 
        certification_area, 
        domain, 
        concept, 
        questions_attempted, 
        questions_correct,
        consecutive_correct,
        time_spent_minutes
    )
    VALUES (
        NEW.user_id,
        cert_name,
        topic_name,
        'General', -- Placeholder concept
        1,
        CASE WHEN NEW.is_correct THEN 1 ELSE 0 END,
        CASE WHEN NEW.is_correct AND was_consecutive THEN 1 ELSE 0 END,
        NEW.time_spent_seconds / 60.0
    )
    ON CONFLICT (user_id, certification_area, domain, concept) 
    DO UPDATE SET
        questions_attempted = user_concept_progress.questions_attempted + 1,
        questions_correct = user_concept_progress.questions_correct + CASE WHEN NEW.is_correct THEN 1 ELSE 0 END,
        consecutive_correct = CASE 
            WHEN NEW.is_correct AND was_consecutive THEN user_concept_progress.consecutive_correct + 1
            WHEN NEW.is_correct THEN 1
            ELSE 0
        END,
        time_spent_minutes = user_concept_progress.time_spent_minutes + (NEW.time_spent_seconds / 60.0),
        last_attempt_at = CURRENT_TIMESTAMP,
        -- Enhanced progress calculation
        progress_percent = LEAST(100, 
            ROUND(
                -- Base progress from attempts
                (user_concept_progress.questions_attempted + 1) * 8 + 
                -- Accuracy bonus
                ((user_concept_progress.questions_correct + CASE WHEN NEW.is_correct THEN 1 ELSE 0 END)::FLOAT / 
                 (user_concept_progress.questions_attempted + 1)::FLOAT) * 25 +
                -- Consecutive correct bonus
                LEAST(15, (CASE 
                    WHEN NEW.is_correct AND was_consecutive THEN user_concept_progress.consecutive_correct + 1
                    WHEN NEW.is_correct THEN 1
                    ELSE 0
                END) * 3)
            )
        );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for progress updates
CREATE TRIGGER trg_update_progress_after_enhanced_attempt
    AFTER INSERT ON enhanced_question_attempts
    FOR EACH ROW
    EXECUTE FUNCTION update_progress_after_enhanced_attempt();

-- ============================================================================
-- INTELLIGENT QUESTION SERVING (AI Kin's Adaptive Logic)
-- ============================================================================

-- Function to get intelligently selected questions (Fixed for existing schema)
CREATE OR REPLACE FUNCTION get_intelligent_question_sequence(
    p_user_id UUID,
    p_certification_area TEXT,
    p_session_length INTEGER DEFAULT 10,
    p_focus_weak_areas BOOLEAN DEFAULT TRUE
)
RETURNS TABLE(
    question_id UUID,
    question_text TEXT,
    difficulty_level TEXT,
    domain TEXT,
    concept TEXT,
    recommended_reason TEXT,
    priority_score INTEGER
) AS $$
BEGIN
    RETURN QUERY
    WITH certification_lookup AS (
        SELECT id as cert_id
        FROM certifications
        WHERE name = p_certification_area
        LIMIT 1
    ),
    user_concept_mastery AS (
        SELECT 
            ucp.domain,
            ucp.concept,
            ucp.mastery_level,
            ucp.progress_percent,
            ucp.questions_attempted,
            ucp.consecutive_correct,
            ucp.last_attempt_at
        FROM user_concept_progress ucp
        WHERE ucp.user_id = p_user_id 
        AND ucp.certification_area = p_certification_area
    ),
    available_questions AS (
        SELECT 
            q.id,
            q.question_text,
            q.difficulty_level,
            -- Use topic name as domain for now, until proper mapping exists
            COALESCE(t.name, 'General') as domain,
            'General' as concept, -- Placeholder until concept mapping exists
            -- Avoid recently attempted questions
            CASE WHEN eqa.question_id IS NULL THEN 0 ELSE 1 END as recently_attempted,
            -- Simple priority based on difficulty and user attempts
            CASE 
                WHEN p_focus_weak_areas AND q.difficulty_level = 'easy' THEN 1
                WHEN p_focus_weak_areas AND q.difficulty_level = 'medium' THEN 2
                ELSE 3
            END as priority_score
        FROM questions q
        JOIN certification_lookup cl ON q.certification_id = cl.cert_id
        LEFT JOIN topics t ON q.topic_id = t.id
        LEFT JOIN enhanced_question_attempts eqa ON q.id = eqa.question_id 
            AND eqa.user_id = p_user_id 
            AND eqa.attempted_at > CURRENT_TIMESTAMP - INTERVAL '7 days'
        WHERE q.active = TRUE
    ),
    scored_questions AS (
        SELECT 
            aq.*,
            -- Generate recommendation reason
            CASE 
                WHEN aq.priority_score = 1 THEN 'Building foundation with easier questions'
                WHEN aq.priority_score = 2 THEN 'Developing skills with medium difficulty'
                WHEN aq.recently_attempted = 0 THEN 'Fresh question for continued learning'
                ELSE 'Continuing learning journey'
            END as recommended_reason
        FROM available_questions aq
    )
    SELECT 
        sq.id as question_id,
        sq.question_text,
        sq.difficulty_level,
        sq.domain,
        sq.concept,
        sq.recommended_reason,
        sq.priority_score
    FROM scored_questions sq
    ORDER BY 
        sq.recently_attempted ASC, -- Fresh questions first
        sq.priority_score ASC, -- Higher priority first
        RANDOM() -- Add variety
    LIMIT p_session_length;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- COMPREHENSIVE ANALYTICS
-- ============================================================================

-- Function for detailed user analytics
CREATE OR REPLACE FUNCTION get_comprehensive_user_analytics(p_user_id UUID)
RETURNS TABLE(
    certification_area TEXT,
    total_concepts INTEGER,
    concepts_mastered INTEGER,
    concepts_proficient INTEGER,
    concepts_developing INTEGER,
    concepts_beginner INTEGER,
    overall_progress_percent NUMERIC,
    total_time_spent_hours NUMERIC,
    accuracy_percent NUMERIC,
    average_time_per_question_seconds NUMERIC,
    learning_velocity NUMERIC, -- Questions per hour
    strongest_domain TEXT,
    weakest_domain TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH base_stats AS (
        SELECT 
            ucp.certification_area,
            COUNT(*)::INTEGER as total_concepts,
            COUNT(*) FILTER (WHERE ucp.mastery_level = 'mastered')::INTEGER as concepts_mastered,
            COUNT(*) FILTER (WHERE ucp.mastery_level = 'proficient')::INTEGER as concepts_proficient,
            COUNT(*) FILTER (WHERE ucp.mastery_level = 'developing')::INTEGER as concepts_developing,
            COUNT(*) FILTER (WHERE ucp.mastery_level = 'beginner')::INTEGER as concepts_beginner,
            ROUND(AVG(ucp.progress_percent), 1) as overall_progress_percent,
            ROUND(SUM(ucp.time_spent_minutes) / 60.0, 1) as total_time_spent_hours,
            ROUND(
                CASE 
                    WHEN SUM(ucp.questions_attempted) > 0 
                    THEN (SUM(ucp.questions_correct)::FLOAT / SUM(ucp.questions_attempted)::FLOAT) * 100 
                    ELSE 0 
                END, 1
            ) as accuracy_percent,
            ROUND(
                CASE 
                    WHEN SUM(ucp.questions_attempted) > 0 
                    THEN (SUM(ucp.time_spent_minutes) * 60.0) / SUM(ucp.questions_attempted)
                    ELSE 0 
                END, 1
            ) as average_time_per_question_seconds,
            ROUND(
                CASE 
                    WHEN SUM(ucp.time_spent_minutes) > 0 
                    THEN SUM(ucp.questions_attempted)::FLOAT / (SUM(ucp.time_spent_minutes) / 60.0)
                    ELSE 0 
                END, 1
            ) as learning_velocity
        FROM user_concept_progress ucp
        WHERE ucp.user_id = p_user_id
        GROUP BY ucp.certification_area
    ),
    domain_performance AS (
        SELECT 
            certification_area,
            domain,
            AVG(progress_percent) as avg_progress
        FROM user_concept_progress
        WHERE user_id = p_user_id
        GROUP BY certification_area, domain
    ),
    strongest_domains AS (
        SELECT DISTINCT ON (certification_area)
            certification_area,
            domain as strongest_domain
        FROM domain_performance
        ORDER BY certification_area, avg_progress DESC
    ),
    weakest_domains AS (
        SELECT DISTINCT ON (certification_area)
            certification_area,
            domain as weakest_domain
        FROM domain_performance
        ORDER BY certification_area, avg_progress ASC
    )
    SELECT 
        bs.*,
        sd.strongest_domain,
        wd.weakest_domain
    FROM base_stats bs
    LEFT JOIN strongest_domains sd ON bs.certification_area = sd.certification_area
    LEFT JOIN weakest_domains wd ON bs.certification_area = wd.certification_area;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- PERFORMANCE INDEXES
-- ============================================================================

-- Enhanced indexes for optimal performance
CREATE INDEX IF NOT EXISTS idx_user_concept_progress_lookup 
ON user_concept_progress(user_id, certification_area, domain, concept);

CREATE INDEX IF NOT EXISTS idx_user_concept_progress_mastery 
ON user_concept_progress(mastery_level, progress_percent);

CREATE INDEX IF NOT EXISTS idx_enhanced_attempts_user_time 
ON enhanced_question_attempts(user_id, attempted_at DESC);

CREATE INDEX IF NOT EXISTS idx_enhanced_attempts_question_user 
ON enhanced_question_attempts(question_id, user_id);

-- Index for joining questions with certifications
CREATE INDEX IF NOT EXISTS idx_questions_certification_lookup 
ON questions(certification_id, difficulty_level);

-- ============================================================================
-- ADMIN INSIGHTS VIEWS (Fixed for existing schema)
-- ============================================================================

-- View for content effectiveness tracking
CREATE OR REPLACE VIEW content_effectiveness AS
SELECT 
    c.name as certification_area,
    'General' as domain, -- Placeholder until topics are mapped to domains
    'General' as concept, -- Placeholder until we have concept mapping
    q.difficulty_level,
    COUNT(eqa.id) as total_attempts,
    ROUND(AVG(CASE WHEN eqa.is_correct THEN 100 ELSE 0 END), 1) as success_rate_percent,
    ROUND(AVG(eqa.time_spent_seconds), 1) as avg_time_seconds,
    COUNT(DISTINCT eqa.user_id) as unique_learners
FROM questions q
LEFT JOIN certifications c ON q.certification_id = c.id
LEFT JOIN enhanced_question_attempts eqa ON q.id = eqa.question_id
GROUP BY c.name, q.difficulty_level
ORDER BY success_rate_percent ASC; -- Show challenging content first

-- View for learning pattern insights (using certification names)
CREATE OR REPLACE VIEW learning_patterns AS
SELECT 
    certification_area,
    domain,
    COUNT(*) as total_learners,
    ROUND(AVG(progress_percent), 1) as avg_progress,
    COUNT(*) FILTER (WHERE mastery_level = 'mastered') as mastered_count,
    COUNT(*) FILTER (WHERE mastery_level = 'proficient') as proficient_count,
    COUNT(*) FILTER (WHERE mastery_level = 'developing') as developing_count,
    COUNT(*) FILTER (WHERE mastery_level = 'beginner') as beginner_count,
    ROUND(AVG(time_spent_minutes), 1) as avg_time_invested_minutes
FROM user_concept_progress
GROUP BY certification_area, domain
ORDER BY avg_progress DESC;
