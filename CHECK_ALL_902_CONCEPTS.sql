-- Check ALL concepts in 902 certification to see naming patterns
SELECT 
    d.name as domain_name,
    c.name as concept_name,
    COUNT(lm.id) as learning_modules_count
FROM concepts c 
JOIN domains d ON c.domain_id = d.id 
JOIN certifications cert ON d.certification_id = cert.id 
LEFT JOIN learning_modules lm ON c.id = lm.concept_id
WHERE cert.test_code = '902'
GROUP BY d.id, d.name, c.id, c.name
ORDER BY d.name, c.name;
