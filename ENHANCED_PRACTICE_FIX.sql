-- ENHANCED PRACTICE SESSION FIX
-- This updates the practice session content items to properly connect to the question bank

-- Update all practice_question type content items to include proper session metadata
UPDATE content_items 
SET content = jsonb_build_object(
  'session_type', 'full_concept_practice',
  'target_question_count', 25,
  'estimated_minutes', 25,
  'description', 'Complete a comprehensive practice session with real exam questions for ' || title,
  'instructions', 'This session will present 25 questions from the test bank to help you master this concept.',
  'concept_id', concept_id,
  'difficulty_levels', jsonb_build_array('beginner', 'intermediate', 'advanced'),
  'question_source', 'test_bank'
)
WHERE type = 'practice_question' 
AND title LIKE 'Full Practice Session:%';

-- Verify the update
SELECT 
  c.name as concept_name,
  ci.title,
  ci.content->'target_question_count' as target_questions,
  ci.content->'session_type' as session_type
FROM content_items ci
JOIN concepts c ON c.id = ci.concept_id
JOIN domains d ON d.id = c.domain_id
JOIN certifications cert ON cert.id = d.certification_id
WHERE cert.test_code = '902' 
AND ci.type = 'practice_question'
ORDER BY c.name;
