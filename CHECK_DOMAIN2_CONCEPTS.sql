-- Check what concepts exist in Domain 2 (Patterns and Algebra)
SELECT 
    c.name as concept_name, 
    d.name as domain_name,
    COUNT(lm.id) as learning_modules_count
FROM concepts c 
JOIN domains d ON c.domain_id = d.id 
JOIN certifications cert ON d.certification_id = cert.id 
LEFT JOIN learning_modules lm ON c.id = lm.concept_id
WHERE cert.test_code = '902' AND d.name = 'Patterns and Algebra'
GROUP BY c.id, c.name, d.name
ORDER BY c.name;
