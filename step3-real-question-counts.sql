-- 🎯 STEP 3: FIND THE REAL QUESTION COUNTS!
-- Now that we know the structure, let's count questions correctly

-- 1. QUESTIONS BY CERTIFICATION (Direct certification_id link)
SELECT 
  '=== DIRECT CERTIFICATION LINK ===' as method,
  c.test_code,
  c.name as cert_name,
  COUNT(q.id) as question_count
FROM certifications c
LEFT JOIN questions q ON q.certification_id = c.id
WHERE c.test_code IN ('901', '902', '903', '904', '905', '391')
GROUP BY c.test_code, c.name
ORDER BY c.test_code;

-- 2. QUESTIONS BY CONCEPT LINK
SELECT 
  '=== CONCEPT LINK ===' as method,
  c.test_code,
  c.name as cert_name,
  COUNT(q.id) as question_count
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts con ON con.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = con.id
WHERE c.test_code IN ('901', '902', '903', '904', '905', '391')
GROUP BY c.test_code, c.name
ORDER BY c.test_code;

-- 3. QUESTIONS IN SECONDARY CERTIFICATION ARRAYS
SELECT 
  '=== SECONDARY CERT ARRAYS ===' as method,
  c.test_code,
  c.name as cert_name,
  COUNT(q.id) as question_count
FROM certifications c
LEFT JOIN questions q ON c.id = ANY(q.secondary_certification_ids)
WHERE c.test_code IN ('901', '902', '903', '904', '905', '391')
GROUP BY c.test_code, c.name
ORDER BY c.test_code;

-- 4. TOTAL QUESTIONS (ALL METHODS COMBINED)
SELECT 
  '=== TOTAL ALL METHODS ===' as method,
  c.test_code,
  c.name as cert_name,
  COUNT(DISTINCT q.id) as unique_question_count
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts con ON con.domain_id = d.id
LEFT JOIN questions q ON (
  q.certification_id = c.id 
  OR q.concept_id = con.id 
  OR c.id = ANY(COALESCE(q.secondary_certification_ids, ARRAY[]::uuid[]))
)
WHERE c.test_code IN ('901', '902', '903', '904', '905', '391')
GROUP BY c.test_code, c.name
ORDER BY c.test_code;

-- 5. SAMPLE QUESTIONS TO VERIFY
SELECT 
  '=== SAMPLE ELA 901 QUESTIONS ===' as verification,
  q.question_text,
  q.difficulty_level,
  q.domain,
  q.concept
FROM certifications c
LEFT JOIN questions q ON (
  q.certification_id = c.id 
  OR c.id = ANY(COALESCE(q.secondary_certification_ids, ARRAY[]::uuid[]))
)
WHERE c.test_code = '901'
  AND q.id IS NOT NULL
LIMIT 3;
