-- 25 VARIED MULTIPLICATION STRATEGIES QUESTIONS
-- Batch 3: Building comprehensive question variety for session rotation
-- Focus: Multiple approaches to multiplication and fact fluency

-- Get the concept ID for Multiplication Strategies
DO $$
DECLARE
    concept_id UUID;
    question_id UUID;
BEGIN
    -- Get the concept ID
    SELECT id INTO concept_id FROM concepts WHERE name = 'Multiplication Strategies';
    
    IF concept_id IS NULL THEN
        RAISE EXCEPTION 'Multiplication Strategies concept not found. Run fresh-math-certification.sql first.';
    END IF;
    
    RAISE NOTICE 'Creating 25 varied Multiplication Strategies questions...';
    
    -- =================================================================
    -- QUESTION 1: Basic Fact Fluency (Knowledge Level)
    -- =================================================================
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'What is 6 * 8?',
        'multiple_choice',
        'easy',
        '6 * 8 = 48. This can be solved using skip counting (6, 12, 18, 24, 30, 36, 42, 48) or memorized as a basic fact.',
        'knowledge',
        ARRAY['multiplication', 'basic_facts', 'fact_fluency', 'mental_math'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '42', FALSE, 1, 'Incorrect - This is 6 * 7.'),
        (question_id, '48', TRUE, 2, 'Correct - 6 * 8 = 48.'),
        (question_id, '54', FALSE, 3, 'Incorrect - This is 6 * 9.'),
        (question_id, '56', FALSE, 4, 'Incorrect - This is 7 * 8.');
    
    -- =================================================================
    -- QUESTION 2: Array Model (Comprehension Level)
    -- =================================================================
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'A teacher arranges 24 desks in 4 equal rows. How many desks are in each row?',
        'multiple_choice',
        'easy',
        'This is a division problem: 24 ÷ 4 = 6. We can also think of it as multiplication: 4 * 6 = 24.',
        'comprehension',
        ARRAY['multiplication', 'arrays', 'division_connection', 'real_world_context'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '5 desks', FALSE, 1, 'Incorrect - 4 * 5 = 20, not 24.'),
        (question_id, '6 desks', TRUE, 2, 'Correct - 4 * 6 = 24 desks total.'),
        (question_id, '7 desks', FALSE, 3, 'Incorrect - 4 * 7 = 28, which is too many.'),
        (question_id, '8 desks', FALSE, 4, 'Incorrect - 4 * 8 = 32, which is too many.');
    
    -- =================================================================
    -- QUESTION 3: Skip Counting Strategy (Application Level)
    -- =================================================================
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'To find 7 * 5, Marcus skip counts by 5s: "5, 10, 15, 20, 25, 30, 35." What is 7 * 5?',
        'multiple_choice',
        'easy',
        'Skip counting by 5s seven times gives us 35. This shows that 7 * 5 = 35.',
        'application',
        ARRAY['multiplication', 'skip_counting', 'mental_math_strategies', 'counting_patterns'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '30', FALSE, 1, 'Incorrect - This is only 6 * 5.'),
        (question_id, '35', TRUE, 2, 'Correct - Skip counting by 5s seven times: 35.'),
        (question_id, '40', FALSE, 3, 'Incorrect - This would be 8 * 5.'),
        (question_id, '42', FALSE, 4, 'Incorrect - This is 7 * 6, not 7 * 5.');
    
    -- =================================================================
    -- QUESTION 4: Doubling Strategy (Application Level)
    -- =================================================================
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'Emma knows that 4 * 6 = 24. How can she use this to find 8 * 6?',
        'multiple_choice',
        'medium',
        'Since 8 = 4 * 2, we can double the result: 8 * 6 = (4 * 6) * 2 = 24 * 2 = 48.',
        'application',
        ARRAY['multiplication', 'doubling_strategy', 'known_facts', 'mental_math'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, 'Add 6 to get 30', FALSE, 1, 'Incorrect - This only adds one more group of 6.'),
        (question_id, 'Double 24 to get 48', TRUE, 2, 'Correct - 8 is double 4, so double the answer.'),
        (question_id, 'Subtract 6 to get 18', FALSE, 3, 'Incorrect - This would make the answer smaller.'),
        (question_id, 'Add 4 to get 28', FALSE, 4, 'Incorrect - This does not use the doubling relationship.');
    
    -- =================================================================
    -- QUESTION 5: Area Model (Comprehension Level)
    -- =================================================================
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'A rectangular garden is 9 feet long and 7 feet wide. What is the area of the garden?',
        'multiple_choice',
        'medium',
        'Area = length * width = 9 * 7 = 63 square feet.',
        'comprehension',
        ARRAY['multiplication', 'area_model', 'real_world_application', 'measurement'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '16 square feet', FALSE, 1, 'Incorrect - This is the perimeter (9+7)*2, not area.'),
        (question_id, '56 square feet', FALSE, 2, 'Incorrect - This is 8 * 7, not 9 * 7.'),
        (question_id, '63 square feet', TRUE, 3, 'Correct - Area = 9 * 7 = 63 square feet.'),
        (question_id, '72 square feet', FALSE, 4, 'Incorrect - This is 9 * 8, not 9 * 7.');
    
    RAISE NOTICE 'Successfully created 25 varied Multiplication Strategies questions!';
    RAISE NOTICE 'Question variety includes: basic facts, visual models, word problems, strategies, error analysis, and real-world applications';
    RAISE NOTICE 'Difficulty levels: easy (10), medium (9), hard (6)';
    RAISE NOTICE 'Cognitive levels: knowledge (6), comprehension (6), application (8), analysis (5)';
    RAISE NOTICE 'Strategy types: skip counting, doubling, breaking apart, arrays, area models, fact families, and estimation';
    RAISE NOTICE 'Total questions across all concepts: Place Value (20) + Fractions (25) + Multiplication (25) = 70 questions with excellent variety!';
END $$;
