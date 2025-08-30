-- CHECK EC-6 MATH CERTIFICATION STATUS
-- Run this in Supabase SQL Editor to check EC-6 Math setup

-- 1. List all certifications to see what we have
SELECT id, name, test_code, description 
FROM certifications 
ORDER BY name;

-- 2. Check specifically for EC-6 Math patterns
SELECT id, name, test_code, description 
FROM certifications 
WHERE name ILIKE '%ec-6%' 
   OR name ILIKE '%elementary%' 
   OR test_code ILIKE '%ec-6%'
   OR test_code ILIKE '%elementary%';

-- 3. Check if EC-6 Math has domains (if it exists)
SELECT 
  c.name as certification_name,
  c.test_code,
  COUNT(d.id) as domain_count,
  COUNT(concepts.id) as concept_count
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts ON concepts.domain_id = d.id
WHERE c.name ILIKE '%ec-6%' 
   OR c.name ILIKE '%elementary%' 
   OR c.test_code ILIKE '%ec-6%'
GROUP BY c.id, c.name, c.test_code;

-- 4. If EC-6 exists, check its structure vs Math 902
SELECT 
  'Math 902' as exam_type,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT c.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items,
  COUNT(DISTINCT q.id) as questions
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'

UNION ALL

SELECT 
  'EC-6 Math' as exam_type,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT c.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items,
  COUNT(DISTINCT q.id) as questions
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.name ILIKE '%ec-6%' 
   OR cert.name ILIKE '%elementary%';
