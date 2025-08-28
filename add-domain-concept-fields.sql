-- Add Domain and Concept Fields to Questions Table
-- Run this in Supabase SQL Editor

-- 1. Add domain column (for organizing questions by subject area)
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS domain TEXT;

-- 2. Add concept column (for specific topic within domain)
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS concept TEXT;

-- 3. Add some example domains and concepts to existing questions
-- Update questions with sample domain/concept data based on certification

-- For Math questions, add appropriate domains
UPDATE questions 
SET 
  domain = CASE 
    WHEN question_text ILIKE '%digit%' OR question_text ILIKE '%number%' OR question_text ILIKE '%value%' THEN 'Number Concepts'
    WHEN question_text ILIKE '%equation%' OR question_text ILIKE '%solve%' OR question_text ILIKE '%reasoning%' THEN 'Algebraic Thinking'
    WHEN question_text ILIKE '%quarter%' OR question_text ILIKE '%dime%' OR question_text ILIKE '%pennies%' THEN 'Measurement'
    WHEN question_text ILIKE '%pattern%' OR question_text ILIKE '%sequence%' THEN 'Patterns & Functions'
    WHEN question_text ILIKE '%estimation%' OR question_text ILIKE '%estimate%' THEN 'Problem Solving'
    ELSE 'General Mathematics'
  END,
  concept = CASE 
    WHEN question_text ILIKE '%digit%' AND question_text ILIKE '%value%' THEN 'Place Value'
    WHEN question_text ILIKE '%equation%' THEN 'Solving Equations'
    WHEN question_text ILIKE '%reasoning%' THEN 'Mathematical Reasoning'
    WHEN question_text ILIKE '%quarter%' OR question_text ILIKE '%dime%' THEN 'Money & Decimals'
    WHEN question_text ILIKE '%pattern%' THEN 'Pattern Recognition'
    WHEN question_text ILIKE '%estimation%' THEN 'Estimation Strategies'
    ELSE 'Basic Concepts'
  END
WHERE certification_id IN (
  SELECT id FROM certifications 
  WHERE name ILIKE '%math%' OR test_code IN ('902', '160')
);

-- For any remaining questions without domain/concept, set defaults
UPDATE questions 
SET 
  domain = 'General Education',
  concept = 'Foundational Skills'
WHERE domain IS NULL OR domain = '';

-- 4. Create an index on domain and concept for better performance
CREATE INDEX IF NOT EXISTS idx_questions_domain ON questions(domain);
CREATE INDEX IF NOT EXISTS idx_questions_concept ON questions(concept);

-- 5. Verify the updates
SELECT 
  domain,
  concept,
  COUNT(*) as question_count
FROM questions 
GROUP BY domain, concept
ORDER BY domain, concept;
