-- Database Diagnostic Check
-- Run this in Supabase SQL Editor to check current state

-- 1. Check if questions table exists and structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'questions' 
ORDER BY ordinal_position;

-- 2. Count questions in database
SELECT COUNT(*) as total_questions FROM questions;

-- 3. Check questions by certification (if any exist)
SELECT 
    certification_id,
    COUNT(*) as question_count
FROM questions 
GROUP BY certification_id;

-- 4. Check questions by domain (if any exist)  
SELECT 
    domain,
    COUNT(*) as question_count
FROM questions 
GROUP BY domain;

-- 5. Check sample questions (first 3)
SELECT 
    id,
    question_text,
    certification_id,
    domain,
    difficulty_level,
    created_at
FROM questions 
ORDER BY created_at DESC 
LIMIT 3;

-- 6. Check user_profiles count
SELECT COUNT(*) as total_users FROM user_profiles;

-- 7. Check user_profiles sample
SELECT 
    id,
    email,
    subscription_status,
    created_at
FROM user_profiles 
ORDER BY created_at DESC 
LIMIT 3;

-- 8. Check certifications table
SELECT 
    id,
    name,
    test_code,
    description
FROM certifications 
ORDER BY name;
