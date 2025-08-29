-- =================================================================
-- Debug Topic & Tag Distribution
-- =================================================================
-- Purpose: To understand the exact distribution of questions across
-- the new math topics by looking at their tags. This will explain
-- why the counts are what they are.
-- =================================================================

WITH topic_tags AS (
  SELECT
    t.name AS topic_name,
    unnest(q.tags) AS tag,
    q.id
  FROM
    public.questions q
  JOIN
    public.topics t ON q.topic_id = t.id
  WHERE
    t.name IN (
      'Number Concepts and Operations',
      'Patterns and Algebraic Reasoning',
      'Geometry and Spatial Reasoning',
      'Data Analysis and Probability'
    )
)
SELECT
  topic_name,
  tag,
  COUNT(id) as question_count
FROM
  topic_tags
GROUP BY
  topic_name,
  tag
ORDER BY
  topic_name,
  question_count DESC;

-- =================================================================
-- How to Interpret the Results:
-- =================================================================
-- This query will return a table showing each new math topic,
-- the tags of the questions within it, and how many questions have
-- that tag.
--
-- This will give us a crystal-clear picture of how the 19 legacy
-- questions and 5 new questions were categorized. Please share the
-- output.
-- =================================================================
