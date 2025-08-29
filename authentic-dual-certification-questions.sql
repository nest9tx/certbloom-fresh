-- ========== ENHANCED DUAL-CERTIFICATION QUESTION TEMPLATE ==========
-- This question demonstrates the new architecture serving both Math EC-6 (902) and Core Subjects (391)

-- ========== QUESTION 1: PLACE VALUE MISCONCEPTION ANALYSIS ==========
WITH 
  -- Get certification IDs for dual tagging
  math_ec6_cert AS (
    SELECT id FROM public.certifications 
    WHERE test_code = '902' OR name ILIKE '%Mathematics (902)%'
    LIMIT 1
  ),
  core_subjects_cert AS (
    SELECT id FROM public.certifications 
    WHERE test_code = '391' OR name ILIKE '%Core Subjects EC-6 (391)%'
    LIMIT 1
  ),
  math_topic AS (
    SELECT t.id FROM public.topics t
    JOIN math_ec6_cert c ON t.certification_id = c.id
    WHERE t.name ILIKE '%Number%' OR t.name ILIKE '%Place%' OR t.name = 'Mathematics'
    LIMIT 1
  ),
  inserted_question AS (
    INSERT INTO public.questions (
      certification_id, 
      topic_id, 
      question_text, 
      difficulty_level, 
      explanation, 
      cognitive_level, 
      tags,
      secondary_certification_ids
    )
    SELECT 
      math_ec6_cert.id,
      math_topic.id,
      'Ms. Rodriguez is working with her 2nd grade students on two-digit place value. When she asks students to show 34 using base-ten blocks, most students correctly use 3 tens and 4 ones. However, when she then asks them to write the number that comes right before 34, several students write "33" but say it as "thirty-four minus one equals thirty-three." What does this student response most likely indicate?',
      'medium',
      'This response indicates students understand the sequential nature of numbers and can perform the subtraction algorithm, but they are relying on procedural knowledge rather than true place value understanding. They know the pattern but haven''t internalized that "thirty-three" represents 3 tens and 3 ones. This suggests they need more work connecting the conceptual understanding (what the digits represent) with the procedural knowledge (counting patterns).',
      'analysis',
      ARRAY['place_value', 'student_misconceptions', 'conceptual_understanding', 'number_sense', 'assessment_analysis'],
      ARRAY[core_subjects_cert.id] -- Secondary certification tagging
    FROM math_ec6_cert, core_subjects_cert, math_topic
    RETURNING id
  )
-- Insert answer choices
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  inserted_question.id,
  choice_text,
  is_correct,
  choice_order,
  explanation
FROM inserted_question,
(VALUES 
  ('Students have not yet learned subtraction concepts and need more basic number work', false, 1, 'Incorrect - Students clearly demonstrate subtraction ability; the issue is with place value understanding, not subtraction skills.'),
  ('Students understand place value conceptually but lack fluency with number naming', true, 2, 'Correct - Students can manipulate the quantities (place value) and perform operations, but their language reveals they haven''t fully connected the conceptual representation with the conventional number naming system.'),
  ('Students are confusing the order of operations in multi-step problems', false, 3, 'Incorrect - This is a single-step place value problem, not a multi-step operation. The confusion relates to number representation, not operation sequencing.'),
  ('Students need more practice with base-ten block manipulation before moving to abstract numbers', false, 4, 'Incorrect - Students already show competence with base-ten blocks. The gap is between physical representation and verbal/symbolic representation.')
) AS choices(choice_text, is_correct, choice_order, explanation);

-- ========== QUESTION 2: MULTIPLICATION STRATEGY SELECTION ==========
WITH 
  math_ec6_cert AS (
    SELECT id FROM public.certifications 
    WHERE test_code = '902' OR name ILIKE '%Mathematics (902)%'
    LIMIT 1
  ),
  core_subjects_cert AS (
    SELECT id FROM public.certifications 
    WHERE test_code = '391' OR name ILIKE '%Core Subjects EC-6 (391)%'
    LIMIT 1
  ),
  math_topic AS (
    SELECT t.id FROM public.topics t
    JOIN math_ec6_cert c ON t.certification_id = c.id
    WHERE t.name ILIKE '%Number%' OR t.name ILIKE '%Operation%' OR t.name = 'Mathematics'
    LIMIT 1
  ),
  inserted_question AS (
    INSERT INTO public.questions (
      certification_id, 
      topic_id, 
      question_text, 
      difficulty_level, 
      explanation, 
      cognitive_level, 
      tags,
      secondary_certification_ids
    )
    SELECT 
      math_ec6_cert.id,
      math_topic.id,
      'Mr. Thompson''s 3rd grade class is learning multiplication. He observes that when solving 6 × 8, different students use different strategies: Student A draws 6 groups of 8 dots and counts by ones; Student B skip-counts "8, 16, 24, 32, 40, 48"; Student C uses the array method with 6 rows and 8 columns; Student D immediately recalls "48" from memory. Based on research on mathematical development, which approach should Mr. Thompson encourage MOST for building robust multiplication understanding?',
      'hard',
      'Student C''s array method should be encouraged most because it builds the strongest conceptual foundation. Arrays make the structure of multiplication visible - showing both the grouping aspect (6 groups of 8) and the area model that will support later fraction and algebra work. While memorization (Student D) is important for fluency, it should follow conceptual understanding. The array method bridges concrete manipulation with abstract understanding better than counting strategies.',
      'evaluation',
      ARRAY['multiplication_strategies', 'mathematical_development', 'conceptual_understanding', 'instructional_decisions', 'research_based_teaching'],
      ARRAY[core_subjects_cert.id]
    FROM math_ec6_cert, core_subjects_cert, math_topic
    RETURNING id
  )
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  inserted_question.id,
  choice_text,
  is_correct,
  choice_order,
  explanation
FROM inserted_question,
(VALUES 
  ('Student A''s counting approach because it shows the most careful attention to detail', false, 1, 'Incorrect - While counting shows care, it doesn''t build multiplication concepts efficiently and may reinforce additive rather than multiplicative thinking.'),
  ('Student B''s skip counting because it builds number fluency most directly', false, 2, 'Incorrect - Skip counting is valuable but doesn''t reveal the structure of multiplication or connect to visual/spatial understanding that supports later learning.'),
  ('Student C''s array method because it builds the strongest conceptual foundation', true, 3, 'Correct - Arrays reveal multiplication structure, connect to area models for fractions/algebra, and bridge concrete and abstract understanding most effectively.'),
  ('Student D''s memorization because automaticity is the goal of multiplication instruction', false, 4, 'Incorrect - While fact fluency is important, memorization without conceptual understanding creates fragile knowledge that doesn''t transfer to new situations.')
) AS choices(choice_text, is_correct, choice_order, explanation);

-- ========== QUESTION 3: FRACTION COMPARISON MISCONCEPTION ==========
WITH 
  math_ec6_cert AS (
    SELECT id FROM public.certifications 
    WHERE test_code = '902' OR name ILIKE '%Mathematics (902)%'
    LIMIT 1
  ),
  core_subjects_cert AS (
    SELECT id FROM public.certifications 
    WHERE test_code = '391' OR name ILIKE '%Core Subjects EC-6 (391)%'
    LIMIT 1
  ),
  math_topic AS (
    SELECT t.id FROM public.topics t
    JOIN math_ec6_cert c ON t.certification_id = c.id
    WHERE t.name ILIKE '%Number%' OR t.name ILIKE '%Fraction%' OR t.name = 'Mathematics'
    LIMIT 1
  ),
  inserted_question AS (
    INSERT INTO public.questions (
      certification_id, 
      topic_id, 
      question_text, 
      difficulty_level, 
      explanation, 
      cognitive_level, 
      tags,
      secondary_certification_ids
    )
    SELECT 
      math_ec6_cert.id,
      math_topic.id,
      'Ms. Johnson''s 4th grade students are comparing fractions. When asked whether 1/3 or 1/5 is larger, several students correctly identify 1/3 as larger. However, when asked to compare 2/3 and 2/5, these same students say 2/5 is larger "because 5 is bigger than 3." What instructional strategy would most effectively address this misconception?',
      'medium',
      'Students are applying whole number thinking to fractions, focusing on the denominators as separate numbers rather than understanding them as part sizes. The most effective strategy is using visual models (pie charts, number lines, or area models) to help students see that when pieces are smaller (larger denominator), you need more of them to make the same amount. This builds conceptual understanding of how fraction parts relate to the whole.',
      'application',
      ARRAY['fraction_misconceptions', 'whole_number_thinking', 'visual_models', 'conceptual_understanding', 'instructional_strategies'],
      ARRAY[core_subjects_cert.id]
    FROM math_ec6_cert, core_subjects_cert, math_topic
    RETURNING id
  )
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  inserted_question.id,
  choice_text,
  is_correct,
  choice_order,
  explanation
FROM inserted_question,
(VALUES 
  ('Have students memorize the rule that bigger denominators mean smaller fractions', false, 1, 'Incorrect - Memorizing rules without understanding creates fragile knowledge and doesn''t address the underlying misconception about fraction structure.'),
  ('Use visual models to show how denominator size relates to piece size', true, 2, 'Correct - Visual models help students see that larger denominators create smaller pieces, building conceptual understanding of fraction relationships.'),
  ('Provide more practice problems with fraction comparison until students improve', false, 3, 'Incorrect - More practice without addressing the conceptual misunderstanding will likely reinforce the incorrect whole-number thinking pattern.'),
  ('Teach the cross-multiplication algorithm for comparing fractions', false, 4, 'Incorrect - Algorithms without conceptual foundation don''t help students understand why procedures work and may increase procedural confusion.')
) AS choices(choice_text, is_correct, choice_order, explanation);

-- ========== QUESTION 4: PROBLEM-SOLVING STRATEGY INSTRUCTION ==========
WITH 
  math_ec6_cert AS (
    SELECT id FROM public.certifications 
    WHERE test_code = '902' OR name ILIKE '%Mathematics (902)%'
    LIMIT 1
  ),
  core_subjects_cert AS (
    SELECT id FROM public.certifications 
    WHERE test_code = '391' OR name ILIKE '%Core Subjects EC-6 (391)%'
    LIMIT 1
  ),
  math_topic AS (
    SELECT t.id FROM public.topics t
    JOIN math_ec6_cert c ON t.certification_id = c.id
    WHERE t.name ILIKE '%Problem%' OR t.name ILIKE '%Operation%' OR t.name = 'Mathematics'
    LIMIT 1
  ),
  inserted_question AS (
    INSERT INTO public.questions (
      certification_id, 
      topic_id, 
      question_text, 
      difficulty_level, 
      explanation, 
      cognitive_level, 
      tags,
      secondary_certification_ids
    )
    SELECT 
      math_ec6_cert.id,
      math_topic.id,
      'Mrs. Chen''s 3rd grade students are working on this word problem: "Maria has 24 stickers. She wants to share them equally among her 6 friends. How many stickers will each friend get?" Most students correctly solve it, but Mrs. Chen wants to build deeper problem-solving skills. What is her best next instructional move?',
      'hard',
      'The best instructional move is asking students to create similar problems because this requires them to understand the problem structure, not just the solution process. When students create their own problems, they must understand the relationship between equal sharing, division, and the quantities involved. This builds metacognitive awareness and helps them recognize similar problem types in the future.',
      'synthesis',
      ARRAY['problem_solving', 'mathematical_reasoning', 'metacognition', 'problem_creation', 'instructional_strategies'],
      ARRAY[core_subjects_cert.id]
    FROM math_ec6_cert, core_subjects_cert, math_topic
    RETURNING id
  )
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  inserted_question.id,
  choice_text,
  is_correct,
  choice_order,
  explanation
FROM inserted_question,
(VALUES 
  ('Give students more challenging problems with larger numbers', false, 1, 'Incorrect - Increasing difficulty without building conceptual understanding may overwhelm students and doesn''t develop problem-solving strategies.'),
  ('Ask students to create similar problems for their classmates to solve', true, 2, 'Correct - Creating problems requires deep understanding of problem structure and builds metacognitive awareness about mathematical relationships.'),
  ('Have students solve the problem using different computational methods', false, 3, 'Incorrect - While multiple methods are valuable, this focuses on computation rather than problem-solving strategy development.'),
  ('Move on to multiplication problems since students understand division', false, 4, 'Incorrect - Understanding one operation doesn''t guarantee understanding of its relationship to other operations or problem-solving transfer.')
) AS choices(choice_text, is_correct, choice_order, explanation);

-- ========== QUESTION 5: ASSESSMENT AND STUDENT UNDERSTANDING ==========
WITH 
  math_ec6_cert AS (
    SELECT id FROM public.certifications 
    WHERE test_code = '902' OR name ILIKE '%Mathematics (902)%'
    LIMIT 1
  ),
  core_subjects_cert AS (
    SELECT id FROM public.certifications 
    WHERE test_code = '391' OR name ILIKE '%Core Subjects EC-6 (391)%'
    LIMIT 1
  ),
  math_topic AS (
    SELECT t.id FROM public.topics t
    JOIN math_ec6_cert c ON t.certification_id = c.id
    WHERE t.name ILIKE '%Assessment%' OR t.name ILIKE '%Number%' OR t.name = 'Mathematics'
    LIMIT 1
  ),
  inserted_question AS (
    INSERT INTO public.questions (
      certification_id, 
      topic_id, 
      question_text, 
      difficulty_level, 
      explanation, 
      cognitive_level, 
      tags,
      secondary_certification_ids
    )
    SELECT 
      math_ec6_cert.id,
      math_topic.id,
      'Mr. Davis notices that his 2nd grade student, Alex, consistently solves addition problems like 47 + 25 by writing "47 + 25 = 612" (writing the sum of digits in each column without regrouping). When Mr. Davis asks Alex to check his answer using base-ten blocks, Alex correctly shows 7 tens and 2 ones. What does this most likely indicate about Alex''s mathematical understanding?',
      'hard',
      'This indicates Alex has strong conceptual understanding of place value and addition with manipulatives, but hasn''t connected this understanding to the symbolic algorithm. Alex knows what addition means and can represent it concretely, but doesn''t understand how the written algorithm represents the same process. This is a common developmental gap where conceptual and procedural knowledge exist separately.',
      'analysis',
      ARRAY['place_value', 'algorithm_understanding', 'conceptual_procedural_gap', 'assessment_analysis', 'student_thinking'],
      ARRAY[core_subjects_cert.id]
    FROM math_ec6_cert, core_subjects_cert, math_topic
    RETURNING id
  )
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  inserted_question.id,
  choice_text,
  is_correct,
  choice_order,
  explanation
FROM inserted_question,
(VALUES 
  ('Alex lacks understanding of basic addition concepts and needs more foundational work', false, 1, 'Incorrect - Alex demonstrates solid conceptual understanding with manipulatives, showing good grasp of addition meaning and place value.'),
  ('Alex understands addition conceptually but hasn''t connected it to the written algorithm', true, 2, 'Correct - Alex shows conceptual strength with manipulatives but the symbolic error pattern reveals a gap between conceptual and procedural understanding.'),
  ('Alex is making careless errors and needs to slow down when computing', false, 3, 'Incorrect - The consistent error pattern (612 instead of 72) indicates a systematic misunderstanding, not carelessness.'),
  ('Alex should focus on memorizing addition facts before learning algorithms', false, 4, 'Incorrect - Alex needs to connect existing conceptual knowledge to symbolic procedures, not abandon conceptual approaches for memorization.')
) AS choices(choice_text, is_correct, choice_order, explanation);

-- Add verification query to confirm dual-certification tagging
SELECT 
  q.question_text,
  primary_cert.name as primary_certification,
  secondary_cert.name as secondary_certification,
  q.difficulty_level,
  q.cognitive_level
FROM questions q
JOIN certifications primary_cert ON q.certification_id = primary_cert.id
LEFT JOIN LATERAL unnest(q.secondary_certification_ids) as secondary_id ON true
LEFT JOIN certifications secondary_cert ON secondary_cert.id = secondary_id
WHERE q.created_at > NOW() - INTERVAL '1 hour'
ORDER BY q.created_at DESC;

-- Success message
SELECT '🌟 Five authentic dual-certification Math EC-6 questions created successfully! 🌟' as message;
SELECT 'Questions serve both Math EC-6 (902) and Core Subjects EC-6 (391) certification paths.' as impact;
SELECT 'Ready for AI co-creator replication using this pattern! 🚀' as next_steps;
