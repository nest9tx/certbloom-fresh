-- SIMPLIFIED MANUAL FIX
-- Copy and paste this into Supabase SQL Editor to fix the study path

-- First, let's check what content_type enum values are allowed
SELECT unnest(enum_range(NULL::content_type)) as valid_content_types;

-- If the above enum types don't include 'practice', 'explanation', 'review', 
-- we'll need to use the existing valid types. Let's also check current content_items
SELECT DISTINCT type FROM content_items LIMIT 10;

-- Insert content items for all Math 902 concepts that don't have any
WITH math_concepts AS (
  SELECT c.id, c.name
  FROM certifications cert
  JOIN domains d ON d.certification_id = cert.id  
  JOIN concepts c ON c.domain_id = d.id
  WHERE cert.test_code = '902'
)
INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes, is_required)
SELECT 
  mc.id,
  'text_explanation'::content_type,
  'Introduction to ' || mc.name,
  jsonb_build_object(
    'sections', jsonb_build_array(
      'Welcome to ' || mc.name || '! This concept includes comprehensive practice questions to help you master key skills.',
      'You will work through varied difficulty levels to build mastery.',
      'Take your time and focus on understanding each problem-solving strategy.'
    )
  ),
  1,
  5,
  true
FROM math_concepts mc
WHERE mc.id NOT IN (SELECT DISTINCT concept_id FROM content_items WHERE concept_id IS NOT NULL)

UNION ALL

SELECT 
  mc.id,
  'practice_question'::content_type,  
  'Full Practice Session: ' || mc.name,
  jsonb_build_object(
    'question', 'Complete a comprehensive practice session for ' || mc.name,
    'description', 'This session includes all available questions for this concept with varied difficulty levels.',
    'session_type', 'full_concept_practice',
    'concept_id', mc.id
  ),
  2,
  25,
  true
FROM math_concepts mc
WHERE mc.id NOT IN (SELECT DISTINCT concept_id FROM content_items WHERE concept_id IS NOT NULL)

UNION ALL

SELECT 
  mc.id,
  'interactive_example'::content_type,
  'Mastery Review: ' || mc.name, 
  jsonb_build_object(
    'steps', jsonb_build_array(
      'Review your performance on practice questions',
      'Identify areas of strength and growth opportunities', 
      'Plan next steps for continued learning'
    ),
    'example', 'Reflect on your understanding of ' || mc.name
  ),
  3,
  10,
  true
FROM math_concepts mc
WHERE mc.id NOT IN (SELECT DISTINCT concept_id FROM content_items WHERE concept_id IS NOT NULL);

-- Verify results
SELECT 
  c.name as concept_name,
  COUNT(ci.id) as content_items_count,
  COUNT(q.id) as questions_count
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id  
LEFT JOIN content_items ci ON ci.concept_id = c.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY c.id, c.name
ORDER BY c.name;
