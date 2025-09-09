-- 🎯 LEARNING MODULE CONTENT BUILDER FOR 902 MATH
-- This builds the rich educational content for Enhanced Learning modules
-- Separate from practice questions - these are the teaching modules

-- ============================================
-- STEP 1: CHECK EXISTING LEARNING MODULES
-- ============================================
SELECT 
    lm.id,
    lm.module_type,
    lm.title,
    lm.estimated_minutes,
    lm.order_index,
    c.name as concept_name,
    CASE 
        WHEN lm.content_data IS NULL THEN '❌ Empty'
        WHEN jsonb_typeof(lm.content_data) = 'object' THEN '✅ Has Content'
        ELSE '⚠️ Basic'
    END as content_status
FROM learning_modules lm
JOIN concepts c ON lm.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902'
ORDER BY c.name, lm.order_index;

-- ============================================
-- STEP 2: BUILD COMPREHENSIVE CONTENT FOR PLACE VALUE MODULES
-- ============================================

-- MODULE 1: Understanding Place Value (Concept Introduction)
UPDATE learning_modules 
SET content_data = jsonb_build_object(
    'core_explanation', 'Place value is the cornerstone of mathematical understanding. Each digit in a number has a value determined by its position, representing powers of 10. This concept forms the foundation for all arithmetic operations and number relationships.',
    
    'key_principles', ARRAY[
        'What is place value and why it matters for student success',
        'Base-10 system fundamentals that students must master', 
        'Reading and writing numbers with confidence',
        'Comparing numbers using systematic place value strategies'
    ],
    
    'visual_aids', ARRAY[
        'Place value chart with powers of 10',
        'Base-10 blocks demonstration',
        'Number line visualization',
        'Real-world examples (money, measurement)'
    ],
    
    'key_vocabulary', ARRAY[
        'place value', 'digit', 'position', 'base-10 system',
        'ones place', 'tens place', 'hundreds place', 'thousands place',
        'decimal point', 'place holder', 'expanded form', 'standard form'
    ],
    
    'interactive_elements', ARRAY[
        'Build numbers with virtual base-10 blocks',
        'Compare numbers using place value reasoning',
        'Identify place value errors in student work',
        'Practice reading large numbers aloud'
    ]
),
teaching_tips = ARRAY[
    'Use concrete manipulatives before abstract symbols',
    'Connect to money - dollars, dimes, pennies mirror hundreds, tens, ones',
    'Practice with "friendly numbers" like 100, 1000 before complex numbers',
    'Always model thinking aloud when working through examples'
],
common_misconceptions = ARRAY[
    'Students think 456 has "three 4s" instead of understanding positional value',
    'Confusion between number of digits and actual value (thinking 89 > 100)',
    'Difficulty with zeros as placeholders (reading 405 as "forty-five")',
    'Mixing up place value names (hundreds vs thousandths in decimals)'
],
classroom_applications = ARRAY[
    'Daily number talks focusing on place value decomposition',
    'Using student population numbers to practice reading large numbers',
    'Connecting to measurement units (meters, centimeters, millimeters)',
    'Budget planning activities using place value with money'
]
WHERE module_type = 'concept_introduction' 
AND concept_id = (
    SELECT c.id FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    JOIN certifications cert ON d.certification_id = cert.id
    WHERE cert.test_code = '902' AND c.name = 'Place Value and Number Sense'
);

-- MODULE 2: How to Teach Place Value (Teaching Demonstration)
UPDATE learning_modules 
SET content_data = jsonb_build_object(
    'lesson_structure', jsonb_build_object(
        'warm_up', 'Number of the day routine with place value focus',
        'introduction', 'Connect to prior knowledge of counting and grouping',
        'guided_practice', 'Use base-10 blocks to build numbers together',
        'independent_practice', 'Students create their own numbers and explain values',
        'closure', 'Exit ticket with place value quick check'
    ),
    
    'teaching_sequence', ARRAY[
        '1. Start with concrete (base-10 blocks, bundles of sticks)',
        '2. Move to pictorial (drawings, place value charts)',
        '3. Progress to abstract (numerals and symbols)',
        '4. Connect to real-world applications'
    ],
    
    'differentiation_strategies', ARRAY[
        'Below grade level: Focus on 2-digit numbers with manipulatives',
        'On grade level: Practice with 3-4 digit numbers and place value charts',
        'Above grade level: Explore decimal place values and very large numbers',
        'ELL students: Emphasize vocabulary with visual supports'
    ],
    
    'assessment_ideas', ARRAY[
        'Have students build 347 with blocks and explain each digit',
        'Ask students to write the number that has 5 hundreds, 0 tens, 8 ones',
        'Show 234 and ask "What if we moved the 2 to the ones place?"',
        'Use exit tickets: "What does the 6 represent in 1,634?"'
    ],
    
    'engagement_activities', ARRAY[
        'Have students explain their thinking while building numbers',
        'Use "Would you rather" questions (Would you rather have 4 in tens place or hundreds place?)',
        'Error analysis activities using common misconceptions',
        'Place value scavenger hunts in real-world contexts'
    ]
)
WHERE module_type = 'teaching_demonstration' 
AND concept_id = (
    SELECT c.id FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    JOIN certifications cert ON d.certification_id = cert.id
    WHERE cert.test_code = '902' AND c.name = 'Place Value and Number Sense'
);

-- MODULE 3: Interactive Practice (Guided Practice)
UPDATE learning_modules 
SET content_data = jsonb_build_object(
    'practice_scenarios', ARRAY[
        jsonb_build_object(
            'scenario', 'Student builds 1,234 with blocks correctly but reads it as "one thousand, two hundred, thirty-four"',
            'student_approaches', ARRAY['Count all blocks', 'Read left to right', 'Use place value'],
            'correct_method', 'Read systematically: 1 thousand, 2 hundreds, 3 tens, 4 ones',
            'common_errors', ARRAY['Counting instead of place value', 'Missing place value language'],
            'teaching_moment', 'Emphasize the language of place value positions'
        ),
        jsonb_build_object(
            'scenario', 'Students compare 1,432 and 1,341',
            'student_approaches', ARRAY['Compare last digits', 'Compare first digits', 'Use place value'],
            'correct_method', 'Compare from left to right: thousands same, hundreds same, tens different (4 > 1)',
            'common_errors', ARRAY['Looking at ones place first', 'Thinking 413 > 341 so second number bigger'],
            'teaching_moment', 'Always start comparing from the leftmost (highest) place value'
        )
    ],
    
    'guided_questions', ARRAY[
        'What place is this digit in?',
        'How much is one group worth in this position?',
        'How many groups do we have?',
        'What is the total value?',
        'How would you explain this to a student?'
    ],
    
    'reflection_prompts', ARRAY[
        'What misconception might lead to this error?',
        'How would you help a student who made this mistake?',
        'What visual aid would be most helpful here?',
        'How does this connect to real-world situations?'
    ]
)
WHERE module_type = 'interactive_practice' 
AND concept_id = (
    SELECT c.id FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    JOIN certifications cert ON d.certification_id = cert.id
    WHERE cert.test_code = '902' AND c.name = 'Place Value and Number Sense'
);

-- MODULE 4: Real Classroom Challenge (Classroom Scenario)
UPDATE learning_modules 
SET content_data = jsonb_build_object(
    'scenario_setup', 'You are teaching place value to your 3rd-grade class. During independent practice, you notice: 
    
    • Sarah consistently says 456 has "four hundreds, five tens, and six ones" (correct)
    • Marcus says 456 has "four, five, and six" (missing place value language)
    • Aisha writes 456 as "400 + 50 + 6" (correct expanded form)
    • David insists that 89 is bigger than 100 because "eight and nine are bigger numbers"
    • Maria (ELL) understands the concept but struggles with place value vocabulary',
    
    'your_task', 'You have 10 minutes left in the lesson. How do you address these different needs while keeping all students engaged?',
    
    'response_options', ARRAY[
        jsonb_build_object(
            'approach', 'Address David''s misconception with whole class',
            'pros', ARRAY['Helps everyone understand', 'Prevents spread of misconception'],
            'cons', ARRAY['May embarrass David', 'Other students already understand'],
            'teaching_tip', 'Use base-10 blocks to show 89 vs 100 visually'
        ),
        jsonb_build_object(
            'approach', 'Quick partner sharing - stronger students help those struggling',
            'pros', ARRAY['Peer teaching', 'Everyone stays engaged', 'Builds confidence'],
            'cons', ARRAY['May not address specific misconceptions', 'Relies on student explanations'],
            'teaching_tip', 'Pair Marcus with Sarah, David with Aisha'
        ),
        jsonb_build_object(
            'approach', 'Mini-lesson on place value language for whole class',
            'pros', ARRAY['Addresses vocabulary needs', 'Reinforces for everyone'],
            'cons', ARRAY['May be too much for some', 'Time pressure'],
            'teaching_tip', 'Focus on Maria''s needs while helping everyone'
        )
    ],
    
    'follow_up_activities', ARRAY[
        'Send home family letter explaining place value concepts',
        'Create differentiated practice for next lesson',
        'Plan small group work targeting specific misconceptions',
        'Use formative assessment to check understanding before moving on'
    ]
)
WHERE module_type = 'classroom_scenario' 
AND concept_id = (
    SELECT c.id FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    JOIN certifications cert ON d.certification_id = cert.id
    WHERE cert.test_code = '902' AND c.name = 'Place Value and Number Sense'
);

-- MODULE 5: Common Misconceptions (Misconception Alert)
UPDATE learning_modules 
SET content_data = jsonb_build_object(
    'misconception_categories', ARRAY[
        jsonb_build_object(
            'type', 'Zero as Placeholder',
            'student_error', 'Reading 405 as "forty-five"',
            'why_it_happens', 'Students ignore the zero and read only visible digits',
            'intervention', 'Use place value charts to show zero holding the tens place',
            'prevention', 'Emphasize that every position has a value, even when it''s zero'
        ),
        jsonb_build_object(
            'type', 'Number Size Confusion',
            'student_error', 'Thinking 89 > 100 because "8 and 9 are big numbers"',
            'why_it_happens', 'Students focus on digit size rather than place value',
            'intervention', 'Use base-10 blocks to show actual quantities',
            'prevention', 'Always connect digits to actual amounts they represent'
        ),
        jsonb_build_object(
            'type', 'Place Value Language',
            'student_error', 'Saying 456 has "four, five, six" instead of place value names',
            'why_it_happens', 'Students see digits as separate numbers, not positions',
            'intervention', 'Model proper place value language consistently',
            'prevention', 'Require students to use place value vocabulary in explanations'
        )
    ],
    
    'diagnostic_questions', ARRAY[
        'What number has 3 hundreds, 0 tens, and 5 ones? (Tests zero understanding)',
        'Which is larger: 67 or 102? Explain your thinking. (Tests number comparison)',
        'Write 3,045 in words. (Tests zero as placeholder)',
        'Show me 234 with base-10 blocks. (Tests conceptual understanding)'
    ],
    
    'intervention_strategies', ARRAY[
        'Use concrete manipulatives before moving to abstract',
        'Provide place value charts for visual organization',
        'Practice with "number talks" focusing on place value',
        'Connect to familiar contexts like money'
    ]
)
WHERE module_type = 'misconception_alert' 
AND concept_id = (
    SELECT c.id FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    JOIN certifications cert ON d.certification_id = cert.id
    WHERE cert.test_code = '902' AND c.name = 'Place Value and Number Sense'
);

-- ============================================
-- STEP 3: VERIFICATION QUERY
-- ============================================
SELECT 
    lm.module_type,
    lm.title,
    lm.estimated_minutes,
    CASE 
        WHEN lm.content_data IS NULL THEN '❌ Empty'
        WHEN jsonb_typeof(lm.content_data) = 'object' AND jsonb_object_keys_length(lm.content_data) > 3 THEN '✅ Rich Content'
        WHEN jsonb_typeof(lm.content_data) = 'object' THEN '⚠️ Basic Content'
        ELSE '❌ No Content'
    END as content_status,
    array_length(lm.teaching_tips, 1) as teaching_tips_count,
    array_length(lm.common_misconceptions, 1) as misconceptions_count
FROM learning_modules lm
JOIN concepts c ON lm.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE cert.test_code = '902' AND c.name = 'Place Value and Number Sense'
ORDER BY lm.order_index;

-- Success message
SELECT '🎯 Place Value learning modules enhanced with comprehensive content!' as status;
SELECT '📚 Each module now includes: rich content, teaching strategies, misconceptions, and applications' as features;
SELECT '🔄 Ready to replicate this pattern for other 902 concepts!' as next_step;
