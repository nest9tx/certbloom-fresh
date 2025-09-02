-- QUICK SETUP FOR ALL EC-6 CERTIFICATIONS
-- This creates the basic structure needed for study-path to work

-- 1. Ensure all certifications exist (quick version)
INSERT INTO certifications (name, test_code, description) VALUES
  ('TExES Core Subjects EC-6 (391)', '391', 'Early Childhood through 6th Grade - All core subjects'),
  ('TExES Core Subjects EC-6: English Language Arts (901)', '901', 'Early Childhood through 6th Grade English Language Arts'),
  ('TExES Core Subjects EC-6: Mathematics (902)', '902', 'Early Childhood through 6th Grade Mathematics'),
  ('TExES Core Subjects EC-6: Social Studies (903)', '903', 'Early Childhood through 6th Grade Social Studies'),
  ('TExES Core Subjects EC-6: Science (904)', '904', 'Early Childhood through 6th Grade Science'),
  ('TExES Core Subjects EC-6: Fine Arts, Health and PE (905)', '905', 'Early Childhood through 6th Grade Fine Arts, Health and Physical Education')
ON CONFLICT (test_code) DO NOTHING;

-- 2. Quick check - show what we have
SELECT 
  c.test_code,
  c.name,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT concepts.id) as concepts,
  CASE 
    WHEN COUNT(DISTINCT d.id) = 0 THEN '❌ Needs domains'
    WHEN COUNT(DISTINCT concepts.id) = 0 THEN '⚠️ Needs concepts'
    ELSE '✅ Has structure'
  END as status
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
LEFT JOIN concepts ON concepts.domain_id = d.id
WHERE c.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY c.id, c.name, c.test_code
ORDER BY c.test_code;
