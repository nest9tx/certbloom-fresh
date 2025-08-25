-- =====================================================
-- CertBloom Concept-Based Learning Database Schema
-- =====================================================
-- Run this in your Supabase SQL Editor to create the
-- concept-based learning system tables and sample data
-- =====================================================

-- 1. DOMAINS TABLE
-- Represents major subject areas within a certification
CREATE TABLE IF NOT EXISTS domains (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  certification_id UUID REFERENCES certifications(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. CONCEPTS TABLE  
-- Specific learning concepts within each domain
CREATE TABLE IF NOT EXISTS concepts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  domain_id UUID REFERENCES domains(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  learning_objectives TEXT[], -- Array of learning objectives
  difficulty_level INTEGER CHECK (difficulty_level BETWEEN 1 AND 5) DEFAULT 1,
  estimated_study_minutes INTEGER DEFAULT 30,
  order_index INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. CONTENT ITEMS TABLE
-- Individual learning materials for each concept
CREATE TABLE IF NOT EXISTS content_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content_type TEXT NOT NULL,
  content_data JSONB NOT NULL, -- Flexible storage for different content types
  order_index INTEGER NOT NULL DEFAULT 0,
  estimated_minutes INTEGER DEFAULT 5,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Add constraint for content types after table creation
DO $$
BEGIN
    -- Check if the content_type column exists before adding constraint
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'content_items' 
        AND column_name = 'content_type'
    ) THEN
        -- Drop existing constraint if it exists
        ALTER TABLE content_items 
        DROP CONSTRAINT IF EXISTS content_items_content_type_check;
        
        -- Add the constraint
        ALTER TABLE content_items 
        ADD CONSTRAINT content_items_content_type_check 
        CHECK (content_type IN (
          'text_explanation',
          'interactive_example', 
          'practice_question',
          'real_world_scenario',
          'teaching_strategy',
          'common_misconception',
          'memory_technique'
        ));
        
        RAISE NOTICE 'Added content_type constraint to content_items table';
    ELSE
        RAISE NOTICE 'content_type column does not exist in content_items table';
    END IF;
END $$;

-- 4. CONCEPT PROGRESS TABLE
-- Tracks individual user progress through concepts
CREATE TABLE IF NOT EXISTS concept_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  mastery_level DECIMAL(3,2) DEFAULT 0.0 CHECK (mastery_level BETWEEN 0.0 AND 1.0),
  time_spent_minutes INTEGER DEFAULT 0,
  times_reviewed INTEGER DEFAULT 0,
  last_studied_at TIMESTAMP WITH TIME ZONE,
  is_mastered BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(user_id, concept_id)
);

-- 5. CONTENT ENGAGEMENT TABLE
-- Tracks user interaction with individual content items
CREATE TABLE IF NOT EXISTS content_engagement (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  content_item_id UUID REFERENCES content_items(id) ON DELETE CASCADE,
  time_spent_seconds INTEGER DEFAULT 0,
  completed BOOLEAN DEFAULT FALSE,
  engagement_data JSONB, -- Store answers, interactions, etc.
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 6. STUDY PLANS TABLE
-- Personalized learning paths for users
CREATE TABLE IF NOT EXISTS study_plans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  certification_id UUID REFERENCES certifications(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  target_exam_date DATE,
  daily_study_minutes INTEGER DEFAULT 30,
  current_concept_id UUID REFERENCES concepts(id),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(user_id, certification_id)
);

-- =====================================================
-- CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Domain indexes
CREATE INDEX IF NOT EXISTS idx_domains_certification_id ON domains(certification_id);
CREATE INDEX IF NOT EXISTS idx_domains_order_index ON domains(order_index);

-- Concept indexes
CREATE INDEX IF NOT EXISTS idx_concepts_domain_id ON concepts(domain_id);
CREATE INDEX IF NOT EXISTS idx_concepts_order_index ON concepts(order_index);
CREATE INDEX IF NOT EXISTS idx_concepts_difficulty_level ON concepts(difficulty_level);

-- Content item indexes
CREATE INDEX IF NOT EXISTS idx_content_items_concept_id ON content_items(concept_id);
CREATE INDEX IF NOT EXISTS idx_content_items_order_index ON content_items(order_index);
-- Create content type index after ensuring column exists
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'content_items' AND column_name = 'content_type') THEN
        CREATE INDEX IF NOT EXISTS idx_content_items_type ON content_items(content_type);
    END IF;
END $$;

-- Progress tracking indexes
CREATE INDEX IF NOT EXISTS idx_concept_progress_user_id ON concept_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_concept_progress_concept_id ON concept_progress(concept_id);
CREATE INDEX IF NOT EXISTS idx_concept_progress_mastery ON concept_progress(mastery_level);
CREATE INDEX IF NOT EXISTS idx_concept_progress_last_studied ON concept_progress(last_studied_at);

-- Engagement indexes
CREATE INDEX IF NOT EXISTS idx_content_engagement_user_id ON content_engagement(user_id);
CREATE INDEX IF NOT EXISTS idx_content_engagement_content_id ON content_engagement(content_item_id);

-- Study plan indexes
CREATE INDEX IF NOT EXISTS idx_study_plans_user_id ON study_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_study_plans_certification_id ON study_plans(certification_id);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE concepts ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE concept_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_engagement ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_plans ENABLE ROW LEVEL SECURITY;

-- Domains: Read access for authenticated users
CREATE POLICY "Users can read domains" ON domains
  FOR SELECT USING (auth.role() = 'authenticated');

-- Concepts: Read access for authenticated users
CREATE POLICY "Users can read concepts" ON concepts
  FOR SELECT USING (auth.role() = 'authenticated');

-- Content Items: Read access for authenticated users
CREATE POLICY "Users can read content items" ON content_items
  FOR SELECT USING (auth.role() = 'authenticated');

-- Concept Progress: Users can manage their own progress
CREATE POLICY "Users can manage their own concept progress" ON concept_progress
  FOR ALL USING (auth.uid() = user_id);

-- Content Engagement: Users can manage their own engagement
CREATE POLICY "Users can manage their own content engagement" ON content_engagement
  FOR ALL USING (auth.uid() = user_id);

-- Study Plans: Users can manage their own study plans
CREATE POLICY "Users can manage their own study plans" ON study_plans
  FOR ALL USING (auth.uid() = user_id);

-- =====================================================
-- SAMPLE DATA: ELEMENTARY MATHEMATICS (EC-6)
-- =====================================================

-- Step 1: Get or create Elementary Mathematics certification
INSERT INTO certifications (name, test_code, description)
SELECT 'Elementary Mathematics (EC-6)', '160', 'Mathematics content knowledge for elementary teachers'
WHERE NOT EXISTS (
    SELECT 1 FROM certifications WHERE test_code = '160'
);

-- Step 2: Create domains (get certification ID first)
WITH cert AS (
    SELECT id as cert_id FROM certifications WHERE test_code = '160' LIMIT 1
)
INSERT INTO domains (certification_id, code, name, description, order_index)
SELECT 
    cert.cert_id,
    domain_code,
    domain_name,
    domain_desc,
    domain_order
FROM cert,
(VALUES 
    ('NUM_OPS', 'Number Concepts and Operations', 'Understanding number systems, operations, and computational fluency', 1),
    ('PATTERNS', 'Patterns and Algebraic Reasoning', 'Algebraic thinking, patterns, and mathematical relationships', 2),
    ('GEOMETRY', 'Geometry and Spatial Reasoning', 'Geometric shapes, spatial relationships, and measurement', 3)
) AS domains_data(domain_code, domain_name, domain_desc, domain_order);

-- Step 3: Create concepts for each domain
WITH cert AS (
    SELECT id as cert_id FROM certifications WHERE test_code = '160' LIMIT 1
),
domain1 AS (
    SELECT d.id as domain_id FROM domains d 
    JOIN cert c ON d.certification_id = c.cert_id 
    WHERE d.order_index = 1
),
domain2 AS (
    SELECT d.id as domain_id FROM domains d 
    JOIN cert c ON d.certification_id = c.cert_id 
    WHERE d.order_index = 2
),
domain3 AS (
    SELECT d.id as domain_id FROM domains d 
    JOIN cert c ON d.certification_id = c.cert_id 
    WHERE d.order_index = 3
)
INSERT INTO concepts (domain_id, name, description, learning_objectives, difficulty_level, estimated_study_minutes, order_index)
SELECT * FROM (
    -- Domain 1 concepts
    SELECT domain1.domain_id, 'Place Value Understanding', 'Master the concept of place value in whole numbers and decimals', 
           ARRAY['Understand place value positions', 'Compare and order numbers', 'Round numbers appropriately'], 2, 45, 1
    FROM domain1
    UNION ALL
    SELECT domain1.domain_id, 'Addition and Subtraction Strategies', 'Develop fluency with addition and subtraction using various strategies',
           ARRAY['Use mental math strategies', 'Apply standard algorithms', 'Solve word problems'], 3, 60, 2
    FROM domain1
    UNION ALL
    -- Domain 2 concepts  
    SELECT domain2.domain_id, 'Pattern Recognition', 'Identify and extend various types of patterns',
           ARRAY['Recognize numeric patterns', 'Identify geometric patterns', 'Create pattern rules'], 2, 40, 1
    FROM domain2
    UNION ALL
    SELECT domain2.domain_id, 'Introduction to Functions', 'Understand basic function concepts and representations',
           ARRAY['Use function tables', 'Graph simple functions', 'Identify function rules'], 4, 50, 2
    FROM domain2
    UNION ALL
    -- Domain 3 concepts
    SELECT domain3.domain_id, 'Shape Properties', 'Understand properties of 2D and 3D shapes',
           ARRAY['Classify shapes by properties', 'Identify angles and sides', 'Compare geometric figures'], 2, 35, 1
    FROM domain3
    UNION ALL
    SELECT domain3.domain_id, 'Area and Perimeter', 'Calculate area and perimeter of various shapes',
           ARRAY['Find perimeter of polygons', 'Calculate area of rectangles', 'Apply formulas correctly'], 3, 55, 2
    FROM domain3
) AS concept_data;

-- Step 4: Create content items
WITH cert AS (
    SELECT id as cert_id FROM certifications WHERE test_code = '160' LIMIT 1
),
concept1 AS (
    SELECT c.id as concept_id FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    JOIN cert ON d.certification_id = cert.cert_id
    WHERE d.order_index = 1 AND c.order_index = 1
),
concept2 AS (
    SELECT c.id as concept_id FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    JOIN cert ON d.certification_id = cert.cert_id
    WHERE d.order_index = 1 AND c.order_index = 2
),
concept3 AS (
    SELECT c.id as concept_id FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    JOIN cert ON d.certification_id = cert.cert_id
    WHERE d.order_index = 2 AND c.order_index = 1
)
INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes)
SELECT * FROM (
    -- Place Value Understanding content
    SELECT concept1.concept_id, 'text_explanation'::content_type, 'What is Place Value?', 
           '{"content": "Place value is the value of a digit based on its position in a number. Each position represents a power of 10.", "key_points": ["Each position has a value 10 times the position to its right", "Zero serves as a placeholder"]}'::jsonb,
           1, 8
    FROM concept1
    UNION ALL
    SELECT concept1.concept_id, 'interactive_example'::content_type, 'Place Value in Action',
           '{"scenario": "Let us explore the number 3,457.62", "steps": ["Identify each digit", "Name the places", "Calculate values"]}'::jsonb,
           2, 12
    FROM concept1
    UNION ALL
    SELECT concept1.concept_id, 'practice_question'::content_type, 'Practice: Compare Numbers',
           '{"question": "Which number is larger: 4,567 or 4,576?", "options": ["4,567", "4,576", "They are equal"], "correct_answer": "4,576"}'::jsonb,
           3, 5
    FROM concept1
    UNION ALL
    SELECT concept1.concept_id, 'real_world_scenario'::content_type, 'Real-World Place Value',
           '{"scenario": "Sarah is a bank teller counting money. She has $2,847 in her drawer.", "application": "She needs to organize the money by place value."}'::jsonb,
           4, 7
    FROM concept1
    UNION ALL
    SELECT concept1.concept_id, 'teaching_strategy'::content_type, 'Teaching Place Value Tips',
           '{"strategy": "Use place value manipulatives and visual models", "materials": ["Base-10 blocks", "Place value charts"]}'::jsonb,
           5, 6
    FROM concept1
    UNION ALL
    -- Addition and Subtraction content
    SELECT concept2.concept_id, 'text_explanation'::content_type, 'Mental Math Strategies',
           '{"content": "Mental math strategies help students add and subtract efficiently without paper and pencil.", "key_points": ["Use number relationships", "Make friendly numbers"]}'::jsonb,
           1, 10
    FROM concept2
    UNION ALL
    SELECT concept2.concept_id, 'interactive_example'::content_type, 'Algorithm Practice',
           '{"problem": "Solve 456 + 287 using the standard algorithm", "steps": ["Align numbers by place value", "Add ones", "Add tens", "Add hundreds"]}'::jsonb,
           2, 8
    FROM concept2
    UNION ALL
    SELECT concept2.concept_id, 'practice_question'::content_type, 'Word Problem Solving',
           '{"question": "Maria had 248 stickers. She gave away 79 stickers. How many does she have left?", "answer": "169 stickers"}'::jsonb,
           3, 6
    FROM concept2
    UNION ALL
    -- Pattern Recognition content
    SELECT concept3.concept_id, 'text_explanation'::content_type, 'Types of Patterns',
           '{"content": "Patterns are everywhere in mathematics! Understanding patterns helps develop algebraic thinking.", "key_points": ["Look for what changes", "Find the rule"]}'::jsonb,
           1, 9
    FROM concept3
    UNION ALL
    SELECT concept3.concept_id, 'interactive_example'::content_type, 'Pattern Investigation',
           '{"pattern": "1, 4, 9, 16, 25, ?", "investigation": ["Look at differences", "Find the pattern rule"], "extension": "Square numbers!"}'::jsonb,
           2, 10
    FROM concept3
) AS content_data;

-- Simple completion message
SELECT 'Sample data created successfully!' as status;

-- =====================================================
-- UTILITY FUNCTIONS (Optional - can be added later)
-- =====================================================

-- Function to get next recommended concept for a user
CREATE OR REPLACE FUNCTION get_next_concept_for_user(user_uuid UUID, cert_uuid UUID)
RETURNS TABLE (
    concept_id UUID,
    concept_name TEXT,
    domain_name TEXT,
    mastery_level DECIMAL
) AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.name,
        d.name,
        COALESCE(cp.mastery_level, 0.0)
    FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    LEFT JOIN concept_progress cp ON c.id = cp.concept_id AND cp.user_id = user_uuid
    WHERE d.certification_id = cert_uuid
    AND (cp.mastery_level IS NULL OR cp.mastery_level < 0.8)
    ORDER BY d.order_index, c.order_index
    LIMIT 1;
END;
$function$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to calculate overall certification progress
CREATE OR REPLACE FUNCTION get_certification_progress(user_uuid UUID, cert_uuid UUID)
RETURNS TABLE (
    total_concepts INTEGER,
    mastered_concepts INTEGER,
    progress_percentage DECIMAL
) AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(c.id)::INTEGER as total_concepts,
        COUNT(CASE WHEN cp.is_mastered THEN 1 END)::INTEGER as mastered_concepts,
        ROUND(
            (COUNT(CASE WHEN cp.is_mastered THEN 1 END)::DECIMAL / COUNT(c.id)::DECIMAL) * 100, 
            1
        ) as progress_percentage
    FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    LEFT JOIN concept_progress cp ON c.id = cp.concept_id AND cp.user_id = user_uuid
    WHERE d.certification_id = cert_uuid;
END;
$function$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- INSTALLATION COMPLETE
-- =====================================================

SELECT '🌸 CertBloom Concept-Based Learning Schema Installation Complete! 🌸' as message;
SELECT 'Ready to test your concept-based learning interface! 🚀' as status;
