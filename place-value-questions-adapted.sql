-- Place Value Questions - Adapted for Existing Schema
-- This creates question content_items and links answer_choices to them

-- EASY QUESTIONS (4 questions as content_items)
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
  'Place Value - Easy Question 1',
  'In the number 3,456, what is the value of the digit 4?',
  3,
  1
FROM concepts c
WHERE c.name = 'Place Value and Number Sense'
UNION ALL
SELECT 
  c.id,
  'question',
  'Place Value - Easy Question 2', 
  'Which number is greater: 5,234 or 5,324?',
  4,
  1
FROM concepts c
WHERE c.name = 'Place Value and Number Sense'
UNION ALL
SELECT 
  c.id,
  'question',
  'Place Value - Easy Question 3',
  'In the decimal 0.567, which digit is in the tenths place?',
  5,
  1
FROM concepts c
WHERE c.name = 'Place Value and Number Sense'
UNION ALL
SELECT 
  c.id,
  'question',
  'Place Value - Easy Question 4',
  'Round 847 to the nearest hundred.',
  6,
  1
FROM concepts c
WHERE c.name = 'Place Value and Number Sense';

-- Get the question content_item IDs
WITH question_items AS (
  SELECT ci.id, ci.title, ci.content,
    ROW_NUMBER() OVER (ORDER BY ci.order_index) as question_num
  FROM content_items ci
  JOIN concepts c ON ci.concept_id = c.id
  WHERE c.name = 'Place Value and Number Sense'
  AND ci.type = 'question'
  AND ci.order_index >= 3
  ORDER BY ci.order_index
  LIMIT 4
)

-- Answer choices for Question 1: "In the number 3,456, what is the value of the digit 4?"
INSERT INTO answer_choices (content_item_id, choice_text, is_correct, choice_order, explanation)
SELECT q.id, '4', false, 1, 'This is just the digit itself, not its place value.'
FROM question_items q WHERE question_num = 1
UNION ALL
SELECT q.id, '40', false, 2, 'This would be correct if 4 were in the tens place.'
FROM question_items q WHERE question_num = 1
UNION ALL
SELECT q.id, '400', true, 3, 'Correct! The digit 4 is in the hundreds place, so its value is 4 × 100 = 400.'
FROM question_items q WHERE question_num = 1
UNION ALL
SELECT q.id, '4,000', false, 4, 'This would be correct if 4 were in the thousands place.'
FROM question_items q WHERE question_num = 1

UNION ALL

-- Answer choices for Question 2: "Which number is greater: 5,234 or 5,324?"
SELECT q.id, '5,234', false, 1, 'Compare the hundreds place: 2 < 3, so this number is smaller.'
FROM question_items q WHERE question_num = 2
UNION ALL
SELECT q.id, '5,324', true, 2, 'Correct! In the hundreds place, 3 > 2, making this number greater.'
FROM question_items q WHERE question_num = 2
UNION ALL
SELECT q.id, 'They are equal', false, 3, 'The numbers differ in the hundreds place (2 vs 3).'
FROM question_items q WHERE question_num = 2
UNION ALL
SELECT q.id, 'Cannot determine', false, 4, 'We can compare these numbers by looking at place values.'
FROM question_items q WHERE question_num = 2

UNION ALL

-- Answer choices for Question 3: "In the decimal 0.567, which digit is in the tenths place?"
SELECT q.id, '0', false, 1, 'The 0 is in the ones place, before the decimal point.'
FROM question_items q WHERE question_num = 3
UNION ALL
SELECT q.id, '5', true, 2, 'Correct! The tenths place is the first position after the decimal point.'
FROM question_items q WHERE question_num = 3
UNION ALL
SELECT q.id, '6', false, 3, 'The 6 is in the hundredths place (second position after decimal).'
FROM question_items q WHERE question_num = 3
UNION ALL
SELECT q.id, '7', false, 4, 'The 7 is in the thousandths place (third position after decimal).'
FROM question_items q WHERE question_num = 3

UNION ALL

-- Answer choices for Question 4: "Round 847 to the nearest hundred"
SELECT q.id, '800', true, 1, 'Correct! Look at tens place (4). Since 4 < 5, round down to 800.'
FROM question_items q WHERE question_num = 4
UNION ALL
SELECT q.id, '850', false, 2, 'This would be rounding to the nearest fifty, not hundred.'
FROM question_items q WHERE question_num = 4
UNION ALL
SELECT q.id, '900', false, 3, 'Since the tens digit (4) is less than 5, we round down, not up.'
FROM question_items q WHERE question_num = 4
UNION ALL
SELECT q.id, '840', false, 4, 'This would be rounding to the nearest ten, not hundred.'
FROM question_items q WHERE question_num = 4;
