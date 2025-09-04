-- Check current content structure for Place Value concept
SELECT 
  'PLACE VALUE CONCEPT CONTENT' as section,
  ci.type,
  ci.title,
  ci.order_index,
  ci.estimated_minutes,
  LENGTH(ci.content::text) as content_length,
  CASE 
    WHEN ci.type = 'practice' THEN 'Practice Session'
    WHEN ci.type = 'question' THEN 'Individual Question'
    ELSE 'Study Material'
  END as category
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
WHERE c.name ILIKE '%Place Value%'
ORDER BY ci.order_index;

-- Check if there are questions available for this concept
SELECT 
  'AVAILABLE QUESTIONS' as section,
  COUNT(*) as total_questions,
  COUNT(ac.id) as questions_with_choices
FROM questions q
LEFT JOIN answer_choices ac ON q.id = ac.question_id
WHERE q.active = true 
  AND (q.tags ? 'place_value' OR q.question_text ILIKE '%place value%');

-- Check practice session configuration
SELECT 
  'PRACTICE SESSIONS' as section,
  ci.content->'target_question_count' as target_questions,
  ci.content->'description' as session_description
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
WHERE c.name ILIKE '%Place Value%' 
  AND ci.type = 'practice';
