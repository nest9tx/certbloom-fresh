-- Just get the concepts to see what we're working with
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
