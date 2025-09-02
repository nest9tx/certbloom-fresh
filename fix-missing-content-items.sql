-- Create content items for all certifications that have questions but no content
-- This connects the learning interface to the practice questions

WITH certification_concepts AS (
  -- Get concepts that have questions but no content items
  SELECT DISTINCT
    cert.test_code,
    cert.name as cert_name,
    c.id as concept_id,
    c.name as concept_name,
    COUNT(q.id) as question_count
  FROM certifications cert
  JOIN domains d ON d.certification_id = cert.id
  JOIN concepts c ON c.domain_id = d.id
  JOIN questions q ON q.concept_id = c.id
  LEFT JOIN content_items ci ON ci.concept_id = c.id
  WHERE cert.test_code IN ('391', '901', '903', '904', '905')
  AND ci.id IS NULL  -- No content items exist
  GROUP BY cert.test_code, cert.name, c.id, c.name
  HAVING COUNT(q.id) > 0  -- Has questions
)
INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes)
SELECT 
  cc.concept_id,
  'explanation' as type,
  'Introduction to ' || cc.concept_name as title,
  jsonb_build_object(
    'sections', ARRAY[
      'Welcome to ' || cc.concept_name || '! This concept includes ' || cc.question_count || ' practice questions.',
      'Practice questions help you master the key skills and knowledge needed for the ' || cc.cert_name || ' certification.',
      'Each question is designed to match the format and difficulty of actual TExES exam questions.',
      'Take your time to read each question carefully and think through your answer before selecting.',
      'After completing the practice questions, you will receive detailed feedback to help you improve.'
    ]
  ),
  1 as order_index,
  5 as estimated_minutes
FROM certification_concepts cc

UNION ALL

SELECT 
  cc.concept_id,
  'practice' as type,
  'Practice Questions: ' || cc.concept_name as title,
  jsonb_build_object(
    'session_type', 'concept_practice',
    'description', 'Practice questions for mastering ' || cc.concept_name,
    'target_question_count', LEAST(cc.question_count, 15),
    'estimated_minutes', LEAST(cc.question_count, 15) * 2,
    'instructions', 'Complete these practice questions to test your understanding of ' || cc.concept_name || '. Each question follows the format you will see on the actual exam.'
  ),
  2 as order_index,
  LEAST(cc.question_count, 15) * 2 as estimated_minutes
FROM certification_concepts cc

UNION ALL

SELECT 
  cc.concept_id,
  'review' as type,
  'Key Concepts Review: ' || cc.concept_name as title,
  jsonb_build_object(
    'sections', ARRAY[
      'Review the fundamental concepts covered in this section.',
      'Make sure you understand the core principles before moving to the next concept.',
      'If you struggled with any practice questions, consider reviewing this material again.',
      'Focus on areas where you had difficulty - this will help you on the actual exam.'
    ]
  ),
  3 as order_index,
  3 as estimated_minutes
FROM certification_concepts cc;

-- Verification query
SELECT 
  'CONTENT CREATION RESULTS' as status,
  cert.test_code,
  COUNT(DISTINCT c.id) as concepts_with_questions,
  COUNT(DISTINCT ci.id) as content_items_created,
  COUNT(DISTINCT q.id) as total_questions
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
WHERE cert.test_code IN ('391', '901', '903', '904', '905')
GROUP BY cert.test_code
ORDER BY cert.test_code;
