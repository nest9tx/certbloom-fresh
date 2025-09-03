-- Check table structure and data locations

-- 1. Check if questions table exists and has data
SELECT 'questions' as table_name, COUNT(*) as record_count
FROM questions
WHERE EXISTS (SELECT 1 FROM questions)
UNION ALL
SELECT 'content_items' as table_name, COUNT(*) as record_count  
FROM content_items
UNION ALL
SELECT 'answer_choices' as table_name, COUNT(*) as record_count
FROM answer_choices;

-- 2. Check the relationship between tables
SELECT 
  'content_items to answer_choices' as relationship,
  COUNT(DISTINCT ci.id) as content_items_with_choices
FROM content_items ci
INNER JOIN answer_choices ac ON ci.id = ac.content_item_id
UNION ALL
SELECT 
  'questions to answer_choices' as relationship,
  COUNT(DISTINCT q.id) as questions_with_choices  
FROM questions q
INNER JOIN answer_choices ac ON q.id = ac.question_id
WHERE EXISTS (SELECT 1 FROM questions);

-- 3. Check schema differences
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'questions' 
AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'content_items' 
AND table_schema = 'public'
ORDER BY ordinal_position;
