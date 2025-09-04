-- Check for any constraints on study_plans table
SELECT 
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name,
  tc.table_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'study_plans'
ORDER BY tc.constraint_type, kcu.column_name;
