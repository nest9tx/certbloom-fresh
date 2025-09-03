-- 🏗️ BULLETPROOF CLEAN SLATE FOUNDATION 
-- This script safely handles all existing constraints and creates perfect structure

-- ============================================
-- STEP 1: DISABLE FOREIGN KEY CHECKS TEMPORARILY
-- ============================================

-- We'll drop tables in the right order to avoid constraint violations

-- ============================================
-- STEP 2: DROP EXISTING PROBLEMATIC TABLES
-- ============================================

-- First, drop all tables that reference others (children first)
DROP TABLE IF EXISTS user_session_answers CASCADE;
DROP TABLE IF EXISTS practice_sessions CASCADE;
DROP TABLE IF EXISTS concept_progress CASCADE;
DROP TABLE IF EXISTS answer_choices CASCADE;
DROP TABLE IF EXISTS content_items CASCADE;
DROP TABLE IF EXISTS questions CASCADE;  -- This is the culprit causing the error

-- Now drop the parent tables
DROP TABLE IF EXISTS concepts CASCADE;
DROP TABLE IF EXISTS domains CASCADE;
DROP TABLE IF EXISTS certifications CASCADE;

-- Also drop any study plan related tables that might exist
DROP TABLE IF EXISTS study_plans CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;

-- ============================================
-- STEP 3: CREATE PERFECT TABLE STRUCTURE
-- ============================================

-- 1. Certifications Table
CREATE TABLE certifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(200) NOT NULL,
  test_code VARCHAR(10) UNIQUE NOT NULL,
  description TEXT,
  total_concepts INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Domains Table  
CREATE TABLE domains (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  certification_id UUID NOT NULL REFERENCES certifications(id) ON DELETE CASCADE,
  name VARCHAR(200) NOT NULL,
  code VARCHAR(20) NOT NULL,
  description TEXT,
  weight_percentage DECIMAL(5,2) DEFAULT 25.00,
  order_index INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(certification_id, code)
);

-- 3. Concepts Table
CREATE TABLE concepts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
  name VARCHAR(200) NOT NULL,
  description TEXT,
  learning_objectives TEXT[],
  difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level >= 1 AND difficulty_level <= 5),
  estimated_study_minutes INTEGER DEFAULT 30,
  order_index INTEGER NOT NULL DEFAULT 0,
  prerequisites UUID[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Content Items Table (our main questions/content table)
CREATE TABLE content_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  concept_id UUID NOT NULL REFERENCES concepts(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL DEFAULT 'question',
  title TEXT NOT NULL,
  content TEXT NOT NULL, -- Store the actual question text here
  explanation TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  estimated_minutes INTEGER NOT NULL DEFAULT 5,
  is_required BOOLEAN NOT NULL DEFAULT true,
  difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level >= 1 AND difficulty_level <= 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Answer Choices Table (linked to content_items via content_item_id)
CREATE TABLE answer_choices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_item_id UUID NOT NULL REFERENCES content_items(id) ON DELETE CASCADE,
  choice_order INTEGER NOT NULL CHECK (choice_order >= 1 AND choice_order <= 4),
  choice_text TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(content_item_id, choice_order)
);

-- 6. User Profiles Table (for user management)
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  subscription_status VARCHAR(50) DEFAULT 'free',
  stripe_customer_id VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Practice Sessions Table
CREATE TABLE practice_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  concept_id UUID NOT NULL REFERENCES concepts(id) ON DELETE CASCADE,
  session_type VARCHAR(50) DEFAULT 'practice',
  questions_attempted INTEGER DEFAULT 0,
  questions_correct INTEGER DEFAULT 0,
  score_percentage DECIMAL(5,2),
  time_spent_seconds INTEGER DEFAULT 0,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Concept Progress Table
CREATE TABLE concept_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  concept_id UUID NOT NULL REFERENCES concepts(id) ON DELETE CASCADE,
  mastery_level DECIMAL(3,2) DEFAULT 0.00 CHECK (mastery_level >= 0.00 AND mastery_level <= 1.00),
  confidence_score INTEGER DEFAULT 1 CHECK (confidence_score >= 1 AND confidence_score <= 5),
  time_spent_minutes INTEGER DEFAULT 0,
  last_studied_at TIMESTAMP WITH TIME ZONE,
  times_reviewed INTEGER DEFAULT 0,
  is_mastered BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, concept_id)
);

-- ============================================
-- STEP 4: CREATE INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_domains_certification_id ON domains(certification_id);
CREATE INDEX idx_concepts_domain_id ON concepts(domain_id);
CREATE INDEX idx_content_items_concept_id ON content_items(concept_id);
CREATE INDEX idx_answer_choices_content_item_id ON answer_choices(content_item_id);
CREATE INDEX idx_practice_sessions_user_id ON practice_sessions(user_id);
CREATE INDEX idx_practice_sessions_concept_id ON practice_sessions(concept_id);
CREATE INDEX idx_concept_progress_user_id ON concept_progress(user_id);

-- ============================================
-- STEP 5: INSERT MATH 902 EXEMPLARY STRUCTURE
-- ============================================

-- Insert Math 902 Certification
INSERT INTO certifications (id, name, test_code, description, total_concepts) VALUES 
('9c8e7f6d-5b4a-3c2d-1e0f-123456789abc', 'Elementary Mathematics (4-8)', '902', 'Mathematics content knowledge for elementary teachers', 16);

-- Insert 4 Domains for Math 902
INSERT INTO domains (id, certification_id, name, code, weight_percentage, order_index) VALUES 
('d1111111-1111-1111-1111-111111111111', '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc', 'Number Concepts and Operations', 'NCO', 25.00, 1),
('d2222222-2222-2222-2222-222222222222', '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc', 'Patterns, Relationships, and Algebraic Reasoning', 'PRAR', 25.00, 2),
('d3333333-3333-3333-3333-333333333333', '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc', 'Geometry, Measurement, and Spatial Reasoning', 'GMSR', 25.00, 3),
('d4444444-4444-4444-4444-444444444444', '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc', 'Data Analysis and Personal Financial Literacy', 'DAPFL', 25.00, 4);

-- Insert 16 Concepts (4 per domain)
INSERT INTO concepts (id, domain_id, name, description, difficulty_level, order_index) VALUES 
-- Domain 1: Number Concepts and Operations
('c1111111-1111-1111-1111-111111111111', 'd1111111-1111-1111-1111-111111111111', 'Place Value and Number Sense', 'Understanding place value in whole numbers and decimals', 1, 1),
('c1111111-1111-1111-1111-111111111112', 'd1111111-1111-1111-1111-111111111111', 'Operations with Whole Numbers', 'Addition, subtraction, multiplication, and division strategies', 2, 2),
('c1111111-1111-1111-1111-111111111113', 'd1111111-1111-1111-1111-111111111111', 'Fractions and Decimals', 'Understanding and operating with fractions and decimals', 3, 3),
('c1111111-1111-1111-1111-111111111114', 'd1111111-1111-1111-1111-111111111111', 'Proportional Reasoning', 'Ratios, proportions, and percentage applications', 4, 4),

-- Domain 2: Patterns, Relationships, and Algebraic Reasoning  
('c2222222-2222-2222-2222-222222222221', 'd2222222-2222-2222-2222-222222222222', 'Patterns and Sequences', 'Identifying and extending patterns in numbers and shapes', 1, 1),
('c2222222-2222-2222-2222-222222222222', 'd2222222-2222-2222-2222-222222222222', 'Algebraic Expressions', 'Writing and evaluating simple algebraic expressions', 2, 2),
('c2222222-2222-2222-2222-222222222223', 'd2222222-2222-2222-2222-222222222222', 'Linear Equations', 'Solving and graphing linear equations and inequalities', 3, 3),
('c2222222-2222-2222-2222-222222222224', 'd2222222-2222-2222-2222-222222222222', 'Functions and Relationships', 'Understanding functions and their representations', 4, 4),

-- Domain 3: Geometry, Measurement, and Spatial Reasoning
('c3333333-3333-3333-3333-333333333331', 'd3333333-3333-3333-3333-333333333333', 'Geometric Shapes and Properties', 'Properties of 2D and 3D shapes', 1, 1),
('c3333333-3333-3333-3333-333333333332', 'd3333333-3333-3333-3333-333333333333', 'Measurement and Units', 'Length, area, volume, weight, and unit conversions', 2, 2),
('c3333333-3333-3333-3333-333333333333', 'd3333333-3333-3333-3333-333333333333', 'Coordinate Geometry', 'Plotting points and basic coordinate plane concepts', 3, 3),
('c3333333-3333-3333-3333-333333333334', 'd3333333-3333-3333-3333-333333333333', 'Transformations and Symmetry', 'Translations, reflections, rotations, and symmetry', 4, 4),

-- Domain 4: Data Analysis and Personal Financial Literacy
('c4444444-4444-4444-4444-444444444441', 'd4444444-4444-4444-4444-444444444444', 'Data Collection and Organization', 'Gathering, organizing, and displaying data', 1, 1),
('c4444444-4444-4444-4444-444444444442', 'd4444444-4444-4444-4444-444444444444', 'Statistical Analysis', 'Mean, median, mode, and interpreting data displays', 2, 2),
('c4444444-4444-4444-4444-444444444443', 'd4444444-4444-4444-4444-444444444444', 'Probability', 'Basic probability concepts and calculations', 3, 3),
('c4444444-4444-4444-4444-444444444444', 'd4444444-4444-4444-4444-444444444444', 'Personal Financial Literacy', 'Money management, budgeting, and financial decision making', 4, 4);

-- ============================================
-- STEP 6: INSERT SAMPLE CONTENT AND QUESTIONS
-- ============================================

-- Sample question for Place Value concept
INSERT INTO content_items (id, concept_id, type, title, content, explanation, order_index, difficulty_level) VALUES 
('a1111111-1111-4111-8111-111111111111', 'c1111111-1111-1111-1111-111111111111', 'question', 'Place Value Understanding', 'What is the value of the digit 7 in the number 4,752?', 'The digit 7 is in the hundreds place, so its value is 7 × 100 = 700.', 1, 1);

-- Answer choices for the place value question
INSERT INTO answer_choices (content_item_id, choice_order, choice_text, is_correct) VALUES 
('a1111111-1111-4111-8111-111111111111', 1, '7', false),
('a1111111-1111-4111-8111-111111111111', 2, '70', false),  
('a1111111-1111-4111-8111-111111111111', 3, '700', true),
('a1111111-1111-4111-8111-111111111111', 4, '7000', false);

-- Sample question for Operations concept
INSERT INTO content_items (id, concept_id, type, title, content, explanation, order_index, difficulty_level) VALUES 
('a2222222-2222-4222-8222-222222222222', 'c1111111-1111-1111-1111-111111111112', 'question', 'Multiplication Strategy', 'Which strategy would be most efficient for calculating 25 × 16?', 'Breaking down 25 × 16 = 25 × (10 + 6) = 250 + 150 = 400 is an efficient mental math strategy.', 1, 2);

-- Answer choices for the operations question
INSERT INTO answer_choices (content_item_id, choice_order, choice_text, is_correct) VALUES 
('a2222222-2222-4222-8222-222222222222', 1, 'Use the standard algorithm', false),
('a2222222-2222-4222-8222-222222222222', 2, 'Break apart using distributive property: 25 × (10 + 6)', true),
('a2222222-2222-4222-8222-222222222222', 3, 'Skip count by 25 sixteen times', false),
('a2222222-2222-4222-8222-222222222222', 4, 'Use repeated addition', false);

-- Sample question for Fractions concept  
INSERT INTO content_items (id, concept_id, type, title, content, explanation, order_index, difficulty_level) VALUES 
('a3333333-3333-4333-8333-333333333333', 'c1111111-1111-1111-1111-111111111113', 'question', 'Fraction Comparison', 'Which fraction is equivalent to 0.75?', '0.75 = 75/100 = 3/4 when reduced to lowest terms.', 1, 3);

-- Answer choices for the fractions question
INSERT INTO answer_choices (content_item_id, choice_order, choice_text, is_correct) VALUES 
('a3333333-3333-4333-8333-333333333333', 1, '2/3', false),
('a3333333-3333-4333-8333-333333333333', 2, '3/4', true),
('a3333333-3333-4333-8333-333333333333', 3, '7/8', false),
('a3333333-3333-4333-8333-333333333333', 4, '4/5', false);

-- ============================================
-- STEP 7: VERIFICATION QUERIES
-- ============================================

-- Verify the structure was created correctly
SELECT 'Clean slate rebuild completed successfully!' as status;
SELECT 'Certification created:' as check_1, name, test_code FROM certifications WHERE test_code = '902';
SELECT 'Domains created:' as check_2, COUNT(*) as domain_count FROM domains WHERE certification_id = '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc';
SELECT 'Concepts created:' as check_3, COUNT(*) as concept_count FROM concepts WHERE domain_id IN (SELECT id FROM domains WHERE certification_id = '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc');
SELECT 'Content items created:' as check_4, COUNT(*) as content_count FROM content_items WHERE concept_id IN (SELECT id FROM concepts WHERE domain_id IN (SELECT id FROM domains WHERE certification_id = '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc'));
SELECT 'Answer choices created:' as check_5, COUNT(*) as answer_count FROM answer_choices WHERE content_item_id IN (SELECT id FROM content_items WHERE concept_id IN (SELECT id FROM concepts WHERE domain_id IN (SELECT id FROM domains WHERE certification_id = '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc')));

-- Test foreign key relationships
SELECT 'Testing foreign keys - should return 0 orphaned records:' as test_fk;
SELECT 'Orphaned content_items:' as orphan_test_1, COUNT(*) FROM content_items ci LEFT JOIN concepts c ON ci.concept_id = c.id WHERE c.id IS NULL;
SELECT 'Orphaned answer_choices:' as orphan_test_2, COUNT(*) FROM answer_choices ac LEFT JOIN content_items ci ON ac.content_item_id = ci.id WHERE ci.id IS NULL;

SELECT '🌸 CertBloom Clean Slate Foundation is ready! Math 902 exemplary study path created.' as final_status;
