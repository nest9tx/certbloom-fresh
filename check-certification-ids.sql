-- Check what certification IDs exist
SELECT 
  id,
  name,
  test_code,
  description
FROM certifications 
ORDER BY test_code;
