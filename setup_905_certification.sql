-- SETUP TExES FINE ARTS EC-6 (905) CERTIFICATION
-- Run this in Supabase SQL Editor to add Fine Arts 905

-- 1. First check if 905 already exists
SELECT id, name, test_code, description 
FROM certifications 
WHERE test_code = '905' OR name ILIKE '%fine arts%';

-- 2. Insert Fine Arts EC-6 certification if it doesn't exist
INSERT INTO certifications (name, test_code, description)
SELECT 
  'TExES Fine Arts EC-6',
  '905',
  'Texas Examinations of Educator Standards (TExES) Fine Arts Early Childhood through Grade 6 certification exam'
WHERE NOT EXISTS (
  SELECT 1 FROM certifications WHERE test_code = '905'
);

-- 3. Get the certification ID for domains setup
SELECT id, name, test_code 
FROM certifications 
WHERE test_code = '905';

-- 4. Add Fine Arts domains (based on TExES 905 competencies)
WITH cert_id AS (
  SELECT id FROM certifications WHERE test_code = '905'
)
INSERT INTO domains (certification_id, name, description, order_index)
SELECT 
  cert_id.id,
  domain_name,
  domain_description,
  domain_order
FROM cert_id,
(VALUES
  ('Creative Expression and Communication', 'Understanding and applying creative processes in visual arts, music, theatre, and dance', 1),
  ('Art History and Cultural Context', 'Knowledge of art history, cultural contexts, and the role of fine arts in society', 2),
  ('Fine Arts Pedagogy and Assessment', 'Teaching methods, curriculum development, and assessment strategies for fine arts education', 3),
  ('Integration and Cross-Curricular Connections', 'Connecting fine arts with other subject areas and promoting interdisciplinary learning', 4)
) AS domains(domain_name, domain_description, domain_order)
WHERE NOT EXISTS (
  SELECT 1 FROM domains d 
  JOIN certifications c ON d.certification_id = c.id 
  WHERE c.test_code = '905'
);

-- 5. Verify the setup
SELECT 
  c.name as certification_name,
  c.test_code,
  d.name as domain_name,
  d.order_index
FROM certifications c
JOIN domains d ON d.certification_id = c.id
WHERE c.test_code = '905'
ORDER BY d.order_index;

-- 6. Check dashboard readiness
SELECT 
  'Fine Arts 905' as exam_type,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT concepts.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items,
  COUNT(DISTINCT q.id) as questions
FROM certifications cert
LEFT JOIN domains d ON d.certification_id = cert.id
LEFT JOIN concepts ON concepts.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = concepts.id
LEFT JOIN questions q ON q.concept_id = concepts.id
WHERE cert.test_code = '905'
GROUP BY cert.id;
