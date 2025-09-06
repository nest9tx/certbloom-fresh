-- Test script to isolate the user_learning_patterns table creation issue

-- First, test ENUM creation
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'content_module_type') THEN
    CREATE TYPE content_module_type AS ENUM (
      'concept_introduction',
      'teaching_demonstration',
      'interactive_tutorial',
      'classroom_scenario',
      'misconception_alert',
      'assessment_strategy',
      'practice_question',
      'comprehensive_test',
      'progress_checkpoint'
    );
    RAISE NOTICE 'Created content_module_type ENUM';
  ELSE
    RAISE NOTICE 'content_module_type ENUM already exists';
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'mastery_level') THEN
    CREATE TYPE mastery_level AS ENUM (
      'not_started',
      'developing',
      'proficient',
      'mastered',
      'expert'
    );
    RAISE NOTICE 'Created mastery_level ENUM';
  ELSE
    RAISE NOTICE 'mastery_level ENUM already exists';
  END IF;
END $$;

-- Test user_learning_patterns table creation
DO $$
BEGIN
  -- Check if table exists first
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_learning_patterns') THEN
    RAISE NOTICE 'user_learning_patterns table already exists';
  ELSE
    -- Try to create the table
    CREATE TABLE user_learning_patterns (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
      
      pattern_type TEXT CHECK (pattern_type IN ('time_preference', 'content_preference', 'difficulty_progression', 'retention_pattern')),
      pattern_data JSONB NOT NULL,
      confidence_score DECIMAL(3,2) DEFAULT 0.0,
      
      identified_at TIMESTAMPTZ DEFAULT NOW(),
      last_updated TIMESTAMPTZ DEFAULT NOW()
    );
    RAISE NOTICE 'Created user_learning_patterns table successfully';
  END IF;
END $$;

-- Test index creation
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_user_learning_patterns_user_id') THEN
    RAISE NOTICE 'Index idx_user_learning_patterns_user_id already exists';
  ELSE
    CREATE INDEX idx_user_learning_patterns_user_id ON user_learning_patterns(user_id);
    RAISE NOTICE 'Created index idx_user_learning_patterns_user_id successfully';
  END IF;
END $$;

SELECT 'Test completed' as status;
