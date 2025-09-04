-- Let's see what content actually exists and fix the questions immediately
-- Run this to see current state and add working questions

-- 1. Check what content_items exist for Place Value
SELECT 
  ci.id,
  ci.type,
  ci.title,
  ci.order_index,
  COUNT(ac.id) as answer_count
FROM content_items ci
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
JOIN concepts c ON ci.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense'
GROUP BY ci.id, ci.type, ci.title, ci.order_index
ORDER BY ci.order_index;

-- 2. If no questions exist, let's add them RIGHT NOW
-- Simple, working questions that will show up immediately

INSERT INTO content_items (
  concept_id,
  type,
  title,
  content,
  order_index,
  estimated_minutes
)
SELECT 
  c.id,
  'question',
  'What is the value of 4 in 3,456?',
  'In the number 3,456, what is the value of the digit 4?',
  10,
  2
FROM concepts c
WHERE c.name = 'Place Value and Number Sense'
AND NOT EXISTS (
  SELECT 1 FROM content_items ci2 
  WHERE ci2.concept_id = c.id 
  AND ci2.type = 'question'
  AND ci2.order_index = 10
);

-- Add answer choices for this question
INSERT INTO answer_choices (content_item_id, choice_text, is_correct, choice_order)
SELECT 
  ci.id,
  '4',
  false,
  1
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense'
AND ci.type = 'question'
AND ci.order_index = 10
UNION ALL
SELECT 
  ci.id,
  '40',
  false,
  2
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense'
AND ci.type = 'question'
AND ci.order_index = 10
UNION ALL
SELECT 
  ci.id,
  '400',
  true,
  3
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense'
AND ci.type = 'question'
AND ci.order_index = 10
UNION ALL
SELECT 
  ci.id,
  '4,000',
  false,
  4
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense'
AND ci.type = 'question'
AND ci.order_index = 10;

-- 3. Verify it worked
SELECT 
  ci.title,
  ci.content,
  ac.choice_text,
  ac.is_correct,
  ac.choice_order
FROM content_items ci
JOIN answer_choices ac ON ci.id = ac.content_item_id
JOIN concepts c ON ci.concept_id = c.id
WHERE c.name = 'Place Value and Number Sense'
AND ci.type = 'question'
ORDER BY ci.order_index, ac.choice_order;
