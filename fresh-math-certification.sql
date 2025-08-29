-- =================================================================
-- FRESH MATH CERTIFICATION STRUCTURE
-- =================================================================
-- Purpose: Create a clean, comprehensive math certification structure
-- that matches the UI expectations with proper granular concepts
-- =================================================================

-- STEP 1: CLEAN SLATE - REMOVE ALL MATH CONTENT
-- =================================================================

-- First, save any questions we want to keep
CREATE TEMP TABLE saved_questions AS
SELECT 
    q.*,
    t.name as topic_name
FROM questions q
LEFT JOIN topics t ON t.id = q.topic_id
WHERE t.name IN (
    'Number Concepts and Operations',
    'Patterns and Algebraic Reasoning',
    'Geometry and Spatial Reasoning',
    'Data Analysis and Probability'
) OR q.tags && ARRAY['place_value', 'fractions', 'multiplication', 'patterns', 'geometry', 'data'];

-- Show what questions we're saving
SELECT 
    'SAVING THESE QUESTIONS:' as info,
    COUNT(*) as total_questions,
    topic_name,
    COUNT(*) as count_per_topic
FROM saved_questions 
GROUP BY topic_name
ORDER BY topic_name;

-- Remove all existing math domains, concepts, and content
-- First, delete ALL questions linked to math concepts (not just the saved ones)
DELETE FROM questions WHERE concept_id IN (
    SELECT c.id FROM concepts c
    JOIN domains d ON d.id = c.domain_id
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
);

-- Also delete questions linked to math topics (backup cleanup)
DELETE FROM questions WHERE topic_id IN (
    SELECT id FROM topics WHERE name IN (
        'Number Concepts and Operations',
        'Patterns and Algebraic Reasoning',
        'Geometry and Spatial Reasoning',
        'Data Analysis and Probability'
    )
);

-- Then remove concepts (which reference domains)  
DELETE FROM concepts WHERE domain_id IN (
    SELECT d.id FROM domains d
    JOIN certifications cert ON cert.id = d.certification_id
    WHERE cert.name ILIKE '%math%' OR cert.name ILIKE '%902%'
);

-- Then remove domains (which reference certifications)
DELETE FROM domains WHERE certification_id IN (
    SELECT id FROM certifications WHERE name ILIKE '%math%' OR name ILIKE '%902%'
);

-- Finally remove certifications
DELETE FROM certifications WHERE name ILIKE '%math%' OR name ILIKE '%902%';

-- =================================================================
-- STEP 2: CREATE FRESH MATH CERTIFICATION
-- =================================================================

-- Create the main math certification
INSERT INTO certifications (id, name, test_code, description)
VALUES (
    gen_random_uuid(),
    'TExES Core Subjects EC-6: Mathematics (902)',
    '902',
    'Early Childhood through 6th Grade Mathematics'
);

-- Get the certification ID for use in domains
DO $$
DECLARE
    cert_id UUID;
    
    -- Domain IDs
    number_domain_id UUID;
    algebra_domain_id UUID;
    geometry_domain_id UUID;
    data_domain_id UUID;
BEGIN
    -- Get the certification ID
    SELECT id INTO cert_id FROM certifications WHERE test_code = '902';
    
    -- Create the 4 main domains with proper TExES weights
    INSERT INTO domains (id, certification_id, name, code, description, weight_percentage, order_index)
    VALUES 
        (gen_random_uuid(), cert_id, 'Number Concepts and Operations', 'NUM_OPS', 'Fundamental number concepts and arithmetic operations', 40.00, 1),
        (gen_random_uuid(), cert_id, 'Patterns and Algebraic Reasoning', 'PATTERNS', 'Pattern recognition and early algebraic thinking', 30.00, 2),
        (gen_random_uuid(), cert_id, 'Geometry and Spatial Reasoning', 'GEOMETRY', 'Geometric concepts and spatial relationships', 20.00, 3),
        (gen_random_uuid(), cert_id, 'Data Analysis and Probability', 'DATA', 'Data interpretation and basic probability', 10.00, 4);
    
    -- Get domain IDs
    SELECT id INTO number_domain_id FROM domains WHERE code = 'NUM_OPS' AND certification_id = cert_id;
    SELECT id INTO algebra_domain_id FROM domains WHERE code = 'PATTERNS' AND certification_id = cert_id;
    SELECT id INTO geometry_domain_id FROM domains WHERE code = 'GEOMETRY' AND certification_id = cert_id;
    SELECT id INTO data_domain_id FROM domains WHERE code = 'DATA' AND certification_id = cert_id;
    
    -- =================================================================
    -- STEP 3: CREATE DETAILED CONCEPTS (40% = 8 concepts for Number)
    -- =================================================================
    
    -- Number Concepts and Operations (8 concepts = 40% of 19)
    -- First, create all concepts without prerequisites
    INSERT INTO concepts (id, domain_id, name, description, learning_objectives, difficulty_level, estimated_study_minutes, order_index, prerequisites)
    VALUES 
        (gen_random_uuid(), number_domain_id, 'Place Value Understanding', 'Master the concept of place value in whole numbers and decimals', 
         ARRAY['Understand place value positions', 'Compare and order numbers', 'Round numbers appropriately'], 2, 45, 1, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), number_domain_id, 'Addition and Subtraction Strategies', 'Develop fluency with addition and subtraction using various strategies',
         ARRAY['Use mental math strategies', 'Apply algorithms correctly', 'Solve multi-step problems'], 2, 50, 2, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), number_domain_id, 'Multiplication Strategies', 'Multiple approaches to multiplication and fact fluency',
         ARRAY['Understand multiplication concepts', 'Use various multiplication strategies', 'Solve word problems'], 3, 55, 3, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), number_domain_id, 'Division Concepts', 'Understanding division as inverse of multiplication',
         ARRAY['Understand division concepts', 'Use division algorithms', 'Interpret remainders'], 3, 50, 4, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), number_domain_id, 'Fraction Understanding', 'Conceptual understanding of fractions, comparison, and operations',
         ARRAY['Understand fraction concepts', 'Compare and order fractions', 'Add and subtract fractions'], 4, 60, 5, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), number_domain_id, 'Decimal Operations', 'Working with decimal numbers and operations',
         ARRAY['Understand decimal place value', 'Perform decimal operations', 'Convert between fractions and decimals'], 4, 55, 6, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), number_domain_id, 'Number Sense & Mental Math', 'Developing intuitive understanding of numbers and estimation',
         ARRAY['Estimate quantities and measurements', 'Use mental math strategies', 'Apply number sense to problem solving'], 2, 40, 7, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), number_domain_id, 'Problem Solving with Numbers', 'Apply number concepts to real-world problems',
         ARRAY['Analyze multi-step problems', 'Choose appropriate operations', 'Justify solutions'], 4, 45, 8, ARRAY[]::UUID[]);
    
    -- =================================================================
    -- STEP 4: ALGEBRA CONCEPTS (30% = 6 concepts)
    -- =================================================================
    
    INSERT INTO concepts (id, domain_id, name, description, learning_objectives, difficulty_level, estimated_study_minutes, order_index, prerequisites)
    VALUES 
        (gen_random_uuid(), algebra_domain_id, 'Pattern Recognition', 'Identify and extend various types of patterns',
         ARRAY['Identify number patterns', 'Extend geometric patterns', 'Describe pattern rules'], 2, 40, 1, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), algebra_domain_id, 'Introduction to Functions', 'Understand basic function concepts and representations',
         ARRAY['Understand input-output relationships', 'Create function tables', 'Represent functions graphically'], 4, 50, 2, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), algebra_domain_id, 'Equation Solving', 'Understanding unknowns and solving simple equations',
         ARRAY['Solve one-step equations', 'Understand equality', 'Use inverse operations'], 3, 45, 3, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), algebra_domain_id, 'Expressions and Variables', 'Working with algebraic expressions',
         ARRAY['Evaluate expressions', 'Simplify expressions', 'Translate word problems to expressions'], 3, 40, 4, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), algebra_domain_id, 'Coordinate Graphing', 'Understanding coordinate planes and graphing',
         ARRAY['Plot points on coordinate plane', 'Interpret graphs', 'Understand scale and axes'], 3, 45, 5, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), algebra_domain_id, 'Proportional Reasoning', 'Understanding ratios, rates, and proportions',
         ARRAY['Understand ratio concepts', 'Solve proportion problems', 'Apply proportional reasoning'], 4, 50, 6, ARRAY[]::UUID[]);
    
    -- =================================================================
    -- STEP 5: GEOMETRY CONCEPTS (20% = 4 concepts)
    -- =================================================================
    
    INSERT INTO concepts (id, domain_id, name, description, learning_objectives, difficulty_level, estimated_study_minutes, order_index, prerequisites)
    VALUES 
        (gen_random_uuid(), geometry_domain_id, 'Shape Properties', 'Understanding geometric shapes and their properties',
         ARRAY['Identify 2D and 3D shapes', 'Understand shape attributes', 'Classify shapes by properties'], 2, 35, 1, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), geometry_domain_id, 'Measurement & Tools', 'Understanding measurement concepts and appropriate tools',
         ARRAY['Use measurement tools correctly', 'Understand units of measure', 'Estimate measurements'], 2, 40, 2, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), geometry_domain_id, 'Area and Perimeter', 'Calculate area and perimeter of various shapes',
         ARRAY['Find perimeter and area', 'Use appropriate formulas', 'Apply to real-world problems'], 3, 45, 3, ARRAY[]::UUID[]),
        
        (gen_random_uuid(), geometry_domain_id, 'Transformations & Symmetry', 'Understanding geometric transformations',
         ARRAY['Identify transformations', 'Understand symmetry', 'Apply transformations'], 4, 40, 4, ARRAY[]::UUID[]);
    
    -- =================================================================
    -- STEP 6: DATA ANALYSIS CONCEPTS (10% = 1 concept)
    -- =================================================================
    
    INSERT INTO concepts (id, domain_id, name, description, learning_objectives, difficulty_level, estimated_study_minutes, order_index, prerequisites)
    VALUES 
        (gen_random_uuid(), data_domain_id, 'Data Interpretation', 'Reading and interpreting tables, charts, and graphs',
         ARRAY['Read various data displays', 'Interpret statistical information', 'Draw conclusions from data'], 3, 50, 1, ARRAY[]::UUID[]);
    
    RAISE NOTICE 'Created fresh math certification structure with 19 concepts across 4 domains';
END $$;

-- =================================================================
-- STEP 7: RESTORE QUESTIONS TO APPROPRIATE CONCEPTS
-- =================================================================

-- Now restore the questions to the new concepts
DO $$
DECLARE
    question_record RECORD;
    target_concept_id UUID;
    migration_count INTEGER := 0;
BEGIN
    
    FOR question_record IN SELECT * FROM saved_questions LOOP
        target_concept_id := NULL;
        
        -- Match questions to concepts based on content and tags
        IF question_record.tags && ARRAY['place_value', 'digit_value', 'base_ten'] OR
           question_record.question_text ILIKE '%place value%' OR 
           question_record.question_text ILIKE '%digit%' THEN
            SELECT id INTO target_concept_id FROM concepts WHERE name = 'Place Value Understanding';
            
        ELSIF question_record.tags && ARRAY['fractions', 'fraction_comparison'] OR
              question_record.question_text ILIKE '%fraction%' THEN
            SELECT id INTO target_concept_id FROM concepts WHERE name = 'Fraction Understanding';
            
        ELSIF question_record.tags && ARRAY['multiplication', 'multiplication_strategies'] OR
              question_record.question_text ILIKE '%multiplication%' OR
              question_record.question_text ILIKE '%×%' THEN
            SELECT id INTO target_concept_id FROM concepts WHERE name = 'Multiplication Strategies';
            
        ELSIF question_record.tags && ARRAY['patterns', 'sequences'] OR
              question_record.question_text ILIKE '%pattern%' THEN
            SELECT id INTO target_concept_id FROM concepts WHERE name = 'Pattern Recognition';
            
        ELSIF question_record.tags && ARRAY['equations', 'unknowns'] OR
              question_record.question_text ILIKE '%equation%' OR
              question_record.question_text ILIKE '%+ __ =%' THEN
            SELECT id INTO target_concept_id FROM concepts WHERE name = 'Equation Solving';
            
        ELSIF question_record.tags && ARRAY['geometry', 'shapes'] OR
              question_record.question_text ILIKE '%shape%' THEN
            SELECT id INTO target_concept_id FROM concepts WHERE name = 'Shape Properties';
            
        ELSIF question_record.tags && ARRAY['measurement', 'tools', 'analog_clock'] OR
              question_record.question_text ILIKE '%measurement%' OR
              question_record.question_text ILIKE '%clock%' THEN
            SELECT id INTO target_concept_id FROM concepts WHERE name = 'Measurement & Tools';
            
        ELSIF question_record.tags && ARRAY['data', 'tables'] OR
              question_record.question_text ILIKE '%table%' OR
              question_record.question_text ILIKE '%data%' THEN
            SELECT id INTO target_concept_id FROM concepts WHERE name = 'Data Interpretation';
            
        ELSE
            -- Default to Place Value Understanding for unmatched number questions
            SELECT id INTO target_concept_id FROM concepts WHERE name = 'Place Value Understanding';
        END IF;
        
        -- Insert the question back with the new concept_id
        INSERT INTO questions (
            id, question_text, choice_a, choice_b, choice_c, choice_d, 
            correct_answer, explanation, cognitive_level, tags, topic_id, concept_id
        ) VALUES (
            question_record.id, question_record.question_text, 
            question_record.choice_a, question_record.choice_b, 
            question_record.choice_c, question_record.choice_d,
            question_record.correct_answer, question_record.explanation,
            question_record.cognitive_level, question_record.tags,
            question_record.topic_id, target_concept_id
        );
        
        migration_count := migration_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Restored % questions to new concept structure', migration_count;
END $$;

-- =================================================================
-- STEP 8: VERIFICATION
-- =================================================================

-- Show the final structure
SELECT 
    'FINAL STRUCTURE:' as info,
    cert.name as certification_name,
    d.name as domain_name,
    d.code as domain_code,
    d.weight_percentage,
    d.order_index,
    COUNT(c.id) as concepts_count,
    COUNT(q.id) as total_questions
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY cert.name, d.name, d.code, d.weight_percentage, d.order_index
ORDER BY d.order_index;

-- Show all concepts with question counts
SELECT 
    d.name as domain_name,
    c.name as concept_name,
    c.difficulty_level,
    c.estimated_study_minutes,
    c.order_index,
    COUNT(q.id) as question_count
FROM domains d
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN questions q ON q.concept_id = c.id
JOIN certifications cert ON cert.id = d.certification_id
WHERE cert.test_code = '902'
GROUP BY d.name, c.name, c.difficulty_level, c.estimated_study_minutes, c.order_index, d.order_index
ORDER BY d.order_index, c.order_index;

-- Clean up temp table
DROP TABLE saved_questions;

SELECT 'SUCCESS: Created fresh, comprehensive math certification structure!' as final_status;
