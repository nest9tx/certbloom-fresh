-- ADD DOMAINS TO EXISTING 905 CERTIFICATION
-- Fixed version to handle database constraints

-- Get the existing 905 certification ID
-- ID: a0e4c3eb-cfde-4e4e-b667-a6dabf5367a7

-- Add Fine Arts, Health and PE domains with all required fields
INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index)
VALUES
  -- Fine Arts domains
  ('a0e4c3eb-cfde-4e4e-b667-a6dabf5367a7', 'Visual Arts', 'VA', 'Drawing, painting, sculpture, and visual design concepts for EC-6 students', 12.5, 1),
  ('a0e4c3eb-cfde-4e4e-b667-a6dabf5367a7', 'Music', 'MU', 'Music theory, performance, listening, and music appreciation for elementary students', 12.5, 2),
  ('a0e4c3eb-cfde-4e4e-b667-a6dabf5367a7', 'Theatre and Drama', 'TD', 'Creative dramatics, storytelling, and performance skills for young learners', 12.5, 3),
  
  -- Health domains
  ('a0e4c3eb-cfde-4e4e-b667-a6dabf5367a7', 'Health Education', 'HE', 'Personal health, nutrition, safety, and wellness concepts for EC-6', 12.5, 4),
  ('a0e4c3eb-cfde-4e4e-b667-a6dabf5367a7', 'Health and Safety', 'HS', 'First aid, emergency procedures, and creating safe learning environments', 12.5, 5),
  
  -- Physical Education domains
  ('a0e4c3eb-cfde-4e4e-b667-a6dabf5367a7', 'Motor Skills and Movement', 'MS', 'Fundamental motor skills, movement patterns, and physical development', 12.5, 6),
  ('a0e4c3eb-cfde-4e4e-b667-a6dabf5367a7', 'Physical Fitness', 'PF', 'Fitness concepts, exercise principles, and lifetime wellness habits', 12.5, 7),
  ('a0e4c3eb-cfde-4e4e-b667-a6dabf5367a7', 'Games and Sports', 'GS', 'Age-appropriate games, sports skills, and cooperative activities', 12.5, 8);

-- Verify the domains were added
SELECT 
  c.name as certification_name,
  c.test_code,
  d.name as domain_name,
  d.description,
  d.order_index
FROM certifications c
JOIN domains d ON d.certification_id = c.id
WHERE c.test_code = '905'
ORDER BY d.order_index;

-- Check dashboard readiness
SELECT 
  'Fine Arts/Health/PE 905' as exam_type,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT concepts.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items,
  COUNT(DISTINCT q.id) as questions
FROM certifications cert
LEFT JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
LEFT JOIN questions q ON q.concept_id = concepts.id
WHERE cert.test_code = '905';
