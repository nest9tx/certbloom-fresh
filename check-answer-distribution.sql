-- Quick script to check answer distribution patterns
SELECT 
  c.name as certification,
  q.correct_answer,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY c.name), 2) as percentage
FROM questions q
JOIN concepts con ON q.concept_id = con.id
JOIN certifications c ON con.certification_id = c.id
WHERE q.correct_answer IS NOT NULL
GROUP BY c.name, q.correct_answer
ORDER BY c.name, q.correct_answer;

-- Check if questions have balanced answer choices
SELECT 
  c.name as certification,
  q.id,
  q.correct_answer,
  string_agg(ac.choice_letter || ': ' || LEFT(ac.choice_text, 50), E'\n') as choices
FROM questions q
JOIN concepts con ON q.concept_id = con.id
JOIN certifications c ON con.certification_id = c.id
LEFT JOIN answer_choices ac ON q.id = ac.question_id
WHERE c.test_code != '902'  -- Exclude Math since it's working well
GROUP BY c.name, q.id, q.correct_answer
ORDER BY c.name, q.id
LIMIT 10;
