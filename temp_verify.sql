SELECT 
    d.name as domain_name,
    COUNT(DISTINCT c.id) as total_concepts,
    COUNT(lm.id) as total_modules
FROM domains d
JOIN certifications cert ON d.certification_id = cert.id
JOIN concepts c ON d.id = c.domain_id
LEFT JOIN learning_modules lm ON c.id = lm.concept_id
WHERE cert.test_code = '902'
GROUP BY d.name, d.order_index
ORDER BY d.order_index;
