-- Fix content_engagement table constraints and add missing fields
-- Run this in your Supabase SQL Editor

-- 1. Add missing fields to content_engagement if they don't exist
DO $$ 
BEGIN
    -- Add engagement_score column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'content_engagement' AND column_name = 'engagement_score') THEN
        ALTER TABLE content_engagement ADD COLUMN engagement_score DECIMAL(3,2) DEFAULT 0.5;
    END IF;

    -- Add completed_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'content_engagement' AND column_name = 'completed_at') THEN
        ALTER TABLE content_engagement ADD COLUMN completed_at TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- 2. Create unique constraint to prevent duplicates
-- Drop existing constraint if it exists and recreate
ALTER TABLE content_engagement DROP CONSTRAINT IF EXISTS unique_user_content;
CREATE UNIQUE INDEX IF NOT EXISTS unique_user_content_engagement 
ON content_engagement (user_id, content_item_id);

-- 3. Clean up any existing duplicates (keep the most recent)
DELETE FROM content_engagement 
WHERE id NOT IN (
    SELECT DISTINCT ON (user_id, content_item_id) id
    FROM content_engagement 
    ORDER BY user_id, content_item_id, created_at DESC
);

-- 4. Update RLS policies to ensure proper access
DROP POLICY IF EXISTS "Users can manage their own content engagement" ON content_engagement;
CREATE POLICY "Users can manage their own content engagement" ON content_engagement
    FOR ALL USING (auth.uid() = user_id);

-- Verify the fix
SELECT 'Content engagement table fixed successfully' as status;
