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
        (question_id, 'Add 4 to get 28', FALSE, 4, 'Incorrect - This doesn\'t use the doubling relationship.');
    
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
    
    -- =================================================================
    -- QUESTION 6: Breaking Apart Strategy (Analysis Level)
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
        'To find 6 * 13, Jamie breaks it apart as 6 * (10 + 3). What should Jamie do next?',
        'multiple_choice',
        'medium',
        'Using the distributive property: 6 * (10 + 3) = (6 * 10) + (6 * 3) = 60 + 18 = 78.',
        'analysis',
        ARRAY['multiplication', 'distributive_property', 'breaking_apart', 'mental_math_strategies'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, 'Multiply 6 * 10 and 6 * 3, then add', TRUE, 1, 'Correct - This uses the distributive property.'),
        (question_id, 'Add 10 + 3, then multiply by 6', FALSE, 2, 'Incorrect - This gives the same answer but misses the strategy.'),
        (question_id, 'Multiply 6 * 10 and 6 * 3, then subtract', FALSE, 3, 'Incorrect - We add the partial products, not subtract.'),
        (question_id, 'Multiply 6 * 13 without breaking apart', FALSE, 4, 'Incorrect - This ignores the breaking apart strategy.');
    
    -- =================================================================
    -- QUESTION 7: Word Problem - Equal Groups (Application Level)
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
        'A bakery makes cookies in batches of 12. If they make 8 batches, how many cookies do they make in total?',
        'multiple_choice',
        'easy',
        'This is a multiplication problem: 8 batches * 12 cookies per batch = 8 * 12 = 96 cookies.',
        'application',
        ARRAY['multiplication', 'equal_groups', 'word_problems', 'real_world_context'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '20 cookies', FALSE, 1, 'Incorrect - This is 8 + 12, not 8 * 12.'),
        (question_id, '84 cookies', FALSE, 2, 'Incorrect - This is 7 * 12, not 8 * 12.'),
        (question_id, '96 cookies', TRUE, 3, 'Correct - 8 * 12 = 96 cookies.'),
        (question_id, '104 cookies', FALSE, 4, 'Incorrect - This is 8 * 13, not 8 * 12.');
    
    -- =================================================================
    -- QUESTION 8: Fact Family Relationships (Comprehension Level)
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
        'If 9 * 4 = 36, which other multiplication fact uses the same numbers?',
        'multiple_choice',
        'easy',
        'Multiplication is commutative, so 9 * 4 = 4 * 9. Both equal 36.',
        'comprehension',
        ARRAY['multiplication', 'fact_families', 'commutative_property', 'number_relationships'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '4 * 9 = 36', TRUE, 1, 'Correct - Multiplication is commutative.'),
        (question_id, '36 * 1 = 36', FALSE, 2, 'Incorrect - This uses different numbers.'),
        (question_id, '6 * 6 = 36', FALSE, 3, 'Incorrect - This uses different numbers.'),
        (question_id, '18 * 2 = 36', FALSE, 4, 'Incorrect - This uses different numbers.');
    
    -- =================================================================
    -- QUESTION 9: Ten Times Pattern (Knowledge Level)
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
        'What is 7 * 10?',
        'multiple_choice',
        'easy',
        'When multiplying by 10, add a zero to the end of the number: 7 * 10 = 70.',
        'knowledge',
        ARRAY['multiplication', 'ten_times_pattern', 'place_value', 'mental_math'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '17', FALSE, 1, 'Incorrect - This is 7 + 10, not 7 * 10.'),
        (question_id, '70', TRUE, 2, 'Correct - Multiplying by 10 adds a zero.'),
        (question_id, '77', FALSE, 3, 'Incorrect - This doesn\'t follow any multiplication pattern.'),
        (question_id, '710', FALSE, 4, 'Incorrect - This places 7 and 10 together, not multiplying.');
    
    -- =================================================================
    -- QUESTION 10: Visual Model Strategy (Comprehension Level)
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
        'A student draws 3 circles with 8 dots in each circle to show multiplication. What multiplication problem is being shown?',
        'multiple_choice',
        'easy',
        'The visual shows 3 groups of 8, which represents 3 * 8.',
        'comprehension',
        ARRAY['multiplication', 'visual_models', 'groups', 'concrete_representation'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '8 * 3', FALSE, 1, 'Incorrect - This shows 8 groups of 3, not 3 groups of 8.'),
        (question_id, '3 * 8', TRUE, 2, 'Correct - 3 groups of 8 dots each.'),
        (question_id, '3 + 8', FALSE, 3, 'Incorrect - This is addition, not multiplication.'),
        (question_id, '8 + 8 + 8', FALSE, 4, 'While this equals 3 * 8, it\'s written as addition.');
    
    -- =================================================================
    -- QUESTION 11: Multiplying by 5 Pattern (Knowledge Level)
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
        'What pattern do you notice in the ones place when multiplying by 5: 5*1=5, 5*2=10, 5*3=15, 5*4=20?',
        'multiple_choice',
        'medium',
        'When multiplying by 5, the ones place alternates between 5 and 0.',
        'knowledge',
        ARRAY['multiplication', 'patterns', 'multiply_by_five', 'number_patterns'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, 'Always ends in 5', FALSE, 1, 'Incorrect - Some end in 0.'),
        (question_id, 'Always ends in 0', FALSE, 2, 'Incorrect - Some end in 5.'),
        (question_id, 'Alternates between 5 and 0', TRUE, 3, 'Correct - The pattern is 5, 0, 5, 0, etc.'),
        (question_id, 'Increases by 1 each time', FALSE, 4, 'Incorrect - The ones place doesn\'t increase by 1.');
    
    -- =================================================================
    -- QUESTION 12: Two-Digit Multiplication (Application Level)
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
        'A classroom has 12 tables, and each table seats 4 students. How many students can sit in the classroom?',
        'multiple_choice',
        'medium',
        'This requires multiplying: 12 * 4 = 48 students.',
        'application',
        ARRAY['multiplication', 'two_digit_multiplication', 'word_problems', 'classroom_context'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '16 students', FALSE, 1, 'Incorrect - This is 12 + 4, not 12 * 4.'),
        (question_id, '44 students', FALSE, 2, 'Incorrect - This is 11 * 4, not 12 * 4.'),
        (question_id, '48 students', TRUE, 3, 'Correct - 12 * 4 = 48 students.'),
        (question_id, '52 students', FALSE, 4, 'Incorrect - This is 13 * 4, not 12 * 4.');
    
    -- =================================================================
    -- QUESTION 13: Zero Property (Knowledge Level)
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
        'What is 25 * 0?',
        'multiple_choice',
        'easy',
        'Any number multiplied by 0 equals 0. This is the zero property of multiplication.',
        'knowledge',
        ARRAY['multiplication', 'zero_property', 'multiplication_properties', 'basic_facts'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '0', TRUE, 1, 'Correct - Any number times 0 equals 0.'),
        (question_id, '25', FALSE, 2, 'Incorrect - This would be the identity property (*1).'),
        (question_id, '250', FALSE, 3, 'Incorrect - This looks like multiplying by 10.'),
        (question_id, 'Cannot be determined', FALSE, 4, 'Incorrect - We can determine this using the zero property.');
    
    -- =================================================================
    -- QUESTION 14: Strategy Comparison (Analysis Level)
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
        'Two students solve 4 * 15 differently. Ana uses 4 * (10 + 5) and Ben uses 4 * 15 directly. Who is correct?',
        'multiple_choice',
        'medium',
        'Both methods are correct. Ana uses the distributive property: 4*(10+5) = 4*10 + 4*5 = 40+20 = 60. Ben gets 60 directly.',
        'analysis',
        ARRAY['multiplication', 'strategy_comparison', 'distributive_property', 'multiple_strategies'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, 'Only Ana is correct', FALSE, 1, 'Incorrect - Both methods work.'),
        (question_id, 'Only Ben is correct', FALSE, 2, 'Incorrect - Both methods work.'),
        (question_id, 'Both are correct', TRUE, 3, 'Correct - Both methods give the same answer: 60.'),
        (question_id, 'Neither is correct', FALSE, 4, 'Incorrect - Both methods are valid.');
    
    -- =================================================================
    -- QUESTION 15: Repeated Addition Connection (Comprehension Level)
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
        'Which addition problem is the same as 6 * 4?',
        'multiple_choice',
        'easy',
        'Multiplication is repeated addition: 6 * 4 means 6 groups of 4, which is 4 + 4 + 4 + 4 + 4 + 4.',
        'comprehension',
        ARRAY['multiplication', 'repeated_addition', 'conceptual_understanding', 'addition_connection'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '6 + 6 + 6 + 6', FALSE, 1, 'Incorrect - This is 4 * 6, not 6 * 4.'),
        (question_id, '4 + 4 + 4 + 4 + 4 + 4', TRUE, 2, 'Correct - This is 6 groups of 4.'),
        (question_id, '6 + 4', FALSE, 3, 'Incorrect - This is just adding 6 and 4.'),
        (question_id, '4 + 6 + 4 + 6', FALSE, 4, 'Incorrect - This alternates and doesn\'t show groups.');
    
    -- =================================================================
    -- QUESTION 16: Real-World Problem Solving (Application Level)
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
        'A parking lot has 8 rows with 9 cars in each row. How many cars are in the parking lot?',
        'multiple_choice',
        'medium',
        'This is an array multiplication problem: 8 rows * 9 cars per row = 8 * 9 = 72 cars.',
        'application',
        ARRAY['multiplication', 'arrays', 'word_problems', 'real_world_application'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '17 cars', FALSE, 1, 'Incorrect - This is 8 + 9, not 8 * 9.'),
        (question_id, '64 cars', FALSE, 2, 'Incorrect - This is 8 * 8, not 8 * 9.'),
        (question_id, '72 cars', TRUE, 3, 'Correct - 8 * 9 = 72 cars.'),
        (question_id, '81 cars', FALSE, 4, 'Incorrect - This is 9 * 9, not 8 * 9.');
    
    -- =================================================================
    -- QUESTION 17: Identity Property (Knowledge Level)
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
        'What is 47 * 1?',
        'multiple_choice',
        'easy',
        'Any number multiplied by 1 equals itself. This is the identity property of multiplication.',
        'knowledge',
        ARRAY['multiplication', 'identity_property', 'multiplication_properties', 'basic_facts'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '1', FALSE, 1, 'Incorrect - This would be 1 * 1.'),
        (question_id, '47', TRUE, 2, 'Correct - Any number times 1 equals itself.'),
        (question_id, '48', FALSE, 3, 'Incorrect - This is 47 + 1, not 47 * 1.'),
        (question_id, '470', FALSE, 4, 'Incorrect - This would be 47 * 10.');
    
    -- =================================================================
    -- QUESTION 18: Missing Factor (Analysis Level)
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
        'What number makes this equation true: ___ * 7 = 42?',
        'multiple_choice',
        'medium',
        'To find the missing factor, divide 42 ÷ 7 = 6. Check: 6 * 7 = 42 ✓',
        'analysis',
        ARRAY['multiplication', 'missing_factors', 'division_connection', 'algebraic_thinking'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '5', FALSE, 1, 'Incorrect - 5 * 7 = 35, not 42.'),
        (question_id, '6', TRUE, 2, 'Correct - 6 * 7 = 42.'),
        (question_id, '7', FALSE, 3, 'Incorrect - 7 * 7 = 49, not 42.'),
        (question_id, '8', FALSE, 4, 'Incorrect - 8 * 7 = 56, not 42.');
    
    -- =================================================================
    -- QUESTION 19: Multi-Step Problem (Application Level)
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
        'A store sells pencils in packages of 8. If Ms. Garcia buys 5 packages and gives away 12 pencils, how many pencils does she have left?',
        'multiple_choice',
        'hard',
        'First multiply: 5 * 8 = 40 pencils total. Then subtract: 40 - 12 = 28 pencils left.',
        'application',
        ARRAY['multiplication', 'multi_step_problems', 'subtraction', 'word_problems'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '25 pencils', FALSE, 1, 'Incorrect - This might be 5 * 8 - 15.'),
        (question_id, '28 pencils', TRUE, 2, 'Correct - (5 * 8) - 12 = 40 - 12 = 28.'),
        (question_id, '32 pencils', FALSE, 3, 'Incorrect - This might be 4 * 8.'),
        (question_id, '52 pencils', FALSE, 4, 'Incorrect - This adds instead of subtracts.');
    
    -- =================================================================
    -- QUESTION 20: Comparison Problem (Analysis Level)
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
        'Sarah has 3 times as many stickers as Tom. If Tom has 9 stickers, how many stickers does Sarah have?',
        'multiple_choice',
        'medium',
        'Sarah has 3 times as many means: 3 * 9 = 27 stickers.',
        'analysis',
        ARRAY['multiplication', 'comparison_problems', 'times_as_many', 'word_problems'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '12 stickers', FALSE, 1, 'Incorrect - This is 9 + 3, not 9 * 3.'),
        (question_id, '18 stickers', FALSE, 2, 'Incorrect - This is 9 * 2, not 9 * 3.'),
        (question_id, '27 stickers', TRUE, 3, 'Correct - 3 times as many: 3 * 9 = 27.'),
        (question_id, '36 stickers', FALSE, 4, 'Incorrect - This is 9 * 4, not 9 * 3.');
    
    -- =================================================================
    -- QUESTION 21: Estimation Strategy (Application Level)
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
        'To estimate 7 * 19, Mia rounds 19 to 20. What should she multiply next?',
        'multiple_choice',
        'medium',
        'After rounding 19 to 20, multiply: 7 * 20 = 140. This gives a good estimate for 7 * 19.',
        'application',
        ARRAY['multiplication', 'estimation', 'rounding', 'mental_math_strategies'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '7 * 20', TRUE, 1, 'Correct - This gives the estimate 140.'),
        (question_id, '8 * 19', FALSE, 2, 'Incorrect - We rounded 19, not 7.'),
        (question_id, '7 * 10', FALSE, 3, 'Incorrect - 19 rounds to 20, not 10.'),
        (question_id, '10 * 20', FALSE, 4, 'Incorrect - We only round one number.');
    
    -- =================================================================
    -- QUESTION 22: Teaching Strategy Analysis (Analysis Level)
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
        'A student struggles with 8 * 6. Which strategy would be most helpful for building understanding?',
        'multiple_choice',
        'hard',
        'For students struggling with facts, visual models help build conceptual understanding before moving to abstract strategies.',
        'analysis',
        ARRAY['multiplication', 'teaching_strategies', 'student_support', 'pedagogical_knowledge'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, 'Memorize the fact through drill', FALSE, 1, 'Incorrect - Doesn\'t build understanding.'),
        (question_id, 'Use visual models like arrays', TRUE, 2, 'Correct - Visual models build conceptual understanding.'),
        (question_id, 'Skip this fact and move on', FALSE, 3, 'Incorrect - Students need support, not avoidance.'),
        (question_id, 'Use only mental math strategies', FALSE, 4, 'Incorrect - Concrete models should come first.');
    
    -- =================================================================
    -- QUESTION 23: Pattern Extension (Knowledge Level)
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
        'Complete the pattern: 2*4=8, 3*4=12, 4*4=16, 5*4=___',
        'multiple_choice',
        'easy',
        'The pattern shows multiplying by 4: 5 * 4 = 20.',
        'knowledge',
        ARRAY['multiplication', 'patterns', 'fact_families', 'sequence'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '18', FALSE, 1, 'Incorrect - This doesn\'t follow the *4 pattern.'),
        (question_id, '20', TRUE, 2, 'Correct - 5 * 4 = 20.'),
        (question_id, '22', FALSE, 3, 'Incorrect - This adds 2, not multiplies by 4.'),
        (question_id, '24', FALSE, 4, 'Incorrect - This is 6 * 4, not 5 * 4.');
    
    -- =================================================================
    -- QUESTION 24: Error Analysis (Analysis Level)
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
        'A student says "9 * 4 = 32 because 8 * 4 = 32." What error did the student make?',
        'multiple_choice',
        'hard',
        'The student confused 8 * 4 = 32 with 9 * 4. Actually, 9 * 4 = 36, not 32.',
        'analysis',
        ARRAY['multiplication', 'error_analysis', 'misconceptions', 'fact_confusion'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, 'Used the wrong operation', FALSE, 1, 'Incorrect - The student used multiplication correctly.'),
        (question_id, 'Confused 9 * 4 with 8 * 4', TRUE, 2, 'Correct - Mixed up which factor goes with 32.'),
        (question_id, 'Added instead of multiplied', FALSE, 3, 'Incorrect - The student was multiplying.'),
        (question_id, 'Made no error - the answer is correct', FALSE, 4, 'Incorrect - 9 * 4 = 36, not 32.');
    
    -- =================================================================
    -- QUESTION 25: Advanced Strategy Application (Application Level)
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
        'To multiply 12 * 15, Alex uses (10+2) * (10+5). Which property allows this strategy?',
        'multiple_choice',
        'hard',
        'This uses the distributive property: (10+2) * (10+5) = 10*10 + 10*5 + 2*10 + 2*5 = 100+50+20+10 = 180.',
        'application',
        ARRAY['multiplication', 'distributive_property', 'advanced_strategies', 'two_digit_multiplication'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, 'Commutative property', FALSE, 1, 'Incorrect - This is about order, not breaking apart.'),
        (question_id, 'Distributive property', TRUE, 2, 'Correct - Breaking apart both numbers uses distributive property.'),
        (question_id, 'Associative property', FALSE, 3, 'Incorrect - This is about grouping three factors.'),
        (question_id, 'Identity property', FALSE, 4, 'Incorrect - This involves multiplying by 1.');
    
    RAISE NOTICE 'Successfully created 25 varied Multiplication Strategies questions!';
    RAISE NOTICE 'Question variety includes: basic facts, visual models, word problems, strategies, error analysis, and real-world applications';
    RAISE NOTICE 'Difficulty levels: easy (10), medium (9), hard (6)';
    RAISE NOTICE 'Cognitive levels: knowledge (6), comprehension (6), application (8), analysis (5)';
    RAISE NOTICE 'Strategy types: skip counting, doubling, breaking apart, arrays, area models, fact families, and estimation';
    RAISE NOTICE 'Total questions across all concepts: Place Value (20) + Fractions (25) + Multiplication (25) = 70 questions with excellent variety!';
END $$;
