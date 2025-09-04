-- 🔍 DIAGNOSE CURRENT DATABASE STRUCTURE
-- Let's see what we actually have in the database

-- Check what tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check content_items table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'content_items'
ORDER BY ordinal_position;

-- Check certifications table structure
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'certifications'
ORDER BY ordinal_position;

-- Check domains table structure
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'domains'
ORDER BY ordinal_position;

-- Check concepts table structure
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'concepts'
ORDER BY ordinal_position;

-- Check what data exists
SELECT 'Certifications' as table_name, COUNT(*) as count FROM certifications
UNION ALL
SELECT 'Domains' as table_name, COUNT(*) as count FROM domains
UNION ALL
SELECT 'Concepts' as table_name, COUNT(*) as count FROM concepts
UNION ALL
SELECT 'Content Items' as table_name, COUNT(*) as count FROM content_items;

-- Show existing certifications
SELECT test_code, certification_name FROM certifications;

-- Show 902 structure if it exists
SELECT 
    c.test_code,
    d.domain_name,
    con.concept_name,
    COUNT(ci.id) as question_count
FROM certifications c
LEFT JOIN domains d ON c.id = d.certification_id
LEFT JOIN concepts con ON d.id = con.domain_id
LEFT JOIN content_items ci ON con.id = ci.concept_id
WHERE c.test_code = '902'
GROUP BY c.test_code, d.domain_name, con.concept_name
ORDER BY d.domain_name, con.concept_name;
