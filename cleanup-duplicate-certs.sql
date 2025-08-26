-- Clean up duplicate Math EC-6 certifications
-- Keep only one standardized version

-- First, let's see what we have
SELECT id, name, test_code, description 
FROM certifications 
WHERE test_code = '902' OR name LIKE '%Mathematics%' 
ORDER BY name;

-- Delete any duplicate or incorrectly named Math certifications
-- Keep only the properly formatted one
DELETE FROM certifications 
WHERE test_code = '902' 
  AND name != 'TExES Core Subjects EC-6: Mathematics (902)';

-- Make sure we have the correct one
INSERT INTO certifications (name, test_code, description)
SELECT 'TExES Core Subjects EC-6: Mathematics (902)', '902', 'Early Childhood through 6th Grade Mathematics'
WHERE NOT EXISTS (
    SELECT 1 FROM certifications 
    WHERE test_code = '902' 
    AND name = 'TExES Core Subjects EC-6: Mathematics (902)'
);

-- Verify the cleanup
SELECT id, name, test_code, description 
FROM certifications 
WHERE test_code = '902' OR name LIKE '%Mathematics%' 
ORDER BY name;
