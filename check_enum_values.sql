-- CHECK VALID CONTENT_TYPE ENUM VALUES
-- Let's see what enum values are actually allowed

SELECT enumlabel 
FROM pg_enum 
WHERE enumtypid = (
  SELECT oid 
  FROM pg_type 
  WHERE typname = 'content_type'
);

-- Also check the enum definition
SELECT 
  n.nspname AS schema_name,
  t.typname AS type_name,
  e.enumlabel AS enum_value
FROM pg_type t 
JOIN pg_enum e ON t.oid = e.enumtypid  
JOIN pg_namespace n ON n.oid = t.typnamespace
WHERE t.typname = 'content_type'
ORDER BY e.enumsortorder;
