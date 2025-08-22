-- Enhanced TExES-Style Questions for CertBloom
-- These questions better reflect the actual exam format and complexity

-- More realistic EC-6 Reading questions with complex scenarios
WITH 
  ec6_cert AS (SELECT id FROM public.certifications WHERE name = 'EC-6 Core Subjects'),
  reading_topic AS (
    SELECT t.id FROM public.topics t
    JOIN ec6_cert c ON t.certification_id = c.id
    WHERE t.name = 'Reading Comprehension'
  )
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
) AS question_data(question_text, difficulty_level, explanation, cognitive_level, tags);

-- Enhanced Mathematics questions with real classroom scenarios
WITH 
  ec6_cert AS (SELECT id FROM public.certifications WHERE name = 'EC-6 Core Subjects'),
  math_topic AS (
    SELECT t.id FROM public.topics t
    JOIN ec6_cert c ON t.certification_id = c.id
    WHERE t.name = 'Mathematics Concepts'
  )
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
) AS question_data(question_text, difficulty_level, explanation, cognitive_level, tags);

-- Add answer choices for the enhanced reading question
WITH enhanced_reading_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_text LIKE 'Ms. Rodriguez notices that several students in her third-grade class can decode unfamiliar words%'
)
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  enhanced_reading_q.id,
  choice_data.choice_text,
  choice_data.is_correct,
  choice_data.choice_order,
  choice_data.explanation
FROM enhanced_reading_q,
(VALUES 
  ('Provide more phonics instruction to improve their decoding skills', false, 1, 'The students already decode well; phonics instruction would not address their comprehension difficulties'),
  ('Teach explicit comprehension strategies such as summarizing, questioning, and making connections', true, 2, 'Correct! Students need direct instruction in how to think about and process text meaning'),
  ('Have students read more challenging texts to build their skills', false, 3, 'More difficult texts would likely increase frustration without addressing the underlying comprehension strategy needs'),
  ('Focus primarily on building their sight word vocabulary', false, 4, 'Sight words help with fluency but do not address comprehension strategy deficits')
) AS choice_data(choice_text, is_correct, choice_order, explanation);

-- Add answer choices for the mathematics error analysis question
WITH math_error_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_text LIKE 'A fourth-grade student consistently makes the following error when multiplying: 23 × 14 = 282%'
)
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  math_error_q.id,
  choice_data.choice_text,
  choice_data.is_correct,
  choice_data.choice_order,
  choice_data.explanation
FROM math_error_q,
(VALUES 
  ('Understanding of place value and regrouping', false, 1, 'The student shows good place value understanding by correctly identifying 23 × 10 = 230'),
  ('The distributive property and partial products method', false, 2, 'The student correctly applies the distributive property by breaking 14 into 10 + 4'),
  ('Basic multiplication facts and computational accuracy', true, 3, 'Correct! The error suggests problems with basic fact recall or computational accuracy in 23 × 4'),
  ('Understanding of the multiplication algorithm', false, 4, 'The student demonstrates good understanding of the algorithm by using partial products correctly')
) AS choice_data(choice_text, is_correct, choice_order, explanation);
