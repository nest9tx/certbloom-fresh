-- Quick investigation to see current duplicates
SELECT 
    cert.name as certification_name,
    d.id as domain_id,
    d.name as domain_name,
    d.code as domain_code,
    d.weight_percentage,
    d.order_index,
    COUNT(c.id) as concepts_count,
    d.created_at
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts c ON c.domain_id = d.id
WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
GROUP BY cert.id, cert.name, d.id, d.name, d.code, d.weight_percentage, d.order_index, d.created_at
ORDER BY cert.name, d.created_at, d.order_index;
