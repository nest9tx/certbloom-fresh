-- CONSTRAINT-SAFE answer randomization that avoids duplicate key violations
-- This approach uses a temporary staging method to shuffle answers safely

DO $$
DECLARE
    question_record RECORD;
    choice_data RECORD;
    correct_choice_text TEXT;
    choice1_text TEXT;
    choice2_text TEXT;
    choice3_text TEXT;
    choice4_text TEXT;
    shuffled_array TEXT[];
    new_correct_position INTEGER;
    i INTEGER;
    j INTEGER;
    temp_text TEXT;
BEGIN
    RAISE NOTICE 'Starting CONSTRAINT-SAFE answer randomization...';
    
    -- First, ensure all questions have at least one correct answer
    FOR question_record IN 
        SELECT DISTINCT q.id
        FROM questions q 
        LEFT JOIN answer_choices ac ON q.id = ac.question_id AND ac.is_correct = true
        WHERE q.concept_id IS NOT NULL 
        AND ac.id IS NULL
    LOOP
        UPDATE answer_choices 
        SET is_correct = true 
        WHERE question_id = question_record.id 
        AND choice_order = 1;
        
        RAISE NOTICE 'Fixed question % - set first choice as correct', question_record.id;
    END LOOP;
    
    -- Now shuffle answers safely for each question
    FOR question_record IN 
        SELECT DISTINCT q.id
        FROM questions q 
        JOIN answer_choices ac ON q.id = ac.question_id
        WHERE q.concept_id IS NOT NULL
        GROUP BY q.id
        HAVING COUNT(ac.id) = 4
    LOOP
        -- Get the correct answer text and all choices
        SELECT ac.choice_text INTO correct_choice_text
        FROM answer_choices ac 
        WHERE ac.question_id = question_record.id 
        AND ac.is_correct = true
        LIMIT 1;
        
        -- Get all four choice texts
        SELECT ac.choice_text INTO choice1_text
        FROM answer_choices ac
        WHERE ac.question_id = question_record.id AND ac.choice_order = 1;
        
        SELECT ac.choice_text INTO choice2_text
        FROM answer_choices ac
        WHERE ac.question_id = question_record.id AND ac.choice_order = 2;
        
        SELECT ac.choice_text INTO choice3_text
        FROM answer_choices ac
        WHERE ac.question_id = question_record.id AND ac.choice_order = 3;
        
        SELECT ac.choice_text INTO choice4_text
        FROM answer_choices ac
        WHERE ac.question_id = question_record.id AND ac.choice_order = 4;
        
        -- Only proceed if we have all data
        IF correct_choice_text IS NOT NULL AND choice1_text IS NOT NULL 
           AND choice2_text IS NOT NULL AND choice3_text IS NOT NULL 
           AND choice4_text IS NOT NULL THEN
            
            -- Create array and shuffle it
            shuffled_array := ARRAY[choice1_text, choice2_text, choice3_text, choice4_text];
            
            -- Fisher-Yates shuffle
            FOR i IN REVERSE 4..2 LOOP
                j := 1 + floor(random() * i)::INTEGER;
                temp_text := shuffled_array[i];
                shuffled_array[i] := shuffled_array[j];
                shuffled_array[j] := temp_text;
            END LOOP;
            
            -- Use a safe update approach: first add unique suffixes, then update
            -- Add temporary suffixes to avoid constraint violation
            UPDATE answer_choices 
            SET choice_text = choice_text || '_TEMP_1'
            WHERE question_id = question_record.id AND choice_order = 1;
            
            UPDATE answer_choices 
            SET choice_text = choice_text || '_TEMP_2'
            WHERE question_id = question_record.id AND choice_order = 2;
            
            UPDATE answer_choices 
            SET choice_text = choice_text || '_TEMP_3'
            WHERE question_id = question_record.id AND choice_order = 3;
            
            UPDATE answer_choices 
            SET choice_text = choice_text || '_TEMP_4'
            WHERE question_id = question_record.id AND choice_order = 4;
            
            -- Now update with shuffled content and reset correctness
            UPDATE answer_choices 
            SET choice_text = shuffled_array[1], is_correct = false
            WHERE question_id = question_record.id AND choice_order = 1;
            
            UPDATE answer_choices 
            SET choice_text = shuffled_array[2], is_correct = false
            WHERE question_id = question_record.id AND choice_order = 2;
            
            UPDATE answer_choices 
            SET choice_text = shuffled_array[3], is_correct = false
            WHERE question_id = question_record.id AND choice_order = 3;
            
            UPDATE answer_choices 
            SET choice_text = shuffled_array[4], is_correct = false
            WHERE question_id = question_record.id AND choice_order = 4;
            
            -- Find where the correct answer ended up and mark it correct
            FOR i IN 1..4 LOOP
                IF shuffled_array[i] = correct_choice_text THEN
                    UPDATE answer_choices 
                    SET is_correct = true 
                    WHERE question_id = question_record.id 
                    AND choice_order = i;
                    new_correct_position := i;
                    EXIT;
                END IF;
            END LOOP;
            
            RAISE NOTICE 'Question %: correct answer moved from position 1 to position %', 
                question_record.id, new_correct_position;
        END IF;
        
    END LOOP;
    
    RAISE NOTICE 'Constraint-safe answer randomization complete!';
    
    -- Show final distribution
    RAISE NOTICE 'Final correct answer distribution:';
    FOR choice_data IN
        SELECT 
            ac.choice_order,
            COUNT(*) as count,
            ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as percentage
        FROM questions q
        JOIN answer_choices ac ON q.id = ac.question_id
        WHERE q.concept_id IS NOT NULL 
        AND ac.is_correct = true
        GROUP BY ac.choice_order
        ORDER BY ac.choice_order
    LOOP
        RAISE NOTICE 'Position % (Choice %): % questions (%.1%%)', 
            choice_data.choice_order, 
            CASE choice_data.choice_order WHEN 1 THEN 'A' WHEN 2 THEN 'B' WHEN 3 THEN 'C' WHEN 4 THEN 'D' END,
            choice_data.count, 
            choice_data.percentage;
    END LOOP;
    
END $$;
