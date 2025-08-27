-- =====================================================
-- SIGNUP FLOW TEST VERIFICATION 🌸
-- =====================================================
-- Run this after the main schema fix to test signup flow
-- =====================================================

-- Test the signup flow components

-- 1. Verify certifications table has correct data
SELECT 'CERTIFICATION DATA CHECK:' as test_step;
SELECT id, name, test_code, description 
FROM certifications 
WHERE test_code = '902';

-- 2. Test a manual study plan creation (simulating signup)
-- Replace 'your-user-id' with an actual user ID from auth.users
DO $$
DECLARE
    test_user_id UUID;
    cert_id UUID;
BEGIN
    -- Get the first user from auth.users for testing
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    
    -- Get the Math EC-6 certification ID
    SELECT id INTO cert_id FROM certifications WHERE test_code = '902';
    
    IF test_user_id IS NOT NULL AND cert_id IS NOT NULL THEN
        -- Try to create a study plan (this simulates what signup should do)
        INSERT INTO study_plans (
            user_id,
            certification_id,
            name,
            daily_study_minutes,
            is_active
        ) VALUES (
            test_user_id,
            cert_id,
            'Test Signup Study Plan',
            30,
            true
        ) ON CONFLICT (user_id, certification_id) DO UPDATE SET
            name = EXCLUDED.name,
            daily_study_minutes = EXCLUDED.daily_study_minutes,
            updated_at = NOW();
            
        RAISE NOTICE 'Test study plan created/updated for user % with cert %', test_user_id, cert_id;
    ELSE
        RAISE NOTICE 'Missing test data: user_id=%, cert_id=%', test_user_id, cert_id;
    END IF;
END $$;

-- 3. Verify the test study plan was created
SELECT 'STUDY PLAN CREATION TEST:' as test_step;
SELECT 
    sp.id,
    sp.user_id,
    sp.name,
    sp.daily_study_minutes,
    sp.is_active,
    c.name as certification_name,
    c.test_code
FROM study_plans sp
JOIN certifications c ON sp.certification_id = c.id
WHERE sp.name = 'Test Signup Study Plan';

-- 4. Clean up test data
DELETE FROM study_plans WHERE name = 'Test Signup Study Plan';

-- =====================================================
-- SIGNUP FLOW READY FOR TESTING 🌸
-- =====================================================
