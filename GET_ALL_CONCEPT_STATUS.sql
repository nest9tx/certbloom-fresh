-- Get all concepts with their learning module counts for display
SELECT 
    c.id as concept_id,
    c.name as concept_name,
    d.name as domain_name,
    COUNT(lm.id) as module_count,
    CASE 
        WHEN COUNT(lm.id) = 5 THEN '✅ Complete'
        WHEN COUNT(lm.id) > 0 THEN '🔄 Partial'
        ELSE '❌ Missing'
    END as status
FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
LEFT JOIN learning_modules lm ON c.id = lm.concept_id
WHERE cert.test_code = '902'
GROUP BY c.id, c.name, d.name, d.order_index
ORDER BY d.order_index, c.name;
