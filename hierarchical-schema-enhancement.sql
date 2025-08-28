-- Enhanced Database Schema for Hierarchical Question Tagging
-- Run this in Supabase SQL Editor to add secondary certification support

-- Add secondary certifications array to questions table
ALTER TABLE public.questions 
ADD COLUMN IF NOT EXISTS secondary_certification_ids UUID[] DEFAULT '{}';

-- Add index for efficient secondary certification queries
CREATE INDEX IF NOT EXISTS idx_questions_secondary_certifications 
ON public.questions USING GIN(secondary_certification_ids);

-- Add comment explaining the hierarchical structure
COMMENT ON COLUMN public.questions.secondary_certification_ids IS 
'Array of certification IDs where this question also applies. Used for hierarchical certifications like EC-6 Core Subjects (391) which includes content from Math (902), ELA (901), etc.';

-- Create function to automatically tag questions for hierarchical certifications
CREATE OR REPLACE FUNCTION auto_tag_hierarchical_certifications()
RETURNS TRIGGER AS $$
DECLARE
    core_subjects_391_id UUID;
    current_cert_name TEXT;
BEGIN
    -- Get the Core Subjects EC-6 (391) certification ID
    SELECT id INTO core_subjects_391_id 
    FROM public.certifications 
    WHERE name ILIKE '%Core Subjects EC-6%' AND (test_code = '391' OR name ILIKE '%(391)%')
    LIMIT 1;
    
    -- Get the current certification name
    SELECT name INTO current_cert_name
    FROM public.certifications
    WHERE id = NEW.certification_id;
    
    -- Auto-tag questions for Core Subjects (391) if they belong to component exams
    IF core_subjects_391_id IS NOT NULL AND current_cert_name IS NOT NULL THEN
        -- Check if this is a component certification (Math 902, ELA 901, etc.)
        IF (current_cert_name ILIKE '%Mathematics%' AND current_cert_name ILIKE '%(902)%') OR
           (current_cert_name ILIKE '%English%' AND current_cert_name ILIKE '%(901)%') OR
           (current_cert_name ILIKE '%Science%' AND current_cert_name ILIKE '%(904)%') OR
           (current_cert_name ILIKE '%Social Studies%' AND current_cert_name ILIKE '%(903)%') OR
           (current_cert_name ILIKE '%Fine Arts%' AND current_cert_name ILIKE '%(905)%') THEN
            
            -- Add Core Subjects (391) as secondary certification if not already present
            IF NOT (core_subjects_391_id = ANY(COALESCE(NEW.secondary_certification_ids, '{}'))) THEN
                NEW.secondary_certification_ids := COALESCE(NEW.secondary_certification_ids, '{}') || ARRAY[core_subjects_391_id];
            END IF;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically apply hierarchical tagging
DROP TRIGGER IF EXISTS trigger_auto_tag_hierarchical ON public.questions;
CREATE TRIGGER trigger_auto_tag_hierarchical
    BEFORE INSERT OR UPDATE ON public.questions
    FOR EACH ROW
    EXECUTE FUNCTION auto_tag_hierarchical_certifications();

-- Create view for easy querying of questions by all certifications (primary + secondary)
CREATE OR REPLACE VIEW questions_with_all_certifications AS
SELECT 
    q.*,
    primary_cert.name as primary_certification_name,
    primary_cert.test_code as primary_test_code,
    array_agg(DISTINCT secondary_cert.name) FILTER (WHERE secondary_cert.id IS NOT NULL) as secondary_certification_names,
    array_agg(DISTINCT secondary_cert.test_code) FILTER (WHERE secondary_cert.id IS NOT NULL) as secondary_test_codes
FROM public.questions q
LEFT JOIN public.certifications primary_cert ON q.certification_id = primary_cert.id
LEFT JOIN LATERAL unnest(COALESCE(q.secondary_certification_ids, '{}')) as secondary_id ON true
LEFT JOIN public.certifications secondary_cert ON secondary_cert.id = secondary_id
GROUP BY q.id, primary_cert.name, primary_cert.test_code;

-- Grant permissions
GRANT SELECT ON questions_with_all_certifications TO authenticated;

-- Function to get questions for a certification (including secondary assignments)
CREATE OR REPLACE FUNCTION get_questions_for_certification(target_cert_id UUID)
RETURNS TABLE(
    question_id UUID,
    question_text TEXT,
    question_type TEXT,
    difficulty_level TEXT,
    primary_certification_name TEXT,
    secondary_certification_names TEXT[],
    topic_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        q.id as question_id,
        q.question_text,
        q.question_type,
        q.difficulty_level,
        primary_cert.name as primary_certification_name,
        array_agg(DISTINCT secondary_cert.name) FILTER (WHERE secondary_cert.id IS NOT NULL) as secondary_certification_names,
        t.name as topic_name
    FROM public.questions q
    LEFT JOIN public.certifications primary_cert ON q.certification_id = primary_cert.id
    LEFT JOIN LATERAL unnest(COALESCE(q.secondary_certification_ids, '{}')) as secondary_id ON true
    LEFT JOIN public.certifications secondary_cert ON secondary_cert.id = secondary_id
    LEFT JOIN public.topics t ON q.topic_id = t.id
    WHERE q.certification_id = target_cert_id 
       OR target_cert_id = ANY(COALESCE(q.secondary_certification_ids, '{}'))
    GROUP BY q.id, q.question_text, q.question_type, q.difficulty_level, primary_cert.name, t.name;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION get_questions_for_certification TO authenticated;
