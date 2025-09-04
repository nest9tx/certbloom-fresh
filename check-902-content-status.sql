-- Check current Math 902 content structure
-- Run this in Supabase SQL Editor

-- 1. Check domains for Math 902
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

-- 2. Check concepts for Math 902
SELECT 
  c.id,
  c.name,
  c.order_index,
  d.name as domain_name,
  d.order_index as domain_order,
  COUNT(ci.id) as content_item_count
FROM concepts c
JOIN domains d ON c.domain_id = d.id
LEFT JOIN content_items ci ON c.id = ci.concept_id
WHERE d.certification_id = '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc'
GROUP BY c.id, c.name, c.order_index, d.name, d.order_index
ORDER BY d.order_index, c.order_index;

-- 3. Check questions for Math 902
SELECT 
  q.id,
  q.question_text,
  q.difficulty_level,
  c.name as concept_name,
  c.order_index as concept_order,
  d.name as domain_name,
  d.order_index as domain_order,
  COUNT(ac.id) as answer_choice_count
FROM questions q
JOIN concepts c ON q.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
LEFT JOIN answer_choices ac ON q.id = ac.question_id
WHERE d.certification_id = '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc'
GROUP BY q.id, q.question_text, q.difficulty_level, c.name, c.order_index, d.name, d.order_index
ORDER BY d.order_index, c.order_index
LIMIT 20;

-- 4. Check content items for Math 902
SELECT 
  ci.id,
  ci.type,
  ci.title,
  ci.order_index,
  c.name as concept_name,
  c.order_index as concept_order,
  d.name as domain_name,
  d.order_index as domain_order
FROM content_items ci
JOIN concepts c ON ci.concept_id = c.id
JOIN domains d ON c.domain_id = d.id
WHERE d.certification_id = '9c8e7f6d-5b4a-3c2d-1e0f-123456789abc'
ORDER BY d.order_index, c.order_index, ci.order_index
LIMIT 20;
