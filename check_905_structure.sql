-- CHECK EXISTING 905 CERTIFICATION STRUCTURE
-- Run this in Supabase SQL Editor to see current 905 setup

-- 1. Check the existing 905 certification details
SELECT id, name, test_code, description 
FROM certifications 
WHERE test_code = '905';

-- 2. Check if 905 has domains already
SELECT 
  c.name as certification_name,
  c.test_code,
  d.id as domain_id,
  d.name as domain_name,
  d.description as domain_description,
  d.order_index
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
WHERE c.test_code = '905'
ORDER BY d.order_index;

-- 3. Check full structure: domains -> concepts -> content_items -> questions
SELECT 
  d.name as domain_name,
  COUNT(DISTINCT concepts.id) as concept_count,
  COUNT(DISTINCT ci.id) as content_items_count,
  COUNT(DISTINCT q.id) as questions_count
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
LEFT JOIN questions q ON q.concept_id = concepts.id
WHERE cert.test_code = '905'
GROUP BY d.id, d.name, d.order_index
ORDER BY d.order_index;

-- 4. Overall 905 summary
SELECT 
  'Fine Arts 905' as exam_type,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT concepts.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items,
  COUNT(DISTINCT q.id) as questions
FROM certifications cert
LEFT JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
LEFT JOIN questions q ON q.concept_id = concepts.id
WHERE cert.test_code = '905';
