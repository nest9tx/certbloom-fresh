-- 🔍 STEP 2: EXAMINE THE QUESTIONS TABLE STRUCTURE
SELECT 
  'QUESTIONS TABLE STRUCTURE' as investigation,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'questions'
  AND table_schema = 'public'
ORDER BY ordinal_position;
