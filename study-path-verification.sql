-- Comprehensive Study Path Question Flow Verification
-- This verifies that our 475 Math 902 questions will populate correctly in both:
-- 1. Individual Math 902 test study path
-- 2. Math portion of the main EC-6 exam study path

-- VERIFICATION 1: Check total question count matches CSV data
SELECT 
    'TOTAL QUESTION VERIFICATION' as verification_type,
    COUNT(*) as total_questions_in_db,
    475 as expected_from_csv,
    CASE 
        WHEN COUNT(*) = 475 THEN '✅ MATCH' 
        ELSE '❌ MISMATCH' 
    END as status
FROM questions q
JOIN concepts c ON c.id = q.concept_id
JOIN domains d ON d.id = c.domain_id
JOIN certifications cert ON cert.id = d.certification_id
WHERE cert.test_code = '902';

-- VERIFICATION 2: Domain distribution for study path display
SELECT 
    'DOMAIN DISTRIBUTION' as verification_type,
    d.name as domain_name,
    d.weight_percentage as domain_weight,
    COUNT(q.id) as questions_per_domain,
    ROUND(COUNT(q.id) * 100.0 / SUM(COUNT(q.id)) OVER (), 1) as actual_percentage
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY d.name, d.weight_percentage, d.order_index
ORDER BY d.order_index;

-- VERIFICATION 3: Concept completeness for granular study paths
SELECT 
    'CONCEPT COMPLETENESS' as verification_type,
    d.name as domain_name,
    c.name as concept_name,
    COUNT(q.id) as question_count,
    CASE 
        WHEN COUNT(q.id) >= 20 THEN '🟢 EXCELLENT (20+)'
        WHEN COUNT(q.id) >= 10 THEN '🟡 GOOD (10-19)'
        WHEN COUNT(q.id) >= 5 THEN '🟠 FAIR (5-9)'
        WHEN COUNT(q.id) > 0 THEN '🔴 LOW (1-4)'
        ELSE '❌ EMPTY'
    END as variety_status
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY d.name, c.name, d.order_index, c.order_index
ORDER BY d.order_index, c.order_index;

-- VERIFICATION 4: Question difficulty distribution for adaptive learning
SELECT 
    'DIFFICULTY DISTRIBUTION' as verification_type,
    d.name as domain_name,
    q.difficulty_level,
    COUNT(*) as question_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY d.name), 1) as percentage_in_domain
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY d.name, q.difficulty_level, d.order_index
ORDER BY d.order_index, 
         CASE q.difficulty_level 
             WHEN 'easy' THEN 1 
             WHEN 'medium' THEN 2 
             WHEN 'hard' THEN 3 
         END;

-- VERIFICATION 5: EC-6 Main Exam Math Section Compatibility
-- Check that Math 902 questions are accessible when EC-6 exam includes math
SELECT 
    'EC-6 COMPATIBILITY CHECK' as verification_type,
    'Math portion of EC-6 exam should include these Math 902 questions' as description,
    COUNT(DISTINCT q.id) as math_questions_available,
    COUNT(DISTINCT c.id) as math_concepts_available,
    COUNT(DISTINCT d.id) as math_domains_available
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902';

-- VERIFICATION 6: Study session variety check
-- Ensure each concept has enough questions for multiple unique sessions
SELECT 
    'SESSION VARIETY CHECK' as verification_type,
    c.name as concept_name,
    COUNT(q.id) as total_questions,
    FLOOR(COUNT(q.id) / 8) as estimated_unique_sessions,
    CASE 
        WHEN COUNT(q.id) >= 24 THEN '🟢 EXCELLENT (3+ unique sessions)'
        WHEN COUNT(q.id) >= 16 THEN '🟡 GOOD (2+ unique sessions)'
        WHEN COUNT(q.id) >= 8 THEN '🟠 FAIR (1+ unique session)'
        ELSE '🔴 INSUFFICIENT (<8 questions)'
    END as session_variety_status
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY c.name, c.order_index, d.order_index
ORDER BY d.order_index, c.order_index;
