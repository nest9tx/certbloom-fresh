-- COMPLETE 391 EC-6 SETUP - PROPER COMPOSITE APPROACH
-- This makes 391 reference the 900 series tests instead of duplicating content

-- Step 1: Ensure 391 certification exists
INSERT INTO certifications (name, test_code, description) VALUES
  ('TExES Core Subjects EC-6 (391)', '391', 'Early Childhood through 6th Grade - All core subjects')
ON CONFLICT (test_code) DO NOTHING;

-- Step 2: For immediate functionality, let's create a simple approach
-- Create 391 domains that will show concepts from 900 series
INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index)
SELECT 
  c.id,
  domain_name,
  domain_code,
  domain_description,
  domain_weight,
  domain_order
FROM certifications c,
(VALUES
  ('English Language Arts and Reading', 'COMPOSITE_ELA', 'All ELA concepts from test 901', 30.0, 1),
  ('Mathematics', 'COMPOSITE_MATH', 'All Math concepts from test 902', 25.0, 2),
  ('Social Studies', 'COMPOSITE_SS', 'All Social Studies concepts from test 903', 22.5, 3),
  ('Science', 'COMPOSITE_SCI', 'All Science concepts from test 904', 22.5, 4)
) AS domains(domain_name, domain_code, domain_description, domain_weight, domain_order)
WHERE c.test_code = '391'
ON CONFLICT DO NOTHING;

-- Step 3: Create "pointer" concepts that reference the 900 series
-- These act as placeholders that will pull questions from the actual 900 series concepts
INSERT INTO concepts (domain_id, name, description, difficulty_level)
SELECT 
  d.id,
  'All ' || substring(d.name from 1 for 20) || ' Concepts',
  'Combined practice from all ' || d.name || ' topics covered in the individual subject tests',
  2
FROM domains d
JOIN certifications c ON d.certification_id = c.id
WHERE c.test_code = '391'
ON CONFLICT DO NOTHING;

-- Step 4: Add content items that will redirect to comprehensive practice
INSERT INTO content_items (concept_id, title, type, content, estimated_minutes, order_index)
SELECT 
  concepts.id,
  'Comprehensive Practice: ' || d.name,
  'practice_question'::content_type,
  jsonb_build_object(
    'session_type', 'composite_practice',
    'description', 'Practice questions covering all ' || d.name || ' concepts from the individual subject test',
    'source_test_code', CASE 
      WHEN d.code = 'COMPOSITE_ELA' THEN '901'
      WHEN d.code = 'COMPOSITE_MATH' THEN '902' 
      WHEN d.code = 'COMPOSITE_SS' THEN '903'
      WHEN d.code = 'COMPOSITE_SCI' THEN '904'
    END,
    'target_question_count', 25,
    'estimated_minutes', 30
  ),
  30,
  1
FROM concepts
JOIN domains d ON concepts.domain_id = d.id
JOIN certifications c ON d.certification_id = c.id
WHERE c.test_code = '391'
ON CONFLICT DO NOTHING;

-- Step 5: Also add study content
INSERT INTO content_items (concept_id, title, type, content, estimated_minutes, order_index)
SELECT 
  concepts.id,
  'Study Guide: ' || d.name,
  'text_explanation'::content_type,
  jsonb_build_object(
    'sections', ARRAY[
      'Overview of ' || d.name || ' for EC-6 teachers',
      'Key concepts you must master',
      'Common question types on the exam',
      'Study strategies and tips'
    ]
  ),
  15,
  0
FROM concepts
JOIN domains d ON concepts.domain_id = d.id
JOIN certifications c ON d.certification_id = c.id
WHERE c.test_code = '391'
ON CONFLICT DO NOTHING;

-- Step 6: Verification
SELECT 
  '🎯 391 SETUP COMPLETE' as result,
  c.test_code,
  c.name,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT concepts.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
WHERE c.test_code = '391'
GROUP BY c.id, c.name, c.test_code;

-- Show the structure
SELECT 
  '📋 391 STRUCTURE' as info,
  d.name as domain,
  concepts.name as concept,
  ci.title as content_title,
  ci.type as content_type
FROM certifications c
JOIN domains d ON d.certification_id = c.id
JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
WHERE c.test_code = '391'
ORDER BY d.order_index, ci.order_index;
