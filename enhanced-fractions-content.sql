-- Enhanced Learning Content for Adding and Subtracting Fractions
-- Run this in your Supabase SQL Editor to replace the basic content

DO $$ 
DECLARE
    concept_uuid UUID;
BEGIN
    -- Find the "Adding and Subtracting Fractions" concept
    SELECT id INTO concept_uuid 
    FROM concepts 
    WHERE name = 'Adding and Subtracting Fractions' 
    LIMIT 1;

    IF concept_uuid IS NOT NULL THEN
        -- Clear existing content
        DELETE FROM content_items WHERE concept_id = concept_uuid;
        
        -- Insert comprehensive learning content
        INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes) VALUES
        
        -- 1. Foundation Understanding
        (concept_uuid, 'text_explanation', 'Understanding Fraction Basics', 
         '{"sections": [
           "What is a fraction? A fraction represents a part of a whole, written as numerator/denominator",
           "Parts of a fraction: The numerator (top number) shows how many parts we have, the denominator (bottom number) shows how many equal parts the whole is divided into",
           "Equivalent fractions: Different fractions that represent the same amount (e.g., 1/2 = 2/4 = 3/6)",
           "Like denominators: Fractions with the same bottom number (e.g., 1/4 and 3/4)",
           "Unlike denominators: Fractions with different bottom numbers (e.g., 1/3 and 1/4)"
         ]}', 1, 10),

        -- 2. Step-by-Step Examples - Like Denominators
        (concept_uuid, 'interactive_example', 'Step-by-Step: Adding Fractions with Like Denominators',
         '{"steps": [
           "Step 1: Check that denominators are the same (like denominators)",
           "Step 2: Add only the numerators (top numbers)",
           "Step 3: Keep the denominator the same",
           "Step 4: Simplify the result if possible"
         ], "example": "1/4 + 1/4 = (1+1)/4 = 2/4 = 1/2"}', 2, 8),

        -- 3. Practice Question - Like Denominators
        (concept_uuid, 'practice_question', 'Practice: Adding Fractions with Like Denominators',
         '{"question": "What is 1/4 + 1/4?", 
           "answers": ["1/2", "2/8", "1/8", "2/4"], 
           "correct": 0, 
           "explanation": "When adding fractions with the same denominator, add the numerators: 1/4 + 1/4 = 2/4. Then simplify: 2/4 = 1/2"}', 3, 5),

        -- 4. Advanced Example - Unlike Denominators
        (concept_uuid, 'interactive_example', 'Step-by-Step: Adding Fractions with Unlike Denominators',
         '{"steps": [
           "Step 1: Find the Least Common Multiple (LCM) of the denominators",
           "Step 2: Convert both fractions to equivalent fractions with the LCM as denominator",
           "Step 3: Add the numerators",
           "Step 4: Keep the common denominator",
           "Step 5: Simplify if possible"
         ], "example": "1/3 + 1/4: LCM of 3,4 is 12. So 1/3 = 4/12 and 1/4 = 3/12. Therefore: 4/12 + 3/12 = 7/12"}', 4, 12),

        -- 5. Practice Question - Unlike Denominators
        (concept_uuid, 'practice_question', 'Practice: Adding Fractions with Unlike Denominators',
         '{"question": "What is 1/3 + 1/6?", 
           "answers": ["2/9", "1/2", "2/6", "1/9"], 
           "correct": 1, 
           "explanation": "To add 1/3 + 1/6, find common denominator 6. Convert: 1/3 = 2/6. Then: 2/6 + 1/6 = 3/6 = 1/2"}', 5, 8),

        -- 6. Subtraction Example
        (concept_uuid, 'interactive_example', 'Step-by-Step: Subtracting Fractions',
         '{"steps": [
           "Step 1: Make sure denominators are the same (find common denominator if needed)",
           "Step 2: Subtract the numerators",
           "Step 3: Keep the denominator the same",
           "Step 4: Simplify the result"
         ], "example": "3/4 - 1/4 = (3-1)/4 = 2/4 = 1/2"}', 6, 8),

        -- 7. Practice Question - Subtraction
        (concept_uuid, 'practice_question', 'Practice: Subtracting Fractions',
         '{"question": "What is 3/4 - 1/4?", 
           "answers": ["1/2", "2/4", "2/0", "4/8"], 
           "correct": 0, 
           "explanation": "Subtract numerators when denominators are same: 3/4 - 1/4 = 2/4 = 1/2"}', 7, 5),

        -- 8. Real-World Application
        (concept_uuid, 'real_world_scenario', 'Real-World Application: Pizza Fractions',
         '{"scenario": "You ordered a pizza cut into 8 slices. You ate 3/8 of the pizza and your friend ate 2/8. How much pizza did you eat together? How much is left? This shows how fraction addition helps us solve everyday problems with sharing and measuring."}', 8, 6),

        -- 9. Teaching Strategy for Educators
        (concept_uuid, 'teaching_strategy', 'Teaching Strategy: Visual Fraction Models',
         '{"strategy": "Use visual aids like fraction circles, bars, or pie charts. Have students physically manipulate fraction pieces to see that 1/4 + 1/4 makes 2/4 (half a circle). This concrete-to-abstract approach helps students understand the concept before moving to symbolic computation."}', 9, 5),

        -- 10. Common Misconception (using text_explanation type)
        (concept_uuid, 'text_explanation', 'Common Mistake: Adding Denominators',
         '{"sections": [
           "Common Mistake: Many students incorrectly add both numerators AND denominators (1/4 + 1/4 = 2/8)",
           "Why this happens: Students apply addition rules incorrectly to fractions", 
           "Remember: denominators represent the size of the pieces, so they stay the same when pieces are the same size",
           "Only add the numerators (how many pieces you have)"
         ]}', 10, 4),

        -- 11. Memory Technique (using text_explanation type)
        (concept_uuid, 'text_explanation', 'Memory Trick: Same Bottom, Add Top',
         '{"sections": [
           "Memory phrase: Same bottom, add the top; different bottom, find a common shop!",
           "This helps students remember to add numerators when denominators match",
           "And find common denominators when they do not match",
           "Practice saying this phrase until it becomes automatic"
         ]}', 11, 3);

        RAISE NOTICE 'Enhanced content created for Adding and Subtracting Fractions concept';
    ELSE
        RAISE NOTICE 'Adding and Subtracting Fractions concept not found';
    END IF;
END $$;
