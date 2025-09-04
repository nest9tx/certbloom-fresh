-- 🎯 CORRECTED HIGH-QUALITY QUESTION BANK FOR PLACE VALUE AND NUMBER SENSE
-- Using the actual content_items table structure

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

    -- Question 1: Basic Place Value Understanding
    INSERT INTO content_items (
        concept_id, type, content, correct_answer, difficulty_level,
        detailed_explanation, real_world_application, confidence_building_tip,
        common_misconceptions, memory_aids, anxiety_note
    ) VALUES (
        place_value_concept_id, 'question',
        'In the number 4,567, what is the value of the digit 5?',
        'B',
        1, -- Beginner level
        'The digit 5 is in the hundreds place, so its value is 5 × 100 = 500. Remember that place value tells us how much each digit is worth based on its position. Moving from right to left: ones, tens, hundreds, thousands.',
        'When teaching students to count money or understand addresses like 1500 Main Street, place value helps them understand what each digit represents.',
        'You use place value every day when you read numbers! You already understand this concept intuitively - this question just helps you formalize that knowledge.',
        ARRAY['Confusing the digit (5) with its value (500)', 'Thinking the 5 represents 5 tens instead of 5 hundreds'],
        ARRAY['Use the phrase "place value, not face value" to remember position matters', 'Think "5 hundreds" rather than just "5"'],
        'Take a deep breath. Place value is logical and follows patterns. If you''re unsure, work from right to left: ones, tens, hundreds.'
    ) RETURNING id INTO question_id;

    -- Add answer choices for Question 1
    INSERT INTO answer_choices (content_item_id, choice_letter, choice_text, explanation, is_correct) VALUES
    (question_id, 'A', '5', 'This is the digit itself, not its place value. The digit 5 is in the hundreds place, so its value is much greater.', false),
    (question_id, 'B', '500', 'Correct! The 5 is in the hundreds place, so its value is 5 × 100 = 500.', true),
    (question_id, 'C', '50', 'This would be correct if the 5 were in the tens place, but it''s in the hundreds place.', false),
    (question_id, 'D', '5,000', 'This would be the value if 5 were in the thousands place, but it''s in the hundreds place.', false);

    -- Question 2: Comparing Numbers (Scenario-based)
    INSERT INTO content_items (
        concept_id, type, content, correct_answer, difficulty_level,
        detailed_explanation, real_world_application, confidence_building_tip,
        common_misconceptions, memory_aids, anxiety_note
    ) VALUES (
        place_value_concept_id, 'question',
        'Ms. Garcia''s class collected 2,847 bottle caps for recycling. Mr. Johnson''s class collected 2,874 bottle caps. Which statement correctly compares these amounts?',
        'C',
        2, -- Intermediate level
        'To compare numbers with the same number of digits, compare from left to right. Both numbers start with 2,8__, so we look at the hundreds place: 4 vs. 7. Since 4 < 7, we have 2,847 < 2,874. Mr. Johnson''s class collected more.',
        'Teachers often need to compare data like test scores, attendance numbers, or fundraising totals. This skill helps you make accurate comparisons for school reports.',
        'You''re developing the same skills you''ll teach your students! Comparing numbers systematically prevents errors and builds confidence.',
        ARRAY['Only looking at the last digits instead of comparing place by place', 'Assuming longer numbers are always bigger (not the case here since both have 4 digits)'],
        ARRAY['When digits are the same, move right to the next place', 'Use the < and > symbols like "hungry alligators" eating the bigger number'],
        'Comparing numbers step-by-step removes guesswork. Trust the process, and you''ll get the right answer.'
    ) RETURNING id INTO question_id;

    -- Add answer choices for Question 2
    INSERT INTO answer_choices (content_item_id, choice_letter, choice_text, explanation, is_correct) VALUES
    (question_id, 'A', 'Ms. Garcia''s class collected more bottle caps', 'Incorrect. 2,847 < 2,874, so Ms. Garcia''s class collected fewer bottle caps.', false),
    (question_id, 'B', 'Both classes collected the same number of bottle caps', 'Incorrect. The numbers are different: 2,847 ≠ 2,874.', false),
    (question_id, 'C', 'Mr. Johnson''s class collected more bottle caps', 'Correct! 2,874 > 2,847, so Mr. Johnson''s class collected more.', true),
    (question_id, 'D', 'It''s impossible to tell without more information', 'Incorrect. We can compare these numbers directly using place value.', false);

    -- Question 3: Rounding in Teaching Context
    INSERT INTO content_items (
        concept_id, type, content, correct_answer, difficulty_level,
        detailed_explanation, real_world_application, confidence_building_tip,
        common_misconceptions, memory_aids, anxiety_note
    ) VALUES (
        place_value_concept_id, 'question',
        'A teacher needs to order approximately 150 books for her classroom library. The exact count shows she needs 147 books. What is 147 rounded to the nearest ten?',
        'A',
        1, -- Beginner level
        'To round to the nearest ten, look at the ones digit. In 147, the ones digit is 7. Since 7 ≥ 5, we round up. The tens digit increases from 4 to 5, giving us 150. This confirms the teacher''s estimate was accurate.',
        'Teachers use rounding for estimates when ordering supplies, planning field trips, or communicating with parents about class sizes and activities.',
        'Rounding is a practical skill you use for quick estimates. You''re learning to be both precise when needed and efficient when estimating.',
        ARRAY['Always rounding up regardless of the ones digit', 'Forgetting to change the ones digit to 0 when rounding'],
        ARRAY['5 or more, give it a shove (round up)', '4 or less, let it rest (round down)'],
        'Rounding follows simple rules. If you forget the rule, think about which ten the number is closer to on a number line.'
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
    ci.correct_answer,
    ci.difficulty_level,
    LEFT(ci.detailed_explanation, 80) || '...' as explanation_preview,
    LEFT(ci.confidence_building_tip, 60) || '...' as confidence_tip_preview
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902' 
AND c.name = 'Place Value and Number Sense'
AND ci.type = 'question'
ORDER BY ci.created_at DESC;

SELECT '✅ High-quality question bank created for Place Value and Number Sense!' as status;
