-- Check 391 certification structure and its relationship to 900-series
SELECT 
    'CERTIFICATION 391 ANALYSIS' as analysis_type,
    cert.test_code,
    cert.name,
    COUNT(DISTINCT d.id) as domains,
    COUNT(DISTINCT c.id) as concepts,
    STRING_AGG(DISTINCT d.name, ' | ' ORDER BY d.name) as domain_names
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
WHERE cert.test_code = '391'
GROUP BY cert.test_code, cert.name;

-- Check if there are separate 900-series certifications that might be conflicting
SELECT 
    'ALL CERTIFICATIONS' as analysis_type,
    test_code,
    name,
    id
FROM certifications 
WHERE test_code IN ('391', '901', '902', '903', '904', '905')
ORDER BY test_code;

-- Check if 391 domains overlap with 900-series certification names
SELECT 
    'DOMAIN OVERLAP CHECK' as analysis_type,
    d.name as domain_name,
    cert.test_code,
    cert.name as cert_name
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
WHERE cert.test_code IN ('391', '901', '902', '903', '904', '905')
ORDER BY d.name, cert.test_code;
