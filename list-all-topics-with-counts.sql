-- =================================================================
-- List All Topics and Their Question Counts
-- =================================================================
-- Purpose: To definitively identify all topics that have questions
-- assigned to them and see how many questions each topic contains.
-- This will help us find the topic that holds the 62 legacy questions.
-- =================================================================

SELECT
  t.name AS topic_name,
  t.id AS topic_id,
  COUNT(q.id) AS number_of_questions
FROM
  public.topics t
JOIN
  public.questions q ON t.id = q.topic_id
GROUP BY
  t.id, t.name
ORDER BY
  number_of_questions DESC;

-- =================================================================
-- How to Interpret the Results:
-- =================================================================
-- This query will give us a list of all your topics and the exact
-- number of questions in each. The one with 62 questions is the
-- legacy topic we need to investigate further.
--
-- Please share the output of this query.
-- =================================================================
