-- Check what enum values exist for content_module_type
SELECT enumlabel 
FROM pg_enum 
WHERE enumtypid = (
    SELECT oid 
    FROM pg_type 
    WHERE typname = 'content_module_type'
)
ORDER BY enumsortorder;

-- Also check the learning_modules table structure
SELECT column_name, data_type, udt_name 
FROM information_schema.columns 
WHERE table_name = 'learning_modules' 
AND column_name = 'module_type';

-- Check existing module types in the table
SELECT DISTINCT module_type 
FROM learning_modules 
WHERE module_type IS NOT NULL;
