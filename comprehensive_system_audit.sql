-- COMPREHENSIVE SYSTEM AUDIT
-- Check all aspects of the learning system

-- 1. CERTIFICATION COMPLETENESS CHECK
SELECT 
  'CERTIFICATION STRUCTURE AUDIT' as section,
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

-- 2. QUESTION DISTRIBUTION ANALYSIS
SELECT 
  'QUESTION DISTRIBUTION BY CERTIFICATION' as section,
  c.name as certification,
  d.name as domain,
  COUNT(q.id) as question_count,
  CASE 
    WHEN COUNT(q.id) < 10 THEN '❌ Too few'
    WHEN COUNT(q.id) < 20 THEN '⚠️ Limited'
    ELSE '✅ Good'
  END as adequacy
FROM certifications c
JOIN domains d ON d.certification_id = c.id
JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = concepts.id
WHERE c.test_code IN ('902', '905')
GROUP BY c.name, d.name, d.order_index
ORDER BY c.test_code, d.order_index;

-- 3. SESSION COMPLETION TRACKING CHECK
SELECT 
  'SESSION COMPLETION ISSUES' as section,
  COUNT(DISTINCT ps.id) as total_sessions,
  COUNT(DISTINCT CASE WHEN ps.completed_at IS NOT NULL THEN ps.id END) as completed_sessions,
  COUNT(DISTINCT CASE WHEN ps.score IS NOT NULL THEN ps.id END) as sessions_with_scores,
  ROUND(
    COUNT(DISTINCT CASE WHEN ps.completed_at IS NOT NULL THEN ps.id END) * 100.0 / 
    NULLIF(COUNT(DISTINCT ps.id), 0), 2
  ) as completion_rate_percent
FROM practice_sessions ps
WHERE ps.created_at > NOW() - INTERVAL '30 days';

-- 4. PROGRESS TRACKING AUDIT
SELECT 
  'PROGRESS TRACKING STATUS' as section,
  COUNT(DISTINCT ucp.id) as total_progress_records,
  COUNT(DISTINCT ucp.user_id) as users_with_progress,
  AVG(ucp.mastery_level) as avg_mastery_level,
  COUNT(DISTINCT CASE WHEN ucp.mastery_level >= 0.8 THEN ucp.id END) as mastered_concepts
FROM user_concept_progress ucp;

-- 5. QUESTION TAGGING AUDIT (Check for cross-contamination)
SELECT 
  'QUESTION TAGGING ISSUES' as section,
  c.name as certification,
  COUNT(q.id) as questions,
  COUNT(DISTINCT q.tags) as unique_tag_sets,
  string_agg(DISTINCT array_to_string(q.tags, ','), '; ') as sample_tags
FROM certifications c
JOIN domains d ON d.certification_id = c.id
JOIN concepts ON concepts.domain_id = d.id
JOIN questions q ON q.concept_id = concepts.id
WHERE c.test_code = '902'
GROUP BY c.name
LIMIT 5;

-- 6. CONTENT ITEMS ANALYSIS
SELECT 
  'CONTENT ITEMS STATUS' as section,
  c.name as certification,
  COUNT(ci.id) as content_items,
  COUNT(CASE WHEN ci.content_type = 'lesson' THEN 1 END) as lessons,
  COUNT(CASE WHEN ci.content_type = 'practice' THEN 1 END) as practice_sets,
  COUNT(CASE WHEN ci.content_type = 'assessment' THEN 1 END) as assessments
FROM certifications c
JOIN domains d ON d.certification_id = c.id
JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
WHERE c.test_code IN ('902', '905')
GROUP BY c.name;
