-- CREATE PRACTICE CONTENT FOR ALL CERTIFICATIONS
-- This adds practice sessions for each concept so they appear in study-path

INSERT INTO content_items (concept_id, title, content_type, content_data, estimated_minutes, order_index)
SELECT 
  concepts.id,
  'Practice Session: ' || concepts.name,
  'interactive_example',
  jsonb_build_object(
    'session_type', 'full_concept_practice',
    'description', 'Complete practice questions for ' || concepts.name || ' in ' || d.name,
    'target_question_count', 15,
    'estimated_minutes', 20
  ),
  20,
  1
FROM concepts
JOIN domains d ON concepts.domain_id = d.id
JOIN certifications c ON d.certification_id = c.id
WHERE c.test_code IN ('391', '901', '902', '903', '904', '905')
  AND NOT EXISTS (
    -- Don't create duplicates
    SELECT 1 FROM content_items ci 
    WHERE ci.concept_id = concepts.id AND ci.content_type = 'interactive_example'
  );

-- Also add some explanatory content for better learning experience
INSERT INTO content_items (concept_id, title, content_type, content_data, estimated_minutes, order_index)
SELECT 
  concepts.id,
  'Learn: ' || concepts.name,
  'text_explanation',
  jsonb_build_object(
    'sections', ARRAY[
      'Core principles and foundations',
      'Key concepts you need to master',
      'Common applications and examples',
      'Tips for exam success'
    ]
  ),
  10,
  0
FROM concepts
JOIN domains d ON concepts.domain_id = d.id
JOIN certifications c ON d.certification_id = c.id
WHERE c.test_code IN ('391', '901', '902', '903', '904', '905')
  AND NOT EXISTS (
    -- Don't create duplicates
    SELECT 1 FROM content_items ci 
    WHERE ci.concept_id = concepts.id AND ci.content_type = 'text_explanation'
  );

-- Verification: Show content availability
SELECT 
  c.test_code,
  c.name,
  COUNT(DISTINCT concepts.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items,
  COUNT(DISTINCT CASE WHEN ci.content_type = 'interactive_example' THEN ci.id END) as practice_sessions,
  COUNT(DISTINCT CASE WHEN ci.content_type = 'text_explanation' THEN ci.id END) as explanations
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
WHERE c.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY c.id, c.name, c.test_code
ORDER BY c.test_code;
