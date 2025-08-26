-- Fix Elementary Mathematics test code
-- Test code 160 is for PPR, not Math EC-6
-- Math EC-6 should be test code 902

-- First, update the existing certification if it exists
UPDATE certifications 
SET test_code = '902', 
    name = 'TExES Core Subjects EC-6: Mathematics (902)'
WHERE test_code = '160' 
  AND name = 'Elementary Mathematics (EC-6)';

-- If no existing certification was updated, insert the correct one
INSERT INTO certifications (name, test_code, description)
SELECT 'TExES Core Subjects EC-6: Mathematics (902)', '902', 'Early Childhood through 6th Grade Mathematics'
WHERE NOT EXISTS (
    SELECT 1 FROM certifications WHERE test_code = '902'
);

-- Also add the PPR certification properly (test code 160)
INSERT INTO certifications (name, test_code, description)
SELECT 'TExES Pedagogy and Professional Responsibilities EC-12 (160)', '160', 'Required for all teaching certificates'
WHERE NOT EXISTS (
    SELECT 1 FROM certifications WHERE test_code = '160' AND name LIKE '%Pedagogy%'
);

-- Update any study plans that were using the wrong certification
-- Point them to the correct Math EC-6 certification
DO $$
DECLARE
    old_cert_id UUID;
    new_cert_id UUID;
BEGIN
    -- Get the old certification ID (if it exists)
    SELECT id INTO old_cert_id FROM certifications WHERE test_code = '160' AND name = 'Elementary Mathematics (EC-6)';
    
    -- Get the new certification ID
    SELECT id INTO new_cert_id FROM certifications WHERE test_code = '902';
    
    -- Update study plans if both certifications exist
    IF old_cert_id IS NOT NULL AND new_cert_id IS NOT NULL THEN
        UPDATE study_plans 
        SET certification_id = new_cert_id
        WHERE certification_id = old_cert_id;
        
        -- Update domain references
        UPDATE domains 
        SET certification_id = new_cert_id
        WHERE certification_id = old_cert_id;
        
        RAISE NOTICE 'Updated study plans and domains to use correct Math EC-6 certification';
    END IF;
END $$;
