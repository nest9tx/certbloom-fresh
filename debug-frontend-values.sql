-- 🔧 SIMPLE CONSTRAINT-FREE DEBUG
-- Since we have clean data, let's see exactly what the frontend sends

-- Remove any existing constraint
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_certification_goal_check;

-- Add a very simple logging trigger to see what values are being attempted
CREATE OR REPLACE FUNCTION log_certification_goal_attempts()
RETURNS trigger AS $$
BEGIN
  -- Log any certification_goal updates for debugging
  IF NEW.certification_goal IS NOT NULL THEN
    RAISE NOTICE 'CERTIFICATION GOAL DEBUG: User % attempting to set goal to [%] (length: %, ascii: %)', 
      NEW.id, 
      NEW.certification_goal, 
      LENGTH(NEW.certification_goal),
      string_to_array(NEW.certification_goal, '')::text[];
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to log attempts
DROP TRIGGER IF EXISTS log_cert_goal_trigger ON user_profiles;
CREATE TRIGGER log_cert_goal_trigger
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  WHEN (OLD.certification_goal IS DISTINCT FROM NEW.certification_goal)
  EXECUTE FUNCTION log_certification_goal_attempts();

SELECT 'Debug logging enabled. Now try selecting a certification and check the Postgres logs!' as instruction;
SELECT 'The logs will show exactly what value the frontend is sending.' as note;
