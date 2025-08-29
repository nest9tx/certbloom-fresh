-- =================================================================
-- Clean Up Duplicate Questions
-- =================================================================
-- Purpose: To find and remove duplicate questions from the 'questions'
-- table. This is necessary before adding a UNIQUE constraint.
-- =================================================================

-- Step 1: Find and review the duplicate questions (Optional)
-- This query will show you which question texts are duplicated.
SELECT
  question_text,
  COUNT(*) AS duplicate_count
FROM
  public.questions
GROUP BY
  question_text
HAVING
  COUNT(*) > 1;


-- Step 2: Delete the duplicate rows
-- This query will delete all but one instance of each duplicated question,
-- keeping the one that was created first.
-- This is the main command to run.
DELETE FROM
  public.questions a
WHERE
  a.ctid <> (
    SELECT
      min(b.ctid)
    FROM
      public.questions b
    WHERE
      a.question_text = b.question_text
  );

-- =================================================================
-- Verification
-- =================================================================
-- After running the DELETE command above, you can re-run the
-- 'fix-on-conflict-constraint.sql' script, and it will now succeed.
-- =================================================================
