-- =================================================================
-- SAFE CLEANUP: DUPLICATE DOMAINS AND CONCEPTS
-- =================================================================
-- Purpose: Safely remove duplicate domains/concepts with comprehensive 
-- question migration to prevent foreign key violations
-- =================================================================

-- STEP 1: INVESTIGATE CURRENT STATE
-- =================================================================

-- Show all math domains to see what we're working with
SELECT 
    cert.name as certification_name,
    d.id as domain_id,
    d.name as domain_name,
    d.code as domain_code,
    d.weight_percentage,
    COUNT(c.id) as concepts_count,
    d.created_at
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts c ON c.domain_id = d.id
WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
GROUP BY cert.id, cert.name, d.id, d.name, d.code, d.weight_percentage, d.created_at
ORDER BY cert.name, d.created_at;

-- Show all concepts and their question counts
SELECT 
    d.name as domain_name,
    d.code as domain_code,
    d.weight_percentage,
    c.id as concept_id,
    c.name as concept_name,
    COUNT(q.id) as question_count
FROM domains d
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
JOIN certifications cert ON cert.id = d.certification_id
WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
GROUP BY d.name, d.code, d.weight_percentage, c.id, c.name
ORDER BY d.code, c.name;

-- =================================================================
-- STEP 2: COMPREHENSIVE QUESTION MIGRATION
-- =================================================================

-- First, let's migrate ALL questions from concepts in domains with codes 001-004
-- to concepts in domains with weight percentages (legacy domains)

DO $$
DECLARE
    -- Variables for the migration
    question_record RECORD;
    target_concept_id UUID;
    migration_count INTEGER := 0;
BEGIN
    
    -- Loop through all questions that are linked to concepts in new domains (001-004)
    FOR question_record IN 
        SELECT 
            q.id as question_id,
            q.concept_id as old_concept_id,
            c.name as concept_name,
            d.code as domain_code,
            d.name as domain_name
        FROM questions q
        JOIN concepts c ON c.id = q.concept_id
        JOIN domains d ON d.id = c.domain_id
        WHERE d.code IN ('001', '002', '003', '004')
    LOOP
        
        -- Find the best target concept in legacy domains
        target_concept_id := NULL;
        
        -- Try to find exact name matches first
        SELECT c.id INTO target_concept_id
        FROM concepts c
        JOIN domains d ON d.id = c.domain_id
        JOIN certifications cert ON cert.id = d.certification_id
        WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
        AND d.weight_percentage > 0
        AND d.code NOT IN ('001', '002', '003', '004')
        AND c.name ILIKE '%' || question_record.concept_name || '%'
        LIMIT 1;
        
        -- If no exact match, find by domain type and keywords
        IF target_concept_id IS NULL THEN
            CASE question_record.domain_code
                WHEN '001' THEN  -- Number Concepts
                    SELECT c.id INTO target_concept_id
                    FROM concepts c
                    JOIN domains d ON d.id = c.domain_id
                    JOIN certifications cert ON cert.id = d.certification_id
                    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
                    AND d.weight_percentage > 0
                    AND (d.name ILIKE '%number%' OR d.name ILIKE '%operation%')
                    ORDER BY c.order_index NULLS LAST
                    LIMIT 1;
                    
                WHEN '002' THEN  -- Patterns/Algebra
                    SELECT c.id INTO target_concept_id
                    FROM concepts c
                    JOIN domains d ON d.id = c.domain_id
                    JOIN certifications cert ON cert.id = d.certification_id
                    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
                    AND d.weight_percentage > 0
                    AND (d.name ILIKE '%pattern%' OR d.name ILIKE '%algebra%')
                    ORDER BY c.order_index NULLS LAST
                    LIMIT 1;
                    
                WHEN '003' THEN  -- Geometry
                    SELECT c.id INTO target_concept_id
                    FROM concepts c
                    JOIN domains d ON d.id = c.domain_id
                    JOIN certifications cert ON cert.id = d.certification_id
                    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
                    AND d.weight_percentage > 0
                    AND (d.name ILIKE '%geometry%' OR d.name ILIKE '%spatial%')
                    ORDER BY c.order_index NULLS LAST
                    LIMIT 1;
                    
                WHEN '004' THEN  -- Data Analysis
                    SELECT c.id INTO target_concept_id
                    FROM concepts c
                    JOIN domains d ON d.id = c.domain_id
                    JOIN certifications cert ON cert.id = d.certification_id
                    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
                    AND d.weight_percentage > 0
                    AND (d.name ILIKE '%data%' OR d.name ILIKE '%probability%')
                    ORDER BY c.order_index NULLS LAST
                    LIMIT 1;
            END CASE;
        END IF;
        
        -- If still no match, use the first available concept in any legacy math domain
        IF target_concept_id IS NULL THEN
            SELECT c.id INTO target_concept_id
            FROM concepts c
            JOIN domains d ON d.id = c.domain_id
            JOIN certifications cert ON cert.id = d.certification_id
            WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
            AND d.weight_percentage > 0
            AND d.code NOT IN ('001', '002', '003', '004')
            ORDER BY c.order_index NULLS LAST
            LIMIT 1;
        END IF;
        
        -- Update the question if we found a target
        IF target_concept_id IS NOT NULL THEN
            UPDATE questions 
            SET concept_id = target_concept_id
            WHERE id = question_record.question_id;
            
            migration_count := migration_count + 1;
            
            RAISE NOTICE 'Migrated question % from concept "%" to target concept %', 
                question_record.question_id, 
                question_record.concept_name, 
                target_concept_id;
        ELSE
            RAISE NOTICE 'Could not find target for question % in concept "%"', 
                question_record.question_id, 
                question_record.concept_name;
        END IF;
        
    END LOOP;
    
    RAISE NOTICE 'Total questions migrated: %', migration_count;
    
END $$;

-- =================================================================
-- STEP 3: VERIFY ALL QUESTIONS ARE MIGRATED
-- =================================================================

-- Check if any questions are still linked to concepts in domains 001-004
SELECT 
    'Questions still in new domains:' as check_type,
    COUNT(q.id) as remaining_questions,
    STRING_AGG(DISTINCT d.code, ', ') as domain_codes
FROM questions q
JOIN concepts c ON c.id = q.concept_id
JOIN domains d ON d.id = c.domain_id
WHERE d.code IN ('001', '002', '003', '004');

-- If the above returns 0, we can safely proceed with deletion

-- =================================================================
-- STEP 4: SAFE CLEANUP - DELETE EMPTY CONCEPTS AND DOMAINS
-- =================================================================

-- Delete concepts that have no questions (should be all of them in domains 001-004 now)
DELETE FROM concepts 
WHERE id IN (
    SELECT c.id
    FROM concepts c
    JOIN domains d ON d.id = c.domain_id
    WHERE d.code IN ('001', '002', '003', '004')
    AND NOT EXISTS (
        SELECT 1 FROM questions q WHERE q.concept_id = c.id
    )
);

-- Delete the empty domains
DELETE FROM domains 
WHERE code IN ('001', '002', '003', '004')
AND id IN (
    SELECT d.id FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
)
AND NOT EXISTS (
    SELECT 1 FROM concepts c WHERE c.domain_id = domains.id
);

-- =================================================================
-- STEP 5: FINAL VERIFICATION
-- =================================================================

-- Show final state
SELECT 
    'FINAL STATE:' as status,
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
ORDER BY d.weight_percentage DESC;

SELECT 'SUCCESS: Safely cleaned up duplicate domains!' as final_status;
