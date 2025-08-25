-- 🌸 STEP 2: SAMPLE DATA FOR TESTING
-- Run this AFTER running step1-core-schema.sql successfully

-- ============================================
-- SAMPLE DATA FOR TESTING
-- ============================================

-- First, let's verify the table structure exists
SELECT 'Checking table structure...' as status;

-- Insert sample certification (using the existing column structure with test_code)
-- First check if it already exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM certifications WHERE test_code = '160') THEN
        INSERT INTO certifications (name, test_code, description) VALUES 
        ('Elementary Mathematics (EC-6)', '160', 'Mathematics content knowledge for elementary teachers');
    END IF;
END $$;

-- Get the certification ID for sample data
DO $$
DECLARE
    cert_id UUID;
    domain_id UUID;
    concept_id UUID;
BEGIN
    -- Get certification ID using test_code
    SELECT id INTO cert_id FROM certifications WHERE test_code = '160';
    
    -- Insert sample domain (check if exists first)
    IF NOT EXISTS (SELECT 1 FROM domains WHERE certification_id = cert_id AND code = '001') THEN
        INSERT INTO domains (certification_id, name, code, description, weight_percentage, order_index) 
        VALUES (cert_id, 'Number Concepts and Operations', '001', 'Fundamental number concepts and arithmetic operations', 25.00, 1)
        RETURNING id INTO domain_id;
    ELSE
        SELECT id INTO domain_id FROM domains WHERE certification_id = cert_id AND code = '001';
    END IF;
    
    -- Insert sample concept
    INSERT INTO concepts (domain_id, name, description, difficulty_level, estimated_study_minutes, order_index) 
    VALUES (
        domain_id, 
        'Adding and Subtracting Fractions',
        'Understanding fraction addition and subtraction with like and unlike denominators',
        2,
        45,
        1
    )
    RETURNING id INTO concept_id;
    
    -- Insert sample content items (updated to use new content types)
    INSERT INTO content_items (concept_id, type, title, content, order_index, estimated_minutes) VALUES
    (concept_id, 'text_explanation', 'Understanding Fraction Basics', 
     '{"sections": ["What is a fraction?", "Parts of a fraction", "Equivalent fractions"]}', 1, 10),
    (concept_id, 'interactive_example', 'Step-by-Step: Adding Fractions with Like Denominators',
     '{"steps": ["Identify the denominators", "Add the numerators", "Keep the same denominator", "Simplify if needed"], "example": "1/4 + 1/4 = 2/4 = 1/2"}', 2, 15),
    (concept_id, 'practice_question', 'Practice: Basic Fraction Addition',
     '{"question": "What is 1/4 + 1/4?", "answers": ["1/2", "2/8", "1/8", "2/4"], "correct": 0, "explanation": "When adding fractions with the same denominator, add the numerators and keep the denominator the same: 1/4 + 1/4 = 2/4 = 1/2"}', 3, 5);
     
END $$;

-- ============================================
-- VERIFICATION
-- ============================================

SELECT 
    '🌸 SAMPLE DATA LOADED! 🌸' as status,
    (SELECT COUNT(*) FROM certifications) as certifications_count,
    (SELECT COUNT(*) FROM domains) as domains_count,
    (SELECT COUNT(*) FROM concepts) as concepts_count,
    (SELECT COUNT(*) FROM content_items) as content_items_count;

-- Show the structure we just created
SELECT 
    c.name as certification,
    d.name as domain,
    con.name as concept,
    ci.title as content_item,
    ci.type as content_type
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id  
LEFT JOIN content_items ci ON con.id = ci.concept_id
ORDER BY c.name, d.order_index, con.order_index, ci.order_index;
