-- ENHANCED PRACTICE SESSION FIX
-- This script updates the existing practice session content items 
-- to include proper metadata for loading real questions

-- Update practice session content items to include better metadata
UPDATE content_items 
SET content = jsonb_build_object(
  'session_type', 'full_concept_practice',
  'target_question_count', 15,
  'estimated_minutes', 25,
  'description', 'Complete a comprehensive practice session for ' || 
    (SELECT c.name FROM concepts c WHERE c.id = content_items.concept_id),
  'instructions', 'Work through 15 practice questions to build mastery. Take your time and review explanations.',
  'concept_id', concept_id,
  'difficulty_levels', jsonb_build_array('all'),
  'question_source', 'test_bank'
)
WHERE type = 'practice_question' 
  AND title LIKE 'Full Practice Session:%'
  AND concept_id IN (
    SELECT c.id 
    FROM certifications cert
    JOIN domains d ON d.certification_id = cert.id  
    JOIN concepts c ON c.domain_id = d.id
    WHERE cert.test_code = '902'
  );

-- Verify the update
SELECT 
  c.name as concept_name,
  ci.title,
  ci.type,
  ci.content->'target_question_count' as target_questions,
  ci.content->'estimated_minutes' as estimated_minutes
FROM content_items ci
JOIN concepts c ON c.id = ci.concept_id
JOIN domains d ON d.id = c.domain_id
JOIN certifications cert ON cert.id = d.certification_id
WHERE cert.test_code = '902' 
  AND ci.type = 'practice_question'
  AND ci.title LIKE 'Full Practice Session:%'
ORDER BY c.name;
