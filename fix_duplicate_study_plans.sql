-- FIX DUPLICATE STUDY PLANS
-- Clean up any duplicate active study plans

-- 1. Show current duplicates
SELECT 
  'CURRENT DUPLICATES:' as section,
  up.email,
  c.name as certification,
  COUNT(*) as active_plans
FROM study_plans sp
JOIN user_profiles up ON sp.user_id = up.id
JOIN certifications c ON sp.certification_id = c.id
WHERE sp.is_active = true
GROUP BY up.email, c.name
HAVING COUNT(*) > 1;

-- 2. Keep only the most recent active study plan per user
WITH ranked_plans AS (
  SELECT 
    sp.*,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC) as rn
  FROM study_plans sp
  WHERE is_active = true
)
UPDATE study_plans 
SET is_active = false
WHERE id IN (
  SELECT id FROM ranked_plans WHERE rn > 1
);

-- 3. Verify cleanup worked
SELECT 
  'AFTER CLEANUP:' as section,
  up.email,
  c.name as certification,
  COUNT(*) as active_plans
FROM study_plans sp
JOIN user_profiles up ON sp.user_id = up.id
JOIN certifications c ON sp.certification_id = c.id
WHERE sp.is_active = true
GROUP BY up.email, c.name;
