-- Complete fix for blank slates issue
-- Step 1: Add missing enum values
-- Step 2: Create content items for concepts with questions but no content

-- Step 1: Add missing enum values to content_type
DO $$
BEGIN
    -- Try to add 'practice' to the enum
    BEGIN
        ALTER TYPE content_type ADD VALUE IF NOT EXISTS 'practice';
        RAISE NOTICE 'Added practice to content_type enum';
    EXCEPTION
        WHEN duplicate_object THEN
            RAISE NOTICE 'practice already exists in content_type enum';
    END;
    
    -- Try to add 'explanation' to the enum  
    BEGIN
        ALTER TYPE content_type ADD VALUE IF NOT EXISTS 'explanation';
        RAISE NOTICE 'Added explanation to content_type enum';
    EXCEPTION
        WHEN duplicate_object THEN
            RAISE NOTICE 'explanation already exists in content_type enum';
    END;
    
    -- Try to add 'review' to the enum
    BEGIN
        ALTER TYPE content_type ADD VALUE IF NOT EXISTS 'review';
        RAISE NOTICE 'Added review to content_type enum';
    EXCEPTION
        WHEN duplicate_object THEN
            RAISE NOTICE 'review already exists in content_type enum';
    END;
END $$;

-- Step 2: Create content items for concepts with questions but no content
DO $$
DECLARE
    cert_record RECORD;
    concept_record RECORD;
    content_count INTEGER;
    question_count INTEGER;
BEGIN
    RAISE NOTICE '🔧 Starting content creation for blank slate concepts...';
    
    -- Loop through target certifications
    FOR cert_record IN 
        SELECT id, test_code, name 
        FROM certifications 
        WHERE test_code IN ('391', '901', '903', '904', '905')
    LOOP
        RAISE NOTICE '🔍 Processing certification: % (%)', cert_record.name, cert_record.test_code;
        
        -- Find concepts with questions but no content
        FOR concept_record IN
            SELECT DISTINCT c.id, c.name
            FROM concepts c
            JOIN domains d ON c.domain_id = d.id
            WHERE d.certification_id = cert_record.id
            AND EXISTS (
                SELECT 1 FROM questions q WHERE q.concept_id = c.id
            )
            AND NOT EXISTS (
                SELECT 1 FROM content_items ci WHERE ci.concept_id = c.id
            )
        LOOP
            -- Count questions for this concept
            SELECT COUNT(*) INTO question_count
            FROM questions 
            WHERE concept_id = concept_record.id;
            
            RAISE NOTICE '  📝 Creating content for: % (% questions)', concept_record.name, question_count;
            
            -- Create essential content items
            INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes)
            VALUES 
                -- Introduction
                (concept_record.id, 'explanation', 'Introduction to ' || concept_record.name, 
                 jsonb_build_object(
                     'sections', ARRAY[
                         'Welcome to ' || concept_record.name || '!',
                         'This concept includes ' || question_count || ' practice questions designed to help you master the material.',
                         'Each question follows the format you will see on the actual TExES exam.',
                         'Take your time to read each question carefully and think through your answer.',
                         'After completing practice questions, you will receive detailed feedback.'
                     ]
                 ), 1, 5),
                
                -- Practice Session  
                (concept_record.id, 'practice', 'Practice Questions: ' || concept_record.name,
                 jsonb_build_object(
                     'session_type', 'concept_practice',
                     'description', 'Practice questions for ' || concept_record.name,
                     'target_question_count', LEAST(question_count, 15),
                     'estimated_minutes', LEAST(question_count, 15) * 2,
                     'instructions', 'Complete these practice questions to test your understanding of ' || concept_record.name || '.'
                 ), 2, LEAST(question_count, 15) * 2),
                
                -- Review
                (concept_record.id, 'review', 'Concept Review: ' || concept_record.name,
                 jsonb_build_object(
                     'sections', ARRAY[
                         'Great work! You have completed the practice questions for ' || concept_record.name || '.',
                         'Review any questions you found challenging and make sure you understand the explanations.',
                         'If you scored well, you are ready to move on to the next concept.',
                         'If you need more practice, consider reviewing this concept again before proceeding.'
                     ]
                 ), 3, 3);
        END LOOP;
    END LOOP;
    
    RAISE NOTICE '✅ Content creation complete!';
END $$;

-- Step 3: Verification
SELECT 
    'VERIFICATION RESULTS' as status,
    cert.test_code,
    cert.name as certification_name,
    COUNT(DISTINCT c.id) as concepts_with_questions,
    COUNT(DISTINCT ci.id) as content_items_created,
    COUNT(DISTINCT q.id) as total_questions
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
JOIN questions q ON q.concept_id = c.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
WHERE cert.test_code IN ('391', '901', '902', '903', '904', '905')
GROUP BY cert.test_code, cert.name
ORDER BY cert.test_code;
