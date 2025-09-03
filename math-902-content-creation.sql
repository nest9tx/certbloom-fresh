-- 📚 MATH 902 CONTENT CREATION TEMPLATES
-- Exemplary content structure for each concept

-- ============================================
-- CONTENT CREATION FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION create_concept_content(
  p_concept_id UUID,
  p_concept_name TEXT
) RETURNS VOID AS $$
BEGIN
  -- 1. Text Explanation (Core concept overview)
  INSERT INTO content_items (
    id, concept_id, type, title, content, order_index, 
    estimated_minutes, is_required, certification_area, subject_area
  ) VALUES (
    gen_random_uuid(),
    p_concept_id,
    'text_explanation',
    p_concept_name || ' - Core Concepts',
    jsonb_build_object(
      'sections', ARRAY[
        'Understanding the fundamental principles of ' || p_concept_name,
        'Key terminology and definitions',
        'Mathematical foundations and background',
        'Connection to elementary mathematics curriculum'
      ]
    ),
    1, 8, true, 'MATH-902', 'Mathematics'
  );

  -- 2. Interactive Example (Step-by-step walkthrough)
  INSERT INTO content_items (
    id, concept_id, type, title, content, order_index,
    estimated_minutes, is_required, certification_area, subject_area
  ) VALUES (
    gen_random_uuid(),
    p_concept_id,
    'interactive_example',
    p_concept_name || ' - Worked Example',
    jsonb_build_object(
      'steps', ARRAY[
        'Step 1: Identify the problem type and key information',
        'Step 2: Choose appropriate mathematical strategy',
        'Step 3: Apply the mathematical concept systematically',
        'Step 4: Verify the solution and check reasonableness'
      ],
      'example', 'Detailed worked example will be added here'
    ),
    2, 12, true, 'MATH-902', 'Mathematics'
  );

  -- 3. Practice Question (Single concept check)
  INSERT INTO content_items (
    id, concept_id, type, title, content, order_index,
    estimated_minutes, is_required, certification_area, subject_area
  ) VALUES (
    gen_random_uuid(),
    p_concept_id,
    'practice_question',
    p_concept_name || ' - Quick Check',
    jsonb_build_object(
      'question', 'Sample practice question for ' || p_concept_name,
      'answers', ARRAY[
        'Option A - Incorrect but plausible',
        'Option B - Correct answer',
        'Option C - Common misconception',
        'Option D - Another distractor'
      ],
      'correct', 1,
      'explanation', 'Detailed explanation of why B is correct and why other options are incorrect'
    ),
    3, 5, true, 'MATH-902', 'Mathematics'
  );

  -- 4. Real-World Scenario (Classroom application)
  INSERT INTO content_items (
    id, concept_id, type, title, content, order_index,
    estimated_minutes, is_required, certification_area, subject_area
  ) VALUES (
    gen_random_uuid(),
    p_concept_id,
    'real_world_scenario',
    p_concept_name || ' - Classroom Connection',
    jsonb_build_object(
      'scenario', 'How ' || p_concept_name || ' appears in elementary classrooms and real-world situations that students encounter'
    ),
    4, 6, true, 'MATH-902', 'Mathematics'
  );

  -- 5. Teaching Strategy (How to teach this concept)
  INSERT INTO content_items (
    id, concept_id, type, title, content, order_index,
    estimated_minutes, is_required, certification_area, subject_area
  ) VALUES (
    gen_random_uuid(),
    p_concept_id,
    'teaching_strategy',
    p_concept_name || ' - Teaching Approach',
    jsonb_build_object(
      'strategy', 'Effective strategies for teaching ' || p_concept_name || ' to elementary students, including manipulatives, visual aids, and progression of instruction'
    ),
    5, 8, true, 'MATH-902', 'Mathematics'
  );

  -- 6. Common Misconception (What students get wrong)
  INSERT INTO content_items (
    id, concept_id, type, title, content, order_index,
    estimated_minutes, is_required, certification_area, subject_area
  ) VALUES (
    gen_random_uuid(),
    p_concept_id,
    'common_misconception',
    p_concept_name || ' - Common Errors',
    jsonb_build_object(
      'misconception', 'Students often struggle with ' || p_concept_name || ' because... Here are the most common errors and how to address them'
    ),
    6, 5, true, 'MATH-902', 'Mathematics'
  );

  -- 7. Memory Technique (Helpful mnemonics)
  INSERT INTO content_items (
    id, concept_id, type, title, content, order_index,
    estimated_minutes, is_required, certification_area, subject_area
  ) VALUES (
    gen_random_uuid(),
    p_concept_id,
    'memory_technique',
    p_concept_name || ' - Memory Aids',
    jsonb_build_object(
      'technique', 'Helpful ways to remember key concepts in ' || p_concept_name || ', including mnemonics, visual patterns, and memory strategies'
    ),
    7, 4, false, 'MATH-902', 'Mathematics'
  );

  -- 8. Full Practice Session (Mixed concept assessment)
  INSERT INTO content_items (
    id, concept_id, type, title, content, order_index,
    estimated_minutes, is_required, certification_area, subject_area
  ) VALUES (
    gen_random_uuid(),
    p_concept_id,
    'practice',
    p_concept_name || ' - Practice Session',
    jsonb_build_object(
      'session_type', 'full_concept_practice',
      'target_question_count', 15,
      'estimated_minutes', 20,
      'description', 'Complete practice session focusing on ' || p_concept_name || ' with varied question types and difficulty levels'
    ),
    8, 20, false, 'MATH-902', 'Mathematics'
  );

END;
$$ LANGUAGE plpgsql;

-- ============================================
-- CREATE CONTENT FOR ALL MATH 902 CONCEPTS
-- ============================================

-- Create content for all concepts
DO $$
DECLARE
  concept_record RECORD;
BEGIN
  FOR concept_record IN 
    SELECT co.id, co.name
    FROM certifications c
    JOIN domains d ON c.id = d.certification_id
    JOIN concepts co ON d.id = co.domain_id
    WHERE c.test_code = '902'
    ORDER BY d.order_index, co.order_index
  LOOP
    PERFORM create_concept_content(concept_record.id, concept_record.name);
    RAISE NOTICE 'Created content for concept: %', concept_record.name;
  END LOOP;
END;
$$;

-- ============================================
-- SAMPLE AUTHENTIC QUESTIONS CREATION
-- ============================================

-- Function to create sample questions for a concept
CREATE OR REPLACE FUNCTION create_sample_questions(
  p_concept_id UUID,
  p_concept_name TEXT,
  p_question_count INTEGER DEFAULT 5
) RETURNS VOID AS $$
DECLARE
  i INTEGER;
  question_id UUID;
BEGIN
  FOR i IN 1..p_question_count LOOP
    -- Create the question content item
    question_id := gen_random_uuid();
    
    INSERT INTO content_items (
      id, concept_id, type, title, question_text, 
      certification_area, subject_area, explanation,
      difficulty_level, competency, skill,
      order_index, estimated_minutes, is_required
    ) VALUES (
      question_id,
      p_concept_id,
      'practice_question',
      p_concept_name || ' - Practice Question ' || i,
      'Sample TExES-style question ' || i || ' for ' || p_concept_name || '. This will be replaced with authentic content.',
      'MATH-902',
      'Mathematics',
      'Detailed explanation for question ' || i || ' covering the key concepts and common misconceptions.',
      CASE WHEN i <= 2 THEN 1 WHEN i <= 4 THEN 2 ELSE 3 END, -- Difficulty progression
      p_concept_name,
      'Problem Solving',
      100 + i, -- Order after main content
      3,
      false
    );
    
    -- Create answer choices
    INSERT INTO answer_choices (content_item_id, choice_order, choice_text, is_correct) VALUES
      (question_id, 1, 'Option A for question ' || i, false),
      (question_id, 2, 'Correct answer for question ' || i, true),
      (question_id, 3, 'Option C for question ' || i, false),
      (question_id, 4, 'Option D for question ' || i, false)
    ON CONFLICT (content_item_id, choice_order) DO UPDATE SET
      choice_text = EXCLUDED.choice_text,
      is_correct = EXCLUDED.is_correct;
      
  END LOOP;
  
  RAISE NOTICE 'Created % sample questions for %', p_question_count, p_concept_name;
END;
$$ LANGUAGE plpgsql;

-- Create sample questions for first few concepts
DO $$
DECLARE
  concept_record RECORD;
BEGIN
  FOR concept_record IN 
    SELECT co.id, co.name
    FROM certifications c
    JOIN domains d ON c.id = d.certification_id
    JOIN concepts co ON d.id = co.domain_id
    WHERE c.test_code = '902'
    ORDER BY d.order_index, co.order_index
    LIMIT 4 -- Start with first 4 concepts
  LOOP
    PERFORM create_sample_questions(concept_record.id, concept_record.name, 3);
  END LOOP;
END;
$$;

-- ============================================
-- VERIFICATION AND SUMMARY
-- ============================================

-- Summary of created content
SELECT 
  c.name as certification,
  d.name as domain,
  co.name as concept,
  ci.type as content_type,
  ci.title,
  ci.estimated_minutes,
  CASE WHEN ci.type = 'practice_question' THEN 
    (SELECT COUNT(*) FROM answer_choices WHERE content_item_id = ci.id)
  END as answer_choices_count
FROM certifications c
JOIN domains d ON c.id = d.certification_id
JOIN concepts co ON d.id = co.domain_id
JOIN content_items ci ON co.id = ci.concept_id
WHERE c.test_code = '902'
ORDER BY d.order_index, co.order_index, ci.order_index;

-- Count summary
SELECT 
  'Math 902 Foundation Complete' as status,
  COUNT(DISTINCT d.id) as domains,
  COUNT(DISTINCT co.id) as concepts,
  COUNT(DISTINCT ci.id) as content_items,
  COUNT(ac.id) as answer_choices
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts co ON d.id = co.domain_id
LEFT JOIN content_items ci ON co.id = ci.concept_id
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE c.test_code = '902';
