-- =================================================================
-- INVESTIGATE DUPLICATE DOMAINS AND CONCEPTS
-- =================================================================

-- Check all domains for math certification
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

-- Check all concepts for math domains
SELECT 
    cert.name as certification_name,
    d.name as domain_name,
    d.code as domain_code,
    c.id as concept_id,
    c.name as concept_name,
    c.difficulty_level,
    c.estimated_study_minutes,
    c.order_index,
    COUNT(q.id) as linked_questions,
    c.created_at
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
GROUP BY cert.name, d.name, d.code, c.id, c.name, c.difficulty_level, c.estimated_study_minutes, c.order_index, c.created_at
ORDER BY cert.name, d.created_at, c.created_at, c.order_index;

-- Check which questions are linked to which concepts
SELECT 
    q.id as question_id,
    LEFT(q.question_text, 80) as question_preview,
    c.name as concept_name,
    d.name as domain_name,
    d.code as domain_code
FROM questions q
LEFT JOIN concepts c ON c.id = q.concept_id
LEFT JOIN domains d ON d.id = c.domain_id
LEFT JOIN certifications cert ON cert.id = d.certification_id
WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%' OR q.concept_id IS NULL
ORDER BY d.code, c.name, q.id;
