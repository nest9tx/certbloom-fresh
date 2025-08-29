-- =================================================================
-- Rebalance Math Questions
-- =================================================================
-- Purpose: To manually reassign questions from the over-filled
-- "Number Concepts and Operations" topic to their correct topics,
-- creating a more balanced distribution for the admin dashboard.
-- =================================================================

DO $$
DECLARE
  patterns_topic_id UUID;
  geometry_topic_id UUID;
  data_topic_id UUID;
BEGIN
  -- Step 1: Get the UUIDs for the destination topics
  SELECT id INTO patterns_topic_id FROM public.topics WHERE name = 'Patterns and Algebraic Reasoning';
  SELECT id INTO geometry_topic_id FROM public.topics WHERE name = 'Geometry and Spatial Reasoning';
  SELECT id INTO data_topic_id FROM public.topics WHERE name = 'Data Analysis and Probability';

  -- Step 2: Move 3 questions to 'Patterns and Algebraic Reasoning'
  RAISE NOTICE 'Moving 3 questions to Patterns and Algebraic Reasoning...';
  UPDATE public.questions
  SET topic_id = patterns_topic_id
  WHERE id IN (
    'b3a53927-f85d-439e-a9d0-ab1133f7b24f', -- "Lila has 3 packs of pencils..."
    '0b47d086-d1a1-4c06-90c2-78e9858f4092', -- "student solves 19 + 36 by breaking 36..."
    '62aeb15b-a418-454c-8f95-ef2afae59b34'  -- "different student strategies for solving 6 x 8..."
  );

  -- Step 3: Move 1 question to 'Geometry and Spatial Reasoning'
  RAISE NOTICE 'Moving 1 question to Geometry and Spatial Reasoning...';
  UPDATE public.questions
  SET topic_id = geometry_topic_id
  WHERE id = '47985616-2c24-47f9-9805-3a685c97ce98'; -- "read an analog clock..."

  -- Step 4: Move 1 question to 'Data Analysis and Probability'
  RAISE NOTICE 'Moving 1 question to Data Analysis and Probability...';
  UPDATE public.questions
  SET topic_id = data_topic_id
  WHERE id = '97fc0ccc-985b-459b-8e00-c996c2fa4b2c'; -- "student consistently makes the following error..."

  RAISE NOTICE 'Rebalancing complete.';
END $$;

-- =================================================================
-- Next Steps:
-- =================================================================
-- 1. Run this script.
-- 2. After it succeeds, run `list-all-topics-with-counts.sql` again
--    to verify the new, balanced counts.
-- 3. Your admin dashboard should now reflect the correct distribution.
-- =================================================================
