-- 🔍 CHECK AND FIX CERTIFICATION NAME FOR 902
-- Let's see what the current name is and fix it

-- First, check current certification data for 902
SELECT 
    id,
    test_code,
    name,
    description,
    created_at
FROM certifications 
WHERE test_code = '902';

-- Update the name to be more appropriate for EC-6 Math
UPDATE certifications 
SET 
    name = 'TExES Core Subjects EC-6: Mathematics (902)',
    description = 'Texas teacher certification exam for elementary mathematics education (grades EC-6)',
    updated_at = NOW()
WHERE test_code = '902';

-- Verify the update
SELECT 
    id,
    test_code,
    name,
    description
FROM certifications 
WHERE test_code = '902';

-- Also update the study plan name to reflect the correct certification
UPDATE study_plans 
SET 
    name = 'Primary: TExES Core Subjects EC-6: Mathematics (902)',
    description = 'Main study plan for TExES Core Subjects EC-6: Mathematics (902) certification',
    updated_at = NOW()
WHERE certification_id = (
    SELECT id FROM certifications WHERE test_code = '902'
);

-- Verify study plan update
SELECT 
    sp.id,
    sp.name,
    sp.description,
    up.email
FROM study_plans sp
JOIN user_profiles up ON sp.user_id = up.id
JOIN certifications c ON sp.certification_id = c.id
WHERE c.test_code = '902';

SELECT '✅ Certification and study plan names updated for 902!' as status;
