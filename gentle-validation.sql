-- 🌸 GENTLE VALIDATION: Ensure Sacred Fields Exist
-- Run this to verify the mandala database structure is ready

-- Check if user_progress table has the sacred mandala fields
SELECT 
    'MANDALA FIELDS CHECK' as status,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'user_progress' 
AND column_name IN ('petal_stage', 'bloom_level', 'confidence_trend', 'energy_level')
ORDER BY column_name;

-- If fields are missing, add them gently
DO $$
BEGIN
    -- Add petal_stage if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_progress' AND column_name = 'petal_stage'
    ) THEN
        ALTER TABLE user_progress ADD COLUMN petal_stage TEXT DEFAULT 'dormant';
        RAISE NOTICE '🌸 Added petal_stage field';
    END IF;
    
    -- Add bloom_level if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_progress' AND column_name = 'bloom_level'
    ) THEN
        ALTER TABLE user_progress ADD COLUMN bloom_level TEXT DEFAULT 'dim';
        RAISE NOTICE '🌸 Added bloom_level field';
    END IF;
    
    -- Add confidence_trend if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_progress' AND column_name = 'confidence_trend'
    ) THEN
        ALTER TABLE user_progress ADD COLUMN confidence_trend DECIMAL DEFAULT 0.5;
        RAISE NOTICE '🌸 Added confidence_trend field';
    END IF;
    
    -- Add energy_level if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_progress' AND column_name = 'energy_level'
    ) THEN
        ALTER TABLE user_progress ADD COLUMN energy_level DECIMAL DEFAULT 0.5;
        RAISE NOTICE '🌸 Added energy_level field';
    END IF;
END $$;

-- Verify fields are now present
SELECT 
    '🌸 SACRED FIELDS VERIFIED' as status,
    COUNT(*) as total_mandala_fields
FROM information_schema.columns 
WHERE table_name = 'user_progress' 
AND column_name IN ('petal_stage', 'bloom_level', 'confidence_trend', 'energy_level');

-- Test the getUserProgress function equivalent
SELECT 
    '🌸 SAMPLE PROGRESS DATA' as status,
    id,
    user_id,
    topic,
    mastery_level,
    petal_stage,
    bloom_level,
    confidence_trend,
    energy_level
FROM user_progress 
LIMIT 3;
