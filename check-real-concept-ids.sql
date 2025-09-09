-- Check actual concept IDs for 902 certification
SELECT c.id, c.name, d.name as domain_name
FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902'
ORDER BY d.order_index, c.id;
