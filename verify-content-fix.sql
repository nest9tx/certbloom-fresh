-- Verify that all certifications now have content items for their concepts with questions
SELECT 
    'VERIFICATION: Content Items Created' as status,
    cert.test_code,
    cert.name as certification_name,
    COUNT(DISTINCT c.id) as concepts_with_questions,
    COUNT(DISTINCT ci.id) as content_items_created,
    COUNT(DISTINCT q.id) as total_questions
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
WHERE cert.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY cert.test_code, cert.name
ORDER BY cert.test_code;

-- Show sample content for each certification
SELECT 
    'SAMPLE CONTENT ITEMS' as info,
    cert.test_code,
    c.name as concept_name,
    ci.type,
    ci.title,
    CASE 
        WHEN ci.content->>'session_type' IS NOT NULL 
        THEN 'Practice: ' || (ci.content->>'target_question_count') || ' questions'
        ELSE LEFT(COALESCE(ci.content->>'sections'->0, ci.content::text), 50) || '...'
    END as content_preview
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN content_items ci ON ci.concept_id = c.id
WHERE cert.test_code IN ('391', '901', '903', '904', '905')
ORDER BY cert.test_code, c.name, ci.order_index
LIMIT 15;
