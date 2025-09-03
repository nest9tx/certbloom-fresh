-- Comprehensive fix for answer patterns and missing correct answers
-- This script will:
-- 1. Set the first choice as correct for questions that have no correct answer
-- 2. Randomize answer positions to distribute correct answers across A, B, C, D

DO $$
DECLARE
    question_record RECORD;
    correct_count INTEGER;
    random_position INTEGER;
BEGIN
    RAISE NOTICE 'Starting answer correction and randomization...';
    
    -- First, fix questions that have no correct answers
    FOR question_record IN 
        SELECT DISTINCT q.id, q.question_text
        FROM questions q 
        LEFT JOIN answer_choices ac ON q.id = ac.question_id AND ac.is_correct = true
        WHERE q.concept_id IS NOT NULL 
        AND ac.id IS NULL  -- No correct answer exists
    LOOP
        -- Set the first choice (choice_order = 1) as correct
        UPDATE answer_choices 
        SET is_correct = true 
        WHERE question_id = question_record.id 
        AND choice_order = 1;
        
        RAISE NOTICE 'Fixed question % - set first choice as correct', question_record.id;
    END LOOP;
    
    -- Now randomize answer positions for all questions
    FOR question_record IN 
        SELECT DISTINCT q.id
        FROM questions q 
        JOIN answer_choices ac ON q.id = ac.question_id
        WHERE q.concept_id IS NOT NULL
        GROUP BY q.id
        HAVING COUNT(ac.id) = 4  -- Only process questions with exactly 4 choices
    LOOP
        -- First, reset all answers to false
        UPDATE answer_choices 
        SET is_correct = false 
        WHERE question_id = question_record.id;
        
        -- Pick a random position (1-4) for the correct answer
        random_position := 1 + floor(random() * 4)::INTEGER;
        
        -- Set that position as correct
        UPDATE answer_choices 
        SET is_correct = true 
        WHERE question_id = question_record.id 
        AND choice_order = random_position;
        
    END LOOP;
    
    RAISE NOTICE 'Answer randomization complete!';
    
    -- Show final distribution
    RAISE NOTICE 'Final correct answer distribution:';
    FOR question_record IN
        SELECT 
            ac.choice_order,
            COUNT(*) as count
        FROM questions q
        JOIN answer_choices ac ON q.id = ac.question_id
        WHERE q.concept_id IS NOT NULL 
        AND ac.is_correct = true
        GROUP BY ac.choice_order
        ORDER BY ac.choice_order
    LOOP
        RAISE NOTICE 'Position %: % questions', question_record.choice_order, question_record.count;
    END LOOP;
    
END $$;
