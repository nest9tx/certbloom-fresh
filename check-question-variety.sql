    -- Quick check of current question availability for session variety
-- This will help us understand if we have enough questions for proper rotation

-- Count questions by concept for Math 902 certification
SELECT 
    'CURRENT QUESTION DISTRIBUTION' as info,
    d.name as domain_name,
    c.name as concept_name,
    COUNT(q.id) as question_count,
    MAX(q.created_at) as latest_question
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY d.name, c.name, d.order_index, c.order_index
ORDER BY d.order_index, c.order_index;

-- Check total questions available
SELECT 
    'TOTAL QUESTIONS AVAILABLE' as info,
    COUNT(q.id) as total_questions,
    COUNT(DISTINCT q.id) as unique_questions,
    COUNT(ac.id) as total_answer_choices,
    ROUND(COUNT(ac.id)::DECIMAL / NULLIF(COUNT(q.id), 0), 2) as avg_choices_per_question
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
LEFT JOIN answer_choices ac ON ac.question_id = q.id
WHERE cert.test_code = '902';

-- Show sample questions to verify they exist
SELECT 
    'SAMPLE QUESTIONS' as info,
    LEFT(q.question_text, 50) || '...' as question_preview,
    c.name as concept_name,
    COUNT(ac.id) as choice_count
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
LEFT JOIN answer_choices ac ON ac.question_id = q.id
WHERE cert.test_code = '902'
GROUP BY q.id, q.question_text, c.name
ORDER BY q.created_at DESC
LIMIT 5;
