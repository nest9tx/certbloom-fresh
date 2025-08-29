-- =================================================================
-- Add UNIQUE Constraints for Safe Question Insertion
-- =================================================================
-- Purpose: To add the necessary UNIQUE constraints to the 'questions'
-- and 'answer_choices' tables. This allows the use of 'ON CONFLICT'
-- to prevent creating duplicate content when running insertion scripts.
--
-- This is a required, one-time schema update.
-- =================================================================

-- Step 1: Add a UNIQUE constraint to the 'question_text' column.
-- This ensures that no two questions can have the exact same text.
ALTER TABLE public.questions
ADD CONSTRAINT questions_question_text_key UNIQUE (question_text);

-- Step 2: Add a UNIQUE constraint to the combination of 'question_id' and 'choice_text'.
-- This ensures that a single question cannot have two identical answer choices.
ALTER TABLE public.answer_choices
ADD CONSTRAINT answer_choices_question_id_choice_text_key UNIQUE (question_id, choice_text);

-- =================================================================
-- Verification
-- =================================================================
-- After running this script successfully, you can now re-run the
-- 'step2-insert-math-questions.sql' script. The 'ON CONFLICT'
-- error will be resolved.
-- =================================================================
