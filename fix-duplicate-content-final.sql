-- Remove Duplicate Content Items and Establish Clean Question Flow
-- This addresses the duplicate fraction questions issue

-- Step 1: Remove duplicate manually-inserted content that conflicts with database questions
DELETE FROM content_items 
WHERE title IN (
    'Practice: Adding Fractions with Like Denominators',
    'Practice: Adding Fractions with Unlike Denominators - 1/3 + 1/6', 
    'Practice: Subtracting Fractions - 3/4 - 1/4'
) 
AND type = 'practice_question'
AND content->>'question' IS NOT NULL;

-- Step 2: Clean up any other duplicate content items by title and type
WITH duplicates AS (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY concept_id, title, type ORDER BY created_at) as rn
    FROM content_items
)
DELETE FROM content_items 
WHERE id IN (
    SELECT id FROM duplicates WHERE rn > 1
);

-- Step 3: Update the database function signature to match what the code expects
DROP FUNCTION IF EXISTS handle_content_engagement_update(UUID, UUID, INTEGER, NUMERIC);
DROP FUNCTION IF EXISTS handle_content_engagement_update(UUID, UUID, INTEGER);

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

-- Step 4: Add proper challenging fraction content for real learning
INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes)
SELECT 
    c.id as concept_id,
    'practice_question' as type,
    'Advanced Practice: Mixed Number Addition' as title,
    '{"question": "What is 2 1/3 + 1 5/6?", 
      "answers": ["3 2/9", "4 1/6", "3 7/6", "4 1/3"], 
      "correct": 1, 
      "explanation": "Convert to improper fractions: 2 1/3 = 7/3, 1 5/6 = 11/6. Find common denominator 6: 7/3 = 14/6. Then: 14/6 + 11/6 = 25/6 = 4 1/6"}' as content,
    10 as order_index,
    8 as estimated_minutes
FROM concepts c 
WHERE c.name ILIKE '%Adding and Subtracting Fractions%'
AND NOT EXISTS (
    SELECT 1 FROM content_items ci 
    WHERE ci.concept_id = c.id 
    AND ci.title = 'Advanced Practice: Mixed Number Addition'
);

INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes)
SELECT 
    c.id as concept_id,
    'practice_question' as type,
    'Advanced Practice: Fraction Word Problem' as title,
    '{"question": "Sarah ate 2/5 of a pizza and her brother ate 1/4 of the same pizza. How much pizza did they eat together?", 
      "answers": ["3/9", "13/20", "3/4", "6/20"], 
      "correct": 1, 
      "explanation": "Find common denominator for 2/5 + 1/4. LCD is 20: 2/5 = 8/20, 1/4 = 5/20. Then: 8/20 + 5/20 = 13/20"}' as content,
    11 as order_index,
    10 as estimated_minutes
FROM concepts c 
WHERE c.name ILIKE '%Adding and Subtracting Fractions%'
AND NOT EXISTS (
    SELECT 1 FROM content_items ci 
    WHERE ci.concept_id = c.id 
    AND ci.title = 'Advanced Practice: Fraction Word Problem'
);

-- Step 5: Add teaching strategy content for progression
INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes)
SELECT 
    c.id as concept_id,
    'teaching_strategy' as type,
    'Teaching Strategy: Fraction Addition Progression' as title,
    '{"strategy": "Start with visual models (pie charts, fraction bars), then move to like denominators, finally tackle unlike denominators. Always connect to real-world examples like cooking measurements.", "techniques": ["Visual fraction models", "Number line activities", "Real-world applications", "Peer tutoring"], "scaffolding": "Begin with unit fractions, progress to proper fractions, then mixed numbers"}' as content,
    12 as order_index,
    6 as estimated_minutes
FROM concepts c 
WHERE c.name ILIKE '%Adding and Subtracting Fractions%'
AND NOT EXISTS (
    SELECT 1 FROM content_items ci 
    WHERE ci.concept_id = c.id 
    AND ci.title = 'Teaching Strategy: Fraction Addition Progression'
);

-- Final cleanup and verification
RAISE NOTICE '🧹 Removed duplicate content items';
RAISE NOTICE '➕ Added challenging fraction practice questions';
RAISE NOTICE '🎯 Content should now progress from intro (1/2 answers) to advanced problems';
RAISE NOTICE '✅ Database function signature fixed for content engagement tracking';
