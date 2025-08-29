-- =================================================================
-- BULLETPROOF CLEANUP: FORCE MIGRATE ALL QUESTIONS FIRST
-- =================================================================
-- Purpose: Aggressively migrate ALL questions before any deletions
-- =================================================================

-- STEP 1: INVESTIGATE WHAT WE'RE WORKING WITH
-- =================================================================

-- Show current state
SELECT 
    'CURRENT STATE:' as info,
    cert.name as certification_name,
    d.name as domain_name,
    d.code as domain_code,
    d.weight_percentage,
    COUNT(c.id) as concepts_count,
    COUNT(q.id) as total_questions
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
GROUP BY cert.name, d.name, d.code, d.weight_percentage
ORDER BY d.weight_percentage DESC, d.code;

-- Show which concepts currently have questions
SELECT 
    'CONCEPTS WITH QUESTIONS:' as info,
    d.name as domain_name,
    d.code as domain_code,
    c.name as concept_name,
    c.id as concept_id,
    COUNT(q.id) as question_count
FROM domains d
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
JOIN certifications cert ON cert.id = d.certification_id
WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
AND EXISTS (SELECT 1 FROM questions WHERE concept_id = c.id)
GROUP BY d.name, d.code, c.name, c.id
ORDER BY d.code, c.name;

-- =================================================================
-- STEP 2: FIX WEIGHTS AND IDENTIFY TARGET DOMAINS
-- =================================================================

-- Fix weight percentages first
UPDATE domains SET weight_percentage = 40.00
WHERE id IN (
    SELECT d.id FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND (d.name ILIKE '%number%' OR d.name ILIKE '%operation%')
    AND d.code NOT IN ('001', '002', '003', '004')
);

UPDATE domains SET weight_percentage = 30.00
WHERE id IN (
    SELECT d.id FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND (d.name ILIKE '%pattern%' OR d.name ILIKE '%algebra%')
    AND d.code NOT IN ('001', '002', '003', '004')
);

UPDATE domains SET weight_percentage = 20.00
WHERE id IN (
    SELECT d.id FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND (d.name ILIKE '%geometry%' OR d.name ILIKE '%spatial%')
    AND d.code NOT IN ('001', '002', '003', '004')
);

UPDATE domains SET weight_percentage = 10.00
WHERE id IN (
    SELECT d.id FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND (d.name ILIKE '%data%' OR d.name ILIKE '%probability%')
    AND d.code NOT IN ('001', '002', '003', '004')
);

-- =================================================================
-- STEP 3: BRUTALLY SIMPLE QUESTION MIGRATION
-- =================================================================

-- Get one target concept for each domain category (the ones we want to keep)
CREATE TEMP TABLE target_concepts (
    category TEXT,
    concept_id UUID,
    domain_id UUID,
    domain_name TEXT
);

-- Insert Number Concepts target
INSERT INTO target_concepts
SELECT 
    'number' as category,
    c.id as concept_id,
    d.id as domain_id,
    d.name as domain_name
FROM concepts c
JOIN domains d ON d.id = c.domain_id
JOIN certifications cert ON cert.id = d.certification_id
WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
AND (d.name ILIKE '%number%' OR d.name ILIKE '%operation%')
AND d.weight_percentage = 40.00
ORDER BY c.order_index NULLS LAST
LIMIT 1;

-- Insert Algebra target
INSERT INTO target_concepts
SELECT 
    'algebra' as category,
    c.id as concept_id,
    d.id as domain_id,
    d.name as domain_name
FROM concepts c
JOIN domains d ON d.id = c.domain_id
JOIN certifications cert ON cert.id = d.certification_id
WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
AND (d.name ILIKE '%pattern%' OR d.name ILIKE '%algebra%')
AND d.weight_percentage = 30.00
ORDER BY c.order_index NULLS LAST
LIMIT 1;

-- Insert Geometry target
INSERT INTO target_concepts
SELECT 
    'geometry' as category,
    c.id as concept_id,
    d.id as domain_id,
    d.name as domain_name
FROM concepts c
JOIN domains d ON d.id = c.domain_id
JOIN certifications cert ON cert.id = d.certification_id
WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
AND (d.name ILIKE '%geometry%' OR d.name ILIKE '%spatial%')
AND d.weight_percentage = 20.00
ORDER BY c.order_index NULLS LAST
LIMIT 1;

-- Insert Data Analysis target
INSERT INTO target_concepts
SELECT 
    'data' as category,
    c.id as concept_id,
    d.id as domain_id,
    d.name as domain_name
FROM concepts c
JOIN domains d ON d.id = c.domain_id
JOIN certifications cert ON cert.id = d.certification_id
WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
AND (d.name ILIKE '%data%' OR d.name ILIKE '%probability%')
AND d.weight_percentage = 10.00
ORDER BY c.order_index NULLS LAST
LIMIT 1;

-- Show target concepts
SELECT 'TARGET CONCEPTS:' as info, * FROM target_concepts;

-- =================================================================
-- STEP 4: MIGRATE ALL QUESTIONS - NO EXCEPTIONS
-- =================================================================

-- Migrate Number Concepts questions
UPDATE questions 
SET concept_id = (SELECT concept_id FROM target_concepts WHERE category = 'number')
WHERE (
    -- Questions by topic
    topic_id IN (
        SELECT id FROM topics WHERE name ILIKE '%number%' OR name ILIKE '%operation%'
    )
    OR
    -- Questions by current concept
    concept_id IN (
        SELECT c.id FROM concepts c
        JOIN domains d ON d.id = c.domain_id
        WHERE (d.name ILIKE '%number%' OR d.name ILIKE '%operation%')
        OR (c.name ILIKE '%place value%' OR c.name ILIKE '%fraction%' OR c.name ILIKE '%multiplication%' OR c.name ILIKE '%number%')
    )
    OR
    -- Questions by tags/content
    (tags && ARRAY['place_value', 'fractions', 'multiplication', 'number_sense'] OR
     question_text ILIKE '%place value%' OR question_text ILIKE '%fraction%' OR question_text ILIKE '%multiplication%')
);

-- Migrate Algebra questions
UPDATE questions 
SET concept_id = (SELECT concept_id FROM target_concepts WHERE category = 'algebra')
WHERE (
    topic_id IN (
        SELECT id FROM topics WHERE name ILIKE '%pattern%' OR name ILIKE '%algebra%'
    )
    OR
    concept_id IN (
        SELECT c.id FROM concepts c
        JOIN domains d ON d.id = c.domain_id
        WHERE (d.name ILIKE '%pattern%' OR d.name ILIKE '%algebra%')
        OR (c.name ILIKE '%pattern%' OR c.name ILIKE '%equation%' OR c.name ILIKE '%algebra%')
    )
    OR
    (tags && ARRAY['patterns', 'equations', 'algebraic_reasoning'] OR
     question_text ILIKE '%pattern%' OR question_text ILIKE '%equation%')
);

-- Migrate Geometry questions
UPDATE questions 
SET concept_id = (SELECT concept_id FROM target_concepts WHERE category = 'geometry')
WHERE (
    topic_id IN (
        SELECT id FROM topics WHERE name ILIKE '%geometry%' OR name ILIKE '%spatial%'
    )
    OR
    concept_id IN (
        SELECT c.id FROM concepts c
        JOIN domains d ON d.id = c.domain_id
        WHERE (d.name ILIKE '%geometry%' OR d.name ILIKE '%spatial%')
        OR (c.name ILIKE '%shape%' OR c.name ILIKE '%measurement%' OR c.name ILIKE '%geometry%')
    )
    OR
    (tags && ARRAY['geometry', 'measurement', 'shapes'] OR
     question_text ILIKE '%shape%' OR question_text ILIKE '%measurement%' OR question_text ILIKE '%clock%')
);

-- Migrate Data Analysis questions
UPDATE questions 
SET concept_id = (SELECT concept_id FROM target_concepts WHERE category = 'data')
WHERE (
    topic_id IN (
        SELECT id FROM topics WHERE name ILIKE '%data%' OR name ILIKE '%probability%'
    )
    OR
    concept_id IN (
        SELECT c.id FROM concepts c
        JOIN domains d ON d.id = c.domain_id
        WHERE (d.name ILIKE '%data%' OR d.name ILIKE '%probability%')
        OR (c.name ILIKE '%data%' OR c.name ILIKE '%probability%')
    )
    OR
    (tags && ARRAY['data', 'probability', 'tables'] OR
     question_text ILIKE '%data%' OR question_text ILIKE '%table%')
);

-- Catch any remaining math questions and put them in Number Concepts
UPDATE questions 
SET concept_id = (SELECT concept_id FROM target_concepts WHERE category = 'number')
WHERE concept_id IN (
    SELECT c.id FROM concepts c
    JOIN domains d ON d.id = c.domain_id
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
)
AND concept_id NOT IN (SELECT concept_id FROM target_concepts);

-- =================================================================
-- STEP 5: VERIFY NO QUESTIONS LEFT BEHIND
-- =================================================================

-- Check if ANY questions are still linked to concepts we want to delete
SELECT 
    'QUESTIONS STILL IN DUPLICATE DOMAINS:' as check_type,
    COUNT(q.id) as remaining_questions,
    STRING_AGG(DISTINCT d.code, ', ') as domain_codes,
    STRING_AGG(DISTINCT c.name, '; ') as concept_names
FROM questions q
JOIN concepts c ON c.id = q.concept_id
JOIN domains d ON d.id = c.domain_id
WHERE d.code IN ('001', '002', '003', '004')
OR c.id NOT IN (SELECT concept_id FROM target_concepts);

-- If the above shows 0 questions, we can proceed safely

-- =================================================================
-- STEP 6: SAFE DELETION - ONLY DELETE EMPTY CONCEPTS/DOMAINS
-- =================================================================

-- Delete concepts that have NO questions (should be safe now)
DELETE FROM concepts 
WHERE id NOT IN (SELECT concept_id FROM target_concepts)
AND id IN (
    SELECT c.id FROM concepts c
    JOIN domains d ON d.id = c.domain_id
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
)
AND NOT EXISTS (SELECT 1 FROM questions q WHERE q.concept_id = concepts.id);

-- Delete domains that have NO concepts (should be safe now)
DELETE FROM domains 
WHERE id IN (
    SELECT d.id FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
)
AND NOT EXISTS (SELECT 1 FROM concepts c WHERE c.domain_id = domains.id);

-- =================================================================
-- STEP 7: FINAL VERIFICATION
-- =================================================================

-- Show final clean state
SELECT 
    'FINAL STATE:' as status,
    cert.name as certification_name,
    d.name as domain_name,
    d.code as domain_code,
    d.weight_percentage,
    COUNT(DISTINCT c.id) as concepts_count,
    COUNT(q.id) as total_questions
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
GROUP BY cert.name, d.name, d.code, d.weight_percentage
ORDER BY d.weight_percentage DESC;

SELECT 'SUCCESS: Bulletproof cleanup completed!' as final_status;
