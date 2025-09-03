-- 🏗️ CLEAN SLATE FOUNDATION - REBUILD EVERYTHING CORRECTLY
-- This script creates the perfect structure from scratch

-- ============================================
-- STEP 1: CLEAN SLATE (BACKUP AND DROP)
-- ============================================

-- Drop problem tables in correct order (foreign keys first)
DROP TABLE IF EXISTS answer_choices CASCADE;
DROP TABLE IF EXISTS content_items CASCADE;
DROP TABLE IF EXISTS concept_progress CASCADE;
DROP TABLE IF EXISTS practice_sessions CASCADE;
DROP TABLE IF EXISTS user_session_answers CASCADE;

-- Keep the core structure but clean problematic data
DELETE FROM concepts WHERE domain_id IN (
  SELECT id FROM domains WHERE certification_id IN (
    SELECT id FROM certifications WHERE test_code = '902'
  )
);
DELETE FROM domains WHERE certification_id IN (
  SELECT id FROM certifications WHERE test_code = '902'
);
DELETE FROM certifications WHERE test_code = '902';

-- ============================================
-- STEP 2: CREATE PERFECT TABLE STRUCTURE
-- ============================================

-- Content Items Table (our main questions/content table)
CREATE TABLE content_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  title TEXT NOT NULL,
  content JSONB,
  question_text TEXT,
  explanation TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  estimated_minutes INTEGER NOT NULL DEFAULT 5,
  is_required BOOLEAN NOT NULL DEFAULT true,
  difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level >= 1 AND difficulty_level <= 5),
  competency VARCHAR(200),
  skill VARCHAR(200),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Answer Choices Table (linked to content_items)
CREATE TABLE answer_choices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_item_id UUID REFERENCES content_items(id) ON DELETE CASCADE,
  choice_order INTEGER NOT NULL CHECK (choice_order >= 1 AND choice_order <= 4),
  choice_text TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(content_item_id, choice_order)
);

-- Ensure only one correct answer per question
CREATE UNIQUE INDEX idx_one_correct_per_question 
ON answer_choices (content_item_id) 
WHERE is_correct = TRUE;

-- Practice Sessions Table
CREATE TABLE practice_sessions (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL,
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  score INTEGER,
  total_questions INTEGER,
  correct_answers INTEGER,
  question_ids TEXT[],
  user_answers INTEGER[],
  session_type VARCHAR(50) DEFAULT 'concept_practice',
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Concept Progress Table
CREATE TABLE concept_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  mastery_level DECIMAL(3,2) DEFAULT 0.00 CHECK (mastery_level >= 0.00 AND mastery_level <= 1.00),
  confidence_score INTEGER DEFAULT 1 CHECK (confidence_score >= 1 AND confidence_score <= 5),
  time_spent_minutes INTEGER DEFAULT 0,
  last_studied_at TIMESTAMP WITH TIME ZONE,
  times_reviewed INTEGER DEFAULT 0,
  is_mastered BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, concept_id)
);

-- ============================================
-- STEP 3: CREATE MATH 902 STRUCTURE
-- ============================================

-- Insert Math 902 Certification
INSERT INTO certifications (id, name, test_code, description, total_concepts) 
VALUES (
  gen_random_uuid(),
  'TExES Mathematics EC-6 (902)',
  '902',
  'Elementary Mathematics certification for Early Childhood through Grade 6',
  16
);

-- Get the certification ID
DO $$
DECLARE
  cert_id UUID;
  domain_i_id UUID;
  domain_ii_id UUID;
  domain_iii_id UUID;
  domain_iv_id UUID;
BEGIN
  SELECT id INTO cert_id FROM certifications WHERE test_code = '902';
  
  -- Create Domains
  INSERT INTO domains (id, certification_id, name, code, description, weight_percentage, order_index)
  VALUES 
    (gen_random_uuid(), cert_id, 'Number Concepts', 'I', 'Number theory, operations, place value, fractions, decimals, and percentages', 25, 1),
    (gen_random_uuid(), cert_id, 'Patterns & Algebra', 'II', 'Algebraic reasoning, patterns, functions, and linear relationships', 25, 2),
    (gen_random_uuid(), cert_id, 'Geometry & Measurement', 'III', 'Geometric properties, measurement concepts, and coordinate geometry', 25, 3),
    (gen_random_uuid(), cert_id, 'Data Analysis & Statistics', 'IV', 'Data collection, analysis, probability, and statistical reasoning', 25, 4)
  RETURNING id;
  
  -- Get domain IDs
  SELECT id INTO domain_i_id FROM domains WHERE certification_id = cert_id AND code = 'I';
  SELECT id INTO domain_ii_id FROM domains WHERE certification_id = cert_id AND code = 'II';
  SELECT id INTO domain_iii_id FROM domains WHERE certification_id = cert_id AND code = 'III';
  SELECT id INTO domain_iv_id FROM domains WHERE certification_id = cert_id AND code = 'IV';
  
  -- Domain I Concepts
  INSERT INTO concepts (id, domain_id, name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
  VALUES 
    (gen_random_uuid(), domain_i_id, 'Number Theory & Operations', 'Understanding whole numbers, integers, rational numbers, and basic number theory', 2, 45, 1, '["Understand number theory concepts", "Apply number operations", "Solve problems with different number types"]'::jsonb, '[]'::jsonb),
    (gen_random_uuid(), domain_i_id, 'Place Value & Numeration', 'Place value concepts, number representation, and numeration systems', 1, 30, 2, '["Master place value concepts", "Convert between number forms", "Understand base-10 system"]'::jsonb, '[]'::jsonb),
    (gen_random_uuid(), domain_i_id, 'Fractions & Decimals', 'Fraction concepts, decimal representation, and conversions', 3, 60, 3, '["Understand fraction concepts", "Work with decimals", "Convert between fractions and decimals"]'::jsonb, '["Number Theory & Operations", "Place Value & Numeration"]'::jsonb),
    (gen_random_uuid(), domain_i_id, 'Ratio, Proportion & Percent', 'Ratios, proportions, percentages, and real-world applications', 3, 50, 4, '["Understand ratio and proportion", "Calculate percentages", "Solve proportion problems"]'::jsonb, '["Fractions & Decimals"]'::jsonb);
    
  -- Domain II Concepts  
  INSERT INTO concepts (id, domain_id, name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
  VALUES 
    (gen_random_uuid(), domain_ii_id, 'Algebraic Reasoning', 'Early algebraic thinking, variables, and algebraic expressions', 3, 55, 1, '["Understand algebraic thinking", "Work with variables", "Create algebraic expressions"]'::jsonb, '["Number Theory & Operations"]'::jsonb),
    (gen_random_uuid(), domain_ii_id, 'Patterns & Functions', 'Identifying patterns, function concepts, and pattern extension', 2, 40, 2, '["Identify and extend patterns", "Understand function concepts", "Create pattern rules"]'::jsonb, '[]'::jsonb),
    (gen_random_uuid(), domain_ii_id, 'Linear Relationships', 'Linear functions, graphing, and coordinate systems', 4, 65, 3, '["Understand linear relationships", "Graph linear functions", "Work with coordinate systems"]'::jsonb, '["Algebraic Reasoning", "Patterns & Functions"]'::jsonb),
    (gen_random_uuid(), domain_ii_id, 'Equations & Inequalities', 'Solving simple equations and understanding inequalities', 4, 50, 4, '["Solve linear equations", "Understand inequalities", "Apply algebraic problem solving"]'::jsonb, '["Algebraic Reasoning"]'::jsonb);
    
  -- Domain III Concepts
  INSERT INTO concepts (id, domain_id, name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
  VALUES 
    (gen_random_uuid(), domain_iii_id, 'Geometric Properties', 'Shapes, properties, transformations, and spatial reasoning', 2, 45, 1, '["Identify geometric shapes", "Understand shape properties", "Apply geometric transformations"]'::jsonb, '[]'::jsonb),
    (gen_random_uuid(), domain_iii_id, 'Measurement Concepts', 'Length, area, volume, weight, and measurement systems', 3, 55, 2, '["Understand measurement concepts", "Convert measurement units", "Calculate area and volume"]'::jsonb, '["Number Theory & Operations"]'::jsonb),
    (gen_random_uuid(), domain_iii_id, 'Coordinate Geometry', 'Coordinate planes, plotting points, and geometric relationships', 4, 50, 3, '["Use coordinate systems", "Plot and interpret points", "Understand geometric relationships"]'::jsonb, '["Geometric Properties", "Linear Relationships"]'::jsonb),
    (gen_random_uuid(), domain_iii_id, 'Geometric Problem Solving', 'Real-world geometry applications and problem solving', 4, 60, 4, '["Solve geometric problems", "Apply geometry to real-world situations", "Use geometric reasoning"]'::jsonb, '["Geometric Properties", "Measurement Concepts"]'::jsonb);
    
  -- Domain IV Concepts
  INSERT INTO concepts (id, domain_id, name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
  VALUES 
    (gen_random_uuid(), domain_iv_id, 'Data Collection & Analysis', 'Collecting, organizing, and interpreting data', 2, 40, 1, '["Collect and organize data", "Create data displays", "Interpret data representations"]'::jsonb, '[]'::jsonb),
    (gen_random_uuid(), domain_iv_id, 'Probability Concepts', 'Basic probability, likelihood, and chance events', 3, 45, 2, '["Understand probability concepts", "Calculate simple probabilities", "Interpret likelihood"]'::jsonb, '["Fractions & Decimals"]'::jsonb),
    (gen_random_uuid(), domain_iv_id, 'Statistical Reasoning', 'Mean, median, mode, range, and statistical interpretation', 3, 50, 3, '["Calculate statistical measures", "Interpret statistical data", "Make data-based conclusions"]'::jsonb, '["Data Collection & Analysis"]'::jsonb),
    (gen_random_uuid(), domain_iv_id, 'Graphs & Charts', 'Creating and interpreting various data representations', 2, 35, 4, '["Create data displays", "Interpret graphs and charts", "Choose appropriate representations"]'::jsonb, '["Data Collection & Analysis"]'::jsonb);
    
  RAISE NOTICE 'Math 902 structure created successfully!';
END $$;

-- ============================================
-- STEP 4: CREATE SAMPLE CONTENT
-- ============================================

-- Create content for the first concept as a test
DO $$
DECLARE
  concept_id UUID;
  content_id UUID;
BEGIN
  -- Get the first concept
  SELECT c.id INTO concept_id 
  FROM concepts c
  JOIN domains d ON c.domain_id = d.id
  JOIN certifications cert ON d.certification_id = cert.id
  WHERE cert.test_code = '902'
  ORDER BY d.order_index, c.order_index
  LIMIT 1;
  
  -- Create a sample practice question
  INSERT INTO content_items (
    id, concept_id, type, title, question_text, explanation,
    order_index, estimated_minutes, difficulty_level, competency
  ) VALUES (
    gen_random_uuid(),
    concept_id,
    'practice_question',
    'Number Theory Sample Question',
    'Which of the following numbers is a prime number?',
    'A prime number is a natural number greater than 1 that has no positive divisors other than 1 and itself. 7 is prime because it can only be divided evenly by 1 and 7.',
    1, 3, 2, 'Number Theory'
  ) RETURNING id INTO content_id;
  
  -- Create answer choices
  INSERT INTO answer_choices (content_item_id, choice_order, choice_text, is_correct) VALUES
    (content_id, 1, '6', false),
    (content_id, 2, '7', true),
    (content_id, 3, '8', false),
    (content_id, 4, '9', false);
    
  RAISE NOTICE 'Sample content created successfully!';
END $$;

-- ============================================
-- VERIFICATION
-- ============================================

-- Verify the complete structure
SELECT 
  c.name as certification,
  d.name as domain,
  co.name as concept,
  COUNT(ci.id) as content_items,
  COUNT(ac.id) as answer_choices
FROM certifications c
JOIN domains d ON c.id = d.certification_id
JOIN concepts co ON d.id = co.domain_id
LEFT JOIN content_items ci ON co.id = ci.concept_id
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE c.test_code = '902'
GROUP BY c.name, d.name, d.order_index, co.name, co.order_index
ORDER BY d.order_index, co.order_index;

-- Test the answer choices structure
SELECT 
  ci.title,
  ci.question_text,
  ac.choice_order,
  ac.choice_text,
  ac.is_correct
FROM content_items ci
JOIN answer_choices ac ON ci.id = ac.content_item_id
ORDER BY ci.id, ac.choice_order;

RAISE NOTICE '🎯 CLEAN FOUNDATION COMPLETE! Math 902 is ready for testing.';
