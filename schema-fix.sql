-- Fix missing foreign key relationships for concept-based learning schema

-- Add missing foreign key constraints that might be causing query issues
ALTER TABLE domains 
ADD CONSTRAINT IF NOT EXISTS domains_certification_id_fkey 
FOREIGN KEY (certification_id) REFERENCES certifications(id) ON DELETE CASCADE;

ALTER TABLE concepts 
ADD CONSTRAINT IF NOT EXISTS concepts_domain_id_fkey 
FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE;

ALTER TABLE content_items 
ADD CONSTRAINT IF NOT EXISTS content_items_concept_id_fkey 
FOREIGN KEY (concept_id) REFERENCES concepts(id) ON DELETE CASCADE;

-- Check if content_type column exists and needs proper enum type
DO $$
DECLARE
    column_exists boolean;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'content_items' 
        AND column_name = 'content_type'
    ) INTO column_exists;
    
    IF column_exists THEN
        RAISE NOTICE 'content_type column exists in content_items';
        
        -- Check if it's the right type
        DECLARE
            column_type text;
        BEGIN
            SELECT data_type FROM information_schema.columns 
            WHERE table_name = 'content_items' 
            AND column_name = 'content_type'
            INTO column_type;
            
            RAISE NOTICE 'content_type column type: %', column_type;
        END;
    ELSE
        RAISE NOTICE 'content_type column does not exist - needs to be added';
    END IF;
END $$;

-- Verify the schema integrity
SELECT 
    t.table_name,
    COUNT(c.column_name) as column_count
FROM information_schema.tables t
LEFT JOIN information_schema.columns c ON t.table_name = c.table_name
WHERE t.table_name IN ('domains', 'concepts', 'content_items', 'concept_progress', 'content_engagement', 'study_plans')
AND t.table_schema = 'public'
GROUP BY t.table_name
ORDER BY t.table_name;

SELECT 'Schema integrity check complete' as status;
