-- 🔧 FIX EXISTING DATA CONSTRAINT VIOLATION
-- This script handles existing bad data before applying the constraint

-- ============================================
-- STEP 1: FIND THE PROBLEMATIC ROWS
-- ============================================

SELECT 'Finding rows that violate the constraint:' as debug_step;
SELECT 
  id,
  email,
  certification_goal,
  LENGTH(certification_goal) as goal_length,
  certification_goal IS NULL as is_null,
  TRIM(certification_goal) as trimmed_goal
FROM user_profiles 
WHERE certification_goal IS NOT NULL
  AND TRIM(certification_goal) NOT IN (
    '160', '391', '901', '902', '903', '904', '905',
    '117', '118', '119', '120', '139', '154', '164',
    '165', '166', '170', '178', '184', '192', '233',
    '236', '268', '272', '293', '351', '354', '610',
    '611', '652', '692', '696'
  );

-- ============================================
-- STEP 2: CLEAN UP THE BAD DATA
-- ============================================

-- Option A: Set invalid certification_goal values to NULL
UPDATE user_profiles 
SET certification_goal = NULL 
WHERE certification_goal IS NOT NULL
  AND TRIM(certification_goal) NOT IN (
    '160', '391', '901', '902', '903', '904', '905',
    '117', '118', '119', '120', '139', '154', '164',
    '165', '166', '170', '178', '184', '192', '233',
    '236', '268', '272', '293', '351', '354', '610',
    '611', '652', '692', '696'
  );

-- Show what we cleaned up
SELECT 'After cleanup - remaining certification goals:' as cleanup_result;
SELECT DISTINCT certification_goal 
FROM user_profiles 
WHERE certification_goal IS NOT NULL;

-- ============================================
-- STEP 3: NOW ADD THE CONSTRAINT SAFELY
-- ============================================

ALTER TABLE user_profiles 
ADD CONSTRAINT user_profiles_certification_goal_check 
CHECK (certification_goal IS NULL OR 
       TRIM(certification_goal) IN (
         '160', '391', '901', '902', '903', '904', '905',
         '117', '118', '119', '120', '139', '154', '164',
         '165', '166', '170', '178', '184', '192', '233',
         '236', '268', '272', '293', '351', '354', '610',
         '611', '652', '692', '696'
       ));

SELECT '✅ Constraint added successfully after cleaning existing data!' as final_result;
