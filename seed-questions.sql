-- Sample Question Bank Data for CertBloom
-- Run this after creating the main schema

-- Insert certifications
INSERT INTO public.certifications (name, test_code, description) VALUES
('EC-6 Core Subjects', '391', 'Early Childhood through 6th Grade - All core subjects'),
('TExES Core Subjects EC-6: English Language Arts', '901', 'Early Childhood through 6th Grade English Language Arts'),
('TExES Core Subjects EC-6: Mathematics', '902', 'Early Childhood through 6th Grade Mathematics'),
('TExES Core Subjects EC-6: Social Studies', '903', 'Early Childhood through 6th Grade Social Studies'),
('TExES Core Subjects EC-6: Science', '904', 'Early Childhood through 6th Grade Science'),
('TExES Core Subjects EC-6: Fine Arts, Health and PE', '905', 'Early Childhood through 6th Grade Fine Arts, Health and PE')
ON CONFLICT (name) DO NOTHING;

-- Get certification IDs for reference
-- Note: In a real implementation, you'd get these IDs dynamically

-- Insert topics for EC-6 Core Subjects
WITH ec6_cert AS (
  SELECT id FROM public.certifications WHERE name = 'EC-6 Core Subjects'
)
INSERT INTO public.topics (certification_id, name, description, weight) 
SELECT 
  ec6_cert.id,
  topic_name,
  topic_description,
  topic_weight
FROM ec6_cert,
(VALUES 
  ('Reading Comprehension', 'Understanding and analyzing written text', 0.25),
  ('Language Arts and Writing', 'Grammar, composition, and language mechanics', 0.20),
  ('Mathematics Concepts', 'Number sense, algebra, and mathematical reasoning', 0.20),
  ('Science Inquiry', 'Scientific method and natural phenomena', 0.15),
  ('Social Studies', 'History, geography, civics, and economics', 0.15),
  ('Child Development', 'Learning theories and developmental stages', 0.05)
) AS topics(topic_name, topic_description, topic_weight)
ON CONFLICT (certification_id, name) DO NOTHING;

-- Insert sample questions for Reading Comprehension
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
    'Which of the following best describes the primary purpose of phonemic awareness instruction in early elementary grades?',
    'medium',
    'Phonemic awareness is the ability to identify and manipulate individual sounds in spoken words, which is foundational for reading development.',
    'comprehension',
    ARRAY['phonics', 'early_reading', 'foundational_skills']
  ),
  (
    'A student consistently struggles with reading fluency despite strong phonics skills. Which intervention would be most appropriate?',
    'hard',
    'Repeated reading practice with appropriate-level texts helps build automaticity and fluency when phonics skills are already established.',
    'application',
    ARRAY['fluency', 'intervention', 'reading_strategies']
  ),
  (
    'According to research, which factor most significantly impacts reading comprehension in elementary students?',
    'medium',
    'Vocabulary knowledge is the strongest predictor of reading comprehension, as students cannot understand what they read if they do not know the meaning of the words.',
    'knowledge',
    ARRAY['comprehension', 'vocabulary', 'research_based']
  ),
  (
    'When implementing guided reading groups, what is the most important consideration for grouping students?',
    'easy',
    'Students should be grouped by similar reading levels to ensure appropriate instructional support and challenge.',
    'application',
    ARRAY['guided_reading', 'grouping', 'instruction']
  ),
  (
    'A teacher notices that a student can decode words accurately but has poor reading comprehension. Which strategy would be most effective?',
    'hard',
    'Teaching explicit comprehension strategies such as predicting, questioning, and summarizing helps students actively engage with text meaning.',
    'analysis',
    ARRAY['comprehension_strategies', 'intervention', 'explicit_instruction']
  )
) AS question_data(question_text, difficulty_level, explanation, cognitive_level, tags);

-- Insert answer choices for the questions
-- Note: This would need to be done with actual question IDs in a real implementation
-- For now, I'll create a simplified version

-- Sample answer choices for phonemic awareness question
WITH phonemic_q AS (
  SELECT q.id FROM public.questions q
  WHERE q.question_text LIKE 'Which of the following best describes the primary purpose of phonemic awareness%'
)
INSERT INTO public.answer_choices (question_id, choice_text, is_correct, choice_order, explanation)
SELECT 
  phonemic_q.id,
  choice_data.choice_text,
  choice_data.is_correct,
  choice_data.choice_order,
  choice_data.explanation
FROM phonemic_q,
(VALUES 
  ('To teach students to recognize letter names and sounds', false, 1, 'This describes phonics instruction, not phonemic awareness'),
  ('To develop students'' ability to identify and manipulate sounds in spoken words', true, 2, 'Correct! Phonemic awareness focuses on manipulating sounds orally, without letters'),
  ('To improve students'' reading fluency and speed', false, 3, 'Fluency comes later in reading development after phonemic awareness is established'),
  ('To expand students'' vocabulary knowledge', false, 4, 'Vocabulary development is separate from phonemic awareness instruction')
) AS choice_data(choice_text, is_correct, choice_order, explanation);

-- Sample questions for Mathematics Concepts
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
    'Which instructional strategy best supports students'' understanding of place value in elementary mathematics?',
    'medium',
    'Using base-ten blocks and other manipulatives helps students visualize the concrete meaning of place value before moving to abstract concepts.',
    'application',
    ARRAY['place_value', 'manipulatives', 'concrete_to_abstract']
  ),
  (
    'A student consistently makes errors when adding multi-digit numbers. What is the most likely cause?',
    'medium',
    'Students often struggle with regrouping (carrying) when they do not fully understand place value concepts.',
    'analysis',
    ARRAY['addition', 'place_value', 'common_errors']
  ),
  (
    'According to research on mathematics instruction, which approach is most effective for developing number sense?',
    'hard',
    'Building flexible thinking about numbers through multiple representations and strategies develops stronger number sense than rote memorization.',
    'evaluation',
    ARRAY['number_sense', 'flexible_thinking', 'research_based']
  )
) AS question_data(question_text, difficulty_level, explanation, cognitive_level, tags);

-- Insert sample reflection prompts
INSERT INTO public.reflection_prompts (prompt_text, category, week_range, active) VALUES
('How did mindfulness practices help you stay focused during your study sessions this week?', 'mindfulness', 'all', true),
('What learning breakthrough or "aha moment" did you experience this week?', 'progress', 'all', true),
('How are you balancing your certification studies with other life responsibilities?', 'balance', 'all', true),
('What aspects of teaching are you most excited to explore once you pass your certification?', 'motivation', 'all', true),
('How has your confidence in your chosen subject area grown this week?', 'growth', 'all', true),
('What study strategies have been most effective for your learning style?', 'progress', 'early', true),
('How do you plan to apply what you''re learning to your future classroom?', 'motivation', 'mid', true),
('Looking back at your journey, what advice would you give to someone just starting their certification path?', 'growth', 'late', true),
('How has your understanding of child development influenced your approach to learning?', 'growth', 'all', true),
('What mindful practices help you manage test anxiety or study stress?', 'mindfulness', 'all', true)
ON CONFLICT DO NOTHING;
