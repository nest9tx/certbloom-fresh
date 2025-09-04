-- Check user_profiles table structure for character limits
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns 
WHERE table_name = 'user_profiles'
ORDER BY ordinal_position;
