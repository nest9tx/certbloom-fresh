-- Add missing enum values to content_type if they don't exist
DO $$
BEGIN
    -- Try to add 'practice' to the enum
    BEGIN
        ALTER TYPE content_type ADD VALUE IF NOT EXISTS 'practice';
    EXCEPTION
        WHEN duplicate_object THEN
            RAISE NOTICE 'practice already exists in content_type enum';
    END;
    
    -- Try to add 'explanation' to the enum  
    BEGIN
        ALTER TYPE content_type ADD VALUE IF NOT EXISTS 'explanation';
    EXCEPTION
        WHEN duplicate_object THEN
            RAISE NOTICE 'explanation already exists in content_type enum';
    END;
    
    -- Try to add 'review' to the enum
    BEGIN
        ALTER TYPE content_type ADD VALUE IF NOT EXISTS 'review';
    EXCEPTION
        WHEN duplicate_object THEN
            RAISE NOTICE 'review already exists in content_type enum';
    END;
    
    RAISE NOTICE 'Enum values added successfully';
END $$;

-- Now show all valid enum values
SELECT unnest(enum_range(NULL::content_type)) as valid_content_types;
