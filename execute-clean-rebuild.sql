-- 🌸 EXECUTE CLEAN SLATE REBUILD
-- This script executes the clean slate foundation rebuild
-- Run this in Supabase SQL Editor to completely rebuild the system

\i clean-slate-foundation.sql

-- After running the foundation, verify the structure:
SELECT 'Checking certifications...' as status;
SELECT id, name, test_code FROM certifications WHERE test_code = '902';

SELECT 'Checking domains...' as status;
SELECT id, name, certification_id FROM domains WHERE certification_id = (SELECT id FROM certifications WHERE test_code = '902');

SELECT 'Checking concepts...' as status;
SELECT id, name, domain_id FROM concepts 
WHERE domain_id IN (SELECT id FROM domains WHERE certification_id = (SELECT id FROM certifications WHERE test_code = '902'))
ORDER BY domain_id, order_index;

SELECT 'Checking content items...' as status;
SELECT ci.id, ci.type, ci.title, c.name as concept_name
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
WHERE c.domain_id IN (SELECT id FROM domains WHERE certification_id = (SELECT id FROM certifications WHERE test_code = '902'))
ORDER BY c.name, ci.order_index;

SELECT 'Checking answer choices...' as status;
SELECT ac.id, ac.content_item_id, ac.choice_order, ac.is_correct, ci.title
FROM answer_choices ac
JOIN content_items ci ON ac.content_item_id = ci.id
JOIN concepts c ON ci.concept_id = c.id
WHERE c.domain_id IN (SELECT id FROM domains WHERE certification_id = (SELECT id FROM certifications WHERE test_code = '902'))
ORDER BY ci.title, ac.choice_order;

-- Test the foreign key relationships
SELECT 'Testing foreign key relationships...' as status;
SELECT COUNT(*) as orphaned_content_items 
FROM content_items ci
LEFT JOIN concepts c ON ci.concept_id = c.id
WHERE c.id IS NULL;

SELECT COUNT(*) as orphaned_answer_choices
FROM answer_choices ac
LEFT JOIN content_items ci ON ac.content_item_id = ci.id
WHERE ci.id IS NULL;

SELECT 'Clean slate rebuild verification complete!' as status;
