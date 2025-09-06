-- 🔍 VERIFY DATABASE ENHANCEMENTS
-- Quick verification of our new educational content

-- 1. Check learning modules for Place Value
SELECT 
  module_type,
  title,
  estimated_minutes,
  order_index
FROM learning_modules lm
JOIN concepts c ON lm.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense'
ORDER BY order_index;

-- 2. Check practice tests
SELECT 
  title,
  question_count,
  time_limit_minutes,
  test_type
FROM practice_tests pt
JOIN concepts c ON pt.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense';

-- 3. Check question bank
SELECT 
  question_text,
  cognitive_level,
  difficulty_level,
  tags
FROM question_bank qb
JOIN concepts c ON qb.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense';

-- 4. Check answer choices
SELECT 
  ac.choice_text,
  ac.is_correct,
  ac.explanation
FROM answer_choices ac
JOIN question_bank qb ON ac.question_id = qb.id
JOIN concepts c ON qb.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense'
ORDER BY ac.choice_order;

-- 5. Summary counts
SELECT 
  'Learning Modules' as content_type,
  COUNT(*) as count
FROM learning_modules lm
JOIN concepts c ON lm.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense'

UNION ALL

SELECT 
  'Practice Tests' as content_type,
  COUNT(*) as count
FROM practice_tests pt
JOIN concepts c ON pt.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense'

UNION ALL

SELECT 
  'Questions' as content_type,
  COUNT(*) as count
FROM question_bank qb
JOIN concepts c ON qb.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense'

UNION ALL

SELECT 
  'Answer Choices' as content_type,
  COUNT(*) as count
FROM answer_choices ac
JOIN question_bank qb ON ac.question_id = qb.id
JOIN concepts c ON qb.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense';
