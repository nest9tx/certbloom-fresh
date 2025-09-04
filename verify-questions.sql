-- Verify questions are properly set up
SELECT 
  'CONTENT ITEMS OF TYPE QUESTION' as status,
  ci.id,
  ci.title,
  LEFT(ci.content::text, 100) as question_preview,
  COUNT(ac.id) as answer_choices_count
FROM content_items ci
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE ci.type = 'question'
GROUP BY ci.id, ci.title, ci.content
ORDER BY ci.created_at;

-- Check if we have Math 902 questions specifically
SELECT 
  'MATH 902 QUESTIONS STATUS' as status,
  COUNT(*) as total_questions,
  COUNT(CASE WHEN ac.content_item_id IS NOT NULL THEN 1 END) as questions_with_choices
FROM content_items ci
JOIN concepts co ON ci.concept_id = co.id
JOIN domains d ON co.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE cert.test_code = '902' AND ci.type = 'question';
