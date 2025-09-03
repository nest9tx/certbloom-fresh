-- Math 902 Working Analysis - Compare with Other Certifications
-- Date: September 3, 2025
-- Purpose: Understand why Math 902 works and others don't

-- STEP 1: Check what columns actually exist in questions table
SELECT 
  'QUESTIONS TABLE STRUCTURE' as analysis_section;

SELECT 
  column_name,
  data_type
FROM information_schema.columns 
WHERE table_name = 'questions'
ORDER BY column_name;

-- STEP 2: Check if answer_choices table exists and how it's populated
SELECT 
  'ANSWER CHOICES ANALYSIS' as analysis_section;

-- Check answer_choices distribution by certification
SELECT 
  cert.test_code,
  cert.name as certification,
  COUNT(DISTINCT q.id) as total_questions,
  COUNT(DISTINCT ac.question_id) as questions_with_choices,
  COUNT(ac.id) as total_answer_choices
FROM questions q
JOIN concepts c ON q.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
LEFT JOIN answer_choices ac ON q.id = ac.question_id
WHERE cert.test_code IN ('902', '901', '903', '904', '905')
GROUP BY cert.test_code, cert.name
ORDER BY cert.test_code;

-- STEP 3: Sample answer choices for Math 902
SELECT 
  'MATH 902 ANSWER CHOICES SAMPLE' as analysis_section;

SELECT 
  q.id as question_id,
  LEFT(q.question_text, 60) as question_preview,
  ac.choice_order,
  ac.choice_text,
  ac.is_correct
FROM questions q
JOIN answer_choices ac ON q.id = ac.question_id
JOIN concepts c ON q.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902'
ORDER BY q.id, ac.choice_order
LIMIT 12;

-- STEP 4: Sample answer choices for ELA 901
SELECT 
  'ELA 901 ANSWER CHOICES SAMPLE' as analysis_section;

SELECT 
  q.id as question_id,
  LEFT(q.question_text, 60) as question_preview,
  ac.choice_order,
  ac.choice_text,
  ac.is_correct
FROM questions q
JOIN answer_choices ac ON q.id = ac.question_id
JOIN concepts c ON q.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '901'
ORDER BY q.id, ac.choice_order
LIMIT 12;

-- STEP 4: Check if Math 902 uses a different question table or structure
SELECT 
  'QUESTION SOURCE ANALYSIS' as analysis_section;

-- Look at the actual table structure being used
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'questions'
  AND column_name IN ('answer_a', 'answer_b', 'answer_c', 'answer_d', 'question_text')
ORDER BY column_name;

-- STEP 5: Check if there are alternative answer choice tables
SELECT 
  'ALTERNATIVE ANSWER STRUCTURE CHECK' as analysis_section;

-- Check if there's an answer_choices table being used
SELECT 
  table_name
FROM information_schema.tables 
WHERE table_name LIKE '%answer%' OR table_name LIKE '%choice%';

-- If answer_choices table exists, check its relationship to questions
SELECT 
  'ANSWER CHOICES TABLE ANALYSIS' as analysis_section;

-- Sample from answer_choices table if it exists
SELECT 
  ac.question_id,
  ac.choice_text,
  ac.is_correct,
  ac.choice_order,
  LEFT(q.question_text, 60) as question_preview,
  cert.test_code
FROM answer_choices ac
JOIN questions q ON ac.question_id = q.id
JOIN concepts c ON q.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902'
LIMIT 10;

-- STEP 6: Check concept structure differences
SELECT 
  'CONCEPT STRUCTURE COMPARISON' as analysis_section;

-- Compare concept structures between working Math 902 and others
SELECT 
  cert.test_code,
  cert.name as certification,
  d.name as domain_name,
  c.name as concept_name,
  COUNT(ci.id) as content_items,
  COUNT(q.id) as questions
FROM certifications cert
JOIN domains d ON cert.id = d.certification_id
JOIN concepts c ON d.id = c.domain_id
LEFT JOIN content_items ci ON c.id = ci.concept_id
LEFT JOIN questions q ON c.id = q.concept_id
WHERE cert.test_code IN ('902', '901', '903', '904')
GROUP BY cert.test_code, cert.name, d.name, c.name
ORDER BY cert.test_code, d.name, c.name;
