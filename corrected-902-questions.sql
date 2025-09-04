-- 🎯 CORRECTED 902 QUESTION CREATION
-- Using only the foreign key relationships we know exist

-- First, let's see what certification, domain, and concept data we have to work with
SELECT 'AVAILABLE CERTIFICATIONS' as section;
SELECT * FROM certifications;

SELECT 'AVAILABLE DOMAINS' as section;
SELECT * FROM domains;

SELECT 'AVAILABLE CONCEPTS' as section;
SELECT * FROM concepts;

-- Show the hierarchy for any 902-related data
SELECT 'CURRENT 902 HIERARCHY' as section;
SELECT 
    cert.*,
    d.*,
    c.*
FROM certifications cert
LEFT JOIN domains d ON cert.id = d.certification_id
LEFT JOIN concepts c ON d.id = c.domain_id
WHERE cert.test_code = '902' OR cert.id IN (
    SELECT DISTINCT certification_id FROM domains WHERE id IN (
        SELECT DISTINCT domain_id FROM concepts
    )
)
ORDER BY cert.id, d.id, c.id;

-- Once we know what exists, we can create questions for specific concept IDs
-- Template for question creation (will fill in actual concept_id values after seeing the data):

/*
INSERT INTO content_items (
    id,
    concept_id,  -- We know this column exists from foreign keys
    type,        -- We saw this in the sample data
    title,       -- We saw this in the sample data  
    content,     -- We saw this in the sample data
    correct_answer,           -- Our enhanced columns
    explanation,             -- Our enhanced columns
    detailed_explanation,    -- Our enhanced columns
    real_world_application,  -- Our enhanced columns
    confidence_building_tip, -- Our enhanced columns
    common_misconceptions,   -- Our enhanced columns
    memory_aids,            -- Our enhanced columns
    anxiety_note,           -- Our enhanced columns
    difficulty_level,       -- Our enhanced columns
    estimated_time_minutes, -- Our enhanced columns
    topic_tags,             -- Our enhanced columns
    cognitive_level,        -- Our enhanced columns
    learning_objective,     -- Our enhanced columns
    prerequisite_concepts,  -- Our enhanced columns
    related_standards,      -- Our enhanced columns
    question_source,        -- Our enhanced columns
    created_at
) VALUES (
    gen_random_uuid(),
    'ACTUAL_CONCEPT_ID_HERE',  -- Will replace with real ID from diagnostic
    'question',
    'Question Title',
    'Question content...',
    'A',
    'Basic explanation...',
    'Detailed explanation...',
    'Real world application...',
    'Confidence building tip...',
    ARRAY['Common misconception 1', 'Common misconception 2'],
    ARRAY['Memory aid 1', 'Memory aid 2'],
    'Anxiety note...',
    3,
    3,
    ARRAY['tag1', 'tag2'],
    'Comprehension',
    'Learning objective...',
    ARRAY['prerequisite1', 'prerequisite2'],
    ARRAY['TEKS 3.3F'],
    'CertBloom Original',
    NOW()
);
*/

SELECT 'Ready to create questions once we see the actual certification/domain/concept data!' as status;
