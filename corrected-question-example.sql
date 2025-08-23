-- ========== CORRECTED QUESTION 12: ELL SUPPORT FOR COMPREHENSION ==========
WITH 
  ec6_cert AS (
    SELECT id FROM public.certifications WHERE name = 'EC-6 Core Subjects'
  ),
  reading_topic AS (
    SELECT t.id FROM public.topics t
    JOIN ec6_cert c ON t.certification_id = c.id
    WHERE t.name = 'Reading Comprehension'
  ),
  inserted_question AS (
    INSERT INTO public.questions (
      certification_id, topic_id, question_text, difficulty_level, explanation, cognitive_level, tags
    )
    SELECT 
      ec6_cert.id,
      reading_topic.id,
      'Mr. Ortiz teaches a mixed-level second-grade class that includes several English Language Learners. During read-alouds, he pauses to explain idioms like "spill the beans" and "under the weather." Why is this an effective practice?',
      'medium',
      'ELLs often struggle with idiomatic expressions. Explaining figurative language in real time builds cultural and linguistic comprehension, promoting equitable access to meaning.',
      'application',
      ARRAY['ELL_support', 'figurative_language', 'cultural_context', 'comprehension_strategies']
    FROM ec6_cert, reading_topic
    RETURNING id
)
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT inserted_question.id, choice_data.choice_text, choice_data.is_correct, choice_data.choice_order, choice_data.explanation
FROM inserted_question,
(VALUES 
  ('It improves decoding of multisyllabic words', false, 1, 'This strategy supports meaning, not phonics'),
  ('It helps students identify rhyming patterns', false, 2, 'Idioms are unrelated to rhyme awareness'),
  ('It supports comprehension of non-literal language', true, 3, 'Correct! Idiom explanation bridges cultural meaning gaps'),
  ('It teaches students to find the main idea more quickly', false, 4, 'This is not about main idea identification')
) AS choice_data(choice_text, is_correct, choice_order, explanation);
