# Stripe Subscription Fix Guide

## Problem Identified
The Stripe webhook is successfully processing subscription payments, but the `user_profiles` table is missing required columns that the webhook is trying to update. This causes the database update to fail silently, leaving users with `subscription_status: 'free'` even after successful payment.

## Missing Columns
The following columns need to be added to the `user_profiles` table:
- `stripe_subscription_id` (TEXT)
- `subscription_plan` (TEXT) 
- `subscription_end_date` (TIMESTAMP WITH TIME ZONE)

## Immediate Fix Steps

### Step 1: Update Database Schema
Run the following SQL in your Supabase SQL Editor:

```sql
-- Add missing Stripe subscription columns to user_profiles
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS stripe_subscription_id TEXT,
ADD COLUMN IF NOT EXISTS subscription_plan TEXT CHECK (subscription_plan IN ('monthly', 'yearly')),
ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP WITH TIME ZONE;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_subscription_status ON public.user_profiles(subscription_status);
CREATE INDEX IF NOT EXISTS idx_user_profiles_stripe_customer_id ON public.user_profiles(stripe_customer_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_stripe_subscription_id ON public.user_profiles(stripe_subscription_id);

-- Ensure subscription_status has proper default
ALTER TABLE public.user_profiles 
ALTER COLUMN subscription_status SET DEFAULT 'free';

-- Update any null subscription statuses to 'free'
UPDATE public.user_profiles 
SET subscription_status = 'free' 
WHERE subscription_status IS NULL;
```

### Step 2: Manual Fix for Current User
After running the above SQL, manually update your current user's subscription status:

```sql
-- Update your current user (replace with your actual user ID)
UPDATE public.user_profiles 
SET subscription_status = 'active',
    subscription_plan = 'monthly',  -- or 'yearly' depending on your subscription
    subscription_end_date = NOW() + INTERVAL '1 month'  -- adjust based on your plan
WHERE email = 'admin@certbloom.com';  -- or use your actual email
```

### Step 3: Test the Fix
1. Check your dashboard - the upgrade button should disappear
2. Try accessing a study path - it should no longer lock you out
3. Make a test subscription to verify the webhook now works correctly

## Files Updated
- `src/pages/api/stripe/webhook.ts` - Added defensive error handling for missing columns
- `stripe-subscription-migration.sql` - Database migration script

## What Was Wrong
1. The webhook was trying to update `stripe_subscription_id`, `subscription_plan`, and `subscription_end_date` columns that didn't exist
2. This caused the entire database update to fail
3. As a result, `subscription_status` remained 'free' even after successful payment
4. The frontend reads `subscription_status` to determine if user has access

## Prevention
The updated webhook now includes defensive error handling that will:
1. Try to update all fields first
2. If columns are missing (error code 42703), fall back to updating just essential fields
3. Log warnings about missing columns for easier debugging

This ensures subscription status gets updated even if schema is incomplete, while providing clear error messages for missing columns.
