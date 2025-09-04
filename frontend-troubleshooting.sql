-- 🔍 FRONTEND TROUBLESHOOTING
-- Check what the frontend is actually seeing

-- 1. Check total content items for 902
SELECT 
    'Total 902 content items' as check_type,
    COUNT(*) as count
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902';

-- 2. Check content items by concept for 902
SELECT 
    c.name as concept_name,
    COUNT(ci.id) as question_count,
    STRING_AGG(ci.title, ', ') as question_titles
FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
LEFT JOIN content_items ci ON c.id = ci.concept_id
WHERE cert.test_code = '902'
GROUP BY c.id, c.name
ORDER BY c.name;

-- 3. Check what the API would see (simulation)
SELECT 
    ci.id,
    ci.title,
    ci.content,
    ci.correct_answer,
    ci.type,
    c.name as concept_name,
    d.name as domain_name,
    COUNT(ac.id) as answer_choices_count
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE cert.test_code = '902'
GROUP BY ci.id, ci.title, ci.content, ci.correct_answer, ci.type, c.name, d.name
ORDER BY ci.created_at DESC;
