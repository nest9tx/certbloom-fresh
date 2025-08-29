-- =================================================================
-- Step 1: Create Foundational Topics for Math EC-6 (902) - CORRECTED
-- =================================================================
-- Purpose: To create the necessary parent topics (domains) for the
-- 'TExES Core Subjects EC-6: Mathematics (902)' certification.
--
-- This script is safe to run multiple times. It now uses TRIM()
-- to avoid issues with hidden whitespace in the test_code.
-- =================================================================

WITH math_cert AS (
  -- First, find the correct certification ID, ignoring whitespace.
  SELECT id FROM public.certifications 
  WHERE trim(test_code) = '902'
  LIMIT 1
)
-- Then, insert the topics and link them to the certification ID.
INSERT INTO public.topics (certification_id, name, description)
SELECT 
  math_cert.id,
  topic_data.name,
  topic_data.description
FROM 
  math_cert,
  (VALUES
    ('Number Concepts and Operations', 'Fundamental number concepts, operations, and computational fluency.'),
    ('Patterns and Algebraic Reasoning', 'Patterns, relationships, algebraic thinking, and functions.'),
    ('Geometry and Spatial Reasoning', 'Geometric shapes, spatial relationships, and measurement.'),
    ('Data Analysis and Probability', 'Data interpretation, statistical concepts, and probability.')
  ) AS topic_data(name, description)
ON CONFLICT (name, certification_id) DO NOTHING; -- This prevents creating duplicates if run again.

-- =================================================================
-- Verification
-- =================================================================
-- After running this script, you should see the 4 topics listed
-- when you run the 'list-math-topics.sql' query.
-- =================================================================
