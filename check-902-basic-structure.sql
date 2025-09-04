-- Check what tables exist and current Math 902 basic structure
-- Run this in Supabase SQL Editor

-- 1. Check if basic tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('domains', 'concepts', 'content_items', 'questions', 'answer_choices')
ORDER BY table_name;

-- 2. Check domains for Math 902
SELECT 
  d.id,
  d.name,
  d.order_index,
  d.description,
  COUNT(c.id) as concept_count
FROM domains d
LEFT JOIN concepts c ON d.id = c.domain_id
WHERE d.certification_id = '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc'
GROUP BY d.id, d.name, d.order_index, d.description
ORDER BY d.order_index;

-- 3. Check concepts for Math 902 (if any exist)
SELECT 
  c.id,
  c.name,
  c.order_index,
  d.name as domain_name,
  d.order_index as domain_order
FROM concepts c
JOIN domains d ON c.domain_id = d.id
WHERE d.certification_id = '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc'
ORDER BY d.order_index, c.order_index;

-- 4. Check content items for Math 902 (if table exists)
SELECT 
  ci.id,
  ci.type,
  ci.title,
  ci.order_index,
  c.name as concept_name
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
WHERE d.certification_id = '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc'
ORDER BY d.order_index, c.order_index, ci.order_index
LIMIT 10;
