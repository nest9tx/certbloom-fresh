-- Stripe Subscription Columns Migration
-- Run this SQL in your Supabase SQL editor to add missing columns

-- Add missing Stripe subscription columns to user_profiles
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS stripe_subscription_id TEXT,
ADD COLUMN IF NOT EXISTS subscription_plan TEXT CHECK (subscription_plan IN ('monthly', 'yearly')),
ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP WITH TIME ZONE;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_subscription_status ON public.user_profiles(subscription_status);
CREATE INDEX IF NOT EXISTS idx_user_profiles_stripe_customer_id ON public.user_profiles(stripe_customer_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_stripe_subscription_id ON public.user_profiles(stripe_subscription_id);

-- Ensure subscription_status has proper default and constraint
ALTER TABLE public.user_profiles 
ALTER COLUMN subscription_status SET DEFAULT 'free';

-- Update any null subscription statuses to 'free'
UPDATE public.user_profiles 
SET subscription_status = 'free' 
WHERE subscription_status IS NULL;

-- Add a trigger to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE
ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
