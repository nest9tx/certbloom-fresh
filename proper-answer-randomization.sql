-- FIXED: Proper answer randomization that moves both content AND correctness
-- This script shuffles the actual answer choices while maintaining correctness

DO $$
DECLARE
    question_record RECORD;
    choice_data RECORD;
    choices_array TEXT[];
    correct_choice_text TEXT;
    shuffled_positions INTEGER[];
    i INTEGER;
    j INTEGER;
    temp_text TEXT;
    new_correct_position INTEGER;
BEGIN
    RAISE NOTICE 'Starting PROPER answer randomization...';
    
    -- First, ensure all questions have at least one correct answer
    FOR question_record IN 
        SELECT DISTINCT q.id
        FROM questions q 
        LEFT JOIN answer_choices ac ON q.id = ac.question_id AND ac.is_correct = true
        WHERE q.concept_id IS NOT NULL 
        AND ac.id IS NULL
    LOOP
        -- Set the first choice as correct for questions with no correct answer
        UPDATE answer_choices 
        SET is_correct = true 
        WHERE question_id = question_record.id 
        AND choice_order = 1;
        
        RAISE NOTICE 'Fixed question % - set first choice as correct', question_record.id;
    END LOOP;
    
    -- Now properly shuffle answer choices for each question
    FOR question_record IN 
        SELECT DISTINCT q.id
        FROM questions q 
        JOIN answer_choices ac ON q.id = ac.question_id
        WHERE q.concept_id IS NOT NULL
        GROUP BY q.id
        HAVING COUNT(ac.id) = 4
    LOOP
        -- Get the correct answer text before shuffling
        SELECT ac.choice_text INTO correct_choice_text
        FROM answer_choices ac 
        WHERE ac.question_id = question_record.id 
        AND ac.is_correct = true
        LIMIT 1;
        
        -- Get all choice texts in order
        SELECT array_agg(ac.choice_text ORDER BY ac.choice_order)
        INTO choices_array
        FROM answer_choices ac
        WHERE ac.question_id = question_record.id;
        
        -- Only proceed if we found the correct answer and have 4 choices
        IF correct_choice_text IS NOT NULL AND array_length(choices_array, 1) = 4 THEN
            -- Simple Fisher-Yates shuffle
            FOR i IN REVERSE 4..2 LOOP
                j := 1 + floor(random() * i)::INTEGER;
                -- Swap positions i and j
                temp_text := choices_array[i];
                choices_array[i] := choices_array[j];
                choices_array[j] := temp_text;
            END LOOP;
            
            -- Update all choices with shuffled content and reset correctness
            UPDATE answer_choices 
            SET choice_text = choices_array[1], is_correct = false
            WHERE question_id = question_record.id AND choice_order = 1;
            
            UPDATE answer_choices 
            SET choice_text = choices_array[2], is_correct = false
            WHERE question_id = question_record.id AND choice_order = 2;
            
            UPDATE answer_choices 
            SET choice_text = choices_array[3], is_correct = false
            WHERE question_id = question_record.id AND choice_order = 3;
            
            UPDATE answer_choices 
            SET choice_text = choices_array[4], is_correct = false
            WHERE question_id = question_record.id AND choice_order = 4;
            
            -- Find where the correct answer ended up and mark it correct
            FOR i IN 1..4 LOOP
                IF choices_array[i] = correct_choice_text THEN
                    UPDATE answer_choices 
                    SET is_correct = true 
                    WHERE question_id = question_record.id 
                    AND choice_order = i;
                    EXIT;
                END IF;
            END LOOP;
        END IF;
        
        correct_choice_text := NULL; -- Reset for next iteration
    END LOOP;
    
    RAISE NOTICE 'Proper answer randomization complete!';
    
    -- Show final distribution
    RAISE NOTICE 'Final correct answer distribution:';
    FOR choice_data IN
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
        RAISE NOTICE 'Position %: % questions', choice_data.choice_order, choice_data.count;
    END LOOP;
    
END $$;
