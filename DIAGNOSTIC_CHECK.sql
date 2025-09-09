-- 🔍 DIAGNOSTIC: Check what's happening with the concepts and modules

-- Check if the concepts exist and their exact names
SELECT 
    c.id as concept_id,
    c.name as concept_name,
    c.order_index
FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902' AND d.name = 'Number Concepts and Operations'
ORDER BY c.order_index;

-- Check if learning modules exist for these concepts
SELECT 
    c.name as concept_name,
    lm.module_type,
    lm.title,
    CASE WHEN lm.content_data IS NULL THEN 'NULL' ELSE 'HAS DATA' END as content_status
FROM concepts c
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
LEFT JOIN learning_modules lm ON c.id = lm.concept_id
WHERE cert.test_code = '902' AND d.name = 'Number Concepts and Operations'
ORDER BY c.order_index, lm.module_type;

-- Check what module types exist in learning_modules table
SELECT DISTINCT module_type 
FROM learning_modules 
WHERE module_type IS NOT NULL;

-- Test the function call with verbose output
SELECT build_concept_learning_modules(
    'Operations with Whole Numbers',
    'Test explanation',
    ARRAY['principle1'],
    ARRAY['visual1'], 
    ARRAY['vocab1'],
    ARRAY['sequence1'],
    ARRAY['diff1'],
    ARRAY['assess1'],
    ARRAY['engage1'],
    ARRAY[jsonb_build_object('type', 'test')],
    ARRAY['question1'],
    ARRAY['intervention1']
) as function_result;
