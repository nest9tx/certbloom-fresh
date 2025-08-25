-- 🌸 FIX: Create missing user_question_attempts table
-- Run this in Supabase SQL Editor to fix the database error

-- Create the user_question_attempts table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_question_attempts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    session_id TEXT NOT NULL,
    question_id UUID NOT NULL,
    selected_answer_id UUID,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    time_spent_seconds INTEGER DEFAULT 0,
    confidence_level INTEGER DEFAULT 3,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Foreign key constraints
    CONSTRAINT fk_user_attempts_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_attempts_question FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_attempts_answer FOREIGN KEY (selected_answer_id) REFERENCES answer_choices(id) ON DELETE SET NULL
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_question_attempts_user_id ON user_question_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_user_question_attempts_session_id ON user_question_attempts(session_id);
CREATE INDEX IF NOT EXISTS idx_user_question_attempts_question_id ON user_question_attempts(question_id);
CREATE INDEX IF NOT EXISTS idx_user_question_attempts_created_at ON user_question_attempts(created_at);

-- Set up Row Level Security
ALTER TABLE user_question_attempts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own attempts
DROP POLICY IF EXISTS "Users can manage their own question attempts" ON user_question_attempts;
CREATE POLICY "Users can manage their own question attempts" ON user_question_attempts
    FOR ALL USING (auth.uid() = user_id);

-- Grant permissions
GRANT ALL ON user_question_attempts TO authenticated;

-- Verify the table was created
SELECT 
    '🌸 USER QUESTION ATTEMPTS TABLE READY' as status,
    COUNT(*) as existing_attempts
FROM user_question_attempts;
