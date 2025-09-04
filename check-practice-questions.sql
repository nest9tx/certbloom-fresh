-- Check what questions exist for practice sessions
SELECT 
  'QUESTIONS TABLE STATUS' as status,
  COUNT(*) as total_questions
FROM questions 
WHERE active = true;

-- Check if any questions have answer choices
SELECT 
  'QUESTIONS WITH CHOICES' as status,
  COUNT(DISTINCT q.id) as questions_with_choices
FROM questions q
JOIN answer_choices ac ON q.id = ac.question_id
WHERE q.active = true;

-- Sample question to see structure
SELECT 
  'SAMPLE QUESTION' as status,
  q.question_text,
  COUNT(ac.id) as choice_count
FROM questions q
LEFT JOIN answer_choices ac ON q.id = ac.question_id
WHERE q.active = true
GROUP BY q.id, q.question_text
LIMIT 1;
