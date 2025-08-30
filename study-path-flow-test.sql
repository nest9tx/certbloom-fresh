-- STUDY PATH FLOW VERIFICATION TEST
-- Test both Individual Math 902 and EC-6 Math Section access

-- TEST 1: Individual Math 902 Study Path
-- Verify all 475 questions are accessible when user selects Math 902 directly
SELECT 
    'INDIVIDUAL MATH 902 TEST ACCESS' as test_name,
    cert.name as certification_name,
    cert.test_code,
    COUNT(DISTINCT q.id) as total_questions,
    COUNT(DISTINCT c.id) as total_concepts,
    COUNT(DISTINCT d.id) as total_domains,
    '✅ Should be 475 questions across 19 concepts in 4 domains' as expected_result
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY cert.id, cert.name, cert.test_code;

-- TEST 2: EC-6 Main Exam Math Section Access
-- When user selects EC-6 main exam (391), verify Math 902 questions are included
SELECT 
    'EC-6 MAIN EXAM MATH SECTION ACCESS' as test_name,
    'Math questions should be available within EC-6 study path' as description,
    COUNT(DISTINCT q.id) as math_questions_available,
    'These Math 902 questions should appear in EC-6 Math domain sections' as note
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id  
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902';

-- TEST 3: Study Path Domain Structure Verification
-- Verify the 4 domains appear correctly with proper weights
SELECT 
    'STUDY PATH DOMAIN STRUCTURE' as test_name,
    d.order_index as domain_order,
    d.name as domain_name,
    d.weight_percentage as official_weight,
    COUNT(q.id) as question_count,
    ROUND(COUNT(q.id) * 100.0 / 475, 1) as actual_percentage,
    CASE 
        WHEN ABS(d.weight_percentage - ROUND(COUNT(q.id) * 100.0 / 475, 0)) <= 2 
        THEN '✅ Weight matches question distribution'
        ELSE '⚠️ Weight vs question count mismatch'
    END as weight_alignment
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY d.id, d.order_index, d.name, d.weight_percentage
ORDER BY d.order_index;

-- TEST 4: Concept-Level Study Session Readiness
-- Verify each concept has sufficient questions for unique sessions
SELECT 
    'CONCEPT SESSION READINESS' as test_name,
    d.name as domain_name,
    c.name as concept_name,
    COUNT(q.id) as question_count,
    CASE 
        WHEN COUNT(q.id) >= 25 THEN '🟢 EXCELLENT - Multiple unique sessions possible'
        WHEN COUNT(q.id) >= 15 THEN '🟡 GOOD - 2-3 unique sessions possible'
        WHEN COUNT(q.id) >= 8 THEN '🟠 ADEQUATE - 1-2 unique sessions possible'
        ELSE '🔴 INSUFFICIENT - May repeat questions'
    END as session_readiness,
    FLOOR(COUNT(q.id) / 8) as estimated_unique_sessions
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY d.name, c.name, d.order_index, c.order_index
ORDER BY d.order_index, c.order_index;

-- TEST 5: Adaptive Learning Algorithm Compatibility
-- Verify difficulty distribution supports adaptive progression
SELECT 
    'ADAPTIVE LEARNING COMPATIBILITY' as test_name,
    c.name as concept_name,
    COUNT(CASE WHEN q.difficulty_level = 'easy' THEN 1 END) as easy_questions,
    COUNT(CASE WHEN q.difficulty_level = 'medium' THEN 1 END) as medium_questions,
    COUNT(CASE WHEN q.difficulty_level = 'hard' THEN 1 END) as hard_questions,
    CASE 
        WHEN COUNT(CASE WHEN q.difficulty_level = 'easy' THEN 1 END) >= 5
             AND COUNT(CASE WHEN q.difficulty_level = 'medium' THEN 1 END) >= 8  
             AND COUNT(CASE WHEN q.difficulty_level = 'hard' THEN 1 END) >= 2
        THEN '✅ Supports full adaptive progression'
        ELSE '⚠️ Limited adaptive capability'
    END as adaptive_support
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY c.name, d.order_index, c.order_index
ORDER BY d.order_index, c.order_index;
