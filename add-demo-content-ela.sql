-- Quick Demo: Add basic content items to ELA 901 certification
-- This will make 901 functional for demonstration

-- Get ELA certification and concept IDs
DO $$
DECLARE
    ela_cert_id UUID;
    reading_domain_id UUID;
    reading_concept_id UUID;
    writing_domain_id UUID;
    writing_concept_id UUID;
BEGIN
    -- Get ELA certification
    SELECT id INTO ela_cert_id FROM certifications WHERE test_code = '901';
    
    -- Get Foundations of Reading domain and concept
    SELECT id INTO reading_domain_id FROM domains WHERE certification_id = ela_cert_id AND code = 'ELA1';
    SELECT id INTO reading_concept_id FROM concepts WHERE domain_id = reading_domain_id LIMIT 1;
    
    -- Get Writing domain and concept
    SELECT id INTO writing_domain_id FROM domains WHERE certification_id = ela_cert_id AND code = 'ELA3';
    SELECT id INTO writing_concept_id FROM concepts WHERE domain_id = writing_domain_id LIMIT 1;
    
    -- Add content items for Reading concept
    INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes, is_required) VALUES
    (reading_concept_id, 'text_explanation', 'Phonics Fundamentals', 
     '{"sections": ["Understanding phonics is essential for early reading development.", "Phonics teaches the relationship between letters and sounds.", "Students learn to decode words by blending sounds together."]}', 
     1, 10, true),
    
    (reading_concept_id, 'interactive_example', 'Phonics in Action', 
     '{"example": "The word ''cat'' has three phonemes: /c/ /a/ /t/", "steps": ["Identify individual sounds", "Blend sounds together", "Recognize the complete word"]}', 
     2, 5, true),
    
    (reading_concept_id, 'practice_question', 'Reading Assessment', 
     '{"question": "Which teaching strategy best helps students decode unfamiliar words?", "answers": ["Memorizing sight words", "Using phonics skills", "Guessing from context", "Looking at pictures"], "correct": 1, "explanation": "Phonics skills provide students with systematic tools to decode unfamiliar words by understanding letter-sound relationships."}', 
     3, 5, true);
    
    -- Add content items for Writing concept
    INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes, is_required) VALUES
    (writing_concept_id, 'text_explanation', 'Writing Process Stages', 
     '{"sections": ["The writing process includes prewriting, drafting, revising, editing, and publishing.", "Each stage serves a specific purpose in developing quality writing.", "Students should understand and practice each stage systematically."]}', 
     1, 10, true),
    
    (writing_concept_id, 'practice_question', 'Writing Process Question', 
     '{"question": "What is the primary purpose of the revising stage in the writing process?", "answers": ["Correcting spelling errors", "Adding new ideas and improving organization", "Checking grammar", "Preparing for publication"], "correct": 1, "explanation": "Revising focuses on improving content, organization, and clarity of ideas, while editing addresses mechanics like spelling and grammar."}', 
     2, 5, true);
    
    RAISE NOTICE 'Demo content added successfully to ELA 901 certification!';
END $$;
