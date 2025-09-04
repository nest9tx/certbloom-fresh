-- Step 2: Check for any study plans for your user
SELECT 
  sp.id,
  sp.user_id,
  sp.certification_id,
  sp.name,
  sp.is_active,
  sp.created_at,
  c.name as cert_name,
  c.test_code
FROM study_plans sp
LEFT JOIN certifications c ON sp.certification_id = c.id
WHERE sp.user_id = '1c04efe6-e1b7-45ef-9d02-079eef06fd9a'
ORDER BY sp.created_at DESC;
