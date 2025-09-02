-- Test if questions are properly connected to concepts and certifications
SELECT 
    'QUESTION CONNECTIVITY TEST' as test_type,
    cert.test_code,
    cert.name as certification_name,
    COUNT(DISTINCT d.id) as domain_count,
    COUNT(DISTINCT c.id) as concept_count,
    COUNT(DISTINCT q.id) as question_count
FROM certifications cert
LEFT JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY cert.test_code, cert.name
ORDER BY cert.test_code;

-- Show specific examples for each certification
SELECT 
    'SAMPLE QUESTIONS BY CERTIFICATION' as test_type,
    cert.test_code,
    c.name as concept_name,
    COUNT(q.id) as question_count,
    STRING_AGG(LEFT(q.question_text, 50), ' | ') as sample_questions
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY cert.test_code, c.name
HAVING COUNT(q.id) > 0
ORDER BY cert.test_code, question_count DESC
LIMIT 20;
