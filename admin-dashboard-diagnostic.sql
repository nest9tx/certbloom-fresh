-- =================================================================
-- Admin Dashboard Question Count Diagnostic Script
-- =================================================================
-- Purpose: To replicate the counts shown on the admin dashboard
-- and diagnose any discrepancies. Run these queries in your
-- Supabase SQL Editor to compare the results with your dashboard.
--

-- =================================================================
-- Query 1: Questions by Certification (Comprehensive Count)
-- =================================================================
-- This query correctly counts questions for each certification,
-- including those where it's a primary OR secondary certification.
-- This is likely the *correct* count you should be seeing.
--
SELECT
  c.name AS certification_name,
  c.test_code,
  COUNT(q.id) AS total_questions
FROM
  public.certifications c
JOIN
  (
    -- Select questions where this is the primary certification
    SELECT id, certification_id AS cert_id FROM public.questions
    UNION ALL
    -- Select questions where this is a secondary certification
    SELECT id, unnest(secondary_certification_ids) AS cert_id FROM public.questions
  ) q ON c.id = q.cert_id
GROUP BY
  c.id, c.name, c.test_code
ORDER BY
  total_questions DESC;


-- =================================================================
-- Query 2: Questions by Domain (Topic)
-- =================================================================
-- This shows the count of questions for each domain/topic.
-- Compare this to the "Questions by Domain" card.
--
SELECT
  t.name AS domain_name,
  COUNT(q.id) AS question_count
FROM
  public.questions q
JOIN
  public.topics t ON q.topic_id = t.id
GROUP BY
  t.name
ORDER BY
  question_count DESC;


-- =================================================================
-- Query 3: Questions by Difficulty
-- =================================================================
-- This shows the count of questions for each difficulty level.
-- Compare this to the "Questions by Difficulty" card.
--
SELECT
  difficulty_level,
  COUNT(*) AS question_count
FROM
  public.questions
GROUP BY
  difficulty_level
ORDER BY
  difficulty_level;


-- =================================================================
-- Query 4: Potential Source of Discrepancy
-- =================================================================
-- This query checks for questions assigned to a generic
-- "Core Subjects" certification as their *primary* certification.
-- This might be the source of the "EC-6 Core Subjects: 62" count
-- if these questions haven't been updated to the new dual-tagging system.
--
SELECT
  c.name,
  c.test_code,
  COUNT(q.id) as question_count
FROM public.questions q
JOIN public.certifications c ON q.certification_id = c.id
WHERE
  c.name ILIKE '%Core Subjects%'
GROUP BY
  c.name, c.test_code;

-- =================================================================
-- Final Check: Total Questions
-- =================================================================
-- A simple, final count of all questions in the table.
--
SELECT COUNT(*) AS total_questions_in_table FROM public.questions;
