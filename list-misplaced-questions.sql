-- =================================================================
-- List Misplaced Questions for Rebalancing
-- =================================================================
-- Purpose: To list all questions currently assigned to the
-- "Number Concepts and Operations" topic, so we can manually
-- identify which ones need to be moved to other topics.
-- =================================================================

SELECT
  q.id AS question_id,
  q.question_text
FROM
  public.questions q
JOIN
  public.topics t ON q.topic_id = t.id
WHERE
  t.name = 'Number Concepts and Operations'
ORDER BY
  q.created_at;

-- =================================================================
-- How to Use This Script:
-- =================================================================
-- 1. Run this query.
-- 2. Review the list of question texts.
-- 3. Identify the `question_id` for any question that you believe
--    belongs in a different topic (e.g., Geometry, Algebra).
-- 4. Share the list of `question_id`s and their correct topics with
--    the AI, and it will generate the final rebalancing script.
-- =================================================================
