-- =================================================================
-- List Available Math Topics
-- =================================================================
-- Purpose: To find the names and IDs of all topics currently
-- associated with the 'TExES Core Subjects EC-6: Mathematics (902)'
-- certification.
--
-- Run this script in your Supabase SQL Editor. The results will
-- tell us which topic names to use in the question-insertion script.
-- =================================================================

WITH math_ec6_cert AS (
  SELECT id FROM public.certifications 
  WHERE test_code = '902' OR name ILIKE '%Mathematics (902)%'
  LIMIT 1
)
SELECT 
  t.id AS topic_id, 
  t.name AS topic_name, 
  t.certification_id
FROM 
  public.topics t, 
  math_ec6_cert
WHERE 
  t.certification_id = math_ec6_cert.id;
