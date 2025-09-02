-- CHECK CURRENT DATABASE STATUS
-- This shows what certifications, domains, and concepts we actually have

SELECT 
  '🎯 CERTIFICATIONS OVERVIEW' as section,
  '' as certification_name,
  '' as test_code,
  0 as domains,
  0 as concepts,
  '' as status
UNION ALL
SELECT 
  '------------------------' as section,
  c.name as certification_name,
  c.test_code,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT concepts.id) as concepts,
  CASE 
    WHEN COUNT(DISTINCT d.id) = 0 THEN '❌ No domains - not ready'
    WHEN COUNT(DISTINCT concepts.id) = 0 THEN '⚠️ Domains only - needs concepts'
    WHEN COUNT(DISTINCT concepts.id) < 5 THEN '🟡 Few concepts - basic ready'
    ELSE '✅ Well structured - fully ready'
  END as status
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts ON concepts.domain_id = d.id
WHERE c.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY c.id, c.name, c.test_code
ORDER BY c.test_code;

-- Show which certifications have content items (practice sessions, etc.)
SELECT 
  '📚 CONTENT AVAILABILITY' as info,
  c.test_code,
  c.name,
  COUNT(DISTINCT ci.id) as content_items,
  COUNT(DISTINCT CASE WHEN ci.content_type = 'practice' THEN ci.id END) as practice_sessions
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
WHERE c.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY c.id, c.name, c.test_code
ORDER BY c.test_code;

-- Show domain structure for each certification
SELECT 
  '🗂️ DOMAIN STRUCTURE' as info,
  c.test_code || ': ' || c.name as certification,
  d.name as domain_name,
  d.code as domain_code,
  COUNT(concepts.id) as concept_count
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts ON concepts.domain_id = d.id
WHERE c.test_code IN ('391', '901', '902', '903', '904', '905')
  AND d.id IS NOT NULL
GROUP BY c.test_code, c.name, d.id, d.name, d.code
ORDER BY c.test_code, d.order_index;
