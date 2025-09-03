-- Check answer_choices table structure and relationships

-- 1. Check answer_choices table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'answer_choices' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Check what foreign keys exist
SELECT 
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
AND tc.table_name = 'answer_choices';

-- 3. Check what records exist and their relationships
SELECT 
  'via content_item_id' as relationship_type,
  COUNT(*) as count
FROM answer_choices ac
INNER JOIN content_items ci ON ac.content_item_id = ci.id
WHERE EXISTS (SELECT 1 FROM answer_choices WHERE content_item_id IS NOT NULL LIMIT 1)
UNION ALL
SELECT 
  'via question_id' as relationship_type,
  COUNT(*) as count
FROM answer_choices ac
INNER JOIN questions q ON ac.question_id = q.id
WHERE EXISTS (SELECT 1 FROM questions LIMIT 1)
  AND EXISTS (SELECT 1 FROM answer_choices WHERE question_id IS NOT NULL LIMIT 1);

-- 4. Sample answer_choices records to see the structure
SELECT ac.id, ac.question_id, ac.content_item_id, ac.choice_order, ac.choice_text, ac.is_correct
FROM answer_choices ac
LIMIT 10;
