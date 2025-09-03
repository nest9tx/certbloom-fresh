-- Diagnose Math 902 Content Issue
-- Check what subjects are associated with 902 certification

-- 1. Check certification areas and subjects
SELECT DISTINCT certification_area, subject_area, COUNT(*) as question_count
FROM content_items 
WHERE certification_area LIKE '%902%' OR certification_area LIKE '%900%'
GROUP BY certification_area, subject_area
ORDER BY certification_area, subject_area;

-- 2. Check specific Math 902 questions with subjects
SELECT id, certification_area, subject_area, question_text, 
       SUBSTRING(question_text, 1, 100) as preview
FROM content_items 
WHERE certification_area = 'MATH-902' 
ORDER BY id
LIMIT 20;

-- 3. Check if there are Science questions incorrectly categorized as Math
SELECT id, certification_area, subject_area, question_text,
       SUBSTRING(question_text, 1, 100) as preview
FROM content_items 
WHERE certification_area = 'MATH-902' 
  AND (question_text ILIKE '%physics%' 
       OR question_text ILIKE '%chemistry%' 
       OR question_text ILIKE '%science%'
       OR question_text ILIKE '%temperature%'
       OR question_text ILIKE '%heat%'
       OR question_text ILIKE '%metal%'
       OR question_text ILIKE '%conductor%')
LIMIT 10;

-- 4. Check answer randomization status
SELECT id, question_text, choice_1, choice_2, choice_3, choice_4, 
       correct_choice, choice_order,
       SUBSTRING(question_text, 1, 50) as preview
FROM content_items 
WHERE certification_area = 'MATH-902'
  AND choice_order IS NOT NULL
LIMIT 5;

-- 5. Check for any questions with incorrect answer mappings
SELECT id, question_text, choice_1, choice_2, choice_3, choice_4, 
       correct_choice, choice_order,
       CASE 
         WHEN choice_order = '[1,2,3,4]' THEN choice_1
         WHEN choice_order = '[2,1,3,4]' THEN choice_2  
         WHEN choice_order = '[3,2,1,4]' THEN choice_3
         WHEN choice_order = '[4,2,3,1]' THEN choice_4
         ELSE 'ERROR'
       END as mapped_correct_answer
FROM content_items 
WHERE certification_area = 'MATH-902'
  AND choice_order IS NOT NULL
LIMIT 10;
