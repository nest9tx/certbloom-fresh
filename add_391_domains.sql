-- ADD MISSING 391 (EC-6 CORE SUBJECTS) DOMAINS
-- This is the composite test that covers all subjects
-- But we should make it reference the 900 series instead!

-- First check if 391 certification exists
INSERT INTO certifications (name, test_code, description) VALUES
  ('TExES Core Subjects EC-6 (391)', '391', 'Early Childhood through 6th Grade - All core subjects')
ON CONFLICT (test_code) DO NOTHING;

-- Note: Instead of creating separate 391 content, we should use the composite mapping
-- This script is for emergency use only - prefer the composite mapping approach

-- Verify the setup
SELECT 
  'Current 391 Status' as status,
  c.test_code,
  c.name,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT concepts.id) as concepts
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts ON concepts.domain_id = d.id
WHERE c.test_code = '391'
GROUP BY c.id, c.name, c.test_code;
