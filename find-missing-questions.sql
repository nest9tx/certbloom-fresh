-- 🕵️ DETECTIVE WORK: FIND THE MISSING QUESTIONS!
-- The admin shows questions exist, but our queries show 0. Let's find them!

-- 1. CHECK IF THERE'S A SEPARATE QUESTIONS TABLE WE MISSED
SELECT 
  'TABLE DISCOVERY' as section,
  table_name,
  CASE 
    WHEN table_name ILIKE '%question%' THEN '🎯 POTENTIAL QUESTIONS TABLE'
    WHEN table_name ILIKE '%content%' THEN '📝 CONTENT RELATED'
    WHEN table_name ILIKE '%practice%' THEN '🏃 PRACTICE RELATED'
    ELSE '📊 OTHER'
  END as relevance
FROM information_schema.tables 
WHERE table_schema = 'public'
  AND (table_name ILIKE '%question%' 
       OR table_name ILIKE '%content%' 
       OR table_name ILIKE '%practice%'
       OR table_name ILIKE '%exam%'
       OR table_name ILIKE '%quiz%')
ORDER BY relevance DESC, table_name;

-- 2. CHECK THE QUESTIONS TABLE STRUCTURE (if it exists)
SELECT 
  'QUESTIONS TABLE CHECK' as investigation,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'questions'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. SAMPLE DATA FROM QUESTIONS TABLE (if it exists)
-- Note: We'll try this but it might error if table doesn't exist
SELECT 
  'QUESTIONS SAMPLE DATA' as investigation,
  id,
  question_text,
  CASE 
    WHEN LENGTH(question_text) > 50 
    THEN SUBSTRING(question_text, 1, 50) || '...'
    ELSE question_text
  END as preview,
  concept_id,
  difficulty_level,
  created_at
FROM questions 
LIMIT 5;

-- 4. CHECK FOR CERTIFICATION/DOMAIN RELATIONSHIPS IN QUESTIONS
SELECT 
  'QUESTIONS BY CERTIFICATION' as investigation,
  c.test_code,
  c.name as cert_name,
  COUNT(q.id) as question_count
FROM certifications c
LEFT JOIN concepts con ON con.certification_id = c.id
LEFT JOIN questions q ON q.concept_id = con.id
GROUP BY c.test_code, c.name
ORDER BY c.test_code;

-- 5. ALTERNATIVE: CHECK IF QUESTIONS ARE LINKED DIFFERENTLY
-- Maybe questions link directly to certifications?
SELECT 
  'DIRECT CERT LINKAGE CHECK' as investigation,
  column_name,
  data_type
FROM information_schema.columns 
WHERE table_name = 'questions'
  AND (column_name ILIKE '%cert%' 
       OR column_name ILIKE '%test%'
       OR column_name ILIKE '%exam%')
ORDER BY column_name;

-- 6. CHECK CONTENT_ITEMS MORE THOROUGHLY
SELECT 
  'CONTENT_ITEMS DEEP DIVE' as investigation,
  type::text as content_type,
  COUNT(*) as total_count,
  COUNT(CASE WHEN content IS NOT NULL THEN 1 END) as with_content,
  COUNT(CASE WHEN question_text IS NOT NULL THEN 1 END) as with_question_text
FROM content_items
GROUP BY type;

-- 7. SAMPLE CONTENT_ITEMS TO SEE STRUCTURE
SELECT 
  'CONTENT_ITEMS SAMPLE' as investigation,
  id,
  type::text,
  CASE 
    WHEN content IS NOT NULL AND LENGTH(content::text) > 50
    THEN SUBSTRING(content::text, 1, 50) || '...'
    WHEN content IS NOT NULL
    THEN content::text
    ELSE 'NULL'
  END as content_preview,
  concept_id
FROM content_items
WHERE type = 'practice_question'
LIMIT 5;

-- 8. CHECK FOR CERTIFICATION-SPECIFIC QUESTION TABLES
-- Maybe each certification has its own table?
SELECT 
  'CERT-SPECIFIC TABLES' as investigation,
  table_name
FROM information_schema.tables 
WHERE table_schema = 'public'
  AND (table_name ILIKE '%901%' 
       OR table_name ILIKE '%902%' 
       OR table_name ILIKE '%903%'
       OR table_name ILIKE '%904%'
       OR table_name ILIKE '%905%'
       OR table_name ILIKE '%391%')
ORDER BY table_name;
