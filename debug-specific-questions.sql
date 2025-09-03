-- Test specific questions to understand the mismatch
-- Check a few specific questions from Physical Science

SELECT 
  ci.id,
  ci.certification_area,
  ci.subject_area,
  ci.question_text,
  ci.choice_1,
  ci.choice_2,
  ci.choice_3,
  ci.choice_4,
  ci.correct_choice,
  ci.choice_order,
  -- Show what each choice_order position maps to
  CASE 
    WHEN ci.choice_order = '[1,2,3,4]' THEN ci.choice_1
    WHEN ci.choice_order = '[2,1,3,4]' THEN ci.choice_2
    WHEN ci.choice_order = '[3,2,1,4]' THEN ci.choice_3
    WHEN ci.choice_order = '[4,2,3,1]' THEN ci.choice_4
    WHEN ci.choice_order = '[1,3,2,4]' THEN ci.choice_1
    WHEN ci.choice_order = '[1,4,3,2]' THEN ci.choice_1
    ELSE 'Complex mapping'
  END as current_first_choice,
  
  -- Check answer_choices table
  (SELECT json_agg(
    json_build_object(
      'choice_order', ac.choice_order,
      'choice_text', ac.choice_text,
      'is_correct', ac.is_correct
    ) ORDER BY ac.choice_order
  ) FROM answer_choices ac WHERE ac.content_item_id = ci.id) as answer_choices_data

FROM content_items ci
WHERE ci.certification_area = 'SCIENCE-902'
  AND ci.question_text ILIKE '%metal%'
LIMIT 5;
