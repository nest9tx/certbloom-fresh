-- 🌸 SIMPLE CHECK: Just show certifications table structure
-- Run this to see what columns exist in certifications table

-- Show certifications table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'certifications' 
ORDER BY ordinal_position;

-- Also try a simple select to see if any data exists
SELECT * FROM certifications LIMIT 1;
