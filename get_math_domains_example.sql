-- GET MATH 902 DOMAIN EXAMPLES
-- Simple query to see the pattern

SELECT 
    name,
    code,
    description,
    weight_percentage,
    order_index
FROM domains d
JOIN certifications c ON d.certification_id = c.id
WHERE c.test_code = '902'
ORDER BY d.order_index;
