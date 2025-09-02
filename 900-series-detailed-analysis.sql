-- 🔍 DETAILED 900 SERIES ANALYSIS
-- Let's examine each 900 series certification to see the actual question counts vs expected

-- Expected: Each 900 series should have 4 domains with 20 questions each = 80 total
-- Exception: Social Studies (903) currently has 60

-- 1. DETAILED BREAKDOWN BY CERTIFICATION
SELECT 
  '=== 901 ELA EC-6 BREAKDOWN ===' as analysis,
  c.test_code,
  d.name as domain_name,
  con.name as concept_name,
  COUNT(ci.id) as actual_questions,
  COUNT(CASE WHEN ci.type = 'practice_question' THEN 1 END) as practice_questions,
  COUNT(CASE WHEN ci.type = 'text_explanation' THEN 1 END) as explanations,
  COUNT(CASE WHEN ci.type = 'interactive_example' THEN 1 END) as examples
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '901'
GROUP BY c.test_code, d.name, con.name
ORDER BY d.name, con.name;

-- 2. ELA 901 SUMMARY
SELECT 
  '901 ELA SUMMARY' as cert,
  COUNT(DISTINCT d.id) as total_domains,
  COUNT(DISTINCT con.id) as total_concepts,
  COUNT(ci.id) as total_content_items,
  COUNT(CASE WHEN ci.type = 'practice_question' THEN 1 END) as total_questions
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '901';

-- 3. SOCIAL STUDIES 903 BREAKDOWN
SELECT 
  '=== 903 SOCIAL STUDIES BREAKDOWN ===' as analysis,
  c.test_code,
  d.name as domain_name,
  con.name as concept_name,
  COUNT(ci.id) as actual_questions,
  COUNT(CASE WHEN ci.type = 'practice_question' THEN 1 END) as practice_questions,
  COUNT(CASE WHEN ci.type = 'text_explanation' THEN 1 END) as explanations,
  COUNT(CASE WHEN ci.type = 'interactive_example' THEN 1 END) as examples
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '903'
GROUP BY c.test_code, d.name, con.name
ORDER BY d.name, con.name;

-- 4. SOCIAL STUDIES 903 SUMMARY
SELECT 
  '903 SOCIAL STUDIES SUMMARY' as cert,
  COUNT(DISTINCT d.id) as total_domains,
  COUNT(DISTINCT con.id) as total_concepts,
  COUNT(ci.id) as total_content_items,
  COUNT(CASE WHEN ci.type = 'practice_question' THEN 1 END) as total_questions
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '903';

-- 5. SCIENCE 904 BREAKDOWN
SELECT 
  '=== 904 SCIENCE BREAKDOWN ===' as analysis,
  c.test_code,
  d.name as domain_name,
  con.name as concept_name,
  COUNT(ci.id) as actual_questions,
  COUNT(CASE WHEN ci.type = 'practice_question' THEN 1 END) as practice_questions,
  COUNT(CASE WHEN ci.type = 'text_explanation' THEN 1 END) as explanations,
  COUNT(CASE WHEN ci.type = 'interactive_example' THEN 1 END) as examples
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '904'
GROUP BY c.test_code, d.name, con.name
ORDER BY d.name, con.name;

-- 6. SCIENCE 904 SUMMARY
SELECT 
  '904 SCIENCE SUMMARY' as cert,
  COUNT(DISTINCT d.id) as total_domains,
  COUNT(DISTINCT con.id) as total_concepts,
  COUNT(ci.id) as total_content_items,
  COUNT(CASE WHEN ci.type = 'practice_question' THEN 1 END) as total_questions
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '904';

-- 7. FINE ARTS 905 BREAKDOWN
SELECT 
  '=== 905 FINE ARTS BREAKDOWN ===' as analysis,
  c.test_code,
  d.name as domain_name,
  con.name as concept_name,
  COUNT(ci.id) as actual_questions,
  COUNT(CASE WHEN ci.type = 'practice_question' THEN 1 END) as practice_questions,
  COUNT(CASE WHEN ci.type = 'text_explanation' THEN 1 END) as explanations,
  COUNT(CASE WHEN ci.type = 'interactive_example' THEN 1 END) as examples
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '905'
GROUP BY c.test_code, d.name, con.name
ORDER BY d.name, con.name;

-- 8. FINE ARTS 905 SUMMARY
SELECT 
  '905 FINE ARTS SUMMARY' as cert,
  COUNT(DISTINCT d.id) as total_domains,
  COUNT(DISTINCT con.id) as total_concepts,
  COUNT(ci.id) as total_content_items,
  COUNT(CASE WHEN ci.type = 'practice_question' THEN 1 END) as total_questions
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '905';

-- 9. COMPARE EXPECTED VS ACTUAL
SELECT 
  'EXPECTED VS ACTUAL SUMMARY' as comparison,
  '901 ELA' as cert,
  '80' as expected_questions,
  COALESCE(COUNT(CASE WHEN ci.type = 'practice_question' THEN 1 END), 0) as actual_questions
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '901'
UNION ALL
SELECT 
  'EXPECTED VS ACTUAL SUMMARY',
  '903 SOCIAL',
  '60',
  COALESCE(COUNT(CASE WHEN ci.type = 'practice_question' THEN 1 END), 0)
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '903'
UNION ALL
SELECT 
  'EXPECTED VS ACTUAL SUMMARY',
  '904 SCIENCE',
  '80',
  COALESCE(COUNT(CASE WHEN ci.type = 'practice_question' THEN 1 END), 0)
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '904'
UNION ALL
SELECT 
  'EXPECTED VS ACTUAL SUMMARY',
  '905 FINE ARTS',
  '80',
  COALESCE(COUNT(CASE WHEN ci.type = 'practice_question' THEN 1 END), 0)
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '905';
