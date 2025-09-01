-- SETUP ALL EC-6 CERTIFICATIONS FOR COMPLETE FUNCTIONALITY
-- Run this to set up the basic structure for all certifications

-- First run the session tracking setup
\i create_session_api.sql;

-- 1. Ensure all certifications exist
INSERT INTO certifications (name, test_code, description) VALUES
  ('TExES Core Subjects EC-6 (391)', '391', 'Early Childhood through 6th Grade - All core subjects'),
  ('TExES Core Subjects EC-6: English Language Arts (901)', '901', 'Early Childhood through 6th Grade English Language Arts'),
  ('TExES Core Subjects EC-6: Mathematics (902)', '902', 'Early Childhood through 6th Grade Mathematics'),
  ('TExES Core Subjects EC-6: Social Studies (903)', '903', 'Early Childhood through 6th Grade Social Studies'),
  ('TExES Core Subjects EC-6: Science (904)', '904', 'Early Childhood through 6th Grade Science'),
  ('TExES Core Subjects EC-6: Fine Arts, Health and PE (905)', '905', 'Early Childhood through 6th Grade Fine Arts, Health and Physical Education')
ON CONFLICT (test_code) DO NOTHING;

-- 2. Add domains for each certification that needs them

-- ELA 901 Domains
INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index)
SELECT 
  c.id,
  domain_name,
  domain_code,
  domain_description,
  domain_weight
FROM certifications c,
(VALUES
  ('Reading Comprehension and Assessment', 'RC', 'Reading comprehension strategies, assessment, and instruction for EC-6', 25.0, 1),
  ('Language Arts Instruction', 'LA', 'Language arts curriculum, instruction, and learning processes', 25.0, 2),
  ('Writing and Grammar', 'WG', 'Writing processes, grammar, and language conventions', 25.0, 3),
  ('Literature and Media', 'LM', 'Literature appreciation, analysis, and media literacy', 25.0, 4)
) AS domains(domain_name, domain_code, domain_description, domain_weight, domain_order)
WHERE c.test_code = '901'
ON CONFLICT DO NOTHING;

-- Social Studies 903 Domains  
INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index)
SELECT 
  c.id,
  domain_name,
  domain_code,
  domain_description,
  domain_weight
FROM certifications c,
(VALUES
  ('History and Culture', 'HC', 'Texas, U.S., and world history and cultural understanding', 30.0, 1),
  ('Geography and Environment', 'GE', 'Physical and human geography, environmental awareness', 25.0, 2),
  ('Government and Citizenship', 'GC', 'Government structures, civic ideals, and citizenship', 25.0, 3),
  ('Economics and Society', 'ES', 'Economic principles, social institutions, and decision-making', 20.0, 4)
) AS domains(domain_name, domain_code, domain_description, domain_weight, domain_order)
WHERE c.test_code = '903'
ON CONFLICT DO NOTHING;

-- Science 904 Domains
INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index)
SELECT 
  c.id,
  domain_name,
  domain_code,
  domain_description,
  domain_weight
FROM certifications c,
(VALUES
  ('Physical Science', 'PS', 'Matter, energy, forces, and motion concepts for elementary students', 25.0, 1),
  ('Life Science', 'LS', 'Living organisms, ecosystems, and biological processes', 25.0, 2),
  ('Earth and Space Science', 'ES', 'Earth processes, weather, climate, and space systems', 25.0, 3),
  ('Scientific Inquiry and Process', 'SI', 'Scientific method, investigation, and process skills', 25.0, 4)
) AS domains(domain_name, domain_code, domain_description, domain_weight, domain_order)
WHERE c.test_code = '904'
ON CONFLICT DO NOTHING;

-- EC-6 Composite 391 Domains (covers all subjects)
INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index)
SELECT 
  c.id,
  domain_name,
  domain_code,
  domain_description,
  domain_weight
FROM certifications c,
(VALUES
  ('English Language Arts and Reading', 'ELA', 'Reading, writing, speaking, listening, and language conventions', 30.0, 1),
  ('Mathematics', 'MATH', 'Number concepts, algebra, geometry, measurement, and data analysis', 25.0, 2),
  ('Social Studies', 'SS', 'History, geography, economics, government, and citizenship', 22.5, 3),
  ('Science', 'SCI', 'Physical, life, earth and space science, and scientific inquiry', 22.5, 4)
) AS domains(domain_name, domain_code, domain_description, domain_weight, domain_order)
WHERE c.test_code = '391'
ON CONFLICT DO NOTHING;

-- 3. Create basic concepts for each domain (simplified structure for initial setup)
-- This creates 3-4 concepts per domain to get started

-- ELA 901 Concepts
INSERT INTO concepts (domain_id, name, description, difficulty_level)
SELECT 
  d.id,
  concept_name,
  concept_description,
  2 -- medium difficulty
FROM domains d
JOIN certifications c ON d.certification_id = c.id
CROSS JOIN (VALUES
  ('Phonics and Decoding', 'Phonemic awareness and decoding strategies'),
  ('Reading Fluency', 'Reading rate, accuracy, and expression'),
  ('Vocabulary Development', 'Word meanings and vocabulary instruction'),
  ('Reading Comprehension', 'Understanding and analyzing texts')
) AS concepts(concept_name, concept_description)
WHERE c.test_code = '901' AND d.code = 'RC'
ON CONFLICT DO NOTHING;

-- Add more concepts for other ELA domains...
INSERT INTO concepts (domain_id, name, description, difficulty_level)
SELECT 
  d.id,
  concept_name,
  concept_description,
  2
FROM domains d
JOIN certifications c ON d.certification_id = c.id
CROSS JOIN (VALUES
  ('Writing Process', 'Planning, drafting, revising, and editing'),
  ('Grammar and Usage', 'Language conventions and mechanics'),
  ('Spelling and Conventions', 'Spelling patterns and writing conventions')
) AS concepts(concept_name, concept_description)
WHERE c.test_code = '901' AND d.code = 'WG'
ON CONFLICT DO NOTHING;

-- 4. Create sample content items for practice
INSERT INTO content_items (concept_id, title, content_type, content, estimated_minutes, order_index)
SELECT 
  concepts.id,
  'Practice Session: ' || concepts.name,
  'practice',
  jsonb_build_object(
    'session_type', 'full_concept_practice',
    'description', 'Complete practice questions for ' || concepts.name,
    'target_question_count', 15,
    'estimated_minutes', 20
  ),
  20,
  1
FROM concepts
JOIN domains d ON concepts.domain_id = d.id
JOIN certifications c ON d.certification_id = c.id
WHERE c.test_code IN ('901', '902', '903', '904', '905', '391')
ON CONFLICT DO NOTHING;

-- 5. Show setup status
SELECT 
  'SETUP COMPLETE - STATUS CHECK' as section,
  c.name as certification_name,
  c.test_code,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT concepts.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items,
  CASE 
    WHEN COUNT(DISTINCT d.id) = 0 THEN '❌ No domains'
    WHEN COUNT(DISTINCT concepts.id) = 0 THEN '⚠️ Domains only'
    WHEN COUNT(DISTINCT ci.id) = 0 THEN '⚠️ Missing content'
    ELSE '✅ Ready for use'
  END as status
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
WHERE c.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY c.id, c.name, c.test_code
ORDER BY c.test_code;
