-- Check current user_progress table structure
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns 
WHERE table_name = 'user_progress'
ORDER BY ordinal_position;
