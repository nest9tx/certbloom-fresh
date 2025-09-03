-- Check for questions missing answer_choices data

-- 1. Questions without answer_choices
SELECT ci.id, ci.certification_area, ci.question_text,
       SUBSTRING(ci.question_text, 1, 80) as preview
FROM content_items ci
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE ac.content_item_id IS NULL
AND ci.certification_area IN ('MATH-902', 'SCIENCE-902')
LIMIT 10;

-- 2. Questions with incomplete answer_choices (less than 4 choices)
SELECT ci.id, ci.certification_area, COUNT(ac.id) as choice_count
FROM content_items ci
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE ci.certification_area IN ('MATH-902', 'SCIENCE-902')
GROUP BY ci.id, ci.certification_area
HAVING COUNT(ac.id) != 4
LIMIT 10;

-- 3. Questions with no correct answer
SELECT ci.id, ci.certification_area, 
       SUBSTRING(ci.question_text, 1, 80) as preview,
       COUNT(ac.id) as total_choices,
       COUNT(CASE WHEN ac.is_correct THEN 1 END) as correct_choices
FROM content_items ci
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE ci.certification_area IN ('MATH-902', 'SCIENCE-902')
GROUP BY ci.id, ci.certification_area, ci.question_text
HAVING COUNT(CASE WHEN ac.is_correct THEN 1 END) != 1
LIMIT 10;

-- 4. Check specific problematic question to understand structure
SELECT ci.id, ci.certification_area, ci.question_text,
       ac.choice_order, ac.choice_text, ac.is_correct
FROM content_items ci
LEFT JOIN answer_choices ac ON ci.id = ac.content_item_id
WHERE ci.question_text ILIKE '%metal conducts heat%'
   OR ci.question_text ILIKE '%copper wire%'
   OR ci.question_text ILIKE '%wooden stick%'
ORDER BY ci.id, ac.choice_order;
