-- =================================================================
-- STEP 2: CORRECTED QUESTION-CONCEPT INTEGRATION  
-- =================================================================
-- Purpose: Link questions to concepts using the correct schema structure:
-- certifications → domains → concepts (not topics!)
-- =================================================================

-- PART 1: DISCOVER CURRENT SCHEMA AND EXISTING CONTENT
-- =================================================================

-- First, let's see what domains and concepts currently exist
SELECT 
    cert.name as certification_name,
    d.name as domain_name,
    c.name as concept_name,
    c.id as concept_id,
    COUNT(ci.id) as content_items_count
FROM certifications cert
LEFT JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts c ON c.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
GROUP BY cert.name, d.name, c.name, c.id
ORDER BY cert.name, d.name, c.name;

-- Check if our topics exist as domains
SELECT 
    d.name as domain_name,
    d.id as domain_id,
    COUNT(c.id) as concepts_count
FROM domains d
LEFT JOIN concepts c ON c.domain_id = d.id
WHERE d.name IN (
    'Number Concepts and Operations',
    'Patterns and Algebraic Reasoning', 
    'Geometry and Spatial Reasoning',
    'Data Analysis and Probability'
)
GROUP BY d.name, d.id
ORDER BY d.name;

-- =================================================================
-- PART 2: CREATE OR UPDATE DOMAIN STRUCTURE TO MATCH OUR TOPICS
-- =================================================================

DO $$
DECLARE
    math_cert_id UUID;
    ec6_cert_id UUID;
    
    -- Domain IDs (might need to be created)
    number_concepts_domain_id UUID;
    algebra_domain_id UUID;
    geometry_domain_id UUID;
    data_domain_id UUID;
    
BEGIN
    -- Get certification IDs
    SELECT id INTO math_cert_id FROM certifications WHERE name ILIKE '%mathematics%' AND name ILIKE '%902%';
    SELECT id INTO ec6_cert_id FROM certifications WHERE name ILIKE '%core subjects%' AND name ILIKE '%391%';
    
    -- If math certification doesn't exist, create it
    IF math_cert_id IS NULL THEN
        INSERT INTO certifications (name, code, description)
        VALUES ('TExES Core Subjects EC-6: Mathematics (902)', '902', 'Early Childhood through 6th Grade Mathematics')
        RETURNING id INTO math_cert_id;
        RAISE NOTICE 'Created Math certification: %', math_cert_id;
    END IF;

    -- Create/Update domains to match our topic structure (one at a time to avoid RETURNING multiple rows)
    INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index)
    VALUES (math_cert_id, 'Number Concepts and Operations', '001', 'Fundamental number concepts and arithmetic operations', 40.00, 1)
    ON CONFLICT (certification_id, code) DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        weight_percentage = EXCLUDED.weight_percentage;
        
    INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index)
    VALUES (math_cert_id, 'Patterns and Algebraic Reasoning', '002', 'Pattern recognition and early algebraic thinking', 30.00, 2)
    ON CONFLICT (certification_id, code) DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        weight_percentage = EXCLUDED.weight_percentage;
        
    INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index)
    VALUES (math_cert_id, 'Geometry and Spatial Reasoning', '003', 'Geometric concepts and spatial relationships', 20.00, 3)
    ON CONFLICT (certification_id, code) DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        weight_percentage = EXCLUDED.weight_percentage;
        
    INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index)
    VALUES (math_cert_id, 'Data Analysis and Probability', '004', 'Data interpretation and basic probability', 10.00, 4)
    ON CONFLICT (certification_id, code) DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        weight_percentage = EXCLUDED.weight_percentage;

    -- Get domain IDs for concept creation
    SELECT id INTO number_concepts_domain_id FROM domains WHERE certification_id = math_cert_id AND code = '001';
    SELECT id INTO algebra_domain_id FROM domains WHERE certification_id = math_cert_id AND code = '002';
    SELECT id INTO geometry_domain_id FROM domains WHERE certification_id = math_cert_id AND code = '003';
    SELECT id INTO data_domain_id FROM domains WHERE certification_id = math_cert_id AND code = '004';

    -- Create concepts within each domain (handle conflicts properly)
    INSERT INTO concepts (domain_id, name, description, difficulty_level, estimated_study_minutes, order_index)
    VALUES 
        -- Number Concepts domain
        (number_concepts_domain_id, 'Place Value Mastery', 'Understanding place value, digit values, and number representation', 2, 25, 1),
        (number_concepts_domain_id, 'Number Sense & Mental Math', 'Developing intuitive understanding of numbers and estimation', 2, 30, 2),
        (number_concepts_domain_id, 'Fraction Understanding', 'Conceptual understanding of fractions, comparison, and misconceptions', 3, 35, 3),
        (number_concepts_domain_id, 'Multiplication Strategies', 'Multiple approaches to multiplication and fact fluency', 3, 30, 4),
        
        -- Algebraic Reasoning domain
        (algebra_domain_id, 'Pattern Recognition', 'Identifying and extending mathematical patterns', 2, 25, 1),
        (algebra_domain_id, 'Equation Solving', 'Understanding unknowns and solving simple equations', 3, 30, 2),
        
        -- Geometry domain
        (geometry_domain_id, 'Measurement & Tools', 'Understanding measurement concepts and appropriate tools', 2, 25, 1),
        (geometry_domain_id, 'Shape Properties', 'Understanding geometric shapes and their properties', 2, 25, 2),
        
        -- Data Analysis domain
        (data_domain_id, 'Data Interpretation', 'Reading and interpreting tables, charts, and graphs', 3, 30, 1)
    ON CONFLICT DO NOTHING;  -- Simplified conflict handling

    RAISE NOTICE 'Created/updated concepts for all math domains';
END $$;

-- =================================================================
-- PART 3: LINK EXISTING QUESTIONS TO CONCEPTS
-- =================================================================
-- Since questions table uses topics, not domains, we need to bridge this

-- First, add concept_id column to questions if it doesn't exist
ALTER TABLE questions ADD COLUMN IF NOT EXISTS concept_id UUID REFERENCES concepts(id);

-- Link questions through topic names to domain names to concepts
UPDATE questions SET concept_id = (
    SELECT c.id 
    FROM concepts c 
    JOIN domains d ON d.id = c.domain_id 
    JOIN topics t ON t.name = d.name
    WHERE t.id = questions.topic_id 
    AND c.name = 'Place Value Mastery'
    LIMIT 1
)
WHERE topic_id IN (SELECT id FROM topics WHERE name = 'Number Concepts and Operations')
AND (
    tags && ARRAY['place_value', 'digit_value', 'base_ten'] OR
    question_text ILIKE '%place value%' OR
    question_text ILIKE '%digit%' OR
    question_text ILIKE '%4,582%'
);

UPDATE questions SET concept_id = (
    SELECT c.id 
    FROM concepts c 
    JOIN domains d ON d.id = c.domain_id 
    JOIN topics t ON t.name = d.name
    WHERE t.id = questions.topic_id 
    AND c.name = 'Number Sense & Mental Math'
    LIMIT 1
)
WHERE topic_id IN (SELECT id FROM topics WHERE name = 'Number Concepts and Operations')
AND (
    tags && ARRAY['number_sense', 'mental_math', 'estimation', 'rounding'] OR
    question_text ILIKE '%estimation%' OR
    question_text ILIKE '%mental math%' OR
    question_text ILIKE '%number sense%'
);

UPDATE questions SET concept_id = (
    SELECT c.id 
    FROM concepts c 
    JOIN domains d ON d.id = c.domain_id 
    JOIN topics t ON t.name = d.name
    WHERE t.id = questions.topic_id 
    AND c.name = 'Fraction Understanding'
    LIMIT 1
)
WHERE topic_id IN (SELECT id FROM topics WHERE name = 'Number Concepts and Operations')
AND (
    tags && ARRAY['fractions', 'fraction_comparison', 'fraction_misconceptions'] OR
    question_text ILIKE '%fraction%' OR
    question_text ILIKE '%1/3%' OR
    question_text ILIKE '%1/2%'
);

UPDATE questions SET concept_id = (
    SELECT c.id 
    FROM concepts c 
    JOIN domains d ON d.id = c.domain_id 
    JOIN topics t ON t.name = d.name
    WHERE t.id = questions.topic_id 
    AND c.name = 'Multiplication Strategies'
    LIMIT 1
)
WHERE topic_id IN (SELECT id FROM topics WHERE name = 'Number Concepts and Operations')
AND (
    tags && ARRAY['multiplication', 'multiplication_strategies', 'fact_fluency'] OR
    question_text ILIKE '%multiplication%' OR
    question_text ILIKE '%6 × 8%' OR
    question_text ILIKE '%23 × 14%'
);

-- Link Algebraic Reasoning questions
UPDATE questions SET concept_id = (
    SELECT c.id 
    FROM concepts c 
    JOIN domains d ON d.id = c.domain_id 
    JOIN topics t ON t.name = d.name
    WHERE t.id = questions.topic_id 
    AND c.name = 'Pattern Recognition'
    LIMIT 1
)
WHERE topic_id IN (SELECT id FROM topics WHERE name = 'Patterns and Algebraic Reasoning')
AND (
    tags && ARRAY['patterns', 'sequences', 'number_patterns'] OR
    question_text ILIKE '%pattern%' OR
    question_text ILIKE '%sequence%'
);

UPDATE questions SET concept_id = (
    SELECT c.id 
    FROM concepts c 
    JOIN domains d ON d.id = c.domain_id 
    JOIN topics t ON t.name = d.name
    WHERE t.id = questions.topic_id 
    AND c.name = 'Equation Solving'
    LIMIT 1
)
WHERE topic_id IN (SELECT id FROM topics WHERE name = 'Patterns and Algebraic Reasoning')
AND (
    tags && ARRAY['equations', 'unknowns', 'algebraic_reasoning'] OR
    question_text ILIKE '%equation%' OR
    question_text ILIKE '%unknown%' OR
    question_text ILIKE '%+ __ =%'
);

-- Link Geometry questions
UPDATE questions SET concept_id = (
    SELECT c.id 
    FROM concepts c 
    JOIN domains d ON d.id = c.domain_id 
    JOIN topics t ON t.name = d.name
    WHERE t.id = questions.topic_id 
    AND c.name = 'Measurement & Tools'
    LIMIT 1
)
WHERE topic_id IN (SELECT id FROM topics WHERE name = 'Geometry and Spatial Reasoning')
AND (
    tags && ARRAY['measurement', 'tools', 'length', 'analog_clock'] OR
    question_text ILIKE '%measurement%' OR
    question_text ILIKE '%clock%' OR
    question_text ILIKE '%2:25%'
);

UPDATE questions SET concept_id = (
    SELECT c.id 
    FROM concepts c 
    JOIN domains d ON d.id = c.domain_id 
    JOIN topics t ON t.name = d.name
    WHERE t.id = questions.topic_id 
    AND c.name = 'Shape Properties'
    LIMIT 1
)
WHERE topic_id IN (SELECT id FROM topics WHERE name = 'Geometry and Spatial Reasoning')
AND (
    tags && ARRAY['geometry', 'shape_properties', 'quadrilaterals'] OR
    question_text ILIKE '%shape%' OR
    question_text ILIKE '%geometry%'
);

-- Link Data Analysis questions
UPDATE questions SET concept_id = (
    SELECT c.id 
    FROM concepts c 
    JOIN domains d ON d.id = c.domain_id 
    JOIN topics t ON t.name = d.name
    WHERE t.id = questions.topic_id 
    AND c.name = 'Data Interpretation'
    LIMIT 1
)
WHERE topic_id IN (SELECT id FROM topics WHERE name = 'Data Analysis and Probability')
AND (
    tags && ARRAY['tables', 'data_interpretation', 'mathematical_reasoning'] OR
    question_text ILIKE '%table%' OR
    question_text ILIKE '%data%'
);

-- =================================================================
-- PART 4: VERIFY THE LINKAGE AND SHOW RESULTS
-- =================================================================

-- Show the linked questions by domain and concept
SELECT 
    cert.name as certification_name,
    d.name as domain_name,
    d.order_index as domain_order,
    c.name as concept_name,
    c.order_index as concept_order,
    COUNT(q.id) as questions_linked,
    ARRAY_AGG(LEFT(q.question_text, 60) || '...') as sample_questions
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.name ILIKE '%mathematics%'
GROUP BY cert.name, d.name, d.order_index, c.name, c.order_index
ORDER BY d.order_index, c.order_index;

-- =================================================================
-- SUCCESS MESSAGE
-- =================================================================
SELECT 'SUCCESS: Questions linked to concepts using correct schema structure (certifications → domains → concepts)!' as status;
