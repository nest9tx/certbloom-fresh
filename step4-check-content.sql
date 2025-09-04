-- Step 4: Check existing content items
SELECT 
    id,
    concept_id,
    type,
    title,
    LEFT(content, 100) as content_preview,
    correct_answer,
    difficulty_level
FROM content_items 
ORDER BY created_at DESC 
LIMIT 10;
