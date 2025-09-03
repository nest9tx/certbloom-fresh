-- 🏗️ CLEAN DATABASE FOUNDATION FOR CERTBLOOM
-- Complete rebuild for exemplary study paths

-- ============================================
-- STEP 1: CLEAN SLATE (OPTIONAL - BACKUP FIRST)
-- ============================================

-- Clean existing problematic data (uncomment if needed)
-- DELETE FROM answer_choices WHERE content_item_id IN (
--   SELECT id FROM content_items WHERE certification_area LIKE '%902%'
-- );
-- DELETE FROM content_items WHERE certification_area LIKE '%902%';
-- DELETE FROM concept_progress WHERE concept_id IN (
--   SELECT id FROM concepts WHERE domain_id IN (
--     SELECT id FROM domains WHERE certification_id IN (
--       SELECT id FROM certifications WHERE test_code = '902'
--     )
--   )
-- );

-- ============================================
-- STEP 2: ENSURE PROPER SCHEMA  
-- ============================================

-- Ensure content_items table has all needed columns
ALTER TABLE content_items 
ADD COLUMN IF NOT EXISTS certification_area VARCHAR(50),
ADD COLUMN IF NOT EXISTS subject_area VARCHAR(100),
ADD COLUMN IF NOT EXISTS competency VARCHAR(200),
ADD COLUMN IF NOT EXISTS skill VARCHAR(200),
ADD COLUMN IF NOT EXISTS difficulty_level INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS question_text TEXT;

-- Update answer_choices to use content_item_id instead of question_id
-- This handles the existing table structure gracefully
DO $$
BEGIN
  -- Check if answer_choices exists and what foreign key it uses
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'answer_choices') THEN
    
    -- If it uses question_id, rename to content_item_id for consistency
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'answer_choices' AND column_name = 'question_id') THEN
      RAISE NOTICE 'Found answer_choices table with question_id - updating for content_items compatibility';
      
      -- Add content_item_id column and copy data if needed
      IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'answer_choices' AND column_name = 'content_item_id') THEN
        ALTER TABLE answer_choices ADD COLUMN content_item_id UUID;
        -- For now, we'll handle the data migration separately
        RAISE NOTICE 'Added content_item_id column to answer_choices';
      END IF;
    END IF;
    
  ELSE
    -- Create answer_choices table if it doesn't exist
    CREATE TABLE answer_choices (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      content_item_id UUID REFERENCES content_items(id) ON DELETE CASCADE,
      choice_order INTEGER NOT NULL CHECK (choice_order >= 1 AND choice_order <= 4),
      choice_text TEXT NOT NULL,
      is_correct BOOLEAN NOT NULL DEFAULT FALSE,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
    RAISE NOTICE 'Created answer_choices table';
  END IF;
  
  -- Ensure required columns exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'answer_choices' AND column_name = 'choice_order') THEN
    ALTER TABLE answer_choices ADD COLUMN choice_order INTEGER NOT NULL DEFAULT 1;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'answer_choices' AND column_name = 'choice_text') THEN
    ALTER TABLE answer_choices ADD COLUMN choice_text TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'answer_choices' AND column_name = 'is_correct') THEN
    ALTER TABLE answer_choices ADD COLUMN is_correct BOOLEAN NOT NULL DEFAULT FALSE;
  END IF;
  
END
$$;

-- Add constraints (drop first to avoid conflicts)
ALTER TABLE answer_choices DROP CONSTRAINT IF EXISTS answer_choices_choice_order_check;
ALTER TABLE answer_choices ADD CONSTRAINT answer_choices_choice_order_check 
  CHECK (choice_order >= 1 AND choice_order <= 4);

-- Create indexes for performance
DROP INDEX IF EXISTS idx_answer_choices_content_item;
CREATE INDEX idx_answer_choices_content_item ON answer_choices(content_item_id);

DROP INDEX IF EXISTS idx_one_correct_per_content_item;
CREATE UNIQUE INDEX idx_one_correct_per_content_item 
ON answer_choices (content_item_id) 
WHERE is_correct = TRUE;

-- ============================================
-- STEP 3: MATH 902 CERTIFICATION STRUCTURE
-- ============================================

-- Insert/Update Math 902 Certification
INSERT INTO certifications (id, name, test_code, description, total_concepts) 
VALUES (
  gen_random_uuid(),
  'TExES Mathematics EC-6 (902)',
  '902',
  'Elementary Mathematics certification for Early Childhood through Grade 6',
  16
) ON CONFLICT (test_code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  total_concepts = EXCLUDED.total_concepts;

-- Get the certification ID for Math 902
WITH math_cert AS (
  SELECT id as cert_id FROM certifications WHERE test_code = '902'
)

-- Insert Math 902 Domains
INSERT INTO domains (id, certification_id, name, code, description, weight_percentage, order_index)
SELECT 
  gen_random_uuid(),
  cert_id,
  name,
  code,
  description,
  weight_percentage,
  order_index
FROM math_cert, (VALUES
  ('Number Concepts', 'I', 'Number theory, operations, place value, fractions, decimals, and percentages', 25, 1),
  ('Patterns & Algebra', 'II', 'Algebraic reasoning, patterns, functions, and linear relationships', 25, 2),
  ('Geometry & Measurement', 'III', 'Geometric properties, measurement concepts, and coordinate geometry', 25, 3),
  ('Data Analysis & Statistics', 'IV', 'Data collection, analysis, probability, and statistical reasoning', 25, 4)
) AS domain_data(name, code, description, weight_percentage, order_index)
ON CONFLICT (certification_id, code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  weight_percentage = EXCLUDED.weight_percentage;

-- ============================================
-- STEP 4: CREATE DOMAIN-SPECIFIC CONCEPTS
-- ============================================

-- Domain I: Number Concepts
WITH domain_i AS (
  SELECT d.id as domain_id 
  FROM domains d 
  JOIN certifications c ON d.certification_id = c.id 
  WHERE c.test_code = '902' AND d.code = 'I'
)
INSERT INTO concepts (id, domain_id, name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
SELECT 
  gen_random_uuid(),
  domain_id,
  name,
  description,
  difficulty_level,
  estimated_study_minutes,
  order_index,
  learning_objectives::jsonb,
  prerequisites::jsonb
FROM domain_i, (VALUES
  ('Number Theory & Operations', 'Understanding whole numbers, integers, rational numbers, and basic number theory', 2, 45, 1, 
   '["Understand number theory concepts", "Apply number operations", "Solve problems with different number types"]'::text, 
   '[]'::text),
  ('Place Value & Numeration', 'Place value concepts, number representation, and numeration systems', 1, 30, 2,
   '["Master place value concepts", "Convert between number forms", "Understand base-10 system"]'::text,
   '[]'::text),
  ('Fractions & Decimals', 'Fraction concepts, decimal representation, and conversions', 3, 60, 3,
   '["Understand fraction concepts", "Work with decimals", "Convert between fractions and decimals"]'::text,
   '["Number Theory & Operations", "Place Value & Numeration"]'::text),
  ('Ratio, Proportion & Percent', 'Ratios, proportions, percentages, and real-world applications', 3, 50, 4,
   '["Understand ratio and proportion", "Calculate percentages", "Solve proportion problems"]'::text,
   '["Fractions & Decimals"]'::text)
) AS concept_data(name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
ON CONFLICT (domain_id, name) DO UPDATE SET
  description = EXCLUDED.description,
  difficulty_level = EXCLUDED.difficulty_level,
  estimated_study_minutes = EXCLUDED.estimated_study_minutes;

-- Domain II: Patterns & Algebra  
WITH domain_ii AS (
  SELECT d.id as domain_id 
  FROM domains d 
  JOIN certifications c ON d.certification_id = c.id 
  WHERE c.test_code = '902' AND d.code = 'II'
)
INSERT INTO concepts (id, domain_id, name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
SELECT 
  gen_random_uuid(),
  domain_id,
  name,
  description,
  difficulty_level,
  estimated_study_minutes,
  order_index,
  learning_objectives::jsonb,
  prerequisites::jsonb
FROM domain_ii, (VALUES
  ('Algebraic Reasoning', 'Early algebraic thinking, variables, and algebraic expressions', 3, 55, 1,
   '["Understand algebraic thinking", "Work with variables", "Create algebraic expressions"]'::text,
   '["Number Theory & Operations"]'::text),
  ('Patterns & Functions', 'Identifying patterns, function concepts, and pattern extension', 2, 40, 2,
   '["Identify and extend patterns", "Understand function concepts", "Create pattern rules"]'::text,
   '[]'::text),
  ('Linear Relationships', 'Linear functions, graphing, and coordinate systems', 4, 65, 3,
   '["Understand linear relationships", "Graph linear functions", "Work with coordinate systems"]'::text,
   '["Algebraic Reasoning", "Patterns & Functions"]'::text),
  ('Equations & Inequalities', 'Solving simple equations and understanding inequalities', 4, 50, 4,
   '["Solve linear equations", "Understand inequalities", "Apply algebraic problem solving"]'::text,
   '["Algebraic Reasoning"]'::text)
) AS concept_data(name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
ON CONFLICT (domain_id, name) DO UPDATE SET
  description = EXCLUDED.description,
  difficulty_level = EXCLUDED.difficulty_level,
  estimated_study_minutes = EXCLUDED.estimated_study_minutes;

-- Domain III: Geometry & Measurement
WITH domain_iii AS (
  SELECT d.id as domain_id 
  FROM domains d 
  JOIN certifications c ON d.certification_id = c.id 
  WHERE c.test_code = '902' AND d.code = 'III'
)
INSERT INTO concepts (id, domain_id, name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
SELECT 
  gen_random_uuid(),
  domain_id,
  name,
  description,
  difficulty_level,
  estimated_study_minutes,
  order_index,
  learning_objectives::jsonb,
  prerequisites::jsonb
FROM domain_iii, (VALUES
  ('Geometric Properties', 'Shapes, properties, transformations, and spatial reasoning', 2, 45, 1,
   '["Identify geometric shapes", "Understand shape properties", "Apply geometric transformations"]'::text,
   '[]'::text),
  ('Measurement Concepts', 'Length, area, volume, weight, and measurement systems', 3, 55, 2,
   '["Understand measurement concepts", "Convert measurement units", "Calculate area and volume"]'::text,
   '["Number Theory & Operations"]'::text),
  ('Coordinate Geometry', 'Coordinate planes, plotting points, and geometric relationships', 4, 50, 3,
   '["Use coordinate systems", "Plot and interpret points", "Understand geometric relationships"]'::text,
   '["Geometric Properties", "Linear Relationships"]'::text),
  ('Geometric Problem Solving', 'Real-world geometry applications and problem solving', 4, 60, 4,
   '["Solve geometric problems", "Apply geometry to real-world situations", "Use geometric reasoning"]'::text,
   '["Geometric Properties", "Measurement Concepts"]'::text)
) AS concept_data(name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
ON CONFLICT (domain_id, name) DO UPDATE SET
  description = EXCLUDED.description,
  difficulty_level = EXCLUDED.difficulty_level,
  estimated_study_minutes = EXCLUDED.estimated_study_minutes;

-- Domain IV: Data Analysis & Statistics
WITH domain_iv AS (
  SELECT d.id as domain_id 
  FROM domains d 
  JOIN certifications c ON d.certification_id = c.id 
  WHERE c.test_code = '902' AND d.code = 'IV'
)
INSERT INTO concepts (id, domain_id, name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
SELECT 
  gen_random_uuid(),
  domain_id,
  name,
  description,
  difficulty_level,
  estimated_study_minutes,
  order_index,
  learning_objectives::jsonb,
  prerequisites::jsonb
FROM domain_iv, (VALUES
  ('Data Collection & Analysis', 'Collecting, organizing, and interpreting data', 2, 40, 1,
   '["Collect and organize data", "Create data displays", "Interpret data representations"]'::text,
   '[]'::text),
  ('Probability Concepts', 'Basic probability, likelihood, and chance events', 3, 45, 2,
   '["Understand probability concepts", "Calculate simple probabilities", "Interpret likelihood"]'::text,
   '["Fractions & Decimals"]'::text),
  ('Statistical Reasoning', 'Mean, median, mode, range, and statistical interpretation', 3, 50, 3,
   '["Calculate statistical measures", "Interpret statistical data", "Make data-based conclusions"]'::text,
   '["Data Collection & Analysis"]'::text),
  ('Graphs & Charts', 'Creating and interpreting various data representations', 2, 35, 4,
   '["Create data displays", "Interpret graphs and charts", "Choose appropriate representations"]'::text,
   '["Data Collection & Analysis"]'::text)
) AS concept_data(name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
ON CONFLICT (domain_id, name) DO UPDATE SET
  description = EXCLUDED.description,
  difficulty_level = EXCLUDED.difficulty_level,
  estimated_study_minutes = EXCLUDED.estimated_study_minutes;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Verify the structure
SELECT 
  c.name as certification,
  c.test_code,
  d.name as domain,
  d.code as domain_code,
  COUNT(co.id) as concept_count
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts co ON d.id = co.domain_id
WHERE c.test_code = '902'
GROUP BY c.name, c.test_code, d.name, d.code, d.order_index
ORDER BY d.order_index;

-- Show all concepts for Math 902
SELECT 
  d.name as domain,
  co.name as concept,
  co.difficulty_level,
  co.estimated_study_minutes,
  co.order_index
FROM certifications c
JOIN domains d ON c.id = d.certification_id
JOIN concepts co ON d.id = co.domain_id
WHERE c.test_code = '902'
ORDER BY d.order_index, co.order_index;
