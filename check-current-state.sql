-- Quick check for current state
SELECT 
    'CURRENT STATE CHECK' as status,
    cert.test_code,
    COUNT(DISTINCT c.id) as concepts_total,
    COUNT(DISTINCT CASE WHEN ci.id IS NOT NULL THEN c.id END) as concepts_with_content,
    COUNT(DISTINCT CASE WHEN q.id IS NOT NULL THEN c.id END) as concepts_with_questions,
    COUNT(DISTINCT ci.id) as total_content_items,
    COUNT(DISTINCT q.id) as total_questions
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY cert.test_code
ORDER BY cert.test_code;

-- Show concepts that have questions but no content (the "blank slate" issue)
SELECT 
    'BLANK SLATE CONCEPTS' as issue_type,
    cert.test_code,
    c.name as concept_name,
    COUNT(q.id) as question_count,
    COUNT(ci.id) as content_item_count
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
WHERE cert.test_code IN ('391', '901', '903', '904', '905')
GROUP BY cert.test_code, c.id, c.name
HAVING COUNT(ci.id) = 0  -- No content items
ORDER BY cert.test_code, question_count DESC
LIMIT 10;
