-- 🎯 FINAL 902 COMPREHENSIVE QUESTIONS
-- Using ACTUAL database structure and IDs

-- Question 1: Place Value and Number Sense (Domain 1 - NCO)
INSERT INTO content_items (
    id,
    concept_id,
    type,
    title,
    content,
    correct_answer,
    explanation,
    detailed_explanation,
    real_world_application,
    confidence_building_tip,
    common_misconceptions,
    memory_aids,
    anxiety_note,
    difficulty_level,
    estimated_time_minutes,
    topic_tags,
    cognitive_level,
    learning_objective,
    prerequisite_concepts,
    related_standards,
    question_source,
    created_at
) VALUES (
    gen_random_uuid(),
    'c1111111-1111-1111-1111-111111111111', -- Place Value and Number Sense
    'question',
    'Place Value Error Analysis',
    'A fourth-grade student writes "three hundred five" as 3005. What instructional strategy would BEST help this student understand the correct place value representation?

A) Have the student practice writing more numbers in expanded form
B) Use base-10 blocks to build the number while saying it aloud
C) Show the student the correct answer and have them copy it multiple times
D) Give the student a place value chart to fill in',
    'B',
    'Manipulatives with verbal reinforcement help students connect concrete, auditory, and abstract representations.',
    'Option B is correct because it addresses the root of the misconception through multi-sensory learning. The student likely added an extra zero because they heard "three hundred" and wrote 300, then "five" and added 05. Using base-10 blocks while saying the number helps students see that "three hundred five" means 3 hundreds, 0 tens, and 5 ones. This concrete representation with verbal reinforcement builds the connection between spoken numbers and written place value.',
    'When students make place value errors, always go back to manipulatives. Have them build numbers with blocks, say them aloud, then write the digits. This multi-sensory approach prevents common errors.',
    'Focus on the process, not just the right answer. Understanding WHY place value works is more important than memorizing patterns.',
    ARRAY['Students add extra zeros when they hear number words like "hundred"', 'Students don''t understand that zero is a placeholder', 'Students write each number word as a separate number (three = 3, hundred = 00, five = 5)'],
    ARRAY['Build it, say it, write it', 'Zero holds the place when there''s nothing there', 'Each position has a value'],
    'Place value errors are very common and easily fixed with the right approach. You''re not alone in finding this tricky.',
    2,
    2,
    ARRAY['place-value', 'number-sense', 'manipulatives', 'multi-sensory-learning', 'elementary-math'],
    'Application',
    'Students will use multiple representations to understand place value relationships',
    ARRAY['counting by ones, tens, and hundreds', 'understanding of number words'],
    ARRAY['TEKS 2.2A', 'TEKS 3.2A', 'TEKS 4.2A'],
    'CertBloom Original - Error Analysis Focus',
    NOW()
);

-- Question 2: Fractions and Decimals (Domain 1 - NCO)
INSERT INTO content_items (
    id,
    concept_id,
    type,
    title,
    content,
    correct_answer,
    explanation,
    detailed_explanation,
    real_world_application,
    confidence_building_tip,
    common_misconceptions,
    memory_aids,
    anxiety_note,
    difficulty_level,
    estimated_time_minutes,
    topic_tags,
    cognitive_level,
    learning_objective,
    prerequisite_concepts,
    related_standards,
    question_source,
    created_at
) VALUES (
    gen_random_uuid(),
    'c1111111-1111-1111-1111-111111111113', -- Fractions and Decimals
    'question',
    'Fraction Equivalence Visual Models',
    'A teacher wants to help students understand that 3/4 and 6/8 are equivalent fractions. Which visual model would be MOST effective for demonstrating this concept to elementary students?

A) Two identical rectangles, one divided into 4 equal parts with 3 shaded, another divided into 8 equal parts with 6 shaded
B) A number line showing both fractions at different positions
C) A pie chart showing only 3/4
D) A hundreds chart with fractions marked',
    'A',
    'Visual models with identical shapes help students see that equivalent fractions represent the same amount of a whole.',
    'Option A is correct because using identical rectangles allows students to visually compare the shaded areas and see they are equal. This concrete representation builds conceptual understanding before moving to abstract algorithms. The visual clearly shows that while the number of parts differs (4 vs 8), the actual amount shaded is the same. This supports the development of fraction sense, which is crucial for later success with fraction operations.',
    'In classroom teaching, use manipulatives like fraction bars or circles to demonstrate equivalent fractions before having students work with symbolic notation. This helps students understand WHY fractions are equivalent, not just HOW to find equivalent fractions.',
    'Remember: You''re building conceptual understanding first, then procedural fluency. Visual models are your foundation for all fraction work.',
    ARRAY['Students often think 6/8 > 3/4 because 6 > 3', 'Students may focus only on numerators or denominators separately', 'Students might think fractions with larger denominators are always larger'],
    ARRAY['Same shape, same shading = equivalent fractions', 'Visual first, symbols second', 'Equal parts of equal wholes'],
    'Take your time with visual models - they build the foundation for all future fraction success. There''s no rush.',
    3,
    3,
    ARRAY['fractions', 'equivalent-fractions', 'visual-models', 'conceptual-understanding', 'elementary-math'],
    'Comprehension',
    'Students will understand that equivalent fractions represent equal amounts using visual models',
    ARRAY['understanding of fractions as parts of a whole', 'basic division concepts'],
    ARRAY['TEKS 3.3F', 'TEKS 4.3C', 'TEKS 5.3A'],
    'CertBloom Original - Pedagogical Focus',
    NOW()
);

-- Question 3: Patterns and Sequences (Domain 2 - PRAR)
INSERT INTO content_items (
    id,
    concept_id,
    type,
    title,
    content,
    correct_answer,
    explanation,
    detailed_explanation,
    real_world_application,
    confidence_building_tip,
    common_misconceptions,
    memory_aids,
    anxiety_note,
    difficulty_level,
    estimated_time_minutes,
    topic_tags,
    cognitive_level,
    learning_objective,
    prerequisite_concepts,
    related_standards,
    question_source,
    created_at
) VALUES (
    gen_random_uuid(),
    'c2222222-2222-2222-2222-222222222221', -- Patterns and Sequences
    'question',
    'Algebraic Thinking Development',
    'Students are exploring the pattern: 2, 6, 18, 54, ... A student says, "I multiply by 3 each time." How should the teacher respond to develop deeper algebraic thinking?

A) "That''s correct! Let''s try another pattern."
B) "Can you show me where you see the multiplication by 3 happening?"
C) "Actually, you add 4, then 12, then 36. Look for the addition pattern."
D) "Let''s check: 2 × 3 = 6, 6 × 3 = 18, 18 × 3 = 54. Can you predict the next term and explain your reasoning?"',
    'D',
    'This response validates the student''s thinking while extending it to prediction and reasoning.',
    'Option D is the best response because it employs effective questioning techniques that build algebraic thinking. First, it validates the student''s correct identification of the pattern rule. Then it asks them to verify their understanding by checking each step. Finally, it extends their thinking by asking for prediction and reasoning - key components of algebraic thinking. This approach helps students move from pattern recognition to pattern analysis and generalization.',
    'In classroom practice, always validate correct student thinking first, then extend it. Ask "Can you predict..." and "How do you know..." to develop mathematical reasoning beyond just finding patterns.',
    'When students identify patterns correctly, celebrate that success! Then build on it by asking them to explain and predict.',
    ARRAY['Teachers might focus only on the arithmetic without developing reasoning', 'Students might memorize patterns without understanding the underlying structure', 'Teachers might immediately correct instead of building on student thinking'],
    ARRAY['Validate first, then extend', 'Pattern + Prediction + Reasoning = Algebraic thinking', 'Ask "How do you know?" regularly'],
    'Building on student thinking (even when they''re right) shows you value their reasoning process.',
    4,
    3,
    ARRAY['patterns', 'algebraic-thinking', 'questioning-techniques', 'mathematical-reasoning', 'pedagogy'],
    'Analysis',
    'Teachers will use effective questioning to develop students'' algebraic reasoning skills',
    ARRAY['basic multiplication facts', 'understanding of patterns', 'number sense'],
    ARRAY['TEKS 3.5A', 'TEKS 4.5A', 'TEKS 5.4B'],
    'CertBloom Original - Pedagogical Response',
    NOW()
);

-- Verification query
SELECT 'CREATED COMPREHENSIVE 902 QUESTIONS!' as status;
SELECT 
    ci.title,
    LEFT(ci.content, 60) || '...' as content_preview,
    ci.correct_answer,
    ci.cognitive_level,
    ci.difficulty_level,
    c.name as concept_name,
    d.name as domain_name
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
WHERE ci.title IN ('Place Value Error Analysis', 'Fraction Equivalence Visual Models', 'Algebraic Thinking Development')
ORDER BY ci.created_at DESC;
