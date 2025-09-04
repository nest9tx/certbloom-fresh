-- Enhanced Content Structure for Better Learning Flow
-- This creates richer, more comprehensive content for each concept

-- First, let's enhance the Place Value concept with better content structure
UPDATE content_items 
SET content = jsonb_build_object(
  'sections', ARRAY[
    'Place value is the foundation of our number system. Each digit in a number has a specific value based on its position.',
    'Understanding place value helps students recognize that the digit 4 in 456 represents 400 (4 hundreds), not just 4.',
    'Common misconceptions include thinking that larger digits always represent larger values, regardless of position.',
    'Key teaching strategy: Use base-10 blocks, place value charts, and real-world examples like money to make abstract concepts concrete.'
  ],
  'key_concepts', ARRAY[
    'Each position represents a power of 10',
    'Reading numbers from left (largest place value) to right',
    'Comparing numbers by examining place values systematically',
    'Rounding using place value understanding'
  ],
  'teaching_strategies', ARRAY[
    'Use manipulatives like base-10 blocks for visual representation',
    'Create place value charts for organizing thinking',
    'Connect to money concepts (dollars, dimes, pennies)',
    'Practice with real-world examples (population numbers, distances)'
  ],
  'common_misconceptions', ARRAY[
    'Students think 456 has "three 4s" instead of understanding positional value',
    'Confusion between number of digits and actual value',
    'Difficulty with zeros as placeholders (e.g., 405)',
    'Mixing up place value names (hundreds vs thousandths)'
  ]
)
WHERE title = 'Understanding Place Value' 
  AND type = 'text_explanation';

-- Add comprehensive practice questions as content items
INSERT INTO content_items (
  id,
  concept_id,
  type,
  title,
  content,
  order_index,
  estimated_minutes,
  is_required
)
SELECT 
  gen_random_uuid(),
  c.id,
  'question',
  'Place Value Identification',
  jsonb_build_object(
    'question', 'In the number 3,574, what is the value of the digit 5?',
    'choices', ARRAY[
      '5',
      '50', 
      '500',
      '5,000'
    ],
    'correct_answer', 3,
    'explanation', 'The digit 5 is in the hundreds place, so its value is 5 × 100 = 500. Position determines value in our base-10 number system.'
  ),
  3,
  2,
  true
FROM concepts c 
WHERE c.name = 'Place Value and Number Sense'
ON CONFLICT DO NOTHING;

-- Add another practice question
INSERT INTO content_items (
  id,
  concept_id,
  type,
  title,
  content,
  order_index,
  estimated_minutes,
  is_required
)
SELECT 
  gen_random_uuid(),
  c.id,
  'question',
  'Comparing Numbers Using Place Value',
  jsonb_build_object(
    'question', 'A teacher wants to help students compare 2,341 and 2,413. Which place value should students examine first?',
    'choices', ARRAY[
      'Ones place',
      'Tens place',
      'Hundreds place', 
      'Thousands place'
    ],
    'correct_answer', 3,
    'explanation', 'When comparing numbers, start with the highest place value (leftmost). Both numbers have 2 thousands, so examine hundreds: 3 < 4, therefore 2,341 < 2,413.'
  ),
  4,
  3,
  true
FROM concepts c 
WHERE c.name = 'Place Value and Number Sense'
ON CONFLICT DO NOTHING;

-- Add teaching scenario question
INSERT INTO content_items (
  id,
  concept_id,
  type,
  title,
  content,
  order_index,
  estimated_minutes,
  is_required
)
SELECT 
  gen_random_uuid(),
  c.id,
  'question',
  'Place Value Teaching Scenario',
  jsonb_build_object(
    'question', 'A student consistently reads 405 as "forty-five." What is the most likely cause of this error, and how should the teacher address it?',
    'choices', ARRAY[
      'The student cannot read numbers; provide basic counting practice',
      'The student does not understand that 0 is a placeholder; use place value charts to show empty positions',
      'The student is rushing; tell them to slow down',
      'The student needs more addition practice with zeros'
    ],
    'correct_answer', 2,
    'explanation', 'The student is ignoring the zero placeholder, reading only the visible digits. Use place value charts to explicitly show that 0 holds the tens place, making the number four hundred five, not forty-five.'
  ),
  5,
  4,
  true
FROM concepts c 
WHERE c.name = 'Place Value and Number Sense'
ON CONFLICT DO NOTHING;

-- Add real-world application question
INSERT INTO content_items (
  id,
  concept_id,
  type,
  title,
  content,
  order_index,
  estimated_minutes,
  is_required
)
SELECT 
  gen_random_uuid(),
  c.id,
  'question',
  'Real-World Place Value Application',
  jsonb_build_object(
    'question', 'Students are comparing city populations: Austin (964,254) and Fort Worth (918,915). Which teaching approach best helps students understand which city is larger?',
    'choices', ARRAY[
      'Have students count each population number aloud',
      'Guide students to compare place values starting from the left: both have 9 hundred thousands, so compare ten thousands place',
      'Tell students that Austin is bigger because it comes first alphabetically',
      'Have students round both numbers to the nearest thousand first'
    ],
    'correct_answer', 2,
    'explanation', 'Systematic place value comparison is the most reliable method. Starting from the left: both have 9 hundred thousands, both have 1 ten thousand (actually Austin has 6, Fort Worth has 1), so Austin > Fort Worth. This teaches the algorithm they can use for any comparison.'
  ),
  6,
  3,
  true
FROM concepts c 
WHERE c.name = 'Place Value and Number Sense'
ON CONFLICT DO NOTHING;
