-- =============================================
-- COMPREHENSIVE SESSION & UI FIXES
-- Addresses: Light UI, Auto-selection, Database constraints
-- =============================================

-- Fix 1: Handle duplicate constraint issues with proper UPSERT
CREATE OR REPLACE FUNCTION handle_concept_progress_update(
    target_user_id UUID,
    target_concept_id UUID,
    new_mastery_level DECIMAL DEFAULT NULL,
    new_time_spent INTEGER DEFAULT NULL,
    new_times_reviewed INTEGER DEFAULT NULL,
    set_mastered BOOLEAN DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    result_data JSON;
    existing_progress RECORD;
BEGIN
    -- Check for existing progress
    SELECT * INTO existing_progress 
    FROM concept_progress 
    WHERE user_id = target_user_id 
    AND concept_id = target_concept_id;

    IF existing_progress.id IS NOT NULL THEN
        -- Update existing record
        UPDATE concept_progress SET
            mastery_level = COALESCE(new_mastery_level, mastery_level),
            time_spent_minutes = COALESCE(new_time_spent, time_spent_minutes),
            times_reviewed = COALESCE(new_times_reviewed, times_reviewed),
            is_mastered = COALESCE(set_mastered, is_mastered),
            last_studied_at = NOW(),
            updated_at = NOW()
        WHERE id = existing_progress.id
        RETURNING to_json(concept_progress.*) INTO result_data;
        
        RAISE NOTICE 'Updated existing concept progress: %', existing_progress.id;
    ELSE
        -- Insert new record
        INSERT INTO concept_progress (
            user_id,
            concept_id,
            mastery_level,
            time_spent_minutes,
            times_reviewed,
            is_mastered,
            last_studied_at,
            created_at,
            updated_at
        ) VALUES (
            target_user_id,
            target_concept_id,
            COALESCE(new_mastery_level, 0.0),
            COALESCE(new_time_spent, 0),
            COALESCE(new_times_reviewed, 1),
            COALESCE(set_mastered, false),
            NOW(),
            NOW(),
            NOW()
        ) RETURNING to_json(concept_progress.*) INTO result_data;
        
        RAISE NOTICE 'Created new concept progress record';
    END IF;

    RETURN result_data;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fix 2: Create function to safely record content engagement
CREATE OR REPLACE FUNCTION handle_content_engagement_update(
    target_user_id UUID,
    target_content_item_id UUID,
    time_spent INTEGER DEFAULT 0,
    engagement_score DECIMAL DEFAULT 0.5
) RETURNS JSON AS $$
DECLARE
    result_data JSON;
BEGIN
    -- Use INSERT ... ON CONFLICT to handle duplicates safely
    INSERT INTO content_engagement (
        user_id,
        content_item_id,
        time_spent_seconds,
        engagement_score,
        completed_at,
        updated_at
    ) VALUES (
        target_user_id,
        target_content_item_id,
        time_spent,
        engagement_score,
        NOW(),
        NOW()
    )
    ON CONFLICT (user_id, content_item_id) 
    DO UPDATE SET
        time_spent_seconds = content_engagement.time_spent_seconds + EXCLUDED.time_spent_seconds,
        engagement_score = EXCLUDED.engagement_score,
        completed_at = EXCLUDED.completed_at,
        updated_at = EXCLUDED.updated_at
    RETURNING to_json(content_engagement.*) INTO result_data;

    RETURN result_data;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fix 3: Ensure proper constraints exist
DO $$
BEGIN
    -- Ensure unique constraint exists on concept_progress
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'unique_user_concept' 
        AND conrelid = 'concept_progress'::regclass
    ) THEN
        ALTER TABLE concept_progress 
        ADD CONSTRAINT unique_user_concept UNIQUE(user_id, concept_id);
        RAISE NOTICE 'Added unique constraint to concept_progress';
    END IF;

    -- Ensure unique constraint exists on content_engagement
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'unique_user_content' 
        AND conrelid = 'content_engagement'::regclass
    ) THEN
        ALTER TABLE content_engagement 
        ADD CONSTRAINT unique_user_content UNIQUE(user_id, content_item_id);
        RAISE NOTICE 'Added unique constraint to content_engagement';
    END IF;
END $$;

-- Fix 4: Grant proper permissions
GRANT EXECUTE ON FUNCTION handle_concept_progress_update TO authenticated;
GRANT EXECUTE ON FUNCTION handle_content_engagement_update TO authenticated;

-- Fix 5: Add RLS policies if they don't exist
DO $$
BEGIN
    -- Concept progress policies
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'concept_progress' 
        AND policyname = 'Users manage their own concept progress'
    ) THEN
        CREATE POLICY "Users manage their own concept progress" 
        ON concept_progress FOR ALL 
        USING (auth.uid() = user_id);
    END IF;

    -- Content engagement policies
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'content_engagement' 
        AND policyname = 'Users manage their own content engagement'
    ) THEN
        CREATE POLICY "Users manage their own content engagement" 
        ON content_engagement FOR ALL 
        USING (auth.uid() = user_id);
    END IF;
END $$;

RAISE NOTICE '🌸 Database constraint fixes applied successfully';
