-- Verify all learning modules are populated with content
SELECT 
    d.name as domain_name,
    c.name as concept_name,
    lm.module_type,
    CASE 
        WHEN lm.content_data IS NOT NULL THEN 'Has Content'
        ELSE 'Missing Content'
    END as content_status,
    jsonb_array_length(lm.content_data->'learning_objectives') as num_objectives,
    jsonb_array_length(lm.content_data->'teaching_tips') as num_teaching_tips
FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
JOIN learning_modules lm ON c.id = lm.concept_id
WHERE cert.test_code = '902'
ORDER BY d.order_index, c.name, lm.module_type;
