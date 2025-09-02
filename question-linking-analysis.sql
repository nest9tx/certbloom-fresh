# Question Linking Fix Script
# Date: September 2, 2025
# Purpose: Connect existing questions to current certification concepts

# The problem: 896 questions exist but only 7 concepts have questions linked
# Most questions have certification_id: null and point to old concept IDs
# Need to redistribute questions across current concept structure

-- First, let's see what certifications the existing linked questions belong to
SELECT DISTINCT 
  c.name as concept_name,
  d.name as domain_name,
  cert.test_code,
  cert.name as certification_name,
  COUNT(q.id) as question_count
FROM questions q
JOIN concepts c ON q.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
JOIN certifications cert ON d.certification_id = cert.id
WHERE q.concept_id IS NOT NULL
GROUP BY c.name, d.name, cert.test_code, cert.name
ORDER BY cert.test_code, question_count DESC;

-- Update questions to link to certifications based on their current concept links
UPDATE questions 
SET certification_id = (
  SELECT d.certification_id 
  FROM concepts c 
  JOIN domains d ON c.domain_id = d.id 
  WHERE c.id = questions.concept_id
)
WHERE concept_id IS NOT NULL 
AND certification_id IS NULL;

-- For questions without concept_id links, we need to distribute them
-- This will be a manual process based on question content and tags

-- Check which questions need concept assignment
SELECT 
  COUNT(*) as unlinked_questions,
  COUNT(DISTINCT tags) as unique_tag_combinations
FROM questions 
WHERE concept_id IS NULL;

-- Sample unlinked questions to see their content
SELECT 
  id, 
  question_text, 
  tags, 
  domain,
  concept
FROM questions 
WHERE concept_id IS NULL 
LIMIT 10;
