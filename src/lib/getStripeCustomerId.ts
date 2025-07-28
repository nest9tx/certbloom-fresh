import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

export async function getStripeCustomerIdForUser(uid: string) {
  // Adjust table/column names as needed
  const { data, error } = await supabase
    .from('user_profiles')
    .select('stripe_customer_id')
    .eq('uid', uid)
    .single();

  if (error || !data) {
    return null;
  }
  return data.stripe_customer_id || null;
}
