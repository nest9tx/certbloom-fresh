-- Check the structure of question content items
SELECT 
    id,
    type,
    title,
    content,
    question_text,
    explanation,
    (
        SELECT json_agg(json_build_object(
            'id', ac.id,
            'choice_text', ac.choice_text,
            'is_correct', ac.is_correct,
            'order_number', ac.order_number
        ) ORDER BY ac.order_number)
        FROM answer_choices ac 
        WHERE ac.content_item_id = ci.id
    ) as answer_choices_data
FROM content_items ci
WHERE type = 'question'
LIMIT 3;

-- Also check what types actually exist
SELECT type, count(*) 
FROM content_items 
GROUP BY type;
