-- 🌱 ENHANCED 902 STRUCTURE WITH WELLNESS SUPPORT
-- Adding mental health and rich content features to our 902 certification

-- First, let's enhance the concepts table to support wellness features
ALTER TABLE concepts ADD COLUMN IF NOT EXISTS content_rich_description TEXT;
ALTER TABLE concepts ADD COLUMN IF NOT EXISTS learning_objectives TEXT[];
ALTER TABLE concepts ADD COLUMN IF NOT EXISTS estimated_study_time_minutes INTEGER DEFAULT 30;
ALTER TABLE concepts ADD COLUMN IF NOT EXISTS difficulty_level INTEGER DEFAULT 1;
ALTER TABLE concepts ADD COLUMN IF NOT EXISTS prerequisites TEXT[];
ALTER TABLE concepts ADD COLUMN IF NOT EXISTS wellness_tips TEXT;
ALTER TABLE concepts ADD COLUMN IF NOT EXISTS confidence_building_notes TEXT;

-- Add wellness tracking to user progress
CREATE TABLE IF NOT EXISTS user_wellness_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_date DATE DEFAULT CURRENT_DATE,
    pre_session_anxiety_level INTEGER CHECK (pre_session_anxiety_level BETWEEN 1 AND 5),
    post_session_confidence_level INTEGER CHECK (post_session_confidence_level BETWEEN 1 AND 5),
    study_minutes INTEGER,
    breaks_taken INTEGER DEFAULT 0,
    mindful_moments_completed INTEGER DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add mental health support content table
CREATE TABLE IF NOT EXISTS wellness_content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type TEXT NOT NULL CHECK (type IN ('breathing_exercise', 'affirmation', 'study_tip', 'anxiety_management', 'break_activity')),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    duration_minutes INTEGER DEFAULT 3,
    tags TEXT[],
    difficulty_level TEXT CHECK (difficulty_level IN ('Beginner', 'Intermediate', 'Advanced')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enhance content_items to support rich explanations and wellness
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS detailed_explanation TEXT;
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS real_world_application TEXT;
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS confidence_building_tip TEXT;
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS common_misconceptions TEXT[];
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS memory_aids TEXT[];
ALTER TABLE content_items ADD COLUMN IF NOT EXISTS anxiety_note TEXT;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_wellness_user_date ON user_wellness_tracking(user_id, session_date);
CREATE INDEX IF NOT EXISTS idx_wellness_content_type ON wellness_content(type);
CREATE INDEX IF NOT EXISTS idx_concepts_difficulty ON concepts(difficulty_level);

-- Enable RLS on new tables
ALTER TABLE user_wellness_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE wellness_content ENABLE ROW LEVEL SECURITY;

-- RLS policies for wellness tracking
CREATE POLICY "Users can manage their own wellness tracking"
    ON user_wellness_tracking FOR ALL
    USING (auth.uid() = user_id);

-- RLS policies for wellness content (read-only for users)
CREATE POLICY "All users can view wellness content"
    ON wellness_content FOR SELECT
    USING (is_active = true);

-- Insert sample wellness content
INSERT INTO wellness_content (type, title, content, duration_minutes, tags) VALUES
('breathing_exercise', '3-Minute Calm', 'Take three deep breaths. Inhale for 4 counts, hold for 4, exhale for 6. You are capable of learning and growing. This study session is just one step in your journey.', 3, ARRAY['anxiety', 'pre-session']),
('affirmation', 'Math Confidence Boost', 'Mathematics is a language of patterns and logic. Every teacher was once a student learning these concepts. You have the intelligence and dedication to master this material. Trust your learning process.', 2, ARRAY['confidence', 'math-specific']),
('study_tip', 'Gentle Progress', 'Remember: Understanding is more important than speed. It''s okay to take your time with difficult concepts. Each question you work through builds your teaching toolkit.', 1, ARRAY['study-strategy', 'mindset']),
('anxiety_management', 'Test Day Prep', 'On test day, you''ll draw from all this preparation. Focus on what you know, not what you don''t. You''re preparing to be an amazing teacher - that''s your true goal.', 3, ARRAY['test-anxiety', 'motivation']),
('break_activity', 'Learning Reflection', 'Take a moment to appreciate what you''ve learned today. Think of one specific way this knowledge will help you as a teacher. Your students will benefit from your dedication.', 5, ARRAY['reflection', 'motivation']);

-- Update existing 902 concepts with rich content and wellness support
UPDATE concepts SET
    content_rich_description = CASE name
        WHEN 'Place Value and Number Sense' THEN 'Understanding how our number system works is fundamental to teaching mathematics confidently. This concept covers place value from ones to millions, comparing numbers, and developing number sense - the intuitive understanding of how numbers behave. You''ll explore multiple representations and teaching strategies that help students grasp these essential foundations.'
        WHEN 'Operations with Whole Numbers' THEN 'Master the four basic operations and their relationships. Learn not just how to compute, but why algorithms work and how to explain them clearly to students. Discover multiple strategies for addition, subtraction, multiplication, and division that accommodate different learning styles.'
        WHEN 'Fractions and Decimals' THEN 'Fractions and decimals often cause anxiety for both teachers and students. This section provides clear, conceptual understanding of these number forms, their relationships, and practical teaching approaches. You''ll gain confidence in explaining why procedures work, not just how to follow them.'
        WHEN 'Proportional Reasoning' THEN 'Proportional reasoning connects arithmetic to algebra and real-world applications. Explore ratios, rates, and proportions through practical contexts that students can relate to. This foundational skill supports future success in higher mathematics.'
        ELSE content_rich_description
    END,
    
    learning_objectives = CASE name
        WHEN 'Place Value and Number Sense' THEN ARRAY[
            'Explain place value concepts using multiple representations',
            'Compare and order numbers confidently',
            'Identify and address common student misconceptions about place value',
            'Use place value understanding to support computational fluency'
        ]
        WHEN 'Operations with Whole Numbers' THEN ARRAY[
            'Demonstrate multiple algorithms for each operation',
            'Explain the reasoning behind standard algorithms',
            'Connect operations to real-world problem contexts',
            'Identify and correct computational errors effectively'
        ]
        WHEN 'Fractions and Decimals' THEN ARRAY[
            'Represent fractions and decimals using multiple models',
            'Explain equivalent fractions and decimal relationships',
            'Perform operations with fractions and decimals confidently',
            'Connect fraction and decimal concepts to real-world applications'
        ]
        WHEN 'Proportional Reasoning' THEN ARRAY[
            'Solve proportion problems using multiple strategies',
            'Identify proportional relationships in various contexts',
            'Explain the connection between fractions, ratios, and percentages',
            'Apply proportional reasoning to solve real-world problems'
        ]
        ELSE learning_objectives
    END,
    
    wellness_tips = CASE name
        WHEN 'Place Value and Number Sense' THEN 'If place value feels overwhelming, remember that even experienced teachers sometimes need to think through larger numbers carefully. Use physical manipulatives or drawings to make abstract concepts concrete. There''s no shame in using tools to support your understanding.'
        WHEN 'Operations with Whole Numbers' THEN 'Don''t worry if you prefer certain algorithms over others - this actually helps you understand how students might feel! Focus on understanding why methods work, and remember that flexibility in approaches makes you a stronger teacher.'
        WHEN 'Fractions and Decimals' THEN 'Fraction anxiety is real and common. Take your time with these concepts. Many excellent teachers have had to work through fraction confusion. Your struggles help you empathize with and better support your future students.'
        WHEN 'Proportional Reasoning' THEN 'Proportional reasoning connects to so many real-world applications - focus on contexts that interest you. Whether it''s cooking, budgeting, or crafts, find personal connections that make the mathematics meaningful.'
        ELSE wellness_tips
    END,
    
    confidence_building_notes = CASE name
        WHEN 'Place Value and Number Sense' THEN 'You use place value understanding every day - when you read numbers, make change, or estimate quantities. You already have intuitive number sense; this section helps you formalize and expand that knowledge.'
        WHEN 'Operations with Whole Numbers' THEN 'You''ve been using these operations your whole life! This section builds on your existing knowledge and gives you the vocabulary and conceptual understanding to teach others effectively.'
        WHEN 'Fractions and Decimals' THEN 'Remember, fractions and decimals are just different ways to represent the same mathematical ideas. You don''t need to master every method - focus on understanding concepts deeply and finding approaches that make sense to you.'
        WHEN 'Proportional Reasoning' THEN 'Proportional thinking is everywhere in teaching - from mixing paint colors to planning field trip ratios. You''re developing skills you''ll use both in mathematics and classroom management.'
        ELSE confidence_building_notes
    END,
    
    difficulty_level = CASE name
        WHEN 'Place Value and Number Sense' THEN 1  -- Beginner
        WHEN 'Operations with Whole Numbers' THEN 2  -- Intermediate
        WHEN 'Fractions and Decimals' THEN 3  -- Advanced
        WHEN 'Proportional Reasoning' THEN 3  -- Advanced
        ELSE difficulty_level
    END,
    
    estimated_study_time_minutes = CASE name
        WHEN 'Place Value and Number Sense' THEN 30
        WHEN 'Operations with Whole Numbers' THEN 30
        WHEN 'Fractions and Decimals' THEN 45
        WHEN 'Proportional Reasoning' THEN 45
        ELSE estimated_study_time_minutes
    END

WHERE EXISTS (
    SELECT 1 FROM domains d 
    JOIN certifications c ON d.certification_id = c.id 
    WHERE d.id = concepts.domain_id 
    AND c.test_code = '902'
);

-- Verify our enhancements
SELECT 
    c.name,
    CASE c.difficulty_level 
        WHEN 1 THEN 'Beginner'
        WHEN 2 THEN 'Intermediate' 
        WHEN 3 THEN 'Advanced'
        ELSE 'Unknown'
    END as difficulty_level,
    c.estimated_study_time_minutes,
    LEFT(c.content_rich_description, 100) || '...' as description_preview,
    array_length(c.learning_objectives, 1) as objective_count
FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902'
ORDER BY d.order_index, c.order_index;

SELECT '✅ Enhanced 902 structure with wellness features completed!' as status;
