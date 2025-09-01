-- DEBUG CERTIFICATION SELECTION ISSUES
-- Check what happens with different certification selections

-- 1. Check current user's certification goal
SELECT 
  'CURRENT USER STATUS:' as section,
  id,
  email,
  certification_goal,
  daily_study_minutes,
  subscription_status
FROM user_profiles 
WHERE email = 'nest9tx@yahoo.com';  -- Replace with your email

-- 2. Check active study plans
SELECT 
  'ACTIVE STUDY PLANS:' as section,
  sp.id as study_plan_id,
  sp.name as plan_name,
  c.name as certification_name,
  c.test_code,
  sp.is_active,
  sp.created_at
FROM study_plans sp
JOIN certifications c ON sp.certification_id = c.id
JOIN user_profiles up ON sp.user_id = up.id
WHERE up.email = 'nest9tx@yahoo.com'  -- Replace with your email
ORDER BY sp.created_at DESC;

-- 3. Check for duplicate study plan issues (the error you saw)
SELECT 
  'DUPLICATE STUDY PLAN CHECK:' as section,
  user_id,
  certification_id,
  COUNT(*) as plan_count,
  string_agg(name, ', ') as plan_names
FROM study_plans 
WHERE is_active = true
GROUP BY user_id, certification_id
HAVING COUNT(*) > 1;

-- 4. Show which certifications can create study plans
SELECT 
  'STUDY PLAN CAPABILITY:' as section,
  c.name as certification_name,
  c.test_code,
  CASE 
    WHEN c.test_code IN ('902', '905') THEN '✅ Can create study plan'
    ELSE '❌ No structured content'
  END as can_create_plan,
  COUNT(DISTINCT d.id) as domains_count
FROM certifications c
LEFT JOIN domains d ON d.certification_id = c.id
WHERE c.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY c.id, c.name, c.test_code
ORDER BY c.test_code;
