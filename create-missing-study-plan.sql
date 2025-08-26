-- Create the missing study plan for your Math EC-6 signup
INSERT INTO study_plans (
  user_id,
  certification_id,
  daily_study_minutes,
  is_active,
  is_primary,
  guarantee_eligible,
  guarantee_start_date,
  created_at,
  updated_at
) VALUES (
  '7a0a2834-e2a8-4c9d-b304-b3fa29ff8487',  -- Your CORRECT user ID
  'eee5c73b-254e-4d86-b760-f5cd15425962',  -- Math EC-6 certification ID
  30,                                        -- 30 minutes daily
  true,                                      -- Active
  true,                                      -- Primary plan
  true,                                      -- Guarantee eligible
  CURRENT_DATE,                              -- Guarantee starts today
  NOW(),                                     -- Created now
  NOW()                                      -- Updated now
);

-- Verify the study plan was created
SELECT 
  id, 
  user_id, 
  certification_id,
  is_active, 
  is_primary,
  guarantee_eligible,
  created_at
FROM study_plans 
WHERE user_id = '7a0a2834-e2a8-4c9d-b304-b3fa29ff8487'
ORDER BY created_at DESC;
