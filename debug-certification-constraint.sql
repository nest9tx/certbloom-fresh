-- 🔧 DEBUG CERTIFICATION GOAL CONSTRAINT ISSUE
-- This script helps debug what values are being rejected

-- First, let's see what's currently in the constraint
SELECT 'Current constraint definition:' as debug_step;
SELECT check_clause 
FROM information_schema.check_constraints 
WHERE constraint_name = 'user_profiles_certification_goal_check';

-- Let's also check what certifications actually exist in our database
SELECT 'Certifications in database:' as debug_step;
SELECT test_code, name 
FROM certifications 
ORDER BY test_code;

-- Test if '902' would be accepted (this should work)
SELECT 'Testing constraint with 902:' as debug_step;
SELECT '902' IN (
  '160',  -- Pedagogy and Professional Responsibilities (PPR)
  '391',  -- Core Subjects EC-6 (comprehensive)
  '901',  -- Core Subjects EC-6: English Language Arts
  '902',  -- Core Subjects EC-6: Mathematics
  '903',  -- Core Subjects EC-6: Social Studies
  '904',  -- Core Subjects EC-6: Science
  '905',  -- Core Subjects EC-6: Fine Arts, Health and PE
  '117',  -- English Language Arts and Reading 4-8
  '118',  -- Mathematics 4-8
  '119',  -- Science 4-8
  '120',  -- Social Studies 4-8
  '139',  -- Mathematics 8-12
  '154',  -- English Language Arts 8-12
  '164',  -- English Language Arts and Reading 7-12
  '165',  -- Bilingual Education Supplemental
  '166',  -- English as a Second Language (ESL) Supplemental
  '170',  -- School Librarian
  '178',  -- Physical Education EC-12
  '184',  -- Bilingual Generalist EC-6
  '192',  -- Bilingual Generalist 4-8
  '233',  -- Music EC-12
  '236',  -- Music 8-12
  '268',  -- Health EC-12
  '272',  -- Generalist 4-8
  '293',  -- Core Subjects 4-8
  '351',  -- Generalist EC-4
  '354',  -- Generalist EC-6
  '610',  -- School Counselor
  '611',  -- Educational Diagnostician
  '652',  -- Reading Specialist
  '692',  -- Principal
  '696'   -- Superintendent
) as is_902_valid;

-- Let's temporarily remove the constraint to see what value is actually being sent
SELECT 'Temporarily removing constraint to debug...' as debug_step;
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_certification_goal_check;

SELECT 'Constraint temporarily removed. Try selecting a certification now, then run the next query to see what value was stored.' as instruction;
