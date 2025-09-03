-- Script to randomize answer choices for better study patterns
-- This will shuffle answer choices while maintaining correctness

DO $$
DECLARE
    question_record RECORD;
    choices_array TEXT[];
    letters_array CHAR[];
    original_correct CHAR;
    new_correct_index INTEGER;
    new_correct_letter CHAR;
    i INTEGER;
BEGIN
    -- Process each question that has answer choices
    FOR question_record IN 
        SELECT DISTINCT q.id, q.correct_answer
        FROM questions q 
        JOIN answer_choices ac ON q.id = ac.question_id
        WHERE q.correct_answer IS NOT NULL
    LOOP
        -- Get all answer choices for this question
        SELECT array_agg(choice_text ORDER BY choice_letter), 
               array_agg(choice_letter ORDER BY choice_letter)
        INTO choices_array, letters_array
        FROM answer_choices 
        WHERE question_id = question_record.id;
        
        -- Only proceed if we have exactly 4 choices (A, B, C, D)
        IF array_length(choices_array, 1) = 4 THEN
            -- Store original correct answer
            original_correct := question_record.correct_answer;
            
            -- Find the index of the correct answer (1-based)
            FOR i IN 1..4 LOOP
                IF letters_array[i] = original_correct THEN
                    new_correct_index := i;
                    EXIT;
                END IF;
            END LOOP;
            
            -- Shuffle the choices array using random
            FOR i IN 1..4 LOOP
                DECLARE
                    j INTEGER;
                    temp_choice TEXT;
                    temp_correct_index INTEGER;
                BEGIN
                    j := 1 + floor(random() * 4)::INTEGER;
                    
                    -- Swap choices
                    temp_choice := choices_array[i];
                    choices_array[i] := choices_array[j];
                    choices_array[j] := temp_choice;
                    
                    -- Track where the correct answer moved
                    IF new_correct_index = i THEN
                        new_correct_index := j;
                    ELSIF new_correct_index = j THEN
                        new_correct_index := i;
                    END IF;
                END;
            END LOOP;
            
            -- Update answer choices with shuffled content
            UPDATE answer_choices 
            SET choice_text = choices_array[1]
            WHERE question_id = question_record.id AND choice_letter = 'A';
            
            UPDATE answer_choices 
            SET choice_text = choices_array[2]
            WHERE question_id = question_record.id AND choice_letter = 'B';
            
            UPDATE answer_choices 
            SET choice_text = choices_array[3]
            WHERE question_id = question_record.id AND choice_letter = 'C';
            
            UPDATE answer_choices 
            SET choice_text = choices_array[4]
            WHERE question_id = question_record.id AND choice_letter = 'D';
            
            -- Update the correct answer letter based on where it moved
            CASE new_correct_index
                WHEN 1 THEN new_correct_letter := 'A';
                WHEN 2 THEN new_correct_letter := 'B';
                WHEN 3 THEN new_correct_letter := 'C';
                WHEN 4 THEN new_correct_letter := 'D';
            END CASE;
            
            UPDATE questions 
            SET correct_answer = new_correct_letter
            WHERE id = question_record.id;
            
            RAISE NOTICE 'Question % - moved correct answer from % to %', 
                question_record.id, original_correct, new_correct_letter;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Answer randomization complete!';
END $$;
