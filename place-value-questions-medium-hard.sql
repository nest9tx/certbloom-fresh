-- Place Value - Medium & Hard Questions
-- Run this after the easy questions script

-- MEDIUM QUESTIONS (4 questions - application level)
INSERT INTO questions (concept_id, question_text, explanation, difficulty_level, estimated_time)
SELECT 
  c.id,
  'A school has 45,678 students. If the enrollment increases by 2,000 students, what will be the value of the digit in the ten thousands place?',
  'Original: 45,678. After increase: 47,678. The digit in ten thousands place is 4, with value 40,000.',
  'medium',
  75
FROM concepts c
WHERE c.name = 'Place Value and Number Sense'
UNION ALL
SELECT 
  c.id,
  'Which of these decimals is closest to 0.5: 0.456, 0.523, 0.498, or 0.567?',
  'Calculate distances: |0.456-0.5|=0.044, |0.523-0.5|=0.023, |0.498-0.5|=0.002, |0.567-0.5|=0.067. So 0.498 is closest.',
  'medium',
  90
FROM concepts c
WHERE c.name = 'Place Value and Number Sense'
UNION ALL
SELECT 
  c.id,
  'In expanded form, 304.07 equals which expression?',
  '304.07 = 3×100 + 0×10 + 4×1 + 0×0.1 + 7×0.01',
  'medium',
  80
FROM concepts c
WHERE c.name = 'Place Value and Number Sense'
UNION ALL
SELECT 
  c.id,
  'If you round 67,849 to the nearest thousand, then round that result to the nearest ten thousand, what is the final answer?',
  'Step 1: 67,849 rounded to nearest thousand is 68,000. Step 2: 68,000 rounded to nearest ten thousand is 70,000.',
  'medium',
  100
FROM concepts c
WHERE c.name = 'Place Value and Number Sense';

-- HARD QUESTIONS (4 questions - analysis/synthesis level)  
INSERT INTO questions (concept_id, question_text, explanation, difficulty_level, estimated_time)
SELECT 
  pv.id,
  'The number 5X7,29Y, when rounded to the nearest thousand, gives 507,000. What are the possible values for the digits X and Y?',
  'For rounding to 507,000, the number must be 506,500 to 507,499. So X can be 0,1,2,3,4,5,6 and Y can be any digit 0-9, with constraints based on X value.',
  'hard',
  150
FROM place_value_concept pv
UNION ALL
SELECT 
  pv.id,
  'A number has the same digit in the tens and tenths places. The sum of all digits is 20. The hundreds digit is 3 more than the ones digit. If the number is between 200 and 300, what is the number?',
  'Let the tens/tenths digit be t, ones digit be o, then hundreds digit is o+3. Number: (o+3)t o . t. Since 200-300, o+3=2, so o=-1 (impossible) or we need 200≤number<300, so try systematically.',
  'hard',
  180
FROM place_value_concept pv
UNION ALL
SELECT 
  pv.id,
  'Which statement about place value is always true when comparing two 4-digit numbers?',
  'The digit in the thousands place determines which number is greater, regardless of the other digits.',
  'hard',
  120
FROM place_value_concept pv
UNION ALL
SELECT 
  pv.id,
  'Express 5,000,000 + 600,000 + 7,000 + 80 + 0.009 in standard form.',
  'Combine all place values: 5,607,080.009',
  'hard',
  90
FROM place_value_concept pv;

-- Now create answer choices for medium questions
WITH medium_questions AS (
  SELECT q.id, q.question_text,
    ROW_NUMBER() OVER (ORDER BY q.created_at) as question_num  
  FROM questions q
  JOIN concepts c ON q.concept_id = c.id
  WHERE c.name = 'Place Value and Number Sense'
  AND q.difficulty_level = 'medium'
  ORDER BY q.created_at DESC
  LIMIT 4
)

INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
-- Medium Q1 answer choices
SELECT q.id, '40,000', true, 1, 'Correct! After adding 2,000: 47,678. The 4 in ten thousands place has value 40,000.'
FROM medium_questions q WHERE question_num = 4
UNION ALL
SELECT q.id, '4,000', false, 2, 'This would be the thousands place value, not ten thousands.'
FROM medium_questions q WHERE question_num = 4
UNION ALL  
SELECT q.id, '4', false, 3, 'This is just the digit, not its place value.'
FROM medium_questions q WHERE question_num = 4
UNION ALL
SELECT q.id, '47,000', false, 4, 'This is not a single place value.'
FROM medium_questions q WHERE question_num = 4

UNION ALL

-- Medium Q2 answer choices  
SELECT q.id, '0.456', false, 1, 'Distance from 0.5 is 0.044, not the closest.'
FROM medium_questions q WHERE question_num = 3
UNION ALL
SELECT q.id, '0.523', false, 2, 'Distance from 0.5 is 0.023, close but not closest.'
FROM medium_questions q WHERE question_num = 3
UNION ALL
SELECT q.id, '0.498', true, 3, 'Correct! Distance from 0.5 is only 0.002, the closest.'
FROM medium_questions q WHERE question_num = 3  
UNION ALL
SELECT q.id, '0.567', false, 4, 'Distance from 0.5 is 0.067, the furthest away.'
FROM medium_questions q WHERE question_num = 3;
