-- Fix Database Function Signature for Content Engagement
-- Copy and paste this into Supabase SQL Editor

-- Remove old function versions
DROP FUNCTION IF EXISTS handle_content_engagement_update(UUID, UUID, INTEGER, NUMERIC);
DROP FUNCTION IF EXISTS handle_content_engagement_update(UUID, UUID, INTEGER);

-- Create the correct function with 3 parameters
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
