-- Quick Fix: Manually populate content items for all Math 902 concepts
-- This will make the study path functional immediately

INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes)
SELECT 
    c.id as concept_id,
    'explanation' as type,
    'Introduction to ' || c.name as title,
    'Welcome to ' || c.name || '! This concept includes comprehensive practice questions to help you master key skills.' as content,
    1 as order_index,
    5 as estimated_minutes
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
WHERE cert.test_code = '902'
  AND c.id NOT IN (SELECT DISTINCT concept_id FROM content_items WHERE concept_id IS NOT NULL);

INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes)
SELECT 
    c.id as concept_id,
    'practice' as type,
    'Practice Questions: ' || c.name as title,
    'Complete practice questions for ' || c.name || '. This session includes varied difficulty levels to build mastery.' as content,
    2 as order_index,
    20 as estimated_minutes
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
WHERE cert.test_code = '902'
  AND c.id NOT IN (SELECT DISTINCT concept_id FROM content_items WHERE concept_id IS NOT NULL);

INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes)
SELECT 
    c.id as concept_id,
    'review' as type,
    'Review & Summary: ' || c.name as title,
    'Review key concepts and strategies for ' || c.name || '. Reflect on areas of strength and opportunities for growth.' as content,
    3 as order_index,
    10 as estimated_minutes
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
WHERE cert.test_code = '902'
  AND c.id NOT IN (SELECT DISTINCT concept_id FROM content_items WHERE concept_id IS NOT NULL);

-- Verify the fix
SELECT 
    'VERIFICATION AFTER FIX' as status,
    c.name as concept_name,
    COUNT(ci.id) as content_items_created,
    'Should see 3 items per concept' as expected
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY c.id, c.name
ORDER BY c.name;
