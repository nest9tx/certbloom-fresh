-- Clean Deployment of Enhanced TExES Questions for CertBloom
-- This script safely resets the question bank and deploys enhanced questions with all answer choices
-- Run this once to get a clean, working question bank

-- Step 1: Clean slate - remove all existing questions and answer choices
DELETE FROM public.answer_choices;
DELETE FROM public.questions;

-- Step 2: Reset sequences (using actual sequence names)
-- Find and reset the questions sequence
SELECT setval(pg_get_serial_sequence('public.questions', 'id'), 1, false);
-- Find and reset the answer_choices sequence  
SELECT setval(pg_get_serial_sequence('public.answer_choices', 'id'), 1, false);

-- Step 3: Insert Enhanced Reading Questions with complete answer choices
WITH 
  ec6_cert AS (SELECT id FROM public.certifications WHERE name = 'EC-6 Core Subjects'),
  reading_topic AS (
    SELECT t.id FROM public.topics t
    JOIN ec6_cert c ON t.certification_id = c.id
    WHERE t.name = 'Reading Comprehension'
  ),
  -- Insert questions and capture their IDs
  inserted_reading_questions AS (
    INSERT INTO public.questions (certification_id, topic_id, question_text, difficulty_level, explanation, cognitive_level, tags)
    SELECT 
      ec6_cert.id,
      reading_topic.id,
      question_data.question_text,
      question_data.difficulty_level,
      question_data.explanation,
      question_data.cognitive_level,
      question_data.tags
    FROM ec6_cert, reading_topic,
    (VALUES 
      (
        'Ms. Rodriguez notices that several students in her third-grade class can decode unfamiliar words accurately but struggle to understand the meaning of passages they read. When she asks comprehension questions, they often respond with details that are not relevant to the question asked. Which of the following instructional strategies would be most effective for addressing this issue?',
        'hard',
        'Students who can decode but struggle with comprehension need explicit instruction in comprehension strategies. Teaching students to identify main ideas, make inferences, and connect text to prior knowledge addresses the root cause of their comprehension difficulties.',
        'analysis',
        ARRAY['comprehension_strategies', 'instructional_practices', 'differentiation', 'assessment']
      ),
      (
        'During a guided reading lesson, a teacher observes that a student frequently substitutes words that make sense contextually but are not the actual words in the text (e.g., reading "house" for "home"). This behavior most likely indicates that the student is:',
        'medium',
        'When students substitute meaningful words, they are using semantic cues (meaning) more than graphophonic cues (letter-sound relationships). This suggests they understand the text but need more focus on visual/phonetic accuracy.',
        'analysis',
        ARRAY['reading_behaviors', 'cueing_systems', 'assessment', 'guided_reading']
      ),
      (
        'A kindergarten teacher wants to assess students'' phonological awareness. She asks students to clap for each syllable they hear in spoken words like "butterfly" and "elephant." This assessment is most directly measuring students'' ability to:',
        'medium',
        'Clapping syllables specifically measures syllable segmentation, which is a key component of phonological awareness. This skill is foundational to later phonemic awareness and decoding abilities.',
        'comprehension',
        ARRAY['phonological_awareness', 'assessment', 'early_literacy', 'kindergarten']
      ),
      (
        'A second-grade teacher notices that English Language Learners in her class have difficulty with reading comprehension, particularly with texts that contain idioms and figurative language. To support these students, the teacher should primarily focus on:',
        'hard',
        'ELLs need explicit instruction in cultural context and figurative language that native speakers often acquire naturally. Building background knowledge and teaching cultural references directly supports comprehension.',
        'application',
        ARRAY['ELL_strategies', 'cultural_responsiveness', 'figurative_language', 'background_knowledge']
      ),
      (
        'When implementing a balanced literacy approach in a first-grade classroom, which combination of instructional components should receive the most emphasis during the first quarter of the school year?',
        'hard',
        'Early first grade should emphasize foundational skills: phonemic awareness, phonics, and print concepts, while gradually building fluency and comprehension through read-alouds and shared reading.',
        'evaluation',
        ARRAY['balanced_literacy', 'scope_and_sequence', 'first_grade', 'instructional_planning']
      )
    ) AS question_data(question_text, difficulty_level, explanation, cognitive_level, tags)
    RETURNING id, question_text
  )
-- Insert answer choices for Ms. Rodriguez question
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  q.id,
  choice_data.choice_text,
  choice_data.is_correct,
  choice_data.choice_order,
  choice_data.explanation
FROM inserted_reading_questions q,
(VALUES 
  ('Provide more phonics instruction to improve their decoding skills', false, 1, 'The students already decode well; phonics instruction would not address their comprehension difficulties'),
  ('Teach explicit comprehension strategies such as summarizing, questioning, and making connections', true, 2, 'Correct! Students need direct instruction in how to think about and process text meaning'),
  ('Have students read more challenging texts to build their skills', false, 3, 'More difficult texts would likely increase frustration without addressing the underlying comprehension strategy needs'),
  ('Focus primarily on building their sight word vocabulary', false, 4, 'Sight words help with fluency but do not address comprehension strategy deficits')
) AS choice_data(choice_text, is_correct, choice_order, explanation)
WHERE q.question_text LIKE 'Ms. Rodriguez notices that several students%';

-- Insert answer choices for guided reading question
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  q.id,
  choice_data.choice_text,
  choice_data.is_correct,
  choice_data.choice_order,
  choice_data.explanation
FROM public.questions q,
(VALUES 
  ('Primarily relying on phonetic cues to decode words', false, 1, 'This would indicate strong graphophonic cue use, not semantic cue dominance'),
  ('Using semantic cues more than visual/phonetic cues', true, 2, 'Correct! Meaningful substitutions show the student prioritizes meaning over visual accuracy'),
  ('Having difficulty with reading comprehension', false, 3, 'The substitutions are meaningful, suggesting good comprehension'),
  ('Needing more sight word practice', false, 4, 'This is about cueing system balance, not sight word knowledge')
) AS choice_data(choice_text, is_correct, choice_order, explanation)
WHERE q.question_text LIKE 'During a guided reading lesson%';

-- Insert answer choices for phonological awareness question
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  q.id,
  choice_data.choice_text,
  choice_data.is_correct,
  choice_data.choice_order,
  choice_data.explanation
FROM public.questions q,
(VALUES 
  ('Identify beginning sounds in words', false, 1, 'This would assess phonemic awareness, not syllable segmentation'),
  ('Segment syllables in spoken words', true, 2, 'Correct! Clapping syllables directly measures syllable segmentation ability'),
  ('Recognize rhyming words', false, 3, 'This would assess rhyme awareness, not syllable segmentation'),
  ('Blend individual sounds into words', false, 4, 'This would assess phonemic blending, not syllable awareness')
) AS choice_data(choice_text, is_correct, choice_order, explanation)
WHERE q.question_text LIKE 'A kindergarten teacher wants to assess%';

-- Insert answer choices for ELL question
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  q.id,
  choice_data.choice_text,
  choice_data.is_correct,
  choice_data.choice_order,
  choice_data.explanation
FROM public.questions q,
(VALUES 
  ('Increasing the complexity of texts to challenge students', false, 1, 'More complex texts would increase the figurative language challenge'),
  ('Building background knowledge and teaching cultural context explicitly', true, 2, 'Correct! ELLs need explicit instruction in cultural references and figurative language'),
  ('Focusing on phonics and decoding skills', false, 3, 'The issue is cultural/figurative language, not decoding'),
  ('Providing more independent reading time', false, 4, 'Independent reading won''t address the cultural knowledge gap')
) AS choice_data(choice_text, is_correct, choice_order, explanation)
WHERE q.question_text LIKE 'A second-grade teacher notices that English Language Learners%';

-- Insert answer choices for balanced literacy question
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  q.id,
  choice_data.choice_text,
  choice_data.is_correct,
  choice_data.choice_order,
  choice_data.explanation
FROM public.questions q,
(VALUES 
  ('Independent reading and writing workshop', false, 1, 'These are important but require foundational skills first'),
  ('Phonemic awareness, phonics, and print concepts', true, 2, 'Correct! Early first grade needs strong foundational skill emphasis'),
  ('Guided reading and literature circles', false, 3, 'These require more developed reading skills'),
  ('Vocabulary development and comprehension strategies', false, 4, 'Important but secondary to foundational skills in early first grade')
) AS choice_data(choice_text, is_correct, choice_order, explanation)
WHERE q.question_text LIKE 'When implementing a balanced literacy approach%';

-- Step 4: Insert Enhanced Mathematics Questions with complete answer choices
WITH 
  ec6_cert AS (SELECT id FROM public.certifications WHERE name = 'EC-6 Core Subjects'),
  math_topic AS (
    SELECT t.id FROM public.topics t
    JOIN ec6_cert c ON t.certification_id = c.id
    WHERE t.name = 'Mathematics Concepts'
  ),
  -- Insert math questions and capture their IDs
  inserted_math_questions AS (
    INSERT INTO public.questions (certification_id, topic_id, question_text, difficulty_level, explanation, cognitive_level, tags)
    SELECT 
      ec6_cert.id,
      math_topic.id,
      question_data.question_text,
      question_data.difficulty_level,
      question_data.explanation,
      question_data.cognitive_level,
      question_data.tags
    FROM ec6_cert, math_topic,
    (VALUES 
      (
        'A fourth-grade student consistently makes the following error when multiplying: 23 × 14 = 282 (instead of 322). The student shows their work: 23 × 4 = 92, 23 × 10 = 230, and 92 + 230 = 282. This error pattern suggests that the student needs additional instruction in:',
        'hard',
        'The student correctly applies the distributive property but makes an error in basic multiplication facts (23 × 4 should be 92, but they may have made a calculation error) or in adding the partial products. The systematic nature suggests a need for fact fluency reinforcement.',
        'analysis',
        ARRAY['error_analysis', 'multiplication', 'fact_fluency', 'place_value']
      ),
      (
        'Ms. Chen wants to develop her students'' number sense and mathematical reasoning. She presents this problem: "Sarah has 47 stickers. She gives away some stickers and now has 23 left. About how many stickers did she give away?" Which response indicates the strongest number sense?',
        'medium',
        'Estimating strategies show flexible thinking about numbers. A student who says "about 25 because 47 is close to 50 and 23 is close to 25, and 50 - 25 = 25" demonstrates number sense and mental math strategies.',
        'evaluation',
        ARRAY['number_sense', 'estimation', 'mental_math', 'problem_solving']
      ),
      (
        'A teacher observes students working on fraction problems. One student explains: "1/4 is bigger than 1/3 because 4 is bigger than 3." This misconception indicates that the student needs instruction focused on:',
        'medium',
        'This common misconception shows the student is applying whole number thinking to fractions. They need concrete experiences with fraction models to understand that the denominator represents the number of equal parts, and more parts means smaller pieces.',
        'analysis',
        ARRAY['fraction_misconceptions', 'conceptual_understanding', 'manipulatives', 'number_sense']
      )
    ) AS question_data(question_text, difficulty_level, explanation, cognitive_level, tags)
    RETURNING id, question_text
  )
-- Insert answer choices for multiplication error question
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  q.id,
  choice_data.choice_text,
  choice_data.is_correct,
  choice_data.choice_order,
  choice_data.explanation
FROM public.questions q,
(VALUES 
  ('Understanding of place value and regrouping', false, 1, 'The student shows good place value understanding by correctly identifying 23 × 10 = 230'),
  ('The distributive property and partial products method', false, 2, 'The student correctly applies the distributive property by breaking 14 into 10 + 4'),
  ('Basic multiplication facts and computational accuracy', true, 3, 'Correct! The error suggests problems with basic fact recall or computational accuracy in 23 × 4'),
  ('Understanding of the multiplication algorithm', false, 4, 'The student demonstrates good understanding of the algorithm by using partial products correctly')
) AS choice_data(choice_text, is_correct, choice_order, explanation)
WHERE q.question_text LIKE 'A fourth-grade student consistently makes%';

-- Insert answer choices for number sense question
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  q.id,
  choice_data.choice_text,
  choice_data.is_correct,
  choice_data.choice_order,
  choice_data.explanation
FROM public.questions q,
(VALUES 
  ('"I need to subtract: 47 - 23 = 24"', false, 1, 'Correct calculation but shows procedural thinking rather than number sense'),
  ('"About 25, because 47 is close to 50 and 23 is close to 25, so 50 - 25 = 25"', true, 2, 'Correct! This shows flexible number sense and estimation strategies'),
  ('"Let me count backwards from 47 to 23"', false, 3, 'This is a valid strategy but doesn''t demonstrate number sense flexibility'),
  ('"I''ll use a number line to find the difference"', false, 4, 'Good strategy but doesn''t show the mental math flexibility of number sense')
) AS choice_data(choice_text, is_correct, choice_order, explanation)
WHERE q.question_text LIKE 'Ms. Chen wants to develop%';

-- Insert answer choices for fraction misconception question
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  q.id,
  choice_data.choice_text,
  choice_data.is_correct,
  choice_data.choice_order,
  choice_data.explanation
FROM public.questions q,
(VALUES 
  ('Converting fractions to decimals for comparison', false, 1, 'This is procedural and doesn''t address the underlying misconception'),
  ('Understanding that denominators represent equal parts of a whole', true, 2, 'Correct! The student needs to understand that more parts means smaller pieces'),
  ('Memorizing fraction equivalencies', false, 3, 'Memorization won''t fix the conceptual misunderstanding'),
  ('Learning the cross-multiplication method', false, 4, 'This is algorithmic and doesn''t address the conceptual error')
) AS choice_data(choice_text, is_correct, choice_order, explanation)
WHERE q.question_text LIKE 'A teacher observes students working on fraction problems%';

-- Step 5: Verify deployment
SELECT 
  'Deployment Summary' as status,
  COUNT(q.id) as total_questions,
  COUNT(ac.id) as total_answer_choices,
  ROUND(COUNT(ac.id)::numeric / COUNT(DISTINCT q.id), 2) as avg_choices_per_question
FROM public.questions q
LEFT JOIN public.answer_choices ac ON q.id = ac.question_id;
