-- Comprehensive diagnosis of the question/content system

-- 1. Check what tables exist and their record counts
SELECT 
  'content_items' as table_name, 
  COUNT(*) as total_records,
  COUNT(CASE WHEN certification_area = 'MATH-902' THEN 1 END) as math_902_count,
  COUNT(CASE WHEN certification_area = 'SCIENCE-902' THEN 1 END) as science_902_count
FROM content_items
UNION ALL
SELECT 
  'questions' as table_name,
  COUNT(*) as total_records,
  0 as math_902_count,
  0 as science_902_count
FROM questions
WHERE EXISTS (SELECT 1 FROM questions LIMIT 1);

-- 2. Check content_items structure and relationships
SELECT 
  ci.certification_area,
  ci.subject_area,
  COUNT(ci.id) as content_count,
  COUNT(ac.id) as answer_choices_count,
  COUNT(CASE WHEN ac.is_correct THEN 1 END) as correct_answers
FROM content_items ci
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE ci.certification_area IN ('MATH-902', 'SCIENCE-902')
GROUP BY ci.certification_area, ci.subject_area
ORDER BY ci.certification_area, ci.subject_area;

-- 3. Check concept to certification mapping
SELECT 
  c.id as concept_id,
  c.name as concept_name,
  d.certification_id,
  cert.name as certification_name,
  cert.test_code,
  COUNT(ci.id) as content_items_for_concept
FROM concepts c
LEFT JOIN domains d ON c.domain_id = d.id
LEFT JOIN certifications cert ON d.certification_id = cert.id
LEFT JOIN content_items ci ON c.id = ci.concept_id
WHERE cert.test_code IN ('902')
GROUP BY c.id, c.name, d.certification_id, cert.name, cert.test_code
ORDER BY cert.name, c.name;

-- 4. Check specific Math 902 content contamination
SELECT 
  'MATH-902 with Science Keywords' as issue_type,
  COUNT(*) as count,
  string_agg(DISTINCT SUBSTRING(question_text, 1, 50), ' | ') as examples
FROM content_items
WHERE certification_area = 'MATH-902'
  AND (question_text ILIKE '%physics%' 
       OR question_text ILIKE '%chemistry%' 
       OR question_text ILIKE '%temperature%'
       OR question_text ILIKE '%heat%'
       OR question_text ILIKE '%metal%'
       OR question_text ILIKE '%conductor%'
       OR question_text ILIKE '%science%')
UNION ALL
SELECT 
  'SCIENCE-902 with Math Keywords' as issue_type,
  COUNT(*) as count,
  string_agg(DISTINCT SUBSTRING(question_text, 1, 50), ' | ') as examples
FROM content_items
WHERE certification_area = 'SCIENCE-902'
  AND (question_text ILIKE '%algebra%' 
       OR question_text ILIKE '%equation%' 
       OR question_text ILIKE '%mathematical%'
       OR question_text ILIKE '%calculate%'
       OR question_text ILIKE '%formula%');

-- 5. Sample of each certification's questions
(SELECT 'MATH-902' as cert, id, SUBSTRING(question_text, 1, 80) as preview
 FROM content_items 
 WHERE certification_area = 'MATH-902' 
 LIMIT 5)
UNION ALL
(SELECT 'SCIENCE-902' as cert, id, SUBSTRING(question_text, 1, 80) as preview
 FROM content_items 
 WHERE certification_area = 'SCIENCE-902' 
 LIMIT 5)
ORDER BY cert, id;
