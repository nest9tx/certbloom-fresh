-- 🚧 CREATE PLACEHOLDER STUDY PLANS FOR OTHER CERTIFICATIONS
-- This will show appropriate "Coming Soon" messaging for non-902 certifications

-- First, let's see what certifications we have
SELECT test_code, name FROM certifications ORDER BY test_code;

-- Create basic study plans for other major certifications with "Coming Soon" status
INSERT INTO study_plans (
    user_id,
    certification_id,
    name,
    description,
    daily_study_minutes,
    is_active,
    progress_percentage,
    created_at,
    updated_at
)
SELECT 
    up.id,
    c.id,
    'Coming Soon: ' || c.name,
    'This certification study path is in development. Full content and adaptive learning features will be available soon.',
    30,
    true,
    0.00,
    NOW(),
    NOW()
FROM user_profiles up
CROSS JOIN certifications c
LEFT JOIN study_plans sp ON sp.user_id = up.id AND sp.certification_id = c.id
WHERE up.certification_goal IS NOT NULL
  AND c.test_code != '902'  -- Don't create for 902, we already have that
  AND sp.id IS NULL;  -- Only create if doesn't exist

-- Verify what we created
SELECT 
    sp.name,
    c.test_code,
    c.name as cert_name,
    count(*) as user_count
FROM study_plans sp
JOIN certifications c ON sp.certification_id = c.id
GROUP BY sp.name, c.test_code, c.name
ORDER BY c.test_code;

SELECT '✅ Placeholder study plans created for other certifications!' as status;
