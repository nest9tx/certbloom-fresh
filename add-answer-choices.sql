-- 🔧 ADD MISSING ANSWER CHOICES FOR 902 QUESTIONS
-- Our questions exist but need their answer choices to display properly

-- First, let's see what content items we created
SELECT 
    id,
    title,
    correct_answer
FROM content_items 
WHERE title IN ('Place Value Error Analysis', 'Fraction Equivalence Visual Models', 'Algebraic Thinking Development')
ORDER BY created_at DESC;

-- Check if answer choices exist for these questions
SELECT 
    ci.title,
    ac.choice_order,
    ac.choice_text,
    ac.is_correct
FROM content_items ci
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE ci.title IN ('Place Value Error Analysis', 'Fraction Equivalence Visual Models', 'Algebraic Thinking Development')
ORDER BY ci.title, ac.choice_order;

-- Add answer choices for Place Value Error Analysis
INSERT INTO answer_choices (content_item_id, choice_order, choice_text, is_correct) VALUES
(
    (SELECT id FROM content_items WHERE title = 'Place Value Error Analysis'),
    1,
    'Have the student practice writing more numbers in expanded form',
    false
),
(
    (SELECT id FROM content_items WHERE title = 'Place Value Error Analysis'),
    2,
    'Use base-10 blocks to build the number while saying it aloud',
    true
),
(
    (SELECT id FROM content_items WHERE title = 'Place Value Error Analysis'),
    3,
    'Show the student the correct answer and have them copy it multiple times',
    false
),
(
    (SELECT id FROM content_items WHERE title = 'Place Value Error Analysis'),
    4,
    'Give the student a place value chart to fill in',
    false
);

-- Add answer choices for Fraction Equivalence Visual Models
INSERT INTO answer_choices (content_item_id, choice_order, choice_text, is_correct) VALUES
(
    (SELECT id FROM content_items WHERE title = 'Fraction Equivalence Visual Models'),
    1,
    'Two identical rectangles, one divided into 4 equal parts with 3 shaded, another divided into 8 equal parts with 6 shaded',
    true
),
(
    (SELECT id FROM content_items WHERE title = 'Fraction Equivalence Visual Models'),
    2,
    'A number line showing both fractions at different positions',
    false
),
(
    (SELECT id FROM content_items WHERE title = 'Fraction Equivalence Visual Models'),
    3,
    'A pie chart showing only 3/4',
    false
),
(
    (SELECT id FROM content_items WHERE title = 'Fraction Equivalence Visual Models'),
    4,
    'A hundreds chart with fractions marked',
    false
);

-- Add answer choices for Algebraic Thinking Development
INSERT INTO answer_choices (content_item_id, choice_order, choice_text, is_correct) VALUES
(
    (SELECT id FROM content_items WHERE title = 'Algebraic Thinking Development'),
    1,
    'That''s correct! Let''s try another pattern.',
    false
),
(
    (SELECT id FROM content_items WHERE title = 'Algebraic Thinking Development'),
    2,
    'Can you show me where you see the multiplication by 3 happening?',
    false
),
(
    (SELECT id FROM content_items WHERE title = 'Algebraic Thinking Development'),
    3,
    'Actually, you add 4, then 12, then 36. Look for the addition pattern.',
    false
),
(
    (SELECT id FROM content_items WHERE title = 'Algebraic Thinking Development'),
    4,
    'Let''s check: 2 × 3 = 6, 6 × 3 = 18, 18 × 3 = 54. Can you predict the next term and explain your reasoning?',
    true
);

-- Verify everything is properly connected
SELECT 'ANSWER CHOICES ADDED!' as status;
SELECT 
    ci.title,
    ci.correct_answer,
    COUNT(ac.id) as answer_choice_count
FROM content_items ci
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE ci.title IN ('Place Value Error Analysis', 'Fraction Equivalence Visual Models', 'Algebraic Thinking Development')
GROUP BY ci.id, ci.title, ci.correct_answer
ORDER BY ci.title;
