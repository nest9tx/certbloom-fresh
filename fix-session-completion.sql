-- Fix Session Completion and Progress Tracking Issues
-- Run this in Supabase SQL Editor

-- 1. Fix the concept progress tracking function
CREATE OR REPLACE FUNCTION handle_concept_progress_update(
    target_user_id UUID,
    target_concept_id UUID,
    new_mastery_level NUMERIC DEFAULT NULL,
    new_time_spent INTEGER DEFAULT NULL,
    new_times_reviewed INTEGER DEFAULT NULL,
    set_mastered BOOLEAN DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    existing_progress RECORD;
    final_mastery NUMERIC;
    final_time INTEGER;
    final_times INTEGER;
    final_mastered BOOLEAN;
BEGIN
    -- Get existing progress
    SELECT * INTO existing_progress 
    FROM concept_progress 
    WHERE user_id = target_user_id AND concept_id = target_concept_id;
    
    -- Calculate final values
    final_mastery := COALESCE(new_mastery_level, existing_progress.mastery_level, 0);
    final_time := COALESCE(new_time_spent, existing_progress.time_spent_minutes, 0);
    final_times := COALESCE(new_times_reviewed, existing_progress.times_reviewed, 0);
    final_mastered := COALESCE(set_mastered, existing_progress.is_mastered, FALSE);
    
    -- Upsert the progress
    INSERT INTO concept_progress (
        user_id,
        concept_id,
        mastery_level,
        time_spent_minutes,
        times_reviewed,
        last_studied_at,
        is_mastered,
        created_at,
        updated_at
    ) VALUES (
        target_user_id,
        target_concept_id,
        final_mastery,
        final_time,
        final_times,
        NOW(),
        final_mastered,
        NOW(),
        NOW()
    )
    ON CONFLICT (user_id, concept_id) 
    DO UPDATE SET
        mastery_level = final_mastery,
        time_spent_minutes = final_time,
        times_reviewed = final_times,
        last_studied_at = NOW(),
        is_mastered = final_mastered,
        updated_at = NOW();
    
    -- Return the updated progress
    RETURN json_build_object(
        'user_id', target_user_id,
        'concept_id', target_concept_id,
        'mastery_level', final_mastery,
        'time_spent_minutes', final_time,
        'times_reviewed', final_times,
        'is_mastered', final_mastered,
        'last_studied_at', NOW()
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'error', SQLERRM,
            'success', false
        );
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION handle_concept_progress_update TO authenticated;

-- 2. Ensure RLS policies allow progress updates
DROP POLICY IF EXISTS "Users can update their own concept progress" ON concept_progress;
CREATE POLICY "Users can update their own concept progress" ON concept_progress
    FOR ALL TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 3. Add helpful debugging
CREATE OR REPLACE FUNCTION debug_progress_update(
    target_user_id UUID,
    target_concept_id UUID
)
RETURNS JSON AS $$
DECLARE
    user_exists BOOLEAN;
    concept_exists BOOLEAN;
    progress_exists BOOLEAN;
BEGIN
    -- Check if user exists
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE id = target_user_id) INTO user_exists;
    
    -- Check if concept exists  
    SELECT EXISTS(SELECT 1 FROM concepts WHERE id = target_concept_id) INTO concept_exists;
    
    -- Check if progress exists
    SELECT EXISTS(SELECT 1 FROM concept_progress WHERE user_id = target_user_id AND concept_id = target_concept_id) INTO progress_exists;
    
    RETURN json_build_object(
        'user_exists', user_exists,
        'concept_exists', concept_exists,
        'progress_exists', progress_exists,
        'user_id', target_user_id,
        'concept_id', target_concept_id
    );
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION debug_progress_update TO authenticated;
