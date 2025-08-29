-- =================================================================
-- Diagnostic Script for Legacy Questions
-- =================================================================
-- Purpose: To inspect the 62 legacy questions currently categorized
-- under 'General Education' to determine their correct new topics.
-- =================================================================

-- Step 1: Find the ID of the 'General Education' topic.
WITH legacy_topic AS (
  SELECT id 
  FROM public.topics 
  WHERE name ILIKE '%General Education%'
  LIMIT 1
)
-- Step 2: List the text and tags of all questions in that topic.
-- The tags are the most important part, as they will help us re-categorize.
SELECT 
  q.id AS question_id,
  q.question_text,
  q.tags
FROM 
  public.questions q,
  legacy_topic
WHERE 
  q.topic_id = legacy_topic.id;

-- =================================================================
-- How to Interpret the Results:
-- =================================================================
-- Look at the 'tags' column for each question. Do you see patterns?
-- For example, do many questions have tags like 'math', 'fractions',
-- 'reading_comprehension', or 'phonics'?
--
-- Based on these patterns, we can write a script to move them. For example:
-- "UPDATE questions SET topic_id = [new_math_topic_id] WHERE tags && ARRAY['math'];"
--
-- Please share the output of this query.
-- =================================================================
