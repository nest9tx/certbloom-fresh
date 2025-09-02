-- SETUP 391 TO REFERENCE 900 SERIES CONTENT
-- 391 (EC-6 Core) should pull from 901 (ELA), 902 (Math), 903 (Social Studies), 904 (Science)

-- First ensure 391 certification exists
INSERT INTO certifications (name, test_code, description) VALUES
  ('TExES Core Subjects EC-6 (391)', '391', 'Early Childhood through 6th Grade - All core subjects')
ON CONFLICT (test_code) DO NOTHING;

-- Create 391 domains that REFERENCE the 900 series
INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index)
SELECT 
  c.id,
  domain_name,
  domain_code,
  domain_description,
  domain_weight,
  domain_order
FROM certifications c,
(VALUES
  ('English Language Arts and Reading', 'ELA_COMPOSITE', 'References all ELA concepts from 901', 30.0, 1),
  ('Mathematics', 'MATH_COMPOSITE', 'References all Math concepts from 902', 25.0, 2),
  ('Social Studies', 'SS_COMPOSITE', 'References all Social Studies concepts from 903', 22.5, 3),
  ('Science', 'SCI_COMPOSITE', 'References all Science concepts from 904', 22.5, 4)
) AS domains(domain_name, domain_code, domain_description, domain_weight, domain_order)
WHERE c.test_code = '391'
ON CONFLICT DO NOTHING;

-- Create a mapping table to link 391 domains to 900 series concepts
CREATE TABLE IF NOT EXISTS composite_concept_mapping (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  composite_domain_id UUID REFERENCES domains(id),
  source_concept_id UUID REFERENCES concepts(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Map 391 ELA domain to all 901 ELA concepts
INSERT INTO composite_concept_mapping (composite_domain_id, source_concept_id)
SELECT 
  d391.id as composite_domain_id,
  c901.id as source_concept_id
FROM domains d391
JOIN certifications cert391 ON d391.certification_id = cert391.id
CROSS JOIN concepts c901
JOIN domains d901 ON c901.domain_id = d901.id
JOIN certifications cert901 ON d901.certification_id = cert901.id
WHERE cert391.test_code = '391' AND d391.code = 'ELA_COMPOSITE'
  AND cert901.test_code = '901'
ON CONFLICT DO NOTHING;

-- Map 391 Math domain to all 902 Math concepts
INSERT INTO composite_concept_mapping (composite_domain_id, source_concept_id)
SELECT 
  d391.id as composite_domain_id,
  c902.id as source_concept_id
FROM domains d391
JOIN certifications cert391 ON d391.certification_id = cert391.id
CROSS JOIN concepts c902
JOIN domains d902 ON c902.domain_id = d902.id
JOIN certifications cert902 ON d902.certification_id = cert902.id
WHERE cert391.test_code = '391' AND d391.code = 'MATH_COMPOSITE'
  AND cert902.test_code = '902'
ON CONFLICT DO NOTHING;

-- Map 391 Social Studies domain to all 903 concepts
INSERT INTO composite_concept_mapping (composite_domain_id, source_concept_id)
SELECT 
  d391.id as composite_domain_id,
  c903.id as source_concept_id
FROM domains d391
JOIN certifications cert391 ON d391.certification_id = cert391.id
CROSS JOIN concepts c903
JOIN domains d903 ON c903.domain_id = d903.id
JOIN certifications cert903 ON d903.certification_id = cert903.id
WHERE cert391.test_code = '391' AND d391.code = 'SS_COMPOSITE'
  AND cert903.test_code = '903'
ON CONFLICT DO NOTHING;

-- Map 391 Science domain to all 904 concepts
INSERT INTO composite_concept_mapping (composite_domain_id, source_concept_id)
SELECT 
  d391.id as composite_domain_id,
  c904.id as source_concept_id
FROM domains d391
JOIN certifications cert391 ON d391.certification_id = cert391.id
CROSS JOIN concepts c904
JOIN domains d904 ON c904.domain_id = d904.id
JOIN certifications cert904 ON d904.certification_id = cert904.id
WHERE cert391.test_code = '391' AND d391.code = 'SCI_COMPOSITE'
  AND cert904.test_code = '904'
ON CONFLICT DO NOTHING;

-- Verification: Show the mapping
SELECT 
  '391 CONCEPT MAPPING' as info,
  d391.name as composite_domain,
  source_cert.test_code as source_test,
  source_domain.name as source_domain,
  source_concept.name as source_concept
FROM composite_concept_mapping ccm
JOIN domains d391 ON ccm.composite_domain_id = d391.id
JOIN concepts source_concept ON ccm.source_concept_id = source_concept.id
JOIN domains source_domain ON source_concept.domain_id = source_domain.id
JOIN certifications source_cert ON source_domain.certification_id = source_cert.id
ORDER BY d391.order_index, source_cert.test_code, source_concept.name;
