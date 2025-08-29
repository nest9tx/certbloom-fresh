-- =================================================================
-- Debugging Script for Question Insertion
-- =================================================================
-- Purpose: To verify that the necessary IDs for certifications and
-- topics are being found before attempting to insert a new question.
-- Run each of these queries separately in your Supabase SQL Editor.
-- If any of them return no rows or an empty result, that is the
-- source of the problem.

-- =================================================================
-- Check 1: Find the 'Math EC-6 (902)' Certification ID
-- =================================================================
-- Does this query return a valid UUID?
SELECT id, name, test_code
FROM public.certifications 
WHERE test_code = '902' OR name ILIKE '%Mathematics (902)%';

-- =================================================================
-- Check 2: Find the 'Core Subjects EC-6 (391)' Certification ID
-- =================================================================
-- Does this query return a valid UUID?
SELECT id, name, test_code
FROM public.certifications 
WHERE test_code = '391' OR name ILIKE '%Core Subjects EC-6 (391)%';

-- =================================================================
-- Check 3: Find the 'Mathematics Topic' ID
-- =================================================================
-- This is the most likely point of failure. This query tries to find
-- a topic (like 'Number Concepts') that is linked to the Math EC-6
-- certification. If your topics are named differently or not linked
-- correctly, this will return nothing.
WITH math_ec6_cert AS (
  SELECT id FROM public.certifications 
  WHERE test_code = '902' OR name ILIKE '%Mathematics (902)%'
  LIMIT 1
)
SELECT t.id, t.name, t.certification_id
FROM public.topics t, math_ec6_cert
WHERE t.certification_id = math_ec6_cert.id
  AND (t.name ILIKE '%Number%' OR t.name ILIKE '%Algebraic%' OR t.name ILIKE '%Problem Solving%');

-- =================================================================
-- What to do next:
-- =================================================================
-- 1. If Check 1 or 2 fails, your `certifications` table has
--    different names than the script expects.
--
-- 2. If Check 3 fails (most likely), it means no topics with names
--    like 'Number', 'Algebraic', etc., are associated with your
--    'Math EC-6' certification.
--
-- Please share the results of these queries, and I will provide
-- a corrected version of the question-insertion script.
-- =================================================================
