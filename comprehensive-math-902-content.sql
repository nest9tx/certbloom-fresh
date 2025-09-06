-- 🏗️ MATH 902 COMPREHENSIVE LEARNING IMPLEMENTATION
-- Complete redesign with teacher-focused, value-added content

-- ============================================
-- STEP 1: CREATE ENHANCED MATH 902 CONTENT
-- ============================================

-- First, let's create a sample comprehensive learning experience for Place Value
-- This will serve as the template for all other concepts

-- 1. CONCEPT INTRODUCTION MODULE
WITH place_value_concept AS (
  SELECT id FROM concepts WHERE name = 'Place Value and Number Sense' LIMIT 1
)
INSERT INTO learning_modules (
  concept_id, module_type, title, description, content_data,
  learning_objectives, success_criteria, estimated_minutes,
  teaching_tips, common_misconceptions, classroom_applications,
  order_index
)
SELECT 
  pv.id,
  'concept_introduction',
  'Understanding Place Value: Foundation of Number Sense',
  'Comprehensive introduction to place value concepts with teacher preparation focus',
  jsonb_build_object(
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
    ]
  ),
  ARRAY[
    'Explain how position determines digit value in base-10 system',
    'Demonstrate place value relationships using multiple representations',
    'Identify and address common student misconceptions about place value',
    'Apply place value understanding to compare and order numbers'
  ],
  ARRAY[
    'Can explain why 4 in 456 represents 400, not just 4',
    'Uses place value charts and manipulatives effectively',
    'Identifies when students confuse digit size with place value',
    'Demonstrates three different ways to represent the same number'
  ],
  10,
  ARRAY[
    'Use concrete manipulatives before abstract symbols',
    'Connect to money - dollars, dimes, pennies mirror hundreds, tens, ones',
    'Practice with "friendly numbers" like 100, 1000 before complex numbers',
    'Always model thinking aloud when working through examples'
  ],
  ARRAY[
    'Students think 456 has "three 4s" instead of understanding positional value',
    'Confusion between number of digits and actual value (thinking 89 > 100)',
    'Difficulty with zeros as placeholders (reading 405 as "forty-five")',
    'Mixing up place value names (hundreds vs thousandths in decimals)'
  ],
  ARRAY[
    'Daily number talks focusing on place value decomposition',
    'Using student population numbers to practice reading large numbers',
    'Connecting to measurement units (meters, centimeters, millimeters)',
    'Budget planning activities using place value with money'
  ],
  1
FROM place_value_concept pv;

-- 2. TEACHING DEMONSTRATION MODULE
WITH place_value_concept AS (
  SELECT id FROM concepts WHERE name = 'Place Value and Number Sense' LIMIT 1
)
INSERT INTO learning_modules (
  concept_id, module_type, title, description, content_data,
  learning_objectives, success_criteria, estimated_minutes,
  order_index
)
SELECT 
  pv.id,
  'teaching_demonstration',
  'How to Teach Place Value: Classroom Strategies',
  'Step-by-step guide for effective place value instruction',
  jsonb_build_object(
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
      'Have students explain their thinking while building numbers',
      'Use "Would you rather" questions (Would you rather have 4 in tens place or hundreds place?)',
      'Error analysis activities using common misconceptions',
      'Place value scavenger hunts in real-world contexts'
    ]
  ),
  ARRAY[
    'Demonstrate effective concrete-to-abstract teaching progression',
    'Implement differentiation strategies for diverse learners',
    'Design formative assessments that reveal student thinking',
    'Create engaging activities that reinforce place value concepts'
  ],
  ARRAY[
    'Can plan a 5-step place value lesson using manipulatives',
    'Modifies instruction for three different ability levels',
    'Designs assessments that uncover misconceptions',
    'Creates real-world connections that motivate students'
  ],
  12,
  2
FROM place_value_concept pv;

-- 3. INTERACTIVE TUTORIAL MODULE
WITH place_value_concept AS (
  SELECT id FROM concepts WHERE name = 'Place Value and Number Sense' LIMIT 1
)
INSERT INTO learning_modules (
  concept_id, module_type, title, description, content_data,
  learning_objectives, success_criteria, estimated_minutes,
  order_index
)
SELECT 
  pv.id,
  'interactive_tutorial',
  'Guided Practice: Place Value Problem Solving',
  'Step-by-step practice with immediate feedback and coaching',
  jsonb_build_object(
    'practice_scenarios', ARRAY[
      jsonb_build_object(
        'problem', 'In the number 3,847, what is the value of the digit 8?',
        'student_approaches', ARRAY['Just say 8', 'Count the places', 'Use place value chart'],
        'correct_method', 'Identify the position (hundreds place) then multiply: 8 × 100 = 800',
        'common_errors', ARRAY['Saying "8"', 'Saying "80"', 'Forgetting the position name'],
        'teaching_moment', 'Emphasize that position determines value, not the digit itself'
      ),
      jsonb_build_object(
        'problem', 'Compare 2,341 and 2,413. Which is greater?',
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
  ),
  ARRAY[
    'Apply place value knowledge to solve problems systematically',
    'Identify and correct common student errors',
    'Explain mathematical reasoning clearly',
    'Connect mathematical concepts to teaching strategies'
  ],
  ARRAY[
    'Solves place value problems using correct mathematical reasoning',
    'Identifies at least 3 common student misconceptions',
    'Explains solution methods in teacher-appropriate language',
    'Suggests appropriate interventions for student errors'
  ],
  15,
  3
FROM place_value_concept pv;

-- 4. CLASSROOM SCENARIO MODULE
WITH place_value_concept AS (
  SELECT id FROM concepts WHERE name = 'Place Value and Number Sense' LIMIT 1
)
INSERT INTO learning_modules (
  concept_id, module_type, title, description, content_data,
  learning_objectives, success_criteria, estimated_minutes,
  order_index
)
SELECT 
  pv.id,
  'classroom_scenario',
  'Real Classroom Challenge: Mixed Understanding',
  'Navigate a realistic teaching scenario with diverse student needs',
  jsonb_build_object(
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
        'approach', 'Small group intervention while others continue practice',
        'pros', ARRAY['Targeted instruction', 'Doesn''t slow down advanced students'],
        'cons', ARRAY['Hard to manage multiple groups', 'May miss other misconceptions'],
        'teaching_tip', 'Have manipulatives ready for immediate intervention'
      ),
      jsonb_build_object(
        'approach', 'Partner work with strategic pairing',
        'pros', ARRAY['Peer teaching opportunity', 'Builds communication skills'],
        'cons', ARRAY['May reinforce incorrect ideas', 'Advanced students do all the work'],
        'teaching_tip', 'Give specific sentence frames for mathematical discussion'
      )
    ],
    
    'expert_reflection', 'The best approach combines elements: briefly address David''s misconception with manipulatives while the class watches (visual learning for all), then use partner work with sentence frames to support Maria''s language development. This targets multiple needs efficiently.',
    
    'follow_up_strategies', ARRAY[
      'Plan small group reteaching for tomorrow',
      'Create place value center activities for different levels',
      'Send home family letter explaining place value concepts',
      'Use formative assessment to check understanding before moving on'
    ]
  ),
  ARRAY[
    'Analyze diverse student understanding levels in real time',
    'Make instructional decisions based on student needs',
    'Implement differentiation strategies effectively',
    'Reflect on teaching effectiveness and plan improvements'
  ],
  ARRAY[
    'Identifies specific misconceptions and their causes',
    'Chooses appropriate intervention strategies',
    'Explains rationale for instructional decisions',
    'Plans follow-up instruction based on assessment data'
  ],
  18,
  4
FROM place_value_concept pv;

-- 5. MISCONCEPTION ALERT MODULE
WITH place_value_concept AS (
  SELECT id FROM concepts WHERE name = 'Place Value and Number Sense' LIMIT 1
)
INSERT INTO learning_modules (
  concept_id, module_type, title, description, content_data,
  learning_objectives, success_criteria, estimated_minutes,
  order_index
)
SELECT 
  pv.id,
  'misconception_alert',
  'Common Place Value Misconceptions: Recognition & Response',
  'Learn to identify and address the most frequent student errors',
  jsonb_build_object(
    'top_misconceptions', ARRAY[
      jsonb_build_object(
        'misconception', 'Digit-focused thinking: "456 has a 4, a 5, and a 6"',
        'why_it_happens', 'Students focus on individual digits rather than positional value',
        'warning_signs', ARRAY['Uses digit names without place value', 'Struggles with expanded form', 'Cannot explain why 4 in 456 ≠ 4 in 784'],
        'intervention', 'Use base-10 blocks to show 4 hundreds ≠ 4 ones',
        'prevention', 'Always use place value language from the beginning'
      ),
      jsonb_build_object(
        'misconception', 'Size misconception: "89 > 100 because 8 and 9 are big numbers"',
        'why_it_happens', 'Students compare individual digits rather than whole numbers',
        'warning_signs', ARRAY['Compares digits rather than values', 'Struggles with 3-digit vs 2-digit comparisons'],
        'intervention', 'Visual comparison with number lines and base-10 blocks',
        'prevention', 'Emphasize "How many groups of 100?" vs "What digits do you see?"'
      ),
      jsonb_build_object(
        'misconception', 'Zero confusion: Reading 405 as "forty-five"',
        'why_it_happens', 'Students don''t understand zero as a placeholder',
        'warning_signs', ARRAY['Omits zeros when reading numbers', 'Writes numbers without proper placeholders'],
        'intervention', 'Use place value charts with empty boxes for zero positions',
        'prevention', 'Explicitly teach zero as "nothing in this place" with visual supports'
      )
    ],
    'diagnostic_questions', ARRAY[
      'What is the value of 7 in 1,724? (Tests positional understanding)',
      'Which is bigger: 99 or 101? Explain why. (Tests number comparison)',
      'Write 3,045 in words. (Tests zero as placeholder)',
      'Show me 234 with base-10 blocks. (Tests conceptual understanding)'
    ],
    'intervention_strategies', ARRAY[
      'Use concrete manipulatives before moving to abstract',
      'Provide place value charts for visual organization',
      'Practice with "number talks" focusing on place value',
      'Connect to familiar contexts like money'
    ]
  ),
  ARRAY[
    'Recognize common place value misconceptions in student work',
    'Understand the underlying causes of mathematical errors',
    'Implement targeted interventions for specific misconceptions',
    'Design instruction that prevents common errors'
  ],
  ARRAY[
    'Identifies misconceptions from sample student work',
    'Explains why specific errors occur',
    'Selects appropriate intervention strategies',
    'Plans proactive instruction to prevent misconceptions'
  ],
  12,
  5
FROM place_value_concept pv;

-- ============================================
-- STEP 2: CREATE COMPREHENSIVE PRACTICE TESTS
-- ============================================

-- Create a concept-level practice test for Place Value
WITH place_value_concept AS (
  SELECT id FROM concepts WHERE name = 'Place Value and Number Sense' LIMIT 1
)
INSERT INTO practice_tests (
  concept_id, test_type, title, description,
  question_count, time_limit_minutes, passing_score,
  adaptive_rules
)
SELECT 
  pv.id,
  'concept_quiz',
  'Place Value Mastery Assessment',
  'Comprehensive assessment of place value understanding with teacher preparation focus',
  15,
  25,
  80,
  jsonb_build_object(
    'difficulty_progression', true,
    'misconception_focus', true,
    'teaching_context_questions', true,
    'explanation_required', true
  )
FROM place_value_concept pv;

-- ============================================
-- STEP 3: CREATE RICH QUESTION BANK
-- ============================================

-- Get the practice test ID for linking questions
WITH place_value_test AS (
  SELECT pt.id as test_id, pt.concept_id
  FROM practice_tests pt
  JOIN concepts c ON pt.concept_id = c.id
  WHERE c.name = 'Place Value and Number Sense'
  LIMIT 1
)

-- Create comprehensive questions with teaching context
INSERT INTO question_bank (
  concept_id, practice_test_id, question_text, question_type,
  correct_answer, explanation, learning_objective,
  cognitive_level, teaching_context, misconception_addressed,
  difficulty_level, estimated_time_seconds, tags
)
SELECT 
  pvt.concept_id, pvt.test_id,
  'In the number 4,527, what is the value of the digit 5?',
  'multiple_choice',
  'B',
  'The digit 5 is in the hundreds place. Since each position represents a power of 10, the value is 5 × 100 = 500. This demonstrates the fundamental principle that position determines value in our base-10 number system.',
  'Understand that digit value depends on position in base-10 system',
  'Comprehension',
  'This type of question helps teachers assess whether students understand positional value versus digit recognition. Students who answer "5" show digit-focused thinking rather than place value understanding.',
  'Students who focus on the digit itself (5) rather than its positional value (500)',
  2, 90,
  ARRAY['place_value', 'digit_value', 'base_10', 'hundreds_place']
FROM place_value_test pvt

UNION ALL

SELECT 
  pvt.concept_id, pvt.test_id,
  'A teacher shows students the number 2,083. Which student explanation demonstrates the best understanding of place value?',
  'multiple_choice',
  'C',
  'Student C demonstrates complete place value understanding by recognizing both the values of non-zero digits AND the function of zero as a placeholder. This shows comprehensive conceptual understanding.',
  'Evaluate student understanding of place value concepts including zero as placeholder',
  'Evaluation',
  'This question helps teachers recognize different levels of student understanding and identify which explanations indicate mastery versus partial understanding.',
  'Misconceptions about zero as placeholder and incomplete place value understanding',
  4, 120,
  ARRAY['place_value', 'zero_placeholder', 'student_understanding', 'teaching_assessment']
FROM place_value_test pvt

UNION ALL

SELECT 
  pvt.concept_id, pvt.test_id,
  'When comparing 1,234 and 1,243, which teaching strategy would best help students understand why 1,243 is greater?',
  'multiple_choice',
  'A',
  'Starting comparison from the leftmost digit teaches students the systematic approach to number comparison. Since thousands and hundreds are equal, the tens place (4 > 3) determines which number is greater.',
  'Apply place value understanding to compare multi-digit numbers using systematic approach',
  'Application',
  'This question assesses whether teachers understand the importance of teaching systematic number comparison strategies and can identify effective instructional approaches.',
  'Random comparison strategies and focus on rightmost digits instead of systematic left-to-right approach',
  3, 100,
  ARRAY['place_value', 'number_comparison', 'teaching_strategy', 'systematic_thinking']
FROM place_value_test pvt;

-- Add answer choices for the questions
-- Note: We'll use the existing content_items structure for compatibility
WITH question_1 AS (
  SELECT id FROM question_bank 
  WHERE question_text LIKE 'In the number 4,527%' 
  LIMIT 1
),
content_item_1 AS (
  INSERT INTO content_items (
    concept_id, 
    type, 
    title, 
    content,
    difficulty_level,
    created_at
  )
  SELECT 
    qb.concept_id,
    'question',
    'Place Value Digit Recognition',
    qb.question_text,
    qb.difficulty_level,
    NOW()
  FROM question_bank qb
  WHERE qb.id = (SELECT id FROM question_1)
  RETURNING id
)
INSERT INTO answer_choices (content_item_id, question_id, choice_text, is_correct, choice_order, explanation, common_misconception)
SELECT 
  ci.id, q1.id, '5', false, 1,
  'This shows digit-focused thinking rather than place value understanding.',
  'Students focus on the digit itself rather than its positional value'
FROM question_1 q1, content_item_1 ci
UNION ALL
SELECT 
  ci.id, q1.id, '500', true, 2,
  'Correct! The 5 is in the hundreds place, so its value is 5 × 100 = 500.',
  null
FROM question_1 q1, content_item_1 ci
UNION ALL
SELECT 
  ci.id, q1.id, '50', false, 3,
  'This would be correct if 5 were in the tens place, but it''s in the hundreds place.',
  'Confusion about place value positions'
FROM question_1 q1, content_item_1 ci
UNION ALL
SELECT 
  ci.id, q1.id, '5,000', false, 4,
  'This would be correct if 5 were in the thousands place, but it''s in the hundreds place.',
  'Misidentifying place value positions'
FROM question_1 q1, content_item_1 ci;

-- Success indicator
SELECT '🎓 Comprehensive Math 902 Place Value content created!' as status,
       'Rich learning modules with teacher preparation focus' as description,
       'Includes: concept introduction, teaching demo, interactive tutorial, classroom scenarios, misconception alerts, and comprehensive assessment' as features;
