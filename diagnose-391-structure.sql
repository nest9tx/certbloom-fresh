-- Diagnostic to check 391 certification structure
SELECT 
    'CERTIFICATION 391 DETAILED STRUCTURE' as section,
    cert.test_code,
    cert.name as cert_name,
    d.name as domain_name,
    c.name as concept_name,
    COUNT(ci.id) as content_items,
    COUNT(q.id) as questions
FROM certifications cert
LEFT JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts c ON c.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '391'
GROUP BY cert.test_code, cert.name, d.name, c.name
ORDER BY d.name, c.name;

-- Check if there are any domain name conflicts with 900-series
SELECT 
    'DOMAIN NAME ANALYSIS' as section,
    d.name as domain_name,
    cert.test_code,
    cert.name as cert_name,
    COUNT(*) as occurrences
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
WHERE cert.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY d.name, cert.test_code, cert.name
HAVING COUNT(*) > 0
ORDER BY d.name, cert.test_code;

-- Check total structure counts
SELECT 
    'SUMMARY COUNTS' as section,
    cert.test_code,
    cert.name,
    COUNT(DISTINCT d.id) as domains,
    COUNT(DISTINCT c.id) as concepts,
    COUNT(DISTINCT ci.id) as content_items,
    COUNT(DISTINCT q.id) as questions
FROM certifications cert
LEFT JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts c ON c.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '391'
GROUP BY cert.test_code, cert.name;
