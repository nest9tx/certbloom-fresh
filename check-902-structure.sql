-- Check Math 902 certification structure
SELECT 
  'MATH 902 CERTIFICATION STATUS' as status,
  c.id as cert_id,
  c.name,
  c.test_code,
  COUNT(DISTINCT d.id) as domain_count,
  COUNT(DISTINCT co.id) as concept_count,
  COUNT(DISTINCT ci.id) as content_item_count
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts co ON d.id = co.domain_id  
LEFT JOIN content_items ci ON co.id = ci.concept_id
WHERE c.test_code = '902'
GROUP BY c.id, c.name, c.test_code;

-- Check domains specifically
SELECT 
  'MATH 902 DOMAINS' as status,
  d.id,
  d.name,
  d.order_index
FROM certifications c
JOIN domains d ON c.id = d.certification_id
WHERE c.test_code = '902'
ORDER BY d.order_index;

-- Check concepts
SELECT 
  'MATH 902 CONCEPTS' as status,
  co.id,
  co.name,
  d.name as domain_name
FROM certifications c
JOIN domains d ON c.id = d.certification_id
JOIN concepts co ON d.id = co.domain_id
WHERE c.test_code = '902'
ORDER BY d.order_index, co.order_index
LIMIT 10;
