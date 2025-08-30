-- Direct query to check study path content status
-- Run this to see what's missing

SELECT 
    'CONCEPT CONTENT STATUS' as status_check,
    c.name as concept_name,
    COUNT(DISTINCT ci.id) as content_items,
    COUNT(DISTINCT q.id) as questions,
    CASE 
        WHEN COUNT(DISTINCT q.id) > 0 AND COUNT(DISTINCT ci.id) = 0 
        THEN '🔴 HAS QUESTIONS BUT NO CONTENT ITEMS - NEEDS FIX'
        WHEN COUNT(DISTINCT ci.id) > 0 AND COUNT(DISTINCT q.id) = 0
        THEN '🟡 HAS CONTENT ITEMS BUT NO QUESTIONS'  
        WHEN COUNT(DISTINCT q.id) > 0 AND COUNT(DISTINCT ci.id) > 0
        THEN '🟢 READY FOR STUDY PATH'
        ELSE '❌ EMPTY CONCEPT'
    END as diagnosis
FROM certifications cert
JOIN domains d ON d.certification_id = cert.id
JOIN concepts c ON c.domain_id = d.id
LEFT JOIN content_items ci ON ci.concept_id = c.id
LEFT JOIN questions q ON q.concept_id = c.id
WHERE cert.test_code = '902'
GROUP BY c.id, c.name, d.order_index, c.order_index
ORDER BY d.order_index, c.order_index;
