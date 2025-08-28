-- Fix content_engagement table schema
-- The table is missing the updated_at column that the code expects

-- Check if content_engagement table exists and add missing columns
DO $$
BEGIN
    -- Add updated_at column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'content_engagement' 
        AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE content_engagement ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
        RAISE NOTICE '✅ Added updated_at column to content_engagement table';
    ELSE
        RAISE NOTICE '⚠️ updated_at column already exists in content_engagement table';
    END IF;

    -- Ensure the table has proper structure
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'content_engagement'
    ) THEN
        CREATE TABLE content_engagement (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL,
            content_item_id UUID NOT NULL,
            time_spent_seconds INTEGER NOT NULL DEFAULT 0,
            completed_at TIMESTAMPTZ DEFAULT NOW(),
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW(),
            UNIQUE(user_id, content_item_id)
        );
        RAISE NOTICE '✅ Created content_engagement table with proper schema';
    END IF;
END $$;

-- Update the handle_content_engagement_update function to work with the correct schema
CREATE OR REPLACE FUNCTION handle_content_engagement_update(
    target_user_id UUID,
    target_content_item_id UUID,
    time_spent INTEGER
)
RETURNS JSON AS $$
BEGIN
    -- Use UPSERT to handle duplicates safely
    INSERT INTO content_engagement (
        user_id,
        content_item_id,
        time_spent_seconds,
        completed_at,
        created_at,
        updated_at
    ) VALUES (
        target_user_id,
        target_content_item_id,
        time_spent,
        NOW(),
        NOW(),
        NOW()
    )
    ON CONFLICT (user_id, content_item_id) 
    DO UPDATE SET
        time_spent_seconds = content_engagement.time_spent_seconds + EXCLUDED.time_spent_seconds,
        completed_at = NOW(),
        updated_at = NOW();
    
    RETURN json_build_object(
        'success', true,
        'message', 'Content engagement updated successfully'
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$ LANGUAGE plpgsql;

-- Final confirmation messages
DO $$
BEGIN
    RAISE NOTICE '🔧 Fixed content_engagement table schema and function';
    RAISE NOTICE '✅ Database tracking errors should be resolved';
END $$;
