-- =================================================================
-- CLEANUP DUPLICATE DOMAINS AND CONCEPTS
-- =================================================================
-- Purpose: Remove duplicate domains/concepts created by integration script
-- and properly link questions to existing legacy domains
-- =================================================================

-- STEP 1: INVESTIGATE THE CURRENT STATE
-- =================================================================

-- Show all math domains with their creation dates to identify duplicates
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

-- =================================================================
-- STEP 2: IDENTIFY LEGACY VS NEW DOMAINS
-- =================================================================

-- Create temporary mapping table to identify which domains to keep (legacy) vs remove (new)
CREATE TEMP TABLE domain_mapping AS
WITH legacy_domains AS (
    -- Legacy domains have codes like 'NUM_OPS', 'PATTERNS', etc. and weight percentages
    SELECT 
        d.id as legacy_id,
        d.name as legacy_name,
        d.code as legacy_code,
        d.weight_percentage,
        CASE 
            WHEN d.name ILIKE '%number%' OR d.name ILIKE '%operations%' THEN 'Number Concepts and Operations'
            WHEN d.name ILIKE '%pattern%' OR d.name ILIKE '%algebra%' THEN 'Patterns and Algebraic Reasoning'
            WHEN d.name ILIKE '%geometry%' OR d.name ILIKE '%spatial%' THEN 'Geometry and Spatial Reasoning'
            WHEN d.name ILIKE '%data%' OR d.name ILIKE '%probability%' THEN 'Data Analysis and Probability'
        END as standardized_name
    FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND d.weight_percentage > 0
    AND d.code NOT IN ('001', '002', '003', '004')  -- Exclude the new numbered codes
),
new_domains AS (
    -- New domains have codes like '001', '002', etc. created by our script
    SELECT 
        d.id as new_id,
        d.name as new_name,
        d.code as new_code
    FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND d.code IN ('001', '002', '003', '004')
)
SELECT 
    ld.legacy_id,
    ld.legacy_name,
    ld.legacy_code,
    ld.weight_percentage,
    nd.new_id,
    nd.new_name,
    nd.new_code,
    ld.standardized_name
FROM legacy_domains ld
FULL OUTER JOIN new_domains nd ON ld.standardized_name = nd.new_name;

-- Show the mapping
SELECT * FROM domain_mapping ORDER BY new_code;

-- =================================================================
-- STEP 3: MIGRATE CONCEPTS FROM NEW DOMAINS TO LEGACY DOMAINS
-- =================================================================

-- Step 3a: For domains that have both legacy and new versions, migrate concepts
UPDATE concepts SET domain_id = (
    SELECT legacy_id FROM domain_mapping 
    WHERE new_id = concepts.domain_id 
    AND legacy_id IS NOT NULL
)
WHERE domain_id IN (
    SELECT new_id FROM domain_mapping WHERE legacy_id IS NOT NULL
);

-- Step 3b: For new domains without legacy equivalents, we need to find the closest match
-- This handles cases where domain names might not match exactly

-- Get the closest legacy domain for orphaned concepts
WITH orphaned_concepts AS (
    SELECT c.*, d.name as domain_name, d.code as domain_code
    FROM concepts c
    JOIN domains d ON d.id = c.domain_id
    WHERE d.code IN ('001', '002', '003', '004')
),
closest_legacy AS (
    SELECT 
        oc.id as concept_id,
        oc.name as concept_name,
        oc.domain_name,
        oc.domain_code,
        CASE 
            WHEN oc.domain_code = '001' THEN (  -- Number Concepts
                SELECT d.id FROM domains d 
                JOIN certifications cert ON cert.id = d.certification_id
                WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
                AND d.weight_percentage > 0
                AND (d.name ILIKE '%number%' OR d.name ILIKE '%operation%')
                ORDER BY d.weight_percentage DESC
                LIMIT 1
            )
            WHEN oc.domain_code = '002' THEN (  -- Patterns/Algebra
                SELECT d.id FROM domains d 
                JOIN certifications cert ON cert.id = d.certification_id
                WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
                AND d.weight_percentage > 0
                AND (d.name ILIKE '%pattern%' OR d.name ILIKE '%algebra%')
                ORDER BY d.weight_percentage DESC
                LIMIT 1
            )
            WHEN oc.domain_code = '003' THEN (  -- Geometry
                SELECT d.id FROM domains d 
                JOIN certifications cert ON cert.id = d.certification_id
                WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
                AND d.weight_percentage > 0
                AND (d.name ILIKE '%geometry%' OR d.name ILIKE '%spatial%')
                ORDER BY d.weight_percentage DESC
                LIMIT 1
            )
            WHEN oc.domain_code = '004' THEN (  -- Data Analysis
                SELECT d.id FROM domains d 
                JOIN certifications cert ON cert.id = d.certification_id
                WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
                AND d.weight_percentage > 0
                AND (d.name ILIKE '%data%' OR d.name ILIKE '%probability%')
                ORDER BY d.weight_percentage DESC
                LIMIT 1
            )
        END as target_legacy_domain_id
    FROM orphaned_concepts oc
)
UPDATE concepts SET domain_id = cl.target_legacy_domain_id
FROM closest_legacy cl
WHERE concepts.id = cl.concept_id
AND cl.target_legacy_domain_id IS NOT NULL;

-- =================================================================
-- STEP 4: MIGRATE QUESTIONS BEFORE CLEANUP
-- =================================================================

-- First, we need to migrate any questions that are still linked to concepts 
-- in the new domains before we can delete those domains

-- Create a mapping of old concept IDs to new concept IDs based on similar names
CREATE TEMP TABLE concept_migration_map AS
WITH new_concepts AS (
    SELECT 
        c.id as new_concept_id,
        c.name as new_concept_name,
        d.code as domain_code
    FROM concepts c
    JOIN domains d ON d.id = c.domain_id
    WHERE d.code IN ('001', '002', '003', '004')
),
legacy_concepts AS (
    SELECT 
        c.id as legacy_concept_id,
        c.name as legacy_concept_name,
        d.name as domain_name,
        d.weight_percentage
    FROM concepts c
    JOIN domains d ON d.id = c.domain_id
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
    AND d.weight_percentage > 0
    AND d.code NOT IN ('001', '002', '003', '004')
)
SELECT 
    nc.new_concept_id,
    nc.new_concept_name,
    nc.domain_code,
    lc.legacy_concept_id,
    lc.legacy_concept_name,
    lc.domain_name
FROM new_concepts nc
LEFT JOIN legacy_concepts lc ON (
    -- Try to match by similar concept names
    (nc.new_concept_name ILIKE '%place value%' AND lc.legacy_concept_name ILIKE '%place value%') OR
    (nc.new_concept_name ILIKE '%fraction%' AND lc.legacy_concept_name ILIKE '%fraction%') OR
    (nc.new_concept_name ILIKE '%multiplication%' AND lc.legacy_concept_name ILIKE '%multiplication%') OR
    (nc.new_concept_name ILIKE '%number sense%' AND lc.legacy_concept_name ILIKE '%number%') OR
    (nc.new_concept_name ILIKE '%pattern%' AND lc.legacy_concept_name ILIKE '%pattern%') OR
    (nc.new_concept_name ILIKE '%equation%' AND lc.legacy_concept_name ILIKE '%equation%') OR
    (nc.new_concept_name ILIKE '%measurement%' AND lc.legacy_concept_name ILIKE '%measurement%') OR
    (nc.new_concept_name ILIKE '%shape%' AND lc.legacy_concept_name ILIKE '%shape%') OR
    (nc.new_concept_name ILIKE '%data%' AND lc.legacy_concept_name ILIKE '%data%')
);

-- Show the migration mapping
SELECT 
    'Concept Migration Map:' as info,
    new_concept_name,
    legacy_concept_name,
    domain_name,
    CASE WHEN legacy_concept_id IS NULL THEN 'NO MATCH FOUND' ELSE 'WILL MIGRATE' END as status
FROM concept_migration_map
ORDER BY domain_code;

-- Migrate questions from new concepts to legacy concepts where we have matches
UPDATE questions 
SET concept_id = cmm.legacy_concept_id
FROM concept_migration_map cmm
WHERE questions.concept_id = cmm.new_concept_id
AND cmm.legacy_concept_id IS NOT NULL;

-- For questions linked to new concepts that have no legacy match, 
-- find the best domain match and link to the first available concept in that domain
UPDATE questions 
SET concept_id = (
    CASE 
        WHEN questions.concept_id IN (
            SELECT new_concept_id FROM concept_migration_map 
            WHERE domain_code = '001' AND legacy_concept_id IS NULL
        ) THEN (
            -- Number Concepts domain - use first available concept
            SELECT c.id FROM concepts c
            JOIN domains d ON d.id = c.domain_id
            JOIN certifications cert ON cert.id = d.certification_id
            WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
            AND d.weight_percentage > 0
            AND (d.name ILIKE '%number%' OR d.name ILIKE '%operation%')
            ORDER BY c.order_index
            LIMIT 1
        )
        WHEN questions.concept_id IN (
            SELECT new_concept_id FROM concept_migration_map 
            WHERE domain_code = '002' AND legacy_concept_id IS NULL
        ) THEN (
            -- Patterns/Algebra domain - use first available concept
            SELECT c.id FROM concepts c
            JOIN domains d ON d.id = c.domain_id
            JOIN certifications cert ON cert.id = d.certification_id
            WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
            AND d.weight_percentage > 0
            AND (d.name ILIKE '%pattern%' OR d.name ILIKE '%algebra%')
            ORDER BY c.order_index
            LIMIT 1
        )
        WHEN questions.concept_id IN (
            SELECT new_concept_id FROM concept_migration_map 
            WHERE domain_code = '003' AND legacy_concept_id IS NULL
        ) THEN (
            -- Geometry domain - use first available concept
            SELECT c.id FROM concepts c
            JOIN domains d ON d.id = c.domain_id
            JOIN certifications cert ON cert.id = d.certification_id
            WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
            AND d.weight_percentage > 0
            AND (d.name ILIKE '%geometry%' OR d.name ILIKE '%spatial%')
            ORDER BY c.order_index
            LIMIT 1
        )
        WHEN questions.concept_id IN (
            SELECT new_concept_id FROM concept_migration_map 
            WHERE domain_code = '004' AND legacy_concept_id IS NULL
        ) THEN (
            -- Data Analysis domain - use first available concept
            SELECT c.id FROM concepts c
            JOIN domains d ON d.id = c.domain_id
            JOIN certifications cert ON cert.id = d.certification_id
            WHERE (cert.name ILIKE '%math%' OR cert.name ILIKE '%902%')
            AND d.weight_percentage > 0
            AND (d.name ILIKE '%data%' OR d.name ILIKE '%probability%')
            ORDER BY c.order_index
            LIMIT 1
        )
    END
)
WHERE questions.concept_id IN (
    SELECT new_concept_id FROM concept_migration_map WHERE legacy_concept_id IS NULL
);

-- =================================================================
-- STEP 5: CLEAN UP DUPLICATE DOMAINS (NOW SAFE)
-- =================================================================

-- Now we can safely remove the new domains since questions have been migrated
DELETE FROM domains 
WHERE code IN ('001', '002', '003', '004')
AND id IN (
    SELECT d.id FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
);

-- =================================================================
-- STEP 6: VERIFY THE CLEANUP
-- =================================================================

-- Show remaining domains for math certification
SELECT 
    cert.name as certification_name,
    d.id as domain_id,
    d.name as domain_name,
    d.code as domain_code,
    d.weight_percentage,
    d.order_index,
    COUNT(c.id) as concepts_count
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts c ON c.domain_id = d.id
WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
GROUP BY cert.id, cert.name, d.id, d.name, d.code, d.weight_percentage, d.order_index
ORDER BY cert.name, d.order_index;

-- Show concepts and their question counts
SELECT 
    d.name as domain_name,
    d.code as domain_code,
    d.weight_percentage,
    c.name as concept_name,
    c.difficulty_level,
    c.estimated_study_minutes,
    COUNT(q.id) as linked_questions
FROM domains d
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
JOIN certifications cert ON cert.id = d.certification_id
WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
GROUP BY d.name, d.code, d.weight_percentage, c.name, c.difficulty_level, c.estimated_study_minutes
ORDER BY d.weight_percentage DESC, c.name;

-- Show questions that are now properly linked
SELECT 
    COUNT(q.id) as total_questions_linked,
    COUNT(CASE WHEN q.concept_id IS NOT NULL THEN 1 END) as questions_with_concepts,
    COUNT(CASE WHEN q.concept_id IS NULL THEN 1 END) as questions_without_concepts
FROM questions q
LEFT JOIN concepts c ON c.id = q.concept_id
LEFT JOIN domains d ON d.id = c.domain_id
LEFT JOIN certifications cert ON cert.id = d.certification_id
WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%' OR q.topic_id IN (
    SELECT t.id FROM topics t WHERE t.name IN (
        'Number Concepts and Operations',
        'Patterns and Algebraic Reasoning',
        'Geometry and Spatial Reasoning',
        'Data Analysis and Probability'
    )
);

-- =================================================================
-- SUCCESS MESSAGE
-- =================================================================
SELECT 'SUCCESS: Cleaned up duplicate domains and migrated concepts to legacy domains!' as status;
