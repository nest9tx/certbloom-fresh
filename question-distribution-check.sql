-- COMPREHENSIVE QUESTION DISTRIBUTION CHECK
-- Verify question counts match dashboard expectations
-- Run this to check current state of question bank

-- =================================================================
-- OVERVIEW: Total Questions by Concept
-- =================================================================
SELECT 
    c.name AS concept_name,
    COUNT(q.id) AS question_count,
    c.description
FROM concepts c
LEFT JOIN questions q ON c.id = q.concept_id
WHERE c.certification_id = (
    SELECT id FROM certifications WHERE name = 'Texas Mathematics 4-8'
)
GROUP BY c.id, c.name, c.description
ORDER BY c.name;

-- =================================================================
-- DETAILED BREAKDOWN: Questions by Difficulty Level
-- =================================================================
SELECT 
    c.name AS concept_name,
    q.difficulty_level,
    COUNT(q.id) AS count
FROM concepts c
LEFT JOIN questions q ON c.id = q.concept_id
WHERE c.certification_id = (
    SELECT id FROM certifications WHERE name = 'Texas Mathematics 4-8'
)
AND q.difficulty_level IS NOT NULL
GROUP BY c.name, q.difficulty_level
ORDER BY c.name, q.difficulty_level;

-- =================================================================
-- COGNITIVE LEVEL DISTRIBUTION
-- =================================================================
SELECT 
    c.name AS concept_name,
    q.cognitive_level,
    COUNT(q.id) AS count
FROM concepts c
LEFT JOIN questions q ON c.id = q.concept_id
WHERE c.certification_id = (
    SELECT id FROM certifications WHERE name = 'Texas Mathematics 4-8'
)
AND q.cognitive_level IS NOT NULL
GROUP BY c.name, q.cognitive_level
ORDER BY c.name, q.cognitive_level;

-- =================================================================
-- DOMAIN-LEVEL SUMMARY (Using concept names to infer domains)
-- =================================================================
SELECT 
    CASE 
        WHEN c.name LIKE '%Place Value%' OR c.name LIKE '%Number%' OR c.name LIKE '%Fraction%' OR c.name LIKE '%Decimal%' OR c.name LIKE '%Integer%' THEN 'Numbers and Operations'
        WHEN c.name LIKE '%Algebra%' OR c.name LIKE '%Pattern%' OR c.name LIKE '%Expression%' OR c.name LIKE '%Equation%' OR c.name LIKE '%Function%' OR c.name LIKE '%Multiplication%' OR c.name LIKE '%Division%' THEN 'Algebra'
        WHEN c.name LIKE '%Geometry%' OR c.name LIKE '%Shape%' OR c.name LIKE '%Angle%' OR c.name LIKE '%Area%' OR c.name LIKE '%Perimeter%' THEN 'Geometry and Measurement'
        WHEN c.name LIKE '%Data%' OR c.name LIKE '%Graph%' OR c.name LIKE '%Statistics%' OR c.name LIKE '%Probability%' THEN 'Data Analysis and Probability'
        ELSE 'Other'
    END AS domain,
    COUNT(q.id) AS total_questions,
    ROUND(COUNT(q.id) * 100.0 / (
        SELECT COUNT(*) FROM questions q2 
        JOIN concepts c2 ON q2.concept_id = c2.id 
        WHERE c2.certification_id = (
            SELECT id FROM certifications WHERE name = 'Texas Mathematics 4-8'
        )
    ), 1) AS percentage_of_total
FROM concepts c
LEFT JOIN questions q ON c.id = q.concept_id
WHERE c.certification_id = (
    SELECT id FROM certifications WHERE name = 'Texas Mathematics 4-8'
)
GROUP BY 1
ORDER BY total_questions DESC;

-- =================================================================
-- TOP CONCEPTS BY QUESTION COUNT
-- =================================================================
SELECT 
    c.name AS concept_name,
    COUNT(q.id) AS question_count,
    CASE 
        WHEN COUNT(q.id) >= 20 THEN 'Excellent Coverage'
        WHEN COUNT(q.id) >= 15 THEN 'Good Coverage'
        WHEN COUNT(q.id) >= 10 THEN 'Moderate Coverage'
        WHEN COUNT(q.id) >= 5 THEN 'Basic Coverage'
        ELSE 'Needs Questions'
    END AS coverage_status
FROM concepts c
LEFT JOIN questions q ON c.id = q.concept_id
WHERE c.certification_id = (
    SELECT id FROM certifications WHERE name = 'Texas Mathematics 4-8'
)
GROUP BY c.id, c.name
ORDER BY question_count DESC;

-- =================================================================
-- SESSION VARIETY CHECK (Questions per Concept)
-- =================================================================
SELECT 
    'SESSION VARIETY ANALYSIS' AS analysis_type,
    COUNT(DISTINCT c.id) AS total_concepts,
    SUM(CASE WHEN q_count.count >= 15 THEN 1 ELSE 0 END) AS concepts_with_good_variety,
    SUM(CASE WHEN q_count.count < 5 THEN 1 ELSE 0 END) AS concepts_needing_questions,
    ROUND(AVG(q_count.count), 1) AS avg_questions_per_concept
FROM concepts c
LEFT JOIN (
    SELECT concept_id, COUNT(*) as count 
    FROM questions 
    GROUP BY concept_id
) q_count ON c.id = q_count.concept_id
WHERE c.certification_id = (
    SELECT id FROM certifications WHERE name = 'Texas Mathematics 4-8'
);

-- =================================================================
-- RECENT ADDITIONS CHECK
-- =================================================================
SELECT 
    'Recent Question Additions' AS section,
    c.name AS concept_name,
    COUNT(q.id) AS questions_added,
    MIN(q.created_at) AS first_added,
    MAX(q.created_at) AS last_added
FROM concepts c
JOIN questions q ON c.id = q.concept_id
WHERE c.certification_id = (
    SELECT id FROM certifications WHERE name = 'Texas Mathematics 4-8'
)
AND q.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY c.name
ORDER BY questions_added DESC;

-- =================================================================
-- ANSWER CHOICES VERIFICATION
-- =================================================================
SELECT 
    'Answer Choices Check' AS section,
    c.name AS concept_name,
    COUNT(DISTINCT q.id) AS questions_with_choices,
    COUNT(ac.id) AS total_answer_choices,
    ROUND(COUNT(ac.id) * 1.0 / COUNT(DISTINCT q.id), 1) AS avg_choices_per_question
FROM concepts c
JOIN questions q ON c.id = q.concept_id
LEFT JOIN answer_choices ac ON q.id = ac.question_id
WHERE c.certification_id = (
    SELECT id FROM certifications WHERE name = 'Texas Mathematics 4-8'
)
GROUP BY c.name
HAVING COUNT(DISTINCT q.id) > 0
ORDER BY questions_with_choices DESC;
