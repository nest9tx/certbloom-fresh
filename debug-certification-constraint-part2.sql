-- 🔧 PART 2: SEE WHAT VALUE WAS ACTUALLY STORED
-- Run this AFTER trying to select a certification in the UI

SELECT 'Values actually stored in certification_goal:' as debug_step;
SELECT DISTINCT 
  certification_goal,
  LENGTH(certification_goal) as value_length,
  ASCII(certification_goal) as first_char_ascii,
  certification_goal = '902' as matches_902,
  certification_goal = '901' as matches_901
FROM user_profiles 
WHERE certification_goal IS NOT NULL;

-- Show the exact characters
SELECT 'Character analysis:' as debug_step;
SELECT 
  certification_goal,
  string_to_array(certification_goal, '')::text[] as character_array
FROM user_profiles 
WHERE certification_goal IS NOT NULL
LIMIT 5;

-- Now let's put back a more permissive constraint that should work
SELECT 'Recreating constraint with better matching...' as debug_step;

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

SELECT '✅ Updated constraint with TRIM() to handle any whitespace issues.' as result;
