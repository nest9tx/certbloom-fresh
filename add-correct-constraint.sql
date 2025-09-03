-- 🔧 ADD CORRECT CONSTRAINT FOR TEST CODES
-- Now that frontend sends test codes, add the proper constraint

-- First drop the existing constraint
ALTER TABLE user_profiles 
DROP CONSTRAINT IF EXISTS user_profiles_certification_goal_check;

-- Now add the correct constraint for test codes
ALTER TABLE user_profiles 
ADD CONSTRAINT user_profiles_certification_goal_check 
CHECK (certification_goal IS NULL OR 
       certification_goal IN (
         '160', '391', '901', '902', '903', '904', '905',
         '117', '118', '119', '120', '139', '154', '164',
         '165', '166', '170', '178', '184', '192', '233',
         '236', '268', '272', '293', '351', '354', '610',
         '611', '652', '692', '696'
       ));

-- Verify constraint is in place
SELECT 'Constraint added for test codes:' as status;
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE constraint_name = 'user_profiles_certification_goal_check';

SELECT '✅ Ready to test! Frontend now sends test codes like "902" instead of display names.' as instruction;
