-- Math 902: Place Value and Number Sense - Complete Concept Buildout
-- This will be our template for all 16 concepts

-- Step 1: Enhance user_progress table for better mastery tracking
ALTER TABLE user_progress 
ADD COLUMN IF NOT EXISTS consecutive_correct integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS time_spent_learning integer DEFAULT 0, -- seconds
ADD COLUMN IF NOT EXISTS is_mastered boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS concept_id uuid REFERENCES concepts(id),
ADD COLUMN IF NOT EXISTS mastery_method text; -- how they achieved mastery

-- Step 2: Create questions table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  concept_id uuid NOT NULL REFERENCES concepts(id),
  question_text text NOT NULL,
  explanation text, -- why the correct answer is right
  difficulty_level text NOT NULL CHECK (difficulty_level IN ('easy', 'medium', 'hard')),
  question_type text DEFAULT 'multiple_choice',
  estimated_time integer DEFAULT 60, -- seconds to answer
  created_at timestamp with time zone DEFAULT NOW(),
  updated_at timestamp with time zone DEFAULT NOW()
);

-- Step 3: Update existing answer_choices table to add explanation column
ALTER TABLE answer_choices 
ADD COLUMN IF NOT EXISTS explanation text;

-- Step 4: Insert comprehensive learning content for Place Value concept

-- Insert explanation content
INSERT INTO content_items (
  concept_id,
  type,
  title,
  content,
  order_index,
  estimated_minutes
) 
SELECT 
  c.id,
  'explanation',
  'Understanding Place Value',
  '# Place Value and Number Sense

Place value is the foundation of our number system. Each digit in a number has a specific value based on its position.

## Key Concepts:
- **Place Value Positions**: Each position represents a power of 10
- **Reading Numbers**: Start from left (largest place value) to right
- **Comparing Numbers**: Compare digits from left to right
- **Rounding**: Use place value to round to specific positions

## Place Value Chart:
```
Millions | Hundred Thousands | Ten Thousands | Thousands | Hundreds | Tens | Ones | . | Tenths | Hundredths | Thousandths
   1,000,000 |     100,000     |    10,000    |   1,000   |   100    |  10  |  1   |   |  0.1   |    0.01    |    0.001
```

## Examples:
- In 456,789: 4 is worth 400,000 (4 × 100,000)
- In 3.247: 2 is worth 0.2 (2 × 0.1)
- To compare 4,567 and 4,576: Look at tens place (6 < 7, so 4,567 < 4,576)',
  1,
  8
FROM concepts c
WHERE c.name = 'Place Value and Number Sense';

-- Insert example content
INSERT INTO content_items (
  concept_id,
  type, 
  title,
  content,
  order_index,
  estimated_minutes
)
SELECT 
  c.id,
  'example',
  'Place Value in Action',
  '# Real-World Place Value Examples

## Example 1: Reading Large Numbers
**Number**: 2,847,593
- **Read as**: Two million, eight hundred forty-seven thousand, five hundred ninety-three
- **Break down**: 2,000,000 + 800,000 + 40,000 + 7,000 + 500 + 90 + 3

## Example 2: Comparing Numbers
**Compare**: 15,234 and 15,324
- Look at thousands place: both have 5 ✓
- Look at hundreds place: 2 vs 3
- Since 2 < 3, we know 15,234 < 15,324

## Example 3: Rounding
**Round 4,678 to the nearest hundred**
- Look at tens place: 7
- Since 7 ≥ 5, round up
- Answer: 4,700

## Example 4: Decimal Place Value
**Number**: 12.456
- 1 is in the tens place (worth 10)
- 2 is in the ones place (worth 2) 
- 4 is in the tenths place (worth 0.4)
- 5 is in the hundredths place (worth 0.05)
- 6 is in the thousandths place (worth 0.006)',
  2,
  6
FROM concepts c
WHERE c.name = 'Place Value and Number Sense';
