-- STEP 1: Check if the study_plans table has the new columns
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'study_plans' 
ORDER BY ordinal_position;

-- STEP 2: If columns are missing, add them
ALTER TABLE study_plans 
ADD COLUMN IF NOT EXISTS is_primary BOOLEAN DEFAULT FALSE;

ALTER TABLE study_plans 
ADD COLUMN IF NOT EXISTS guarantee_eligible BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS guarantee_start_date DATE,
ADD COLUMN IF NOT EXISTS first_attempt_date DATE,
ADD COLUMN IF NOT EXISTS guarantee_used BOOLEAN DEFAULT FALSE;

-- STEP 3: Create indexes
CREATE INDEX IF NOT EXISTS idx_study_plans_primary ON study_plans(user_id, is_primary) WHERE is_primary = true;

CREATE UNIQUE INDEX IF NOT EXISTS idx_study_plans_one_primary_per_user 
ON study_plans(user_id) WHERE is_primary = true;

-- STEP 4: Check current data
SELECT 
  id, 
  user_id, 
  certification_id,
  is_active, 
  is_primary,
  created_at
FROM study_plans 
WHERE user_id = '7a0a2834-e2a8-4c9c-b304-e3d4a29f0487'
ORDER BY created_at DESC;

-- STEP 5: Check if certifications table exists and has the right structure
SELECT id, name, test_code FROM certifications WHERE test_code = '160' LIMIT 1;
