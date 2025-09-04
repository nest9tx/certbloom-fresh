-- Check the study_plans table structure to see field limits
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns 
WHERE table_name = 'study_plans'
ORDER BY ordinal_position;
