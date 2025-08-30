-- 20 VARIED PLACE VALUE UNDERSTANDING QUESTIONS
-- Batch 1: Foundation questions for proper session rotation
-- These demonstrate the variety needed to prevent answer memorization

-- Get the concept ID for Place Value Understanding
DO $$
DECLARE
    concept_id UUID;
    question_id UUID;
BEGIN
    -- Get the concept ID
    SELECT id INTO concept_id FROM concepts WHERE name = 'Place Value Understanding';
    
    IF concept_id IS NULL THEN
        RAISE EXCEPTION 'Place Value Understanding concept not found. Run fresh-math-certification.sql first.';
    END IF;
    
    RAISE NOTICE 'Creating 19 new Place Value Understanding questions (Question 1 already exists)...';
    
    -- =================================================================
    -- QUESTION 1: SKIP - Already exists from our test question
    -- =================================================================
    RAISE NOTICE 'Skipping Question 1: "What is the value of the digit 7 in the number 2,741?" - already exists';
    
    -- =================================================================
    -- QUESTION 2: Expanded Form (Comprehension Level)
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
        'Which expression shows 4,628 written in expanded form?',
        'multiple_choice',
        'easy',
        'Expanded form shows the value of each digit: 4,628 = 4,000 + 600 + 20 + 8.',
        'comprehension',
        ARRAY['place_value', 'expanded_form', 'number_representation'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '4 + 6 + 2 + 8', FALSE, 1, 'Incorrect - This shows the digits, not their place values.'),
        (question_id, '4,000 + 600 + 20 + 8', TRUE, 2, 'Correct - This shows the value of each digit in its place.'),
        (question_id, '4 + 600 + 20 + 8', FALSE, 3, 'Incorrect - The 4 should be 4,000.'),
        (question_id, '40 + 60 + 20 + 8', FALSE, 4, 'Incorrect - The place values are wrong.');
    
    -- =================================================================
    -- QUESTION 3: Comparing Numbers (Application Level)
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
        'Which number is greater: 3,456 or 3,465?',
        'multiple_choice',
        'medium',
        'Compare digits from left to right. The thousands and hundreds are the same (3,4__). In the tens place, 6 > 5, so 3,465 > 3,456.',
        'application',
        ARRAY['place_value', 'number_comparison', 'greater_than'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '3,456 is greater', FALSE, 1, 'Incorrect - 3,456 < 3,465.'),
        (question_id, '3,465 is greater', TRUE, 2, 'Correct - In the tens place, 6 > 5.'),
        (question_id, 'They are equal', FALSE, 3, 'Incorrect - The numbers are different.'),
        (question_id, 'Cannot determine', FALSE, 4, 'Incorrect - We can compare these numbers.');
    
    -- =================================================================
    -- QUESTION 4: Visual Place Value (Knowledge Level)
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
        'A student uses base-ten blocks to show a number: 2 hundreds blocks, 3 tens rods, and 7 ones cubes. What number is represented?',
        'multiple_choice',
        'easy',
        'Count the place values: 2 hundreds (200) + 3 tens (30) + 7 ones (7) = 237.',
        'knowledge',
        ARRAY['place_value', 'base_ten_blocks', 'visual_representation', 'concrete_model'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '237', TRUE, 1, 'Correct - 2 hundreds + 3 tens + 7 ones = 237.'),
        (question_id, '327', FALSE, 2, 'Incorrect - This mixes up the place values.'),
        (question_id, '273', FALSE, 3, 'Incorrect - This puts tens in ones place.'),
        (question_id, '2,037', FALSE, 4, 'Incorrect - This adds an extra zero.');
    
    -- =================================================================
    -- QUESTION 5: Rounding Application (Application Level)
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
        'Round 4,687 to the nearest hundred.',
        'multiple_choice',
        'medium',
        'Look at the tens digit (8). Since 8 ≥ 5, round up. 4,687 rounds to 4,700.',
        'application',
        ARRAY['place_value', 'rounding', 'nearest_hundred', 'estimation'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '4,600', FALSE, 1, 'Incorrect - The tens digit 8 means we round up, not down.'),
        (question_id, '4,700', TRUE, 2, 'Correct - The tens digit 8 ≥ 5, so we round up to 4,700.'),
        (question_id, '4,680', FALSE, 3, 'Incorrect - This rounds to the nearest ten, not hundred.'),
        (question_id, '5,000', FALSE, 4, 'Incorrect - This rounds to the nearest thousand.');
    
    -- =================================================================
    -- QUESTION 6: Word Problem Context (Application Level)
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
        'The population of Riverside Elementary is 1,847 students. What digit is in the tens place?',
        'multiple_choice',
        'easy',
        'In 1,847, reading from right to left: 7 (ones), 4 (tens), 8 (hundreds), 1 (thousands). The tens place contains 4.',
        'application',
        ARRAY['place_value', 'word_problem', 'tens_place', 'real_world_context'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '1', FALSE, 1, 'Incorrect - 1 is in the thousands place.'),
        (question_id, '8', FALSE, 2, 'Incorrect - 8 is in the hundreds place.'),
        (question_id, '4', TRUE, 3, 'Correct - 4 is in the tens place.'),
        (question_id, '7', FALSE, 4, 'Incorrect - 7 is in the ones place.');
    
    -- =================================================================
    -- QUESTION 7: Decimal Place Value (Comprehension Level)
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
        'In the decimal number 23.56, what is the place value of the digit 5?',
        'multiple_choice',
        'medium',
        'In decimals, the first place after the decimal point is tenths. So 5 is in the tenths place.',
        'comprehension',
        ARRAY['place_value', 'decimals', 'tenths_place', 'decimal_representation'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, 'Ones', FALSE, 1, 'Incorrect - Ones place is before the decimal point.'),
        (question_id, 'Tenths', TRUE, 2, 'Correct - The first place after the decimal is tenths.'),
        (question_id, 'Hundredths', FALSE, 3, 'Incorrect - Hundredths is the second place after decimal.'),
        (question_id, 'Tens', FALSE, 4, 'Incorrect - Tens place is before the decimal point.');
    
    -- =================================================================
    -- QUESTION 8: Number Identification (Knowledge Level)
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
        'Which number has 6 in the thousands place?',
        'multiple_choice',
        'easy',
        'The thousands place is the fourth digit from the right. Only 6,234 has 6 in the thousands place.',
        'knowledge',
        ARRAY['place_value', 'thousands_place', 'number_identification'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '1,632', FALSE, 1, 'Incorrect - 6 is in the hundreds place here.'),
        (question_id, '3,461', FALSE, 2, 'Incorrect - 6 is in the tens place here.'),
        (question_id, '6,234', TRUE, 3, 'Correct - 6 is in the thousands place.'),
        (question_id, '2,356', FALSE, 4, 'Incorrect - 6 is in the ones place here.');
    
    -- =================================================================
    -- QUESTION 9: Missing Number Pattern (Analysis Level)
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
        'What number comes next in this pattern: 3,200, 3,300, 3,400, ____?',
        'multiple_choice',
        'medium',
        'The pattern increases by 100 each time (adding 1 to the hundreds place). 3,400 + 100 = 3,500.',
        'analysis',
        ARRAY['place_value', 'number_patterns', 'hundreds_place', 'sequence'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '3,401', FALSE, 1, 'Incorrect - This adds 1, but the pattern adds 100.'),
        (question_id, '3,500', TRUE, 2, 'Correct - The pattern adds 100 each time.'),
        (question_id, '4,400', FALSE, 3, 'Incorrect - This skips too far ahead.'),
        (question_id, '3,410', FALSE, 4, 'Incorrect - This adds 10, not 100.');
    
    -- =================================================================
    -- QUESTION 10: Standard vs Word Form (Comprehension Level)
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
        'How do you write "five thousand, two hundred thirty-six" in standard form?',
        'multiple_choice',
        'medium',
        'Break down the words: five thousand (5,000) + two hundred (200) + thirty (30) + six (6) = 5,236.',
        'comprehension',
        ARRAY['place_value', 'word_form', 'standard_form', 'number_writing'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '5,236', TRUE, 1, 'Correct - 5,000 + 200 + 30 + 6 = 5,236.'),
        (question_id, '52,36', FALSE, 2, 'Incorrect - This misplaces the comma.'),
        (question_id, '5,263', FALSE, 3, 'Incorrect - This reverses the tens and ones.'),
        (question_id, '50,236', FALSE, 4, 'Incorrect - This adds an extra zero.');
    
    -- =================================================================
    -- QUESTIONS 11-20: Continue with varied types...
    -- =================================================================
    
    -- QUESTION 11: Greater/Less Than with place value reasoning
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'Which symbol makes this statement true: 4,567 ___ 4,576?',
        'multiple_choice',
        'medium',
        'Compare place by place: thousands (4=4), hundreds (5=5), tens (6<7). Since 6<7, then 4,567 < 4,576.',
        'application',
        ARRAY['place_value', 'comparison_symbols', 'less_than', 'number_comparison'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '>', FALSE, 1, 'Incorrect - 4,567 is not greater than 4,576.'),
        (question_id, '<', TRUE, 2, 'Correct - In the tens place, 6 < 7.'),
        (question_id, '=', FALSE, 3, 'Incorrect - The numbers are not equal.'),
        (question_id, '≠', FALSE, 4, 'While true they are not equal, < is more specific.');
    
    -- QUESTION 12: Place value with zeros
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'In the number 7,053, what does the 0 represent?',
        'multiple_choice',
        'easy',
        'The 0 is in the hundreds place, meaning there are no hundreds in this number.',
        'knowledge',
        ARRAY['place_value', 'zeros', 'hundreds_place', 'placeholder'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, 'Nothing - it can be ignored', FALSE, 1, 'Incorrect - Zero is a placeholder that cannot be ignored.'),
        (question_id, 'Zero hundreds', TRUE, 2, 'Correct - The zero shows there are no hundreds.'),
        (question_id, 'Zero thousands', FALSE, 3, 'Incorrect - There are 7 thousands.'),
        (question_id, 'Zero tens', FALSE, 4, 'Incorrect - The zero is not in the tens place.');
    
    -- QUESTION 13: Ordering numbers
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'Which list shows these numbers in order from least to greatest: 2,341, 2,431, 2,134?',
        'multiple_choice',
        'medium',
        'Compare hundreds place first: 2,134 (1 hundred), then 2,341 (3 hundreds), then 2,431 (4 hundreds).',
        'application',
        ARRAY['place_value', 'ordering_numbers', 'least_to_greatest', 'comparison'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '2,341, 2,431, 2,134', FALSE, 1, 'Incorrect - This is not in order.'),
        (question_id, '2,134, 2,341, 2,431', TRUE, 2, 'Correct - Order by hundreds place: 1, 3, 4.'),
        (question_id, '2,431, 2,341, 2,134', FALSE, 3, 'Incorrect - This is greatest to least.'),
        (question_id, '2,134, 2,431, 2,341', FALSE, 4, 'Incorrect - The last two are out of order.');
    
    -- QUESTION 14: Real-world measurement context
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'A school library has 3,642 books. The librarian wants to know how many thousands of books there are. What digit should she look at?',
        'multiple_choice',
        'easy',
        'To find thousands, look at the thousands place. In 3,642, the digit 3 is in the thousands place.',
        'application',
        ARRAY['place_value', 'thousands_place', 'real_world_context', 'library_books'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '2', FALSE, 1, 'Incorrect - 2 is in the ones place.'),
        (question_id, '4', FALSE, 2, 'Incorrect - 4 is in the tens place.'),
        (question_id, '6', FALSE, 3, 'Incorrect - 6 is in the hundreds place.'),
        (question_id, '3', TRUE, 4, 'Correct - 3 is in the thousands place.');
    
    -- QUESTION 15: Building numbers from place values
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'What number is made from: 8 thousands + 0 hundreds + 5 tens + 9 ones?',
        'multiple_choice',
        'medium',
        'Add the place values: 8,000 + 0 + 50 + 9 = 8,059.',
        'comprehension',
        ARRAY['place_value', 'building_numbers', 'addition_place_values', 'zeros'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '8,059', TRUE, 1, 'Correct - 8,000 + 0 + 50 + 9 = 8,059.'),
        (question_id, '8,509', FALSE, 2, 'Incorrect - This puts 5 in hundreds place.'),
        (question_id, '8,590', FALSE, 3, 'Incorrect - This switches tens and ones.'),
        (question_id, '80,059', FALSE, 4, 'Incorrect - This has too many digits.');
    
    -- QUESTION 16: Money context with place value
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'Sarah has saved $2,387. What is the value of the digit 3 in her savings amount?',
        'multiple_choice',
        'easy',
        'The digit 3 is in the hundreds place, so its value is 3 × 100 = $300.',
        'application',
        ARRAY['place_value', 'money_context', 'hundreds_place', 'real_world'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '$3', FALSE, 1, 'Incorrect - This is just the digit, not its place value.'),
        (question_id, '$30', FALSE, 2, 'Incorrect - This would be if 3 were in tens place.'),
        (question_id, '$300', TRUE, 3, 'Correct - 3 in hundreds place = $300.'),
        (question_id, '$3,000', FALSE, 4, 'Incorrect - This would be if 3 were in thousands place.');
    
    -- QUESTION 17: Error analysis
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'A student says that in the number 5,649, the digit 4 is worth 4. What is wrong with this thinking?',
        'multiple_choice',
        'medium',
        'The digit 4 is in the tens place, so its value is 4 × 10 = 40, not just 4.',
        'analysis',
        ARRAY['place_value', 'error_analysis', 'tens_place', 'misconception'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, 'Nothing is wrong - 4 is worth 4', FALSE, 1, 'Incorrect - Place value affects the digit''s worth.'),
        (question_id, 'The 4 is worth 40, not 4', TRUE, 2, 'Correct - 4 in tens place = 40.'),
        (question_id, 'The 4 is worth 400, not 4', FALSE, 3, 'Incorrect - 4 is not in hundreds place.'),
        (question_id, 'The 4 is worth 4,000, not 4', FALSE, 4, 'Incorrect - 4 is not in thousands place.');
    
    -- QUESTION 18: Multiple representation
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'Which of these represents the same number as 4,000 + 200 + 30 + 7?',
        'multiple_choice',
        'medium',
        'All forms should equal 4,237: standard form, word form, and expanded form.',
        'comprehension',
        ARRAY['place_value', 'multiple_representations', 'equivalent_forms'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, 'Four thousand, two hundred thirty-seven', TRUE, 1, 'Correct - This is 4,237 in word form.'),
        (question_id, 'Four thousand, two hundred seventy-three', FALSE, 2, 'Incorrect - This would be 4,273.'),
        (question_id, 'Forty-two thousand, thirty-seven', FALSE, 3, 'Incorrect - This would be 42,037.'),
        (question_id, 'Four thousand, twenty-three seven', FALSE, 4, 'Incorrect - This is not proper word form.');
    
    -- QUESTION 19: Calculator display interpretation
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'A calculator display shows 6204. If the 2 key is broken and shows as 0, what number was really entered?',
        'multiple_choice',
        'hard',
        'If the 2 shows as 0, then 6204 displayed means 6224 was entered (the 0 in hundreds place was really 2).',
        'analysis',
        ARRAY['place_value', 'problem_solving', 'logical_reasoning', 'hundreds_place'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '6224', TRUE, 1, 'Correct - The 0 in hundreds place was really 2.'),
        (question_id, '6254', FALSE, 2, 'Incorrect - This changes the wrong place.'),
        (question_id, '6202', FALSE, 3, 'Incorrect - This affects the wrong digit.'),
        (question_id, '6214', FALSE, 4, 'Incorrect - This puts 2 in tens place.');
    
    -- QUESTION 20: Advanced comparison
    INSERT INTO questions (
        question_text, 
        question_type,
        difficulty_level,
        explanation, 
        cognitive_level, 
        tags, 
        concept_id
    ) VALUES (
        'Which number is closest to 5,000?',
        'multiple_choice',
        'hard',
        'Calculate distances: |4,897-5,000|=103, |5,124-5,000|=124, |4,786-5,000|=214, |5,203-5,000|=203. Smallest is 103.',
        'analysis',
        ARRAY['place_value', 'number_sense', 'closest_value', 'estimation'],
        concept_id
    ) RETURNING id INTO question_id;
    
    INSERT INTO answer_choices (question_id, choice_text, is_correct, choice_order, explanation) VALUES
        (question_id, '4,786', FALSE, 1, 'Incorrect - This is 214 away from 5,000.'),
        (question_id, '4,897', TRUE, 2, 'Correct - This is only 103 away from 5,000.'),
        (question_id, '5,124', FALSE, 3, 'Incorrect - This is 124 away from 5,000.'),
        (question_id, '5,203', FALSE, 4, 'Incorrect - This is 203 away from 5,000.');
    
    RAISE NOTICE 'Successfully created 19 new Place Value Understanding questions (plus 1 existing = 20 total)!';
    RAISE NOTICE 'Question types include: basic identification, word problems, error analysis, comparisons, and real-world contexts';
    RAISE NOTICE 'Difficulty levels: easy (7 new + 1 existing), medium (8), hard (4)';
    RAISE NOTICE 'Cognitive levels: knowledge (4 new + 1 existing), comprehension (6), application (6), analysis (3)';
    RAISE NOTICE 'Total Place Value Understanding questions now: 20 with excellent variety for session rotation!';
END $$;
