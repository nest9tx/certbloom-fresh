-- =================================================================
-- Step 2: Insert Authentic Dual-Certification Questions - CORRECTED
-- =================================================================
-- Purpose: To insert 5 high-quality, dual-certification questions
-- for the Math EC-6 (902) certification. This script is now
-- guaranteed to work because the foundational topics have been created.
--
-- This script is safe to run multiple times. ON CONFLICT clauses
-- prevent creating duplicate questions or answer choices.
-- =================================================================

-- ========== QUESTION 1: PLACE VALUE MISCONCEPTION ANALYSIS ==========
WITH 
  math_cert AS (
    SELECT id FROM public.certifications WHERE trim(test_code) = '902' LIMIT 1
  ),
  core_subjects_cert AS (
    SELECT id FROM public.certifications WHERE trim(test_code) = '391' LIMIT 1
  ),
  math_topic AS (
    -- CORRECTED: Uses the exact topic name we created.
    SELECT t.id FROM public.topics t
    JOIN math_cert c ON t.certification_id = c.id
    WHERE t.name = 'Number Concepts and Operations'
    LIMIT 1
  ),
  inserted_question AS (
    INSERT INTO public.questions (
      certification_id, topic_id, question_text, difficulty_level, 
      explanation, cognitive_level, tags, secondary_certification_ids
    )
    SELECT 
      math_cert.id, math_topic.id,
      'Ms. Rodriguez is working with her 2nd grade students on two-digit place value. When she asks students to show 34 using base-ten blocks, most students correctly use 3 tens and 4 ones. However, when she then asks them to write the number that comes right before 34, several students write "33" but say it as "thirty-four minus one equals thirty-three." What does this student response most likely indicate?',
      'medium',
      'This response indicates students understand the sequential nature of numbers and can perform the subtraction algorithm, but they are relying on procedural knowledge rather than true place value understanding. They know the pattern but haven''t internalized that "thirty-three" represents 3 tens and 3 ones. This suggests they need more work connecting the conceptual understanding (what the digits represent) with the procedural knowledge (counting patterns).',
      'analysis',
      ARRAY['place_value', 'student_misconceptions', 'conceptual_understanding', 'number_sense', 'assessment_analysis'],
      ARRAY[core_subjects_cert.id]
    FROM math_cert, core_subjects_cert, math_topic
    ON CONFLICT (question_text) DO NOTHING -- Prevents duplicates
    RETURNING id
  )
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  inserted_question.id, choice_text, is_correct, choice_order, explanation
FROM inserted_question,
(VALUES 
  ('Students have not yet learned subtraction concepts and need more basic number work', false, 1, 'Incorrect - Students clearly demonstrate subtraction ability; the issue is with place value understanding, not subtraction skills.'),
  ('Students understand place value conceptually but lack fluency with number naming', true, 2, 'Correct - Students can manipulate the quantities (place value) and perform operations, but their language reveals they haven''t fully connected the conceptual representation with the conventional number naming system.'),
  ('Students are confusing the order of operations in multi-step problems', false, 3, 'Incorrect - This is a single-step place value problem, not a multi-step operation. The confusion relates to number representation, not operation sequencing.'),
  ('Students need more practice with base-ten block manipulation before moving to abstract numbers', false, 4, 'Incorrect - Students already show competence with base-ten blocks. The gap is between physical representation and verbal/symbolic representation.')
) AS choices(choice_text, is_correct, choice_order, explanation)
ON CONFLICT (question_id, choice_text) DO NOTHING; -- Prevents duplicates

-- ========== QUESTION 2: MULTIPLICATION STRATEGY SELECTION ==========
WITH 
  math_cert AS (
    SELECT id FROM public.certifications WHERE trim(test_code) = '902' LIMIT 1
  ),
  core_subjects_cert AS (
    SELECT id FROM public.certifications WHERE trim(test_code) = '391' LIMIT 1
  ),
  math_topic AS (
    -- CORRECTED: Uses the exact topic name we created.
    SELECT t.id FROM public.topics t
    JOIN math_cert c ON t.certification_id = c.id
    WHERE t.name = 'Number Concepts and Operations'
    LIMIT 1
  ),
  inserted_question AS (
    INSERT INTO public.questions (
      certification_id, topic_id, question_text, difficulty_level, 
      explanation, cognitive_level, tags, secondary_certification_ids
    )
    SELECT 
      math_cert.id, math_topic.id,
      'Mr. Thompson''s 3rd grade class is learning multiplication. He observes that when solving 6 × 8, different students use different strategies: Student A draws 6 groups of 8 dots and counts by ones; Student B skip-counts "8, 16, 24, 32, 40, 48"; Student C uses the array method with 6 rows and 8 columns; Student D immediately recalls "48" from memory. Based on research on mathematical development, which approach should Mr. Thompson encourage MOST for building robust multiplication understanding?',
      'hard',
      'Student C''s array method should be encouraged most because it builds the strongest conceptual foundation. Arrays make the structure of multiplication visible - showing both the grouping aspect (6 groups of 8) and the area model that will support later fraction and algebra work. While memorization (Student D) is important for fluency, it should follow conceptual understanding. The array method bridges concrete manipulation with abstract understanding better than counting strategies.',
      'evaluation',
      ARRAY['multiplication_strategies', 'mathematical_development', 'conceptual_understanding', 'instructional_decisions', 'research_based_teaching'],
      ARRAY[core_subjects_cert.id]
    FROM math_cert, core_subjects_cert, math_topic
    ON CONFLICT (question_text) DO NOTHING
    RETURNING id
  )
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  inserted_question.id, choice_text, is_correct, choice_order, explanation
FROM inserted_question,
(VALUES 
  ('Student A''s counting approach because it shows the most careful attention to detail', false, 1, 'Incorrect - While counting shows care, it doesn''t build multiplication concepts efficiently and may reinforce additive rather than multiplicative thinking.'),
  ('Student B''s skip counting because it builds number fluency most directly', false, 2, 'Incorrect - Skip counting is valuable but doesn''t reveal the structure of multiplication or connect to visual/spatial understanding that supports later learning.'),
  ('Student C''s array method because it builds the strongest conceptual foundation', true, 3, 'Correct - Arrays reveal multiplication structure, connect to area models for fractions/algebra, and bridge concrete and abstract understanding most effectively.'),
  ('Student D''s memorization because automaticity is the goal of multiplication instruction', false, 4, 'Incorrect - While fact fluency is important, memorization without conceptual understanding creates fragile knowledge that doesn''t transfer to new situations.')
) AS choices(choice_text, is_correct, choice_order, explanation)
ON CONFLICT (question_id, choice_text) DO NOTHING;

-- ========== QUESTION 3: FRACTION COMPARISON MISCONCEPTION ==========
WITH 
  math_cert AS (
    SELECT id FROM public.certifications WHERE trim(test_code) = '902' LIMIT 1
  ),
  core_subjects_cert AS (
    SELECT id FROM public.certifications WHERE trim(test_code) = '391' LIMIT 1
  ),
  math_topic AS (
    -- CORRECTED: Uses the exact topic name we created.
    SELECT t.id FROM public.topics t
    JOIN math_cert c ON t.certification_id = c.id
    WHERE t.name = 'Number Concepts and Operations'
    LIMIT 1
  ),
  inserted_question AS (
    INSERT INTO public.questions (
      certification_id, topic_id, question_text, difficulty_level, 
      explanation, cognitive_level, tags, secondary_certification_ids
    )
    SELECT 
      math_cert.id, math_topic.id,
      'Ms. Johnson''s 4th grade students are comparing fractions. When asked whether 1/3 or 1/5 is larger, several students correctly identify 1/3 as larger. However, when asked to compare 2/3 and 2/5, these same students say 2/5 is larger "because 5 is bigger than 3." What instructional strategy would most effectively address this misconception?',
      'medium',
      'Students are applying whole number thinking to fractions, focusing on the denominators as separate numbers rather than understanding them as part sizes. The most effective strategy is using visual models (pie charts, number lines, or area models) to help students see that when pieces are smaller (larger denominator), you need more of them to make the same amount. This builds conceptual understanding of how fraction parts relate to the whole.',
      'analysis',
      ARRAY['fraction_comparison', 'student_misconceptions', 'whole_number_thinking', 'visual_models'],
      ARRAY[core_subjects_cert.id]
    FROM math_cert, core_subjects_cert, math_topic
    ON CONFLICT (question_text) DO NOTHING
    RETURNING id
  )
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  inserted_question.id, choice_text, is_correct, choice_order, explanation
FROM inserted_question,
(VALUES 
  ('Have students memorize the rule that bigger denominators mean smaller fractions', false, 1, 'Incorrect - Memorizing rules without understanding creates fragile knowledge and doesn''t address the underlying misconception about fraction structure.'),
  ('Use visual models to show how denominator size relates to piece size', true, 2, 'Correct - Visual models help students see that larger denominators create smaller pieces, building conceptual understanding of fraction relationships.'),
  ('Teach the cross-multiplication algorithm for comparing fractions', false, 3, 'Incorrect - Algorithms without conceptual foundation don''t help students understand why procedures work and may increase procedural confusion.'),
  ('Drill students on fraction comparison facts for fluency', false, 4, 'Incorrect - Fluency drills do not address the underlying conceptual error and will not lead to transferable knowledge.')
) AS choices(choice_text, is_correct, choice_order, explanation)
ON CONFLICT (question_id, choice_text) DO NOTHING;

-- ========== QUESTION 4: PROBLEM-SOLVING STRATEGY INSTRUCTION ==========
WITH 
  math_cert AS (
    SELECT id FROM public.certifications WHERE trim(test_code) = '902' LIMIT 1
  ),
  core_subjects_cert AS (
    SELECT id FROM public.certifications WHERE trim(test_code) = '391' LIMIT 1
  ),
  math_topic AS (
    -- CORRECTED: Uses the exact topic name we created.
    SELECT t.id FROM public.topics t
    JOIN math_cert c ON t.certification_id = c.id
    WHERE t.name = 'Patterns and Algebraic Reasoning'
    LIMIT 1
  ),
  inserted_question AS (
    INSERT INTO public.questions (
      certification_id, topic_id, question_text, difficulty_level, 
      explanation, cognitive_level, tags, secondary_certification_ids
    )
    SELECT 
      math_cert.id, math_topic.id,
      'Mr. Davis is teaching his 4th-grade students multi-step word problems. He notices that many students rush to calculate and often use the wrong operation. He wants to improve their problem-solving skills, not just their ability to find an answer. Which of the following instructional strategies would be most effective for this purpose?',
      'hard',
      'The most effective strategy is teaching a structured problem-solving framework like UPS (Understand, Plan, Solve). This metacognitive approach forces students to slow down, analyze the problem''s structure, identify what is being asked, and plan their steps before they begin calculating. It shifts the focus from "answer-getting" to a process of reasoning and builds transferable problem-solving skills, which is a core goal of mathematics education.',
      'evaluation',
      ARRAY['problem_solving', 'instructional_strategies', 'metacognition', 'word_problems', 'research_based_teaching'],
      ARRAY[core_subjects_cert.id]
    FROM math_cert, core_subjects_cert, math_topic
    ON CONFLICT (question_text) DO NOTHING
    RETURNING id
  )
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  inserted_question.id, choice_text, is_correct, choice_order, explanation
FROM inserted_question,
(VALUES 
  ('Providing students with worksheets that have keyword charts (e.g., "altogether" means add)', false, 1, 'Incorrect - Keyword strategies are notoriously unreliable and discourage students from actually reading and understanding the problem context. They promote a superficial approach.'),
  ('Teaching a structured problem-solving framework (e.g., Understand, Plan, Solve)', true, 2, 'Correct - This approach builds metacognitive skills, encouraging students to analyze the problem structure and plan their solution path before calculating, which directly addresses the issue.'),
  ('Having students write their own word problems using various operations', false, 3, 'Incorrect - While a useful activity for deepening understanding, it does not directly teach students how to dissect and solve pre-existing, complex problems.'),
  ('Using timed drills on basic math facts to increase calculation speed', false, 4, 'Incorrect - The problem is not calculation speed but operation choice and problem comprehension. Increasing speed could even exacerbate the issue of rushing.')
) AS choices(choice_text, is_correct, choice_order, explanation)
ON CONFLICT (question_id, choice_text) DO NOTHING;

-- ========== QUESTION 5: ASSESSMENT ANALYSIS (SUBTRACTION) ==========
WITH 
  math_cert AS (
    SELECT id FROM public.certifications WHERE trim(test_code) = '902' LIMIT 1
  ),
  core_subjects_cert AS (
    SELECT id FROM public.certifications WHERE trim(test_code) = '391' LIMIT 1
  ),
  math_topic AS (
    -- CORRECTED: Uses the exact topic name we created.
    SELECT t.id FROM public.topics t
    JOIN math_cert c ON t.certification_id = c.id
    WHERE t.name = 'Number Concepts and Operations'
    LIMIT 1
  ),
  inserted_question AS (
    INSERT INTO public.questions (
      certification_id, topic_id, question_text, difficulty_level, 
      explanation, cognitive_level, tags, secondary_certification_ids
    )
    SELECT 
      math_cert.id, math_topic.id,
      'A 3rd-grade student, Maria, solves the subtraction problem 305 - 176 as follows: She subtracts 5-6 and gets 1, subtracts 0-7 and gets 7, and subtracts 3-1 and gets 2, for a final answer of 271. This specific error pattern most likely indicates that Maria:',
      'medium',
      'This error pattern is a classic sign of the "smaller-from-larger" subtraction bug. Instead of regrouping (borrowing), the student subtracts the smaller digit from the larger digit within each column, regardless of their position (e.g., 6-5 instead of 5-6). This shows a fundamental misunderstanding of place value and the regrouping process. She is treating each column as a separate, unrelated problem.',
      'analysis',
      ARRAY['student_misconceptions', 'assessment_analysis', 'subtraction', 'place_value', 'regrouping'],
      ARRAY[core_subjects_cert.id]
    FROM math_cert, core_subjects_cert, math_topic
    ON CONFLICT (question_text) DO NOTHING
    RETURNING id
  )
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  inserted_question.id, choice_text, is_correct, choice_order, explanation
FROM inserted_question,
(VALUES 
  ('Has a solid understanding of regrouping but made a careless calculation error.', false, 1, 'Incorrect - The error is systematic and conceptual, not a careless mistake. It demonstrates a lack of understanding of regrouping.'),
  ('Is subtracting the smaller digit from the larger digit in each column.', true, 2, 'Correct - This accurately describes the error pattern (6-5=1, 7-0=7, 3-1=2) and points to a core conceptual misunderstanding of place value in subtraction.'),
  ('Does not know her basic subtraction facts for numbers under 10.', false, 3, 'Incorrect - She correctly performs the single-digit subtractions (e.g., 6-5), but applies them incorrectly without regrouping. The issue is procedural/conceptual, not fact recall.'),
  ('Is guessing at the answers because the problem is too difficult for her grade level.', false, 4, 'Incorrect - The error has a clear, logical (though incorrect) pattern, indicating a specific misconception rather than random guessing.')
) AS choices(choice_text, is_correct, choice_order, explanation)
ON CONFLICT (question_id, choice_text) DO NOTHING;
