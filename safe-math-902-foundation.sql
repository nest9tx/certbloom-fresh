-- 🔧 SAFE DATABASE FOUNDATION SCRIPT
-- Handles existing table structures gracefully

-- ============================================
-- STEP 1: SCHEMA COMPATIBILITY CHECK
-- ============================================

-- Function to safely create answer choices regardless of FK column name
CREATE OR REPLACE FUNCTION safe_create_answer_choice(
  p_content_item_id UUID,
  p_choice_order INTEGER,
  p_choice_text TEXT,
  p_is_correct BOOLEAN
) RETURNS VOID AS $$
BEGIN
  -- Check which foreign key column exists in answer_choices
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'answer_choices' AND column_name = 'content_item_id') THEN
    -- Use content_item_id
    INSERT INTO answer_choices (content_item_id, choice_order, choice_text, is_correct)
    VALUES (p_content_item_id, p_choice_order, p_choice_text, p_is_correct)
    ON CONFLICT (content_item_id, choice_order) DO UPDATE SET
      choice_text = EXCLUDED.choice_text,
      is_correct = EXCLUDED.is_correct;
  ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'answer_choices' AND column_name = 'question_id') THEN
    -- Use question_id (legacy)
    INSERT INTO answer_choices (question_id, choice_order, choice_text, is_correct)
    VALUES (p_content_item_id, p_choice_order, p_choice_text, p_is_correct)
    ON CONFLICT (question_id, choice_order) DO UPDATE SET
      choice_text = EXCLUDED.choice_text,
      is_correct = EXCLUDED.is_correct;
  ELSE
    RAISE EXCEPTION 'Answer choices table structure not recognized';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STEP 2: ENSURE CONTENT_ITEMS STRUCTURE
-- ============================================

-- Ensure content_items has all needed columns
ALTER TABLE content_items 
ADD COLUMN IF NOT EXISTS certification_area VARCHAR(50),
ADD COLUMN IF NOT EXISTS subject_area VARCHAR(100),
ADD COLUMN IF NOT EXISTS competency VARCHAR(200),
ADD COLUMN IF NOT EXISTS skill VARCHAR(200),
ADD COLUMN IF NOT EXISTS difficulty_level INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS question_text TEXT;

-- ============================================
-- STEP 3: CREATE MATH 902 FOUNDATION
-- ============================================

-- Clear existing Math 902 data safely
DELETE FROM answer_choices WHERE 
  (content_item_id IN (SELECT id FROM content_items WHERE certification_area = 'MATH-902'))
  OR (question_id IN (SELECT id FROM content_items WHERE certification_area = 'MATH-902'));

DELETE FROM content_items WHERE certification_area = 'MATH-902';

DELETE FROM concept_progress WHERE concept_id IN (
  SELECT co.id FROM concepts co
  JOIN domains d ON co.domain_id = d.id
  JOIN certifications c ON d.certification_id = c.id
  WHERE c.test_code = '902'
);

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

-- Create domains for Math 902
WITH math_cert AS (
  SELECT id as cert_id FROM certifications WHERE test_code = '902'
)
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

-- Create a few sample concepts to test
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
   '[]'::text)
) AS concept_data(name, description, difficulty_level, estimated_study_minutes, order_index, learning_objectives, prerequisites)
ON CONFLICT (domain_id, name) DO UPDATE SET
  description = EXCLUDED.description,
  difficulty_level = EXCLUDED.difficulty_level,
  estimated_study_minutes = EXCLUDED.estimated_study_minutes;

-- ============================================
-- STEP 4: CREATE SAMPLE CONTENT
-- ============================================

-- Create sample content for first concept
WITH first_concept AS (
  SELECT co.id as concept_id, co.name as concept_name
  FROM concepts co
  JOIN domains d ON co.domain_id = d.id
  JOIN certifications c ON d.certification_id = c.id
  WHERE c.test_code = '902' AND co.name = 'Number Theory & Operations'
)
INSERT INTO content_items (
  id, concept_id, type, title, question_text,
  certification_area, subject_area, explanation,
  difficulty_level, competency, skill,
  order_index, estimated_minutes, is_required
)
SELECT 
  gen_random_uuid(),
  concept_id,
  'practice_question',
  'Number Theory Sample Question',
  'Which number is a prime number?',
  'MATH-902',
  'Mathematics',
  'A prime number has exactly two factors: 1 and itself. 7 is prime because its only factors are 1 and 7.',
  2,
  concept_name,
  'Number Theory',
  1,
  3,
  true
FROM first_concept;

-- Add answer choices for the sample question
DO $$
DECLARE
  question_id UUID;
BEGIN
  SELECT id INTO question_id 
  FROM content_items 
  WHERE question_text = 'Which number is a prime number?' 
  AND certification_area = 'MATH-902';
  
  IF question_id IS NOT NULL THEN
    PERFORM safe_create_answer_choice(question_id, 1, '6', false);
    PERFORM safe_create_answer_choice(question_id, 2, '7', true);
    PERFORM safe_create_answer_choice(question_id, 3, '8', false);
    PERFORM safe_create_answer_choice(question_id, 4, '9', false);
    
    RAISE NOTICE 'Created sample question with ID: %', question_id;
  END IF;
END
$$;

-- ============================================
-- VERIFICATION
-- ============================================

-- Show what we created
SELECT 
  'Math 902 Foundation Created' as status,
  (SELECT COUNT(*) FROM certifications WHERE test_code = '902') as certifications,
  (SELECT COUNT(*) FROM domains d JOIN certifications c ON d.certification_id = c.id WHERE c.test_code = '902') as domains,
  (SELECT COUNT(*) FROM concepts co JOIN domains d ON co.domain_id = d.id JOIN certifications c ON d.certification_id = c.id WHERE c.test_code = '902') as concepts,
  (SELECT COUNT(*) FROM content_items WHERE certification_area = 'MATH-902') as content_items,
  (SELECT COUNT(*) FROM answer_choices WHERE 
    (content_item_id IN (SELECT id FROM content_items WHERE certification_area = 'MATH-902'))
    OR (question_id IN (SELECT id FROM content_items WHERE certification_area = 'MATH-902'))
  ) as answer_choices;

RAISE NOTICE 'Safe Math 902 foundation setup complete!';
