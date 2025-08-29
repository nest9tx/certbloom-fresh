-- =================================================================
-- Inspect Legacy Math Questions
-- =================================================================
-- Purpose: To list the text and tags for the 19 legacy questions
-- currently in the old 'Mathematics Concepts' topic. This will
-- allow us to re-categorize them correctly.
-- =================================================================

SELECT
  question_text,
  tags
FROM
  public.questions
WHERE
  -- Using the exact ID for the 'Mathematics Concepts' topic from previous query
  topic_id = 'b14d4b30-c13b-4331-a936-f6f6f45096aa';

-- =================================================================
-- Next Steps:
-- =================================================================
-- Please share the output of this query. The 'tags' column will
-- tell us which new, correct topic each question should be moved to.
-- =================================================================
