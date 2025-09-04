-- Place Value Questions Bank (12 questions across difficulty levels)
-- Run this after the previous script

-- EASY QUESTIONS (4 questions - foundational understanding)
INSERT INTO questions (concept_id, question_text, explanation, difficulty_level, estimated_time)
SELECT 
  c.id,
  'In the number 3,456, what is the value of the digit 4?',
  'The digit 4 is in the hundreds place, so its value is 4 × 100 = 400.',
  'easy',
  45
FROM concepts c
WHERE c.name = 'Place Value and Number Sense'
UNION ALL
SELECT 
  c.id,
  'Which number is greater: 5,234 or 5,324?',
  'Compare from left to right. Both start with 5, but in the hundreds place, 3 > 2, so 5,324 > 5,234.',
  'easy', 
  45
FROM concepts c
WHERE c.name = 'Place Value and Number Sense'
UNION ALL
SELECT 
  c.id,
  'In the decimal 0.567, which digit is in the tenths place?',
  'The tenths place is the first position after the decimal point, which contains the digit 5.',
  'easy',
  40
FROM concepts c
WHERE c.name = 'Place Value and Number Sense'
UNION ALL  
SELECT 
  c.id,
  'Round 847 to the nearest hundred.',
  'Look at the tens place (4). Since 4 < 5, round down to 800.',
  'easy',
  50
FROM concepts c
WHERE c.name = 'Place Value and Number Sense';

-- Get question IDs for answer choices
WITH question_ids AS (
  SELECT q.id, q.question_text,
    ROW_NUMBER() OVER (ORDER BY q.created_at) as question_num
  FROM questions q
  JOIN concepts c ON q.concept_id = c.id
  WHERE c.name = 'Place Value and Number Sense'
  AND q.difficulty_level = 'easy'
  ORDER BY q.created_at DESC
  LIMIT 4
)

-- Answer choices for Easy Question 1: "In the number 3,456, what is the value of the digit 4?"
INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT q.id, '4', false, 1, 'This is just the digit itself, not its place value.' 
FROM question_ids q WHERE question_num = 4
UNION ALL
SELECT q.id, '40', false, 2, 'This would be correct if 4 were in the tens place.'
FROM question_ids q WHERE question_num = 4  
UNION ALL
SELECT q.id, '400', true, 3, 'Correct! The digit 4 is in the hundreds place, so its value is 4 × 100 = 400.'
FROM question_ids q WHERE question_num = 4
UNION ALL
SELECT q.id, '4,000', false, 4, 'This would be correct if 4 were in the thousands place.'
FROM question_ids q WHERE question_num = 4

UNION ALL

-- Answer choices for Easy Question 2: "Which number is greater: 5,234 or 5,324?"
SELECT q.id, '5,234', false, 1, 'Compare the hundreds place: 2 < 3, so this number is smaller.'
FROM question_ids q WHERE question_num = 3
UNION ALL  
SELECT q.id, '5,324', true, 2, 'Correct! In the hundreds place, 3 > 2, making this number greater.'
FROM question_ids q WHERE question_num = 3
UNION ALL
SELECT q.id, 'They are equal', false, 3, 'The numbers differ in the hundreds place (2 vs 3).'
FROM question_ids q WHERE question_num = 3
UNION ALL
SELECT q.id, 'Cannot determine', false, 4, 'We can compare these numbers by looking at place values.'
FROM question_ids q WHERE question_num = 3

UNION ALL

-- Answer choices for Easy Question 3: "In the decimal 0.567, which digit is in the tenths place?"
SELECT q.id, '0', false, 1, 'The 0 is in the ones place, before the decimal point.'
FROM question_ids q WHERE question_num = 2
UNION ALL
SELECT q.id, '5', true, 2, 'Correct! The tenths place is the first position after the decimal point.'
FROM question_ids q WHERE question_num = 2
UNION ALL  
SELECT q.id, '6', false, 3, 'The 6 is in the hundredths place (second position after decimal).'
FROM question_ids q WHERE question_num = 2
UNION ALL
SELECT q.id, '7', false, 4, 'The 7 is in the thousandths place (third position after decimal).'
FROM question_ids q WHERE question_num = 2

UNION ALL

-- Answer choices for Easy Question 4: "Round 847 to the nearest hundred"
SELECT q.id, '800', true, 1, 'Correct! Look at tens place (4). Since 4 < 5, round down to 800.'
FROM question_ids q WHERE question_num = 1
UNION ALL
SELECT q.id, '850', false, 2, 'This would be rounding to the nearest fifty, not hundred.'
FROM question_ids q WHERE question_num = 1
UNION ALL
SELECT q.id, '900', false, 3, 'Since the tens digit (4) is less than 5, we round down, not up.'
FROM question_ids q WHERE question_num = 1
UNION ALL
SELECT q.id, '840', false, 4, 'This would be rounding to the nearest ten, not hundred.'
FROM question_ids q WHERE question_num = 1;
