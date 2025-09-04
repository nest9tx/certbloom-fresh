-- Updated Math 902 Mastery System Design
-- This addresses the time-based mastery flaws

-- First, let's check the current mastery logic in user_progress table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'user_progress'
ORDER BY ordinal_position;

-- Then create an improved mastery tracking system

-- 1. Enhanced user_progress tracking
-- Add fields for proper mastery assessment:
-- - questions_attempted: total questions tried
-- - questions_correct: total correct answers  
-- - consecutive_correct: current streak of correct answers
-- - mastery_score: weighted score based on difficulty and accuracy
-- - time_spent_learning: actual time on explanation/example content
-- - mastery_method: how they achieved mastery (score-based, streak-based, etc.)

-- Sample improved mastery criteria:
-- MASTERY ACHIEVED when:
-- 1. At least 80% accuracy on minimum 8 questions AND
-- 2. At least 3 consecutive correct answers AND  
-- 3. At least 5 minutes spent on learning content AND
-- 4. Questions span different difficulty levels

-- 2. Expand question bank per concept
-- Minimum 12-15 questions per concept (192-240 total for Math 902)
-- - 4-5 Easy questions (foundational understanding)
-- - 4-5 Medium questions (application) 
-- - 4-5 Hard questions (analysis/synthesis)

-- 3. Question variety and anti-gaming measures
-- - Randomized question selection
-- - Answer choice shuffling
-- - Time limits on questions (prevent lookup)
-- - Minimum time spent reading question text

-- 4. Progressive difficulty unlock
-- - Must show competency on easier questions before harder ones
-- - Adaptive question selection based on performance
-- - Spaced repetition for missed concepts
