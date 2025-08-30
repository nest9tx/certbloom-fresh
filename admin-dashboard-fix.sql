-- Admin Dashboard Data Refresh Fix
-- Check current question distribution to understand the data flow issue

-- First, let's see the actual structure we're working with
SELECT 
    'SCHEMA VERIFICATION' as info,
    c.name as concept_name,
    d.name as domain_name,
    cert.name as certification_name,
    cert.test_code,
    COUNT(q.id) as question_count
FROM certifications cert
LEFT JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
GROUP BY cert.name, cert.test_code, d.name, c.name
ORDER BY cert.test_code, d.name, c.name;

-- Check if there are any questions with old schema references
SELECT 
    'OLD SCHEMA QUESTIONS' as info,
    q.id,
    q.certification_id,
    q.topic_id,
    q.domain,
    q.concept,
    q.created_at
FROM questions q
WHERE q.certification_id IS NOT NULL 
   OR q.topic_id IS NOT NULL
   OR q.domain IS NOT NULL
   OR q.concept IS NOT NULL
LIMIT 10;

-- Show total questions by approach
SELECT 
    'TOTAL QUESTIONS BY APPROACH' as info,
    COUNT(CASE WHEN q.concept_id IS NOT NULL THEN 1 END) as concept_linked_questions,
    COUNT(CASE WHEN q.certification_id IS NOT NULL THEN 1 END) as certification_linked_questions,
    COUNT(CASE WHEN q.topic_id IS NOT NULL THEN 1 END) as topic_linked_questions,
    COUNT(*) as total_questions
FROM questions q;
