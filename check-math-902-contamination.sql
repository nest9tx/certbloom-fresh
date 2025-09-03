-- Check Math 902 certification issue

-- 1. What certifications exist?
SELECT DISTINCT certification_area, COUNT(*) as question_count
FROM content_items 
GROUP BY certification_area
ORDER BY certification_area;

-- 2. Check Math 902 questions specifically  
SELECT id, certification_area, subject_area, 
       SUBSTRING(question_text, 1, 100) as question_preview,
       CASE 
         WHEN question_text ILIKE '%algebra%' OR question_text ILIKE '%equation%' OR question_text ILIKE '%mathematical%' THEN 'MATH'
         WHEN question_text ILIKE '%science%' OR question_text ILIKE '%physics%' OR question_text ILIKE '%chemistry%' THEN 'SCIENCE'
         WHEN question_text ILIKE '%reading%' OR question_text ILIKE '%literature%' OR question_text ILIKE '%comprehension%' THEN 'ELA'
         ELSE 'UNCLEAR'
       END as content_type
FROM content_items 
WHERE certification_area = 'MATH-902'
ORDER BY id
LIMIT 20;

-- 3. Check if there are misclassified questions
SELECT COUNT(*) as science_in_math,
       'These are Science questions in Math 902' as note
FROM content_items 
WHERE certification_area = 'MATH-902'
  AND (question_text ILIKE '%physics%' 
       OR question_text ILIKE '%chemistry%' 
       OR question_text ILIKE '%temperature%'
       OR question_text ILIKE '%heat%'
       OR question_text ILIKE '%metal%'
       OR question_text ILIKE '%conductor%'
       OR question_text ILIKE '%science%');

-- 4. Check what domains are in Math 902
SELECT DISTINCT d.domain_code, d.domain_title, COUNT(ci.id) as question_count
FROM content_items ci
LEFT JOIN domains d ON d.certification_area = ci.certification_area
WHERE ci.certification_area = 'MATH-902'
GROUP BY d.domain_code, d.domain_title
ORDER BY d.domain_code;
