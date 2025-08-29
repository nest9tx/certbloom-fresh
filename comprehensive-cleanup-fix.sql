-- =================================================================
-- COMPREHENSIVE DUPLICATE CLEANUP & WEIGHT FIX
-- =================================================================
-- Purpose: Fix weight percentages and complete cleanup of duplicates
-- =================================================================

-- STEP 1: INVESTIGATE CURRENT STATE
-- =================================================================

-- Show current state of all math domains
SELECT 
    'CURRENT STATE:' as info,
    cert.name as certification_name,
    d.id as domain_id,
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
GROUP BY cert.name, d.id, d.name, d.code, d.weight_percentage
ORDER BY d.weight_percentage DESC, d.code;

-- =================================================================
-- STEP 2: FIX WEIGHT PERCENTAGES ON LEGACY DOMAINS
-- =================================================================

-- Update the weight percentages based on TExES standards
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
-- STEP 3: COMPREHENSIVE QUESTION MIGRATION
-- =================================================================

-- Migrate ALL questions to the highest-weighted domain in each category
DO $$
DECLARE
    question_record RECORD;
    target_concept_id UUID;
    migration_count INTEGER := 0;
    
    -- Get the primary domain IDs (highest weighted in each category)
    number_domain_id UUID;
    algebra_domain_id UUID;
    geometry_domain_id UUID;
    data_domain_id UUID;
BEGIN
    
    -- Get the primary domain IDs for each category
    SELECT d.id INTO number_domain_id
    FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND (d.name ILIKE '%number%' OR d.name ILIKE '%operation%')
    AND d.weight_percentage = 40.00
    ORDER BY d.created_at
    LIMIT 1;
    
    SELECT d.id INTO algebra_domain_id
    FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND (d.name ILIKE '%pattern%' OR d.name ILIKE '%algebra%')
    AND d.weight_percentage = 30.00
    ORDER BY d.created_at
    LIMIT 1;
    
    SELECT d.id INTO geometry_domain_id
    FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND (d.name ILIKE '%geometry%' OR d.name ILIKE '%spatial%')
    AND d.weight_percentage = 20.00
    ORDER BY d.created_at
    LIMIT 1;
    
    SELECT d.id INTO data_domain_id
    FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND (d.name ILIKE '%data%' OR d.name ILIKE '%probability%')
    AND d.weight_percentage = 10.00
    ORDER BY d.created_at
    LIMIT 1;
    
    RAISE NOTICE 'Primary domain IDs: Number=%, Algebra=%, Geometry=%, Data=%', 
        number_domain_id, algebra_domain_id, geometry_domain_id, data_domain_id;
    
    -- Migrate all questions to the primary domains
    FOR question_record IN 
        SELECT 
            q.id as question_id,
            q.concept_id as old_concept_id,
            c.name as concept_name,
            d.name as domain_name,
            t.name as topic_name
        FROM questions q
        LEFT JOIN concepts c ON c.id = q.concept_id
        LEFT JOIN domains d ON d.id = c.domain_id
        LEFT JOIN topics t ON t.id = q.topic_id
        WHERE (
            -- Questions in math domains
            d.id IN (
                SELECT dom.id FROM domains dom
                JOIN certifications cert ON cert.id = dom.certification_id
                WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
            )
            OR
            -- Questions in math topics
            t.name IN (
                'Number Concepts and Operations',
                'Patterns and Algebraic Reasoning',
                'Geometry and Spatial Reasoning',
                'Data Analysis and Probability'
            )
        )
    LOOP
        
        target_concept_id := NULL;
        
        -- Determine target domain based on content
        IF question_record.concept_name IS NOT NULL THEN
            -- Use concept name to determine target
            IF question_record.concept_name ILIKE '%place value%' OR 
               question_record.concept_name ILIKE '%fraction%' OR 
               question_record.concept_name ILIKE '%number%' OR 
               question_record.concept_name ILIKE '%multiplication%' THEN
                -- Number Concepts
                SELECT c.id INTO target_concept_id
                FROM concepts c
                WHERE c.domain_id = number_domain_id
                ORDER BY c.order_index NULLS LAST
                LIMIT 1;
            ELSIF question_record.concept_name ILIKE '%pattern%' OR 
                  question_record.concept_name ILIKE '%equation%' OR 
                  question_record.concept_name ILIKE '%algebra%' THEN
                -- Algebra
                SELECT c.id INTO target_concept_id
                FROM concepts c
                WHERE c.domain_id = algebra_domain_id
                ORDER BY c.order_index NULLS LAST
                LIMIT 1;
            ELSIF question_record.concept_name ILIKE '%shape%' OR 
                  question_record.concept_name ILIKE '%measurement%' OR 
                  question_record.concept_name ILIKE '%geometry%' THEN
                -- Geometry
                SELECT c.id INTO target_concept_id
                FROM concepts c
                WHERE c.domain_id = geometry_domain_id
                ORDER BY c.order_index NULLS LAST
                LIMIT 1;
            ELSIF question_record.concept_name ILIKE '%data%' OR 
                  question_record.concept_name ILIKE '%probability%' THEN
                -- Data Analysis
                SELECT c.id INTO target_concept_id
                FROM concepts c
                WHERE c.domain_id = data_domain_id
                ORDER BY c.order_index NULLS LAST
                LIMIT 1;
            END IF;
        END IF;
        
        -- If no concept match, use topic name
        IF target_concept_id IS NULL AND question_record.topic_name IS NOT NULL THEN
            IF question_record.topic_name ILIKE '%number%' OR question_record.topic_name ILIKE '%operation%' THEN
                SELECT c.id INTO target_concept_id
                FROM concepts c WHERE c.domain_id = number_domain_id
                ORDER BY c.order_index NULLS LAST LIMIT 1;
            ELSIF question_record.topic_name ILIKE '%pattern%' OR question_record.topic_name ILIKE '%algebra%' THEN
                SELECT c.id INTO target_concept_id
                FROM concepts c WHERE c.domain_id = algebra_domain_id
                ORDER BY c.order_index NULLS LAST LIMIT 1;
            ELSIF question_record.topic_name ILIKE '%geometry%' OR question_record.topic_name ILIKE '%spatial%' THEN
                SELECT c.id INTO target_concept_id
                FROM concepts c WHERE c.domain_id = geometry_domain_id
                ORDER BY c.order_index NULLS LAST LIMIT 1;
            ELSIF question_record.topic_name ILIKE '%data%' OR question_record.topic_name ILIKE '%probability%' THEN
                SELECT c.id INTO target_concept_id
                FROM concepts c WHERE c.domain_id = data_domain_id
                ORDER BY c.order_index NULLS LAST LIMIT 1;
            END IF;
        END IF;
        
        -- Default to Number Concepts if still no match
        IF target_concept_id IS NULL THEN
            SELECT c.id INTO target_concept_id
            FROM concepts c WHERE c.domain_id = number_domain_id
            ORDER BY c.order_index NULLS LAST LIMIT 1;
        END IF;
        
        -- Update the question
        IF target_concept_id IS NOT NULL AND target_concept_id != question_record.old_concept_id THEN
            UPDATE questions 
            SET concept_id = target_concept_id
            WHERE id = question_record.question_id;
            
            migration_count := migration_count + 1;
        END IF;
        
    END LOOP;
    
    RAISE NOTICE 'Total questions migrated: %', migration_count;
    
END $$;

-- =================================================================
-- STEP 4: REMOVE ALL DUPLICATE/EMPTY DOMAINS AND CONCEPTS
-- =================================================================

-- Delete concepts in duplicate domains (codes 001-004)
DELETE FROM concepts 
WHERE domain_id IN (
    SELECT d.id FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND d.code IN ('001', '002', '003', '004')
);

-- Delete duplicate domains (codes 001-004)
DELETE FROM domains 
WHERE code IN ('001', '002', '003', '004')
AND id IN (
    SELECT d.id FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
);

-- Delete empty concepts in any remaining math domains
DELETE FROM concepts 
WHERE id IN (
    SELECT c.id FROM concepts c
    JOIN domains d ON d.id = c.domain_id
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND NOT EXISTS (SELECT 1 FROM questions q WHERE q.concept_id = c.id)
);

-- Delete empty domains
DELETE FROM domains 
WHERE id IN (
    SELECT d.id FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND NOT EXISTS (SELECT 1 FROM concepts c WHERE c.domain_id = d.id)
);

-- =================================================================
-- STEP 5: FINAL VERIFICATION
-- =================================================================

-- Show final clean state
SELECT 
    'FINAL CLEAN STATE:' as status,
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

-- Show question distribution
SELECT 
    d.name as domain_name,
    d.weight_percentage || '%' as target_weight,
    COUNT(q.id) as question_count,
    ROUND((COUNT(q.id) * 100.0 / SUM(COUNT(q.id)) OVER()), 1) || '%' as actual_percentage
FROM domains d
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
JOIN certifications cert ON cert.id = d.certification_id
WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
GROUP BY d.name, d.weight_percentage
ORDER BY d.weight_percentage DESC;

SELECT 'SUCCESS: Completed comprehensive cleanup with proper weights!' as final_status;
