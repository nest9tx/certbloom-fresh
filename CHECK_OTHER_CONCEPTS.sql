-- Check specific content for non-Place Value concepts
SELECT 
    c.name as concept_name,
    lm.module_type,
    lm.content_data->'learning_objectives' as objectives,
    lm.content_data->'teaching_tips' as tips
FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
JOIN learning_modules lm ON c.id = lm.concept_id
WHERE cert.test_code = '902' 
  AND c.name != 'Place Value and Number Sense'
  AND lm.module_type = 'concept_introduction'
ORDER BY d.order_index, c.name;
