-- 🎯 SIMPLE QUESTION BANK - USING ONLY EXISTING COLUMNS
-- Let's start with just the basic structure that exists

-- First, let's get the concept ID for Place Value and Number Sense
DO $$
DECLARE
    place_value_concept_id UUID;
    question_id UUID;
BEGIN
    -- Get the concept ID
    SELECT c.id INTO place_value_concept_id
    FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    JOIN certifications cert ON d.certification_id = cert.id
    WHERE cert.test_code = '902' 
    AND c.name = 'Place Value and Number Sense';

    -- Question 1: Basic Place Value Understanding - using only basic columns
    INSERT INTO content_items (
        concept_id, 
        type, 
        content
    ) VALUES (
        place_value_concept_id, 
        'question',
        'In the number 4,567, what is the value of the digit 5?'
    ) RETURNING id INTO question_id;

    -- Add answer choices for Question 1
    INSERT INTO answer_choices (content_item_id, choice_letter, choice_text, explanation, is_correct) VALUES
    (question_id, 'A', '5', 'This is the digit itself, not its place value. The digit 5 is in the hundreds place, so its value is much greater.', false),
    (question_id, 'B', '500', 'Correct! The 5 is in the hundreds place, so its value is 5 × 100 = 500.', true),
    (question_id, 'C', '50', 'This would be correct if the 5 were in the tens place, but it is in the hundreds place.', false),
    (question_id, 'D', '5,000', 'This would be the value if 5 were in the thousands place, but it is in the hundreds place.', false);

    -- Question 2: Comparing Numbers
    INSERT INTO content_items (
        concept_id, 
        type, 
        content
    ) VALUES (
        place_value_concept_id, 
        'question',
        'Ms. Garcia''s class collected 2,847 bottle caps for recycling. Mr. Johnson''s class collected 2,874 bottle caps. Which statement correctly compares these amounts?'
    ) RETURNING id INTO question_id;

    -- Add answer choices for Question 2
    INSERT INTO answer_choices (content_item_id, choice_letter, choice_text, explanation, is_correct) VALUES
    (question_id, 'A', 'Ms. Garcia''s class collected more bottle caps', 'Incorrect. 2,847 < 2,874, so Ms. Garcia''s class collected fewer bottle caps.', false),
    (question_id, 'B', 'Both classes collected the same number of bottle caps', 'Incorrect. The numbers are different: 2,847 ≠ 2,874.', false),
    (question_id, 'C', 'Mr. Johnson''s class collected more bottle caps', 'Correct! 2,874 > 2,847, so Mr. Johnson''s class collected more.', true),
    (question_id, 'D', 'It is impossible to tell without more information', 'Incorrect. We can compare these numbers directly using place value.', false);

    -- Question 3: Rounding
    INSERT INTO content_items (
        concept_id, 
        type, 
        content
    ) VALUES (
        place_value_concept_id, 
        'question',
        'A teacher needs to order approximately 150 books for her classroom library. The exact count shows she needs 147 books. What is 147 rounded to the nearest ten?'
    ) RETURNING id INTO question_id;

    -- Add answer choices for Question 3
    INSERT INTO answer_choices (content_item_id, choice_letter, choice_text, explanation, is_correct) VALUES
    (question_id, 'A', '150', 'Correct! The ones digit (7) is 5 or greater, so we round up to 150.', true),
    (question_id, 'B', '140', 'Incorrect. This would be rounding down, but since the ones digit is 7 (≥5), we round up.', false),
    (question_id, 'C', '100', 'Incorrect. This is rounding to the nearest hundred, not the nearest ten.', false),
    (question_id, 'D', '147', 'Incorrect. This is the exact number, not rounded to the nearest ten.', false);

END $$;

-- Verify our question bank
SELECT 
    ci.content,
    ci.type,
    ci.created_at,
    COUNT(ac.id) as answer_count
FROM content_items ci
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
JOIN concepts c ON ci.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902' 
AND c.name = 'Place Value and Number Sense'
AND ci.type = 'question'
GROUP BY ci.id, ci.content, ci.type, ci.created_at
ORDER BY ci.created_at DESC;

SELECT '✅ Basic question bank created for Place Value and Number Sense!' as status;
