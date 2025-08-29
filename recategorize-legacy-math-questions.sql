-- =================================================================
-- Recategorize Legacy Math Questions
-- =================================================================
-- Purpose: To move the 19 legacy math questions from the old
-- 'Mathematics Concepts' topic into their correct new topics based
-- on their tags. This will fix the domain counts on the dashboard.
-- =================================================================

DO $$
DECLARE
  -- Declare variables for all the topic IDs we'll need.
  legacy_math_topic_id UUID;
  number_ops_topic_id UUID;
  algebra_topic_id UUID;
  geometry_topic_id UUID;
  data_topic_id UUID;

BEGIN
  -- Step 1: Get the IDs for all relevant topics.
  SELECT id INTO legacy_math_topic_id FROM public.topics WHERE name = 'Mathematics Concepts' LIMIT 1;
  SELECT id INTO number_ops_topic_id FROM public.topics WHERE name = 'Number Concepts and Operations' LIMIT 1;
  SELECT id INTO algebra_topic_id FROM public.topics WHERE name = 'Patterns and Algebraic Reasoning' LIMIT 1;
  SELECT id INTO geometry_topic_id FROM public.topics WHERE name = 'Geometry and Spatial Reasoning' LIMIT 1;
  SELECT id INTO data_topic_id FROM public.topics WHERE name = 'Data Analysis and Probability' LIMIT 1;

  -- Step 2: Move questions tagged with 'geometry' or 'measurement'.
  UPDATE public.questions
  SET topic_id = geometry_topic_id
  WHERE topic_id = legacy_math_topic_id
    AND (tags && ARRAY['geometry', 'measurement']);

  -- Step 3: Move questions tagged with 'patterns', 'algebraic_reasoning', or 'sequences'.
  UPDATE public.questions
  SET topic_id = algebra_topic_id
  WHERE topic_id = legacy_math_topic_id
    AND (tags && ARRAY['patterns', 'algebraic_reasoning', 'sequences']);

  -- Step 4: Move questions tagged with 'data_interpretation'.
  UPDATE public.questions
  SET topic_id = data_topic_id
  WHERE topic_id = legacy_math_topic_id
    AND (tags && ARRAY['data_interpretation']);

  -- Step 5: Move all remaining questions from the legacy topic to 'Number Concepts and Operations'.
  -- This acts as a catch-all for the majority of the questions.
  UPDATE public.questions
  SET topic_id = number_ops_topic_id
  WHERE topic_id = legacy_math_topic_id;

END $$;

-- =================================================================
-- Verification
-- =================================================================
-- After running this script, your admin dashboard's "Questions by Domain"
-- card should be accurate. The old "Mathematics Concepts" topic will
-- have 0 questions, and the new topics will have the correct counts.
-- =================================================================
