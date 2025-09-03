#!/bin/bash

# Check answer distribution patterns
echo "=== Answer Distribution Analysis ==="
psql "postgresql://postgres.atfobdrnloxntyxrjvwj:Lumina-supabae-2024@aws-0-us-west-1.pooler.supabase.com:6543/postgres" << 'EOF'

-- Check answer distribution by certification
SELECT 
  c.name as certification,
  q.correct_answer,
  COUNT(*) as count
FROM questions q
JOIN concepts con ON q.concept_id = con.id
JOIN certifications c ON con.certification_id = c.id
WHERE q.correct_answer IS NOT NULL
GROUP BY c.name, q.correct_answer
ORDER BY c.name, q.correct_answer;

EOF

echo -e "\n=== Sample Questions with Answers ==="
psql "postgresql://postgres.atfobdrnloxntyxrjvwj:Lumina-supabae-2024@aws-0-us-west-1.pooler.supabase.com:6543/postgres" << 'EOF'

-- Sample questions from non-Math certifications
SELECT 
  c.test_code,
  LEFT(q.question_text, 80) as question,
  q.correct_answer,
  COUNT(ac.id) as num_choices
FROM questions q
JOIN concepts con ON q.concept_id = con.id
JOIN certifications c ON con.certification_id = c.id
LEFT JOIN answer_choices ac ON q.id = ac.question_id
WHERE c.test_code != '902'
GROUP BY c.test_code, q.id, q.question_text, q.correct_answer
ORDER BY c.test_code, q.id
LIMIT 10;

EOF
