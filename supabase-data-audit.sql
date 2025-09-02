-- 🔍 COMPREHENSIVE SUPABASE DATA AUDIT
-- This will show us exactly what's in the database vs hardcoded content

-- 1. CERTIFICATIONS OVERVIEW
SELECT 
  'CERTIFICATIONS' as table_name,
  COUNT(*) as total_count,
  string_agg(DISTINCT test_code, ', ' ORDER BY test_code) as test_codes
FROM certifications;

-- 2. DOMAINS BY CERTIFICATION
SELECT 
  'DOMAINS BY CERT' as section,
  c.test_code,
  c.name as cert_name,
  COUNT(d.id) as domain_count,
  string_agg(d.name, ' | ' ORDER BY d.name) as domain_names
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
GROUP BY c.id, c.test_code, c.name
ORDER BY c.test_code;

-- 3. CONCEPTS BY CERTIFICATION
SELECT 
  'CONCEPTS BY CERT' as section,
  c.test_code,
  COUNT(con.id) as concept_count,
  string_agg(DISTINCT d.name, ', ' ORDER BY d.name) as domains_with_concepts
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
GROUP BY c.id, c.test_code
ORDER BY c.test_code;

-- 4. CONTENT ITEMS BY CERTIFICATION (The learning materials)
SELECT 
  'CONTENT_ITEMS BY CERT' as section,
  c.test_code,
  c.name as cert_name,
  COUNT(ci.id) as content_items_count,
  COUNT(DISTINCT ci.type) as content_types_count,
  string_agg(DISTINCT ci.type::text, ', ' ORDER BY ci.type::text) as content_types
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
GROUP BY c.id, c.test_code, c.name
ORDER BY c.test_code;

-- 5. PRACTICE QUESTIONS CHECK (Table may not exist - questions might be hardcoded)
SELECT 
  'PRACTICE_QUESTIONS TABLE CHECK' as section,
  'Questions likely hardcoded in frontend - no practice_questions table found' as note;

-- 6. STUDY PLANS (User progress data)
SELECT 
  'STUDY_PLANS' as section,
  c.test_code,
  COUNT(sp.id) as study_plan_count,
  COUNT(DISTINCT sp.user_id) as unique_users,
  string_agg(DISTINCT sp.name, ' | ') as plan_names
FROM certifications c
LEFT JOIN study_plans sp ON c.id = sp.certification_id
GROUP BY c.id, c.test_code
ORDER BY c.test_code;

-- 7. PRACTICE SESSIONS CHECK (Table may not exist)
SELECT 
  'PRACTICE_SESSIONS TABLE CHECK' as section,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'practice_sessions')
    THEN 'Table exists'
    ELSE 'Table does not exist'
  END as table_status;

-- 8. DETAILED CONTENT BREAKDOWN FOR EACH CERT
SELECT 
  'DETAILED CONTENT BREAKDOWN' as section,
  c.test_code,
  d.name as domain_name,
  con.name as concept_name,
  COUNT(ci.id) as content_items,
  string_agg(ci.type::text, ', ') as content_types
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
GROUP BY c.test_code, d.name, con.name
HAVING COUNT(ci.id) > 0
ORDER BY c.test_code, d.name, con.name;

-- 9. CHECK FOR ORPHANED DATA
SELECT 'ORPHANED DATA CHECK' as section;

-- Domains without certifications
SELECT 'Domains without certifications' as issue, COUNT(*) as count
FROM domains d
LEFT JOIN certifications c ON d.certification_id = c.id
WHERE c.id IS NULL;

-- Concepts without domains
SELECT 'Concepts without domains' as issue, COUNT(*) as count
FROM concepts con
LEFT JOIN domains d ON con.domain_id = d.id
WHERE d.id IS NULL;

-- Content items without concepts
SELECT 'Content items without concepts' as issue, COUNT(*) as count
FROM content_items ci
LEFT JOIN concepts con ON ci.concept_id = con.id
WHERE con.id IS NULL;

-- Practice questions with invalid cert codes (skip if table doesn't exist)
SELECT 'Questions table check' as issue, 
       CASE 
         WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'practice_questions')
         THEN 'practice_questions table exists'
         ELSE 'practice_questions table does not exist - questions likely hardcoded'
       END as count;
