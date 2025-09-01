-- CERTIFICATION SETUP STATUS CHECK
-- Run this to see which certifications are fully ready vs incomplete

-- 1. Overall certification status summary
SELECT 
  c.name as certification_name,
  c.test_code,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT concepts.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items,
  COUNT(DISTINCT q.id) as questions,
  CASE 
    WHEN COUNT(DISTINCT d.id) = 0 THEN '❌ No domains'
    WHEN COUNT(DISTINCT concepts.id) = 0 THEN '⚠️ Domains only'
    WHEN COUNT(DISTINCT ci.id) = 0 THEN '⚠️ Missing content'
    WHEN COUNT(DISTINCT q.id) = 0 THEN '⚠️ Missing questions'
    ELSE '✅ Fully ready'
  END as status
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
LEFT JOIN questions q ON q.concept_id = concepts.id
WHERE c.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY c.id, c.name, c.test_code
ORDER BY c.test_code;

-- 2. Detailed breakdown by certification
SELECT 
  '--- DETAILED BREAKDOWN ---' as info;

-- Math 902 (should be complete)
SELECT 
  'MATH 902 STATUS:' as section,
  d.name as domain_name,
  COUNT(DISTINCT concepts.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items,
  COUNT(DISTINCT q.id) as questions
FROM certifications c
JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
LEFT JOIN questions q ON q.concept_id = concepts.id
WHERE c.test_code = '902'
GROUP BY d.id, d.name, d.order_index
ORDER BY d.order_index;

-- Fine Arts 905 (should have domains)
SELECT 
  'FINE ARTS 905 STATUS:' as section,
  d.name as domain_name,
  d.code as domain_code,
  COUNT(DISTINCT concepts.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items
FROM certifications c
JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
WHERE c.test_code = '905'
GROUP BY d.id, d.name, d.code, d.order_index
ORDER BY d.order_index;

-- Check which certifications the API can handle
SELECT 
  'API MAPPING CHECK:' as section,
  'Math EC-6' as frontend_name,
  '902' as mapped_test_code,
  'Should work' as api_status
UNION ALL
SELECT 
  'API MAPPING CHECK:',
  'Fine Arts EC-6',
  '905',
  'Should work'
UNION ALL
SELECT 
  'API MAPPING CHECK:',
  'Other EC-6 subjects',
  'No mapping',
  'Will save but no study plan';
