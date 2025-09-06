-- Add missing Stripe-related columns to user_profiles table
ALTER TABLE user_profiles 
ADD COLUMN stripe_subscription_id VARCHAR(255),
ADD COLUMN subscription_plan VARCHAR(50),
ADD COLUMN subscription_end_date TIMESTAMPTZ;

-- Add index for better performance on subscription queries
CREATE INDEX IF NOT EXISTS idx_user_profiles_subscription_status ON user_profiles(subscription_status);
CREATE INDEX IF NOT EXISTS idx_user_profiles_stripe_customer_id ON user_profiles(stripe_customer_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_stripe_subscription_id ON user_profiles(stripe_subscription_id);

-- Update any existing users who might have active Stripe customers but missing subscription data
-- This will help with any existing test accounts
UPDATE user_profiles 
SET subscription_status = 'free' 
WHERE subscription_status IS NULL;
