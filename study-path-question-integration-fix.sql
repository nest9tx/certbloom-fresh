-- Study Path Question Integration Fix
-- Connect the study path concept system to our actual question bank
-- This will make our 475 Math 902 questions available in study sessions

-- STEP 1: Add questions count to concept structure queries
-- Check current content_items vs actual questions per concept
SELECT 
    'CONCEPT CONTENT ANALYSIS' as analysis_type,
    c.name as concept_name,
    COUNT(DISTINCT ci.id) as content_items_count,
    COUNT(DISTINCT q.id) as questions_count,
    CASE 
        WHEN COUNT(DISTINCT q.id) > 0 AND COUNT(DISTINCT ci.id) = 0 
        THEN '🔴 HAS QUESTIONS BUT NO CONTENT ITEMS'
        WHEN COUNT(DISTINCT ci.id) > 0 AND COUNT(DISTINCT q.id) = 0
        THEN '🟡 HAS CONTENT ITEMS BUT NO QUESTIONS'  
        WHEN COUNT(DISTINCT q.id) > 0 AND COUNT(DISTINCT ci.id) > 0
        THEN '🟢 HAS BOTH CONTENT AND QUESTIONS'
        ELSE '❌ EMPTY CONCEPT'
    END as status
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY c.id, c.name, d.order_index, c.order_index
ORDER BY d.order_index, c.order_index;

-- STEP 2: Create practice content items from our actual questions
-- This will populate the study path with real practice sessions
DO $$
DECLARE
    concept_record RECORD;
    question_record RECORD;
    content_order INTEGER;
BEGIN
    -- For each concept with questions but no content
    FOR concept_record IN 
        SELECT c.id as concept_id, c.name as concept_name
        FROM certifications cert
        JOIN domains d ON d.certification_id = cert.id
        JOIN concepts c ON c.domain_id = d.id
        WHERE cert.test_code = '902'
          AND c.id IN (
              SELECT DISTINCT q.concept_id 
              FROM questions q 
              WHERE q.concept_id = c.id
          )
          AND c.id NOT IN (
              SELECT DISTINCT ci.concept_id 
              FROM content_items ci 
              WHERE ci.concept_id = c.id
          )
    LOOP
        RAISE NOTICE 'Processing concept: %', concept_record.concept_name;
        
        -- Add introduction content item
        INSERT INTO content_items (
            concept_id, 
            type, 
            title, 
            content, 
            order_index, 
            estimated_minutes
        ) VALUES (
            concept_record.concept_id,
            'explanation',
            'Introduction to ' || concept_record.concept_name,
            'Welcome to ' || concept_record.concept_name || '! This concept includes comprehensive practice questions to help you master key skills.',
            1,
            5
        );
        
        -- Add practice session content item that links to questions
        INSERT INTO content_items (
            concept_id,
            type,
            title, 
            content,
            order_index,
            estimated_minutes
        ) VALUES (
            concept_record.concept_id,
            'practice',
            'Practice Questions: ' || concept_record.concept_name,
            'Complete practice questions for ' || concept_record.concept_name || '. This session includes varied difficulty levels to build mastery.',
            2,
            20
        );
        
        -- Add review content item
        INSERT INTO content_items (
            concept_id,
            type,
            title,
            content, 
            order_index,
            estimated_minutes
        ) VALUES (
            concept_record.concept_id,
            'review',
            'Review & Summary: ' || concept_record.concept_name,
            'Review key concepts and strategies for ' || concept_record.concept_name || '. Reflect on areas of strength and opportunities for growth.',
            3,
            10
        );
        
    END LOOP;
    
    RAISE NOTICE 'Content items created for all concepts with questions!';
END $$;

-- STEP 3: Verify the fix
SELECT 
    'POST-FIX VERIFICATION' as verification_type,
    c.name as concept_name,
    COUNT(DISTINCT ci.id) as content_items_count,
    COUNT(DISTINCT q.id) as questions_count,
    CASE 
        WHEN COUNT(DISTINCT q.id) > 0 AND COUNT(DISTINCT ci.id) > 0
        THEN '✅ READY FOR STUDY PATH'
        ELSE '❌ STILL MISSING CONTENT'
    END as study_path_status
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY c.id, c.name, d.order_index, c.order_index
ORDER BY d.order_index, c.order_index;
