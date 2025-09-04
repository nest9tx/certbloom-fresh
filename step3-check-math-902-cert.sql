-- Step 3: Check if Math 902 certification exists
SELECT 
  id,
  name,
  test_code,
  created_at
FROM certifications 
WHERE test_code = '902'
ORDER BY created_at DESC;
