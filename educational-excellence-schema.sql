-- 🎓 CERTBLOOM EDUCATIONAL EXCELLENCE SCHEMA
-- Complete redesign for comprehensive teacher preparation

-- ============================================
-- CORE LEARNING ARCHITECTURE
-- ============================================

-- Enhanced content types for comprehensive learning
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'content_module_type') THEN
    CREATE TYPE content_module_type AS ENUM (
      'concept_introduction',    -- Video/text explanation of core concept
      'teaching_demonstration',  -- How to teach this to students
      'interactive_tutorial',    -- Step-by-step guided practice
      'classroom_scenario',      -- Real teaching situations
      'misconception_alert',     -- Common student errors to watch for
      'assessment_strategy',     -- How to assess student understanding
      'practice_question',       -- Individual practice problems
      'comprehensive_test',      -- Section-wide assessment
      'progress_checkpoint'      -- Mastery verification
    );
  END IF;
END $$;

-- Learning progression tracking
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'mastery_level') THEN
    CREATE TYPE mastery_level AS ENUM (
      'not_started',    -- 0-20%
      'developing',     -- 21-60%
      'proficient',     -- 61-85%
      'mastered',       -- 86-95%
      'expert'          -- 96-100%
    );
  END IF;
END $$;

-- ============================================
-- ENHANCED CONTENT MANAGEMENT
-- ============================================

-- Learning modules (replaces basic content_items)
CREATE TABLE IF NOT EXISTS learning_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  module_type content_module_type NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  
  -- Rich content structure
  content_data JSONB NOT NULL DEFAULT '{}',
  learning_objectives TEXT[] DEFAULT '{}',
  success_criteria TEXT[] DEFAULT '{}',
  prerequisite_modules UUID[] DEFAULT '{}',
  
  -- Educational metadata
  difficulty_level INTEGER CHECK (difficulty_level BETWEEN 1 AND 5) DEFAULT 1,
  estimated_minutes INTEGER DEFAULT 10,
  teaching_tips TEXT[] DEFAULT '{}',
  common_misconceptions TEXT[] DEFAULT '{}',
  classroom_applications TEXT[] DEFAULT '{}',
  
  -- Progression control
  order_index INTEGER NOT NULL DEFAULT 0,
  is_required BOOLEAN DEFAULT true,
  unlock_criteria JSONB DEFAULT '{"type": "sequential"}',
  
  -- Quality metrics
  effectiveness_score DECIMAL(3,2) DEFAULT 0.0,
  completion_rate DECIMAL(3,2) DEFAULT 0.0,
  satisfaction_rating DECIMAL(3,2) DEFAULT 0.0,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- COMPREHENSIVE ASSESSMENT SYSTEM
-- ============================================

-- Practice test configuration
CREATE TABLE IF NOT EXISTS practice_tests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  test_type TEXT CHECK (test_type IN ('concept_quiz', 'section_test', 'full_exam')),
  title TEXT NOT NULL,
  description TEXT,
  
  -- Test configuration
  question_count INTEGER DEFAULT 10,
  time_limit_minutes INTEGER DEFAULT 30,
  passing_score INTEGER DEFAULT 70,
  retake_policy JSONB DEFAULT '{"unlimited": true}',
  
  -- Adaptive settings
  difficulty_adaptation BOOLEAN DEFAULT true,
  question_pool_size INTEGER DEFAULT 50,
  adaptive_rules JSONB DEFAULT '{}',
  
  -- Requirements
  prerequisite_concepts UUID[] DEFAULT '{}',
  unlock_criteria JSONB DEFAULT '{}',
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Question bank with enhanced metadata
CREATE TABLE IF NOT EXISTS question_bank (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  practice_test_id UUID REFERENCES practice_tests(id) ON DELETE SET NULL,
  
  -- Question content
  question_text TEXT NOT NULL,
  question_type TEXT CHECK (question_type IN ('multiple_choice', 'true_false', 'short_answer', 'scenario_based')),
  correct_answer TEXT NOT NULL,
  explanation TEXT NOT NULL,
  
  -- Educational context
  learning_objective TEXT,
  cognitive_level TEXT CHECK (cognitive_level IN ('Knowledge', 'Comprehension', 'Application', 'Analysis', 'Synthesis', 'Evaluation')),
  teaching_context TEXT, -- How this relates to classroom teaching
  misconception_addressed TEXT, -- What student error this helps identify
  
  -- Difficulty and performance
  difficulty_level INTEGER CHECK (difficulty_level BETWEEN 1 AND 5) DEFAULT 1,
  estimated_time_seconds INTEGER DEFAULT 120,
  point_value INTEGER DEFAULT 1,
  
  -- Adaptive learning data
  times_used INTEGER DEFAULT 0,
  correct_rate DECIMAL(3,2) DEFAULT 0.0,
  average_time_seconds DECIMAL(8,2) DEFAULT 0.0,
  discrimination_index DECIMAL(3,2) DEFAULT 0.0, -- How well it differentiates ability levels
  
  -- Metadata
  tags TEXT[] DEFAULT '{}',
  source TEXT DEFAULT 'CertBloom Original',
  last_performance_update TIMESTAMPTZ DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enhance existing answer_choices table instead of recreating
DO $$
BEGIN
  -- Add new columns to existing answer_choices table if they don't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'answer_choices' AND column_name = 'explanation') THEN
    ALTER TABLE answer_choices ADD COLUMN explanation TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'answer_choices' AND column_name = 'common_misconception') THEN
    ALTER TABLE answer_choices ADD COLUMN common_misconception TEXT;
  END IF;
  
  -- Ensure we have question_id reference (might be content_item_id in existing schema)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'answer_choices' AND column_name = 'question_id') THEN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'answer_choices' AND column_name = 'content_item_id') THEN
      -- Add question_id column that references question_bank
      ALTER TABLE answer_choices ADD COLUMN question_id UUID REFERENCES question_bank(id) ON DELETE CASCADE;
    END IF;
  END IF;
  
  RAISE NOTICE 'Enhanced existing answer_choices table with new columns';
END $$;

-- ============================================
-- ADVANCED PROGRESS TRACKING
-- ============================================

-- Comprehensive user progress with analytics
CREATE TABLE IF NOT EXISTS user_learning_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  
  -- Mastery tracking
  current_mastery_level mastery_level DEFAULT 'not_started',
  mastery_score DECIMAL(5,2) DEFAULT 0.0, -- 0-100 percentage
  confidence_level INTEGER CHECK (confidence_level BETWEEN 1 AND 5) DEFAULT 3,
  
  -- Time and effort tracking
  total_time_minutes INTEGER DEFAULT 0,
  active_study_time_minutes INTEGER DEFAULT 0, -- Focused study time
  sessions_completed INTEGER DEFAULT 0,
  modules_completed INTEGER DEFAULT 0,
  
  -- Performance metrics
  questions_attempted INTEGER DEFAULT 0,
  questions_correct INTEGER DEFAULT 0,
  average_question_time DECIMAL(8,2) DEFAULT 0.0,
  improvement_rate DECIMAL(5,2) DEFAULT 0.0, -- Week-over-week improvement
  
  -- Learning patterns
  preferred_content_types TEXT[] DEFAULT '{}',
  struggle_areas TEXT[] DEFAULT '{}',
  strength_areas TEXT[] DEFAULT '{}',
  learning_velocity DECIMAL(5,2) DEFAULT 0.0, -- Concepts per week
  
  -- Scheduling and retention
  last_studied_at TIMESTAMPTZ,
  next_review_date TIMESTAMPTZ,
  retention_score DECIMAL(3,2) DEFAULT 1.0,
  spaced_repetition_interval INTEGER DEFAULT 1, -- Days until next review
  
  -- Timestamps
  first_attempt_at TIMESTAMPTZ DEFAULT NOW(),
  mastery_achieved_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, concept_id)
);

-- Individual learning sessions
CREATE TABLE IF NOT EXISTS learning_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  
  -- Session metadata
  session_type TEXT CHECK (session_type IN ('study', 'practice', 'assessment', 'review')),
  started_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  duration_minutes INTEGER,
  
  -- Performance data
  modules_completed INTEGER DEFAULT 0,
  questions_attempted INTEGER DEFAULT 0,
  questions_correct INTEGER DEFAULT 0,
  average_confidence DECIMAL(3,2) DEFAULT 0.0,
  
  -- Learning outcomes
  concepts_mastered TEXT[] DEFAULT '{}',
  areas_needing_review TEXT[] DEFAULT '{}',
  satisfaction_rating INTEGER CHECK (satisfaction_rating BETWEEN 1 AND 5),
  difficulty_rating INTEGER CHECK (difficulty_rating BETWEEN 1 AND 5),
  
  -- Context
  study_environment TEXT, -- home, library, etc.
  distractions_present BOOLEAN DEFAULT false,
  mood_before INTEGER CHECK (mood_before BETWEEN 1 AND 5),
  mood_after INTEGER CHECK (mood_after BETWEEN 1 AND 5),
  
  session_notes TEXT
);

-- Question attempt tracking with rich analytics
CREATE TABLE IF NOT EXISTS question_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  question_id UUID REFERENCES question_bank(id) ON DELETE CASCADE,
  session_id UUID REFERENCES learning_sessions(id) ON DELETE SET NULL,
  
  -- Attempt data
  selected_answer TEXT,
  is_correct BOOLEAN,
  time_spent_seconds INTEGER,
  confidence_before INTEGER CHECK (confidence_before BETWEEN 1 AND 5),
  confidence_after INTEGER CHECK (confidence_after BETWEEN 1 AND 5),
  
  -- Learning context
  attempt_number INTEGER DEFAULT 1,
  hint_used BOOLEAN DEFAULT false,
  explanation_viewed BOOLEAN DEFAULT false,
  flagged_for_review BOOLEAN DEFAULT false,
  
  -- Performance indicators
  hesitation_time DECIMAL(8,2), -- Time before first answer selection
  answer_changes INTEGER DEFAULT 0, -- How many times they changed their answer
  difficulty_perceived INTEGER CHECK (difficulty_perceived BETWEEN 1 AND 5),
  
  attempted_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TEACHING-FOCUSED ENHANCEMENTS
-- ============================================

-- Classroom scenarios and teaching contexts
CREATE TABLE IF NOT EXISTS teaching_scenarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  scenario_type TEXT CHECK (scenario_type IN ('classroom_management', 'lesson_planning', 'student_assessment', 'differentiation', 'misconception_handling')),
  
  title TEXT NOT NULL,
  grade_levels TEXT[] DEFAULT '{}',
  scenario_description TEXT NOT NULL,
  
  -- Teaching elements
  learning_objectives TEXT[] DEFAULT '{}',
  student_demographics TEXT,
  classroom_context TEXT,
  available_resources TEXT[] DEFAULT '{}',
  time_constraints TEXT,
  
  -- Challenge and solution
  teaching_challenge TEXT NOT NULL,
  recommended_approaches TEXT[] DEFAULT '{}',
  potential_pitfalls TEXT[] DEFAULT '{}',
  success_indicators TEXT[] DEFAULT '{}',
  
  -- Reflection prompts
  reflection_questions TEXT[] DEFAULT '{}',
  extension_activities TEXT[] DEFAULT '{}',
  
  difficulty_level INTEGER CHECK (difficulty_level BETWEEN 1 AND 5) DEFAULT 1,
  estimated_minutes INTEGER DEFAULT 15,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Student misconception library
CREATE TABLE IF NOT EXISTS misconception_library (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  
  misconception_description TEXT NOT NULL,
  why_it_occurs TEXT NOT NULL,
  how_to_identify TEXT NOT NULL,
  correction_strategies TEXT[] DEFAULT '{}',
  prevention_methods TEXT[] DEFAULT '{}',
  
  grade_levels TEXT[] DEFAULT '{}',
  frequency_rating INTEGER CHECK (frequency_rating BETWEEN 1 AND 5) DEFAULT 3,
  severity_rating INTEGER CHECK (severity_rating BETWEEN 1 AND 5) DEFAULT 3,
  
  example_student_work TEXT,
  teacher_responses TEXT[] DEFAULT '{}',
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ANALYTICS AND INSIGHTS
-- ============================================

-- Predictive analytics for success
CREATE TABLE IF NOT EXISTS success_predictions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
  
  predicted_mastery_date DATE,
  confidence_interval DECIMAL(3,2), -- 0.0 to 1.0
  required_study_time_hours DECIMAL(5,2),
  success_probability DECIMAL(3,2),
  
  factors_positive TEXT[] DEFAULT '{}',
  factors_negative TEXT[] DEFAULT '{}',
  recommendations TEXT[] DEFAULT '{}',
  
  prediction_date TIMESTAMPTZ DEFAULT NOW(),
  actual_mastery_date DATE, -- Filled in when mastery is achieved
  prediction_accuracy DECIMAL(3,2) -- Calculated after mastery
);

-- Learning pattern analysis
CREATE TABLE IF NOT EXISTS user_learning_patterns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  pattern_type TEXT CHECK (pattern_type IN ('time_preference', 'content_preference', 'difficulty_progression', 'retention_pattern')),
  pattern_data JSONB NOT NULL,
  confidence_score DECIMAL(3,2) DEFAULT 0.0,
  
  identified_at TIMESTAMPTZ DEFAULT NOW(),
  last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE (with safety checks)
-- ============================================

-- Learning modules indexes
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'learning_modules') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_learning_modules_concept_id') THEN
      CREATE INDEX idx_learning_modules_concept_id ON learning_modules(concept_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_learning_modules_type') THEN
      CREATE INDEX idx_learning_modules_type ON learning_modules(module_type);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_learning_modules_order') THEN
      CREATE INDEX idx_learning_modules_order ON learning_modules(order_index);
    END IF;
  END IF;
END $$;

-- Question bank indexes
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'question_bank') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_question_bank_concept_id') THEN
      CREATE INDEX idx_question_bank_concept_id ON question_bank(concept_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_question_bank_difficulty') THEN
      CREATE INDEX idx_question_bank_difficulty ON question_bank(difficulty_level);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_question_bank_performance') THEN
      CREATE INDEX idx_question_bank_performance ON question_bank(correct_rate);
    END IF;
  END IF;
END $$;

-- Progress tracking indexes
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_learning_progress') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_user_progress_user_id') THEN
      CREATE INDEX idx_user_progress_user_id ON user_learning_progress(user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_user_progress_concept_id') THEN
      CREATE INDEX idx_user_progress_concept_id ON user_learning_progress(concept_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_user_progress_mastery') THEN
      CREATE INDEX idx_user_progress_mastery ON user_learning_progress(mastery_score);
    END IF;
  END IF;
END $$;

-- Sessions and attempts indexes
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'learning_sessions') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_learning_sessions_user_id') THEN
      CREATE INDEX idx_learning_sessions_user_id ON learning_sessions(user_id);
    END IF;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'question_attempts') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_question_attempts_user_id') THEN
      CREATE INDEX idx_question_attempts_user_id ON question_attempts(user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_question_attempts_question_id') THEN
      CREATE INDEX idx_question_attempts_question_id ON question_attempts(question_id);
    END IF;
  END IF;
END $$;

-- Teaching resources indexes
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'teaching_scenarios') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_teaching_scenarios_concept_id') THEN
      CREATE INDEX idx_teaching_scenarios_concept_id ON teaching_scenarios(concept_id);
    END IF;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'misconception_library') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_misconceptions_concept_id') THEN
      CREATE INDEX idx_misconceptions_concept_id ON misconception_library(concept_id);
    END IF;
  END IF;
END $$;

-- Analytics indexes
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'success_predictions') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_success_predictions_user_id') THEN
      CREATE INDEX idx_success_predictions_user_id ON success_predictions(user_id);
    END IF;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_learning_patterns') THEN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_user_learning_patterns_user_id') THEN
      CREATE INDEX idx_user_learning_patterns_user_id ON user_learning_patterns(user_id);
    END IF;
  END IF;
END $$;

-- ============================================
-- FUNCTIONS FOR ENHANCED FEATURES
-- ============================================

-- Calculate mastery score based on multiple factors
CREATE OR REPLACE FUNCTION calculate_mastery_score(
  p_user_id UUID,
  p_concept_id UUID
) RETURNS DECIMAL(5,2) AS $$
DECLARE
  v_question_performance DECIMAL(5,2);
  v_time_factor DECIMAL(3,2);
  v_retention_factor DECIMAL(3,2);
  v_confidence_factor DECIMAL(3,2);
  v_final_score DECIMAL(5,2);
BEGIN
  -- Question performance (60% weight)
  SELECT 
    CASE 
      WHEN questions_attempted = 0 THEN 0
      ELSE (questions_correct::DECIMAL / questions_attempted::DECIMAL) * 100
    END INTO v_question_performance
  FROM user_learning_progress
  WHERE user_id = p_user_id AND concept_id = p_concept_id;
  
  -- Time efficiency factor (15% weight)
  -- Better scores for faster, accurate responses
  SELECT 
    CASE 
      WHEN average_question_time = 0 THEN 1.0
      WHEN average_question_time <= 60 THEN 1.0
      WHEN average_question_time <= 120 THEN 0.8
      ELSE 0.6
    END INTO v_time_factor
  FROM user_learning_progress
  WHERE user_id = p_user_id AND concept_id = p_concept_id;
  
  -- Retention factor (15% weight)
  SELECT COALESCE(retention_score, 1.0) INTO v_retention_factor
  FROM user_learning_progress
  WHERE user_id = p_user_id AND concept_id = p_concept_id;
  
  -- Confidence factor (10% weight)
  SELECT 
    CASE 
      WHEN confidence_level >= 4 THEN 1.0
      WHEN confidence_level >= 3 THEN 0.8
      ELSE 0.6
    END INTO v_confidence_factor
  FROM user_learning_progress
  WHERE user_id = p_user_id AND concept_id = p_concept_id;
  
  -- Calculate weighted final score
  v_final_score := (
    (COALESCE(v_question_performance, 0) * 0.60) +
    (COALESCE(v_question_performance, 0) * v_time_factor * 0.15) +
    (COALESCE(v_question_performance, 0) * v_retention_factor * 0.15) +
    (COALESCE(v_question_performance, 0) * v_confidence_factor * 0.10)
  );
  
  RETURN LEAST(100.0, GREATEST(0.0, v_final_score));
END;
$$ LANGUAGE plpgsql;

-- Get next recommended learning module
CREATE OR REPLACE FUNCTION get_next_learning_module(
  p_user_id UUID,
  p_concept_id UUID
) RETURNS UUID AS $$
DECLARE
  v_next_module_id UUID;
BEGIN
  -- Find next uncompleted required module in sequence
  SELECT lm.id INTO v_next_module_id
  FROM learning_modules lm
  LEFT JOIN learning_sessions ls ON lm.id = ANY(
    SELECT module_id FROM jsonb_array_elements_text(ls.session_notes::jsonb->'completed_modules') AS module_id
    WHERE ls.user_id = p_user_id AND ls.concept_id = p_concept_id
  )
  WHERE lm.concept_id = p_concept_id
    AND lm.is_required = true
    AND ls.id IS NULL
  ORDER BY lm.order_index
  LIMIT 1;
  
  RETURN v_next_module_id;
END;
$$ LANGUAGE plpgsql;

-- Success message
SELECT '🎓 Enhanced educational schema created successfully!' as status;
