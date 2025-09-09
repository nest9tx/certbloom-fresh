-- 🎯 COMPLETE WORKING EXAMPLE: TExES 902 Math Question
-- Use this as template for all AI-generated questions

-- ============================================
-- STEP 1: GET CONCEPT ID (Run this first)
-- ============================================
SELECT c.id as concept_id, c.name, d.name as domain_name
FROM concepts c
JOIN domains d ON c.domain_id = d.id  
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902' 
  AND c.name = 'Place Value and Number Sense'
LIMIT 1;

-- Copy the concept_id from above result and use it below

-- ============================================
-- STEP 2: INSERT COMPLETE QUESTION
-- ============================================
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
    -- REPLACE THIS WITH ACTUAL CONCEPT ID FROM STEP 1
    (SELECT id FROM concepts c
     JOIN domains d ON c.domain_id = d.id
     JOIN certifications cert ON d.certification_id = cert.id
     WHERE cert.test_code = '902' AND c.name = 'Place Value and Number Sense'),
    'question',
    'Place Value Error Analysis - Zero Placeholder',
    'Mrs. Rodriguez notices that her third-grade student Elena consistently writes "three hundred five" as 3005 instead of 305. When asked to explain, Elena says, "I hear three-hundred so I write 300, then I hear five so I write 05." Which intervention would BEST help Elena understand correct place value representation?

A. Have Elena practice writing numbers in expanded form (300 + 5 = 305)
B. Give Elena worksheets with more number writing practice  
C. Use base-10 blocks to build 305 while saying "three hundreds, zero tens, five ones"
D. Show Elena the correct answer and have her copy it five times',
    'C',
    'Multi-sensory instruction with manipulatives helps students connect concrete representations to abstract notation.',
    'Option C is correct because Elena''s error shows she doesn''t understand that zero serves as a placeholder in the tens position. By using base-10 blocks while verbalizing "three hundreds, zero tens, five ones," Elena can see and hear that the zero holds the tens place when there are no tens. This multi-sensory approach (visual blocks + auditory reinforcement) addresses her specific misconception about place value positions and the role of zero as a placeholder.',
    'In classroom practice, always use manipulatives when students show place value confusion. Have them build numbers with blocks, say each place value aloud, then write the digits. This concrete-to-abstract progression prevents common place value errors.',
    'You''re helping Elena understand a fundamental concept that supports all future math learning. Place value mastery takes time and the right teaching approach.',
    ARRAY[
        'Students add extra zeros when they hear number words like "hundred"',
        'Students don''t understand that zero is a placeholder for empty positions',
        'Students write each number word as separate digits (three=3, hundred=00, five=5)'
    ],
    ARRAY[
        'Build it, say it, write it - always in that order',
        'Zero holds the place when there''s nothing there',
        'Each position has a job - even when it''s empty'
    ],
    'Place value errors are very common in elementary students. This is normal learning development, not a deficit.',
    2,
    3,
    ARRAY['place-value', 'error-analysis', 'manipulatives', 'multi-sensory-learning', 'zero-placeholder'],
    'Application',
    'Teachers will identify place value misconceptions and select appropriate instructional interventions',
    ARRAY['counting by ones, tens, and hundreds', 'understanding of number words'],
    ARRAY['TEKS 2.2A', 'TEKS 3.2A'],
    'CertBloom Original - Place Value Error Analysis',
    NOW()
);

-- ============================================  
-- STEP 3: ADD ANSWER CHOICES
-- ============================================
INSERT INTO answer_choices (content_item_id, choice_letter, choice_text, is_correct, explanation) VALUES
-- Choice A (incorrect - expanded form doesn't address the misconception)
(
    (SELECT id FROM content_items WHERE title = 'Place Value Error Analysis - Zero Placeholder'),
    'A',
    'Have Elena practice writing numbers in expanded form (300 + 5 = 305)',
    false,
    'While expanded form is helpful, it doesn''t address Elena''s specific misconception about zero as a placeholder in the tens position'
),
-- Choice B (incorrect - more practice without conceptual understanding)
(
    (SELECT id FROM content_items WHERE title = 'Place Value Error Analysis - Zero Placeholder'),
    'B',
    'Give Elena worksheets with more number writing practice',
    false,
    'Additional practice without addressing the underlying misconception will likely result in the same errors being repeated'
),
-- Choice C (correct - multi-sensory approach with manipulatives)
(
    (SELECT id FROM content_items WHERE title = 'Place Value Error Analysis - Zero Placeholder'),
    'C',
    'Use base-10 blocks to build 305 while saying "three hundreds, zero tens, five ones"',
    true,
    'This multi-sensory approach helps Elena see and understand that zero holds the tens place, directly addressing her misconception'
),
-- Choice D (incorrect - rote copying without understanding)
(
    (SELECT id FROM content_items WHERE title = 'Place Value Error Analysis - Zero Placeholder'),
    'D',
    'Show Elena the correct answer and have her copy it five times',
    false,
    'Copying the correct answer doesn''t build understanding of why 305 is correct or help Elena avoid the error in the future'
);

-- ============================================
-- VERIFICATION QUERY
-- ============================================
SELECT 
    ci.title,
    ci.correct_answer,
    ci.difficulty_level,
    ci.cognitive_level,
    LEFT(ci.content, 100) || '...' as content_preview,
    array_length(ci.topic_tags, 1) as tag_count,
    COUNT(ac.id) as answer_choice_count
FROM content_items ci
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE ci.title = 'Place Value Error Analysis - Zero Placeholder'
GROUP BY ci.id, ci.title, ci.correct_answer, ci.difficulty_level, ci.cognitive_level, ci.content;

-- Success message
SELECT '🎯 Complete question created successfully!' as status;
SELECT '📊 Includes: Full scenario, 4 answer choices, comprehensive metadata, and wellness features' as features;
SELECT '🔄 Ready to create more questions using this exact pattern!' as next_step;
