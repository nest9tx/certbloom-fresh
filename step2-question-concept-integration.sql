-- =================================================================
-- STEP 2: END-TO-END STUDY PATH INTEGRATION
-- =================================================================
-- Purpose: Link math questions to concepts and establish the session
-- selection algorithm for optimal user experience.
-- =================================================================

-- PART 1: DISCOVER EXISTING CONCEPTS
-- =================================================================
-- First, let's see what concepts already exist for our topics
SELECT 
    c.name as concept_name,
    c.id as concept_id,
    t.name as topic_name,
    COUNT(ci.id) as content_items_count
FROM concepts c
LEFT JOIN topics t ON t.id = c.topic_id
LEFT JOIN content_items ci ON ci.concept_id = c.id
WHERE t.name IN (
    'Number Concepts and Operations',
    'Patterns and Algebraic Reasoning', 
    'Geometry and Spatial Reasoning',
    'Data Analysis and Probability'
)
GROUP BY c.id, c.name, t.name
ORDER BY t.name, c.name;

-- =================================================================
-- PART 2: CREATE MISSING CONCEPTS FOR OUR QUESTIONS
-- =================================================================
-- These concepts will bridge questions to study materials

DO $$
DECLARE
    -- Topic IDs
    number_concepts_topic_id UUID;
    algebra_topic_id UUID;
    geometry_topic_id UUID;
    data_topic_id UUID;
    
    -- Concept IDs (will be created)
    place_value_concept_id UUID;
    number_sense_concept_id UUID;
    fraction_concept_id UUID;
    multiplication_concept_id UUID;
    pattern_concept_id UUID;
    equation_concept_id UUID;
    measurement_concept_id UUID;
    geometry_concept_id UUID;
    data_analysis_concept_id UUID;
    
BEGIN
    -- Get topic IDs
    SELECT id INTO number_concepts_topic_id FROM topics WHERE name = 'Number Concepts and Operations';
    SELECT id INTO algebra_topic_id FROM topics WHERE name = 'Patterns and Algebraic Reasoning';
    SELECT id INTO geometry_topic_id FROM topics WHERE name = 'Geometry and Spatial Reasoning';
    SELECT id INTO data_topic_id FROM topics WHERE name = 'Data Analysis and Probability';

    -- Create Number Concepts 
    INSERT INTO concepts (topic_id, name, description, order_index)
    VALUES 
        (number_concepts_topic_id, 'Place Value Mastery', 'Understanding place value, digit values, and number representation', 1),
        (number_concepts_topic_id, 'Number Sense & Mental Math', 'Developing intuitive understanding of numbers and estimation', 2),
        (number_concepts_topic_id, 'Fraction Understanding', 'Conceptual understanding of fractions, comparison, and misconceptions', 3),
        (number_concepts_topic_id, 'Multiplication Strategies', 'Multiple approaches to multiplication and fact fluency', 4)
    ON CONFLICT (topic_id, name) DO NOTHING
    RETURNING id INTO place_value_concept_id;

    -- Create Algebraic Reasoning Concepts
    INSERT INTO concepts (topic_id, name, description, order_index)
    VALUES 
        (algebra_topic_id, 'Pattern Recognition', 'Identifying and extending mathematical patterns', 1),
        (algebra_topic_id, 'Equation Solving', 'Understanding unknowns and solving simple equations', 2)
    ON CONFLICT (topic_id, name) DO NOTHING;

    -- Create Geometry Concepts
    INSERT INTO concepts (topic_id, name, description, order_index)
    VALUES 
        (geometry_topic_id, 'Measurement & Tools', 'Understanding measurement concepts and appropriate tools', 1),
        (geometry_topic_id, 'Shape Properties', 'Understanding geometric shapes and their properties', 2)
    ON CONFLICT (topic_id, name) DO NOTHING;

    -- Create Data Analysis Concepts
    INSERT INTO concepts (topic_id, name, description, order_index)
    VALUES 
        (data_topic_id, 'Data Interpretation', 'Reading and interpreting tables, charts, and graphs', 1)
    ON CONFLICT (topic_id, name) DO NOTHING;

    RAISE NOTICE 'Concepts created successfully for all math topics';
END $$;

-- =================================================================
-- PART 3: LINK QUESTIONS TO CONCEPTS BASED ON CONTENT
-- =================================================================
-- This creates the bridge between practice questions and study materials

-- Update questions to link to appropriate concepts based on their content/tags
UPDATE questions SET concept_id = (
    SELECT c.id FROM concepts c 
    JOIN topics t ON t.id = c.topic_id 
    WHERE t.name = 'Number Concepts and Operations' 
    AND c.name = 'Place Value Mastery'
)
WHERE topic_id = (SELECT id FROM topics WHERE name = 'Number Concepts and Operations')
AND (
    tags && ARRAY['place_value', 'digit_value', 'base_ten'] OR
    question_text ILIKE '%place value%' OR
    question_text ILIKE '%digit%' OR
    question_text ILIKE '%4,582%'
);

UPDATE questions SET concept_id = (
    SELECT c.id FROM concepts c 
    JOIN topics t ON t.id = c.topic_id 
    WHERE t.name = 'Number Concepts and Operations' 
    AND c.name = 'Number Sense & Mental Math'
)
WHERE topic_id = (SELECT id FROM topics WHERE name = 'Number Concepts and Operations')
AND (
    tags && ARRAY['number_sense', 'mental_math', 'estimation', 'rounding'] OR
    question_text ILIKE '%estimation%' OR
    question_text ILIKE '%mental math%' OR
    question_text ILIKE '%number sense%'
);

UPDATE questions SET concept_id = (
    SELECT c.id FROM concepts c 
    JOIN topics t ON t.id = c.topic_id 
    WHERE t.name = 'Number Concepts and Operations' 
    AND c.name = 'Fraction Understanding'
)
WHERE topic_id = (SELECT id FROM topics WHERE name = 'Number Concepts and Operations')
AND (
    tags && ARRAY['fractions', 'fraction_comparison', 'fraction_misconceptions'] OR
    question_text ILIKE '%fraction%' OR
    question_text ILIKE '%1/3%' OR
    question_text ILIKE '%1/2%'
);

UPDATE questions SET concept_id = (
    SELECT c.id FROM concepts c 
    JOIN topics t ON t.id = c.topic_id 
    WHERE t.name = 'Number Concepts and Operations' 
    AND c.name = 'Multiplication Strategies'
)
WHERE topic_id = (SELECT id FROM topics WHERE name = 'Number Concepts and Operations')
AND (
    tags && ARRAY['multiplication', 'multiplication_strategies', 'fact_fluency'] OR
    question_text ILIKE '%multiplication%' OR
    question_text ILIKE '%6 × 8%' OR
    question_text ILIKE '%23 × 14%'
);

-- Link Algebraic Reasoning questions
UPDATE questions SET concept_id = (
    SELECT c.id FROM concepts c 
    JOIN topics t ON t.id = c.topic_id 
    WHERE t.name = 'Patterns and Algebraic Reasoning' 
    AND c.name = 'Pattern Recognition'
)
WHERE topic_id = (SELECT id FROM topics WHERE name = 'Patterns and Algebraic Reasoning')
AND (
    tags && ARRAY['patterns', 'sequences', 'number_patterns'] OR
    question_text ILIKE '%pattern%' OR
    question_text ILIKE '%sequence%'
);

UPDATE questions SET concept_id = (
    SELECT c.id FROM concepts c 
    JOIN topics t ON t.id = c.topic_id 
    WHERE t.name = 'Patterns and Algebraic Reasoning' 
    AND c.name = 'Equation Solving'
)
WHERE topic_id = (SELECT id FROM topics WHERE name = 'Patterns and Algebraic Reasoning')
AND (
    tags && ARRAY['equations', 'unknowns', 'algebraic_reasoning'] OR
    question_text ILIKE '%equation%' OR
    question_text ILIKE '%unknown%' OR
    question_text ILIKE '%+ __ =%'
);

-- Link Geometry questions
UPDATE questions SET concept_id = (
    SELECT c.id FROM concepts c 
    JOIN topics t ON t.id = c.topic_id 
    WHERE t.name = 'Geometry and Spatial Reasoning' 
    AND c.name = 'Measurement & Tools'
)
WHERE topic_id = (SELECT id FROM topics WHERE name = 'Geometry and Spatial Reasoning')
AND (
    tags && ARRAY['measurement', 'tools', 'length', 'analog_clock'] OR
    question_text ILIKE '%measurement%' OR
    question_text ILIKE '%clock%' OR
    question_text ILIKE '%2:25%'
);

UPDATE questions SET concept_id = (
    SELECT c.id FROM concepts c 
    JOIN topics t ON t.id = c.topic_id 
    WHERE t.name = 'Geometry and Spatial Reasoning' 
    AND c.name = 'Shape Properties'
)
WHERE topic_id = (SELECT id FROM topics WHERE name = 'Geometry and Spatial Reasoning')
AND (
    tags && ARRAY['geometry', 'shape_properties', 'quadrilaterals'] OR
    question_text ILIKE '%shape%' OR
    question_text ILIKE '%geometry%'
);

-- Link Data Analysis questions
UPDATE questions SET concept_id = (
    SELECT c.id FROM concepts c 
    JOIN topics t ON t.id = c.topic_id 
    WHERE t.name = 'Data Analysis and Probability' 
    AND c.name = 'Data Interpretation'
)
WHERE topic_id = (SELECT id FROM topics WHERE name = 'Data Analysis and Probability')
AND (
    tags && ARRAY['tables', 'data_interpretation', 'mathematical_reasoning'] OR
    question_text ILIKE '%table%' OR
    question_text ILIKE '%data%'
);

-- =================================================================
-- PART 4: VERIFY THE LINKAGE
-- =================================================================
-- Check that questions are properly linked to concepts
SELECT 
    t.name as topic_name,
    c.name as concept_name,
    COUNT(q.id) as questions_linked,
    ARRAY_AGG(LEFT(q.question_text, 50) || '...') as sample_questions
FROM topics t
LEFT JOIN concepts c ON c.topic_id = t.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE t.name IN (
    'Number Concepts and Operations',
    'Patterns and Algebraic Reasoning',
    'Geometry and Spatial Reasoning', 
    'Data Analysis and Probability'
)
GROUP BY t.name, c.name
ORDER BY t.name, c.name;

-- =================================================================
-- SUCCESS MESSAGE
-- =================================================================
SELECT 'SUCCESS: Questions linked to concepts. Ready for study session integration!' as status;
