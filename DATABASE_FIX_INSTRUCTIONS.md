# Database Fix Instructions

## The Issues Fixed

1. **Test Code Correction**: The sample data was using test code `160` for Math EC-6, but `160` is actually for PPR (Pedagogy and Professional Responsibilities). Math EC-6 should be test code `902`.

2. **RLS Permissions**: Updated the API to use service role key properly to bypass RLS restrictions when creating study plans.

3. **Certification Mapping**: All code now consistently uses test code `902` for Math EC-6.

## Required Database Update

**Run this SQL in your Supabase SQL Editor:**

```sql
-- Fix Elementary Mathematics test code
-- Test code 160 is for PPR, not Math EC-6
-- Math EC-6 should be test code 902

-- First, update the existing certification if it exists
UPDATE certifications 
SET test_code = '902', 
    name = 'TExES Core Subjects EC-6: Mathematics (902)',
    updated_at = NOW()
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
        SET certification_id = new_cert_id,
            updated_at = NOW()
        WHERE certification_id = old_cert_id;
        
        -- Update domain references
        UPDATE domains 
        SET certification_id = new_cert_id,
            updated_at = NOW()
        WHERE certification_id = old_cert_id;
        
        RAISE NOTICE 'Updated study plans and domains to use correct Math EC-6 certification';
    END IF;
END $$;
```

## What This Fixes

✅ **Certification Goal Saving**: The API now properly creates/updates study plans using service role permissions

✅ **Structured Learning Path Display**: Dashboard will show the structured learning section when user has Math EC-6 goal

✅ **Study Path Navigation**: Fixed navigation and test code lookup

✅ **Database Consistency**: All Math EC-6 references now use the correct test code `902`

## Test the Flow

1. **Go to Dashboard** → Click "Choose your certification"
2. **Select "TExES Core Subjects EC-6: Mathematics (902)"** → Click "Save Goal"
3. **Should see**: "Structured Learning Path Available" section appear
4. **Click "Begin Structured Learning →"** → Should go to study-path
5. **Should see**: Mathematics certification card with "Start Learning" button

The certification goal should now save properly and the structured learning path should be visible!
