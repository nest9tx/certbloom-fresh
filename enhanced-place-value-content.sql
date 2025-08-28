-- Enhanced Learning Content for Place Value Understanding
-- This addresses the light content in other concepts too

DO $$ 
DECLARE
    place_value_concept_uuid UUID;
    place_value_understanding_concept_uuid UUID;
BEGIN
    -- Find Place Value concepts
    SELECT id INTO place_value_concept_uuid 
    FROM concepts 
    WHERE name ILIKE '%Place Value%' AND name NOT ILIKE '%Understanding%'
    LIMIT 1;

    SELECT id INTO place_value_understanding_concept_uuid 
    FROM concepts 
    WHERE name ILIKE '%Place Value Understanding%'
    LIMIT 1;

    -- Enhance Place Value concept if found
    IF place_value_concept_uuid IS NOT NULL THEN
        -- Clear existing content
        DELETE FROM content_items WHERE concept_id = place_value_concept_uuid;
        
        -- Insert comprehensive learning content for Place Value
        INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes) VALUES
        
        (place_value_concept_uuid, 'text_explanation', 'Understanding Place Value Basics', 
         '{"sections": [
           "What is place value? Each digit in a number has a value based on its position",
           "Place value positions: ones, tens, hundreds, thousands, etc.",
           "Reading numbers: 4,567 = 4 thousands + 5 hundreds + 6 tens + 7 ones",
           "Comparing numbers: Look at digits from left to right (highest place value first)"
         ]}', 1, 8),

        (place_value_concept_uuid, 'interactive_example', 'Step-by-Step: Comparing Numbers Using Place Value',
         '{"steps": [
           "Step 1: Line up the numbers by place value",
           "Step 2: Compare digits starting from the leftmost (highest) place",
           "Step 3: The number with the larger digit in the highest differing place is larger",
           "Step 4: If all digits are the same, the numbers are equal"
         ], "example": "Compare 4,567 and 4,576: Same thousands (4), same hundreds (5), same tens (6 vs 7). Since 7 > 6, then 4,576 > 4,567"}', 2, 10),

        (place_value_concept_uuid, 'practice_question', 'Practice: Comparing Multi-Digit Numbers',
         '{"question": "Which number is larger: 4,567 or 4,576?", 
           "answers": ["4,567", "4,576", "They are equal", "Cannot determine"], 
           "correct": 1, 
           "explanation": "Compare place by place: 4=4 (thousands), 5=5 (hundreds), 6<7 (tens). Since 7>6 in the tens place, 4,576 is larger."}', 3, 5),

        (place_value_concept_uuid, 'practice_question', 'Practice: Place Value Identification',
         '{"question": "In the number 8,294, what is the value of the digit 2?", 
           "answers": ["2", "20", "200", "2,000"], 
           "correct": 2, 
           "explanation": "The digit 2 is in the hundreds place, so its value is 2 × 100 = 200"}', 4, 5),

        (place_value_concept_uuid, 'real_world_scenario', 'Real-World Application: Money and Place Value',
         '{"scenario": "When counting money, place value helps us understand that $1,234 means 1 thousand-dollar bill, 2 hundred-dollar bills, 3 ten-dollar bills, and 4 one-dollar bills. This is why place value is essential for understanding our number system."}', 5, 6),

        (place_value_concept_uuid, 'teaching_strategy', 'Teaching Strategy: Place Value Charts and Manipulatives',
         '{"strategy": "Use base-10 blocks, place value charts, or expanded form worksheets. Have students build numbers with manipulatives, then write them in standard form, expanded form (2,000 + 300 + 40 + 5), and word form."}', 6, 5),

        (place_value_concept_uuid, 'text_explanation', 'Memory Trick: Bigger Left, Bigger Number',
         '{"sections": [
           "Memory phrase: Start from the left, the bigger digit wins!",
           "Always compare the leftmost (highest place value) digits first",
           "This helps you quickly determine which number is larger",
           "Practice this rule with different number pairs"
         ]}', 7, 3);

    END IF;

    -- Enhance Place Value Understanding concept if found
    IF place_value_understanding_concept_uuid IS NOT NULL THEN
        -- Clear existing content  
        DELETE FROM content_items WHERE concept_id = place_value_understanding_concept_uuid;
        
        INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes) VALUES
        
        (place_value_understanding_concept_uuid, 'text_explanation', 'Deep Dive: Place Value System', 
         '{"sections": [
           "Our number system is base-10: each place is 10 times the place to its right",
           "Understanding zero as a placeholder: 205 means 2 hundreds, 0 tens, 5 ones",
           "Expanded notation: 3,456 = 3×1000 + 4×100 + 5×10 + 6×1",
           "Decimal place value: extends the pattern to the right (tenths, hundredths, etc.)"
         ]}', 1, 12),

        (place_value_understanding_concept_uuid, 'interactive_example', 'Building Numbers with Place Value',
         '{"steps": [
           "Start with the largest place value needed",
           "Determine how many of each place value unit you need", 
           "Use zero as placeholder for empty places",
           "Read the final number from left to right"
         ], "example": "To make 4,205: 4 thousands + 2 hundreds + 0 tens + 5 ones = 4,205"}', 2, 8);

    END IF;

    RAISE NOTICE 'Enhanced place value content created successfully';
END $$;
