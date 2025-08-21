import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

export async function getSubscriptionStatus(uid: string): Promise<'active' | 'canceled' | 'free'> {
  const { data, error } = await supabase
    .from('user_profiles')
    .select('subscription_status')
    .eq('id', uid)
    .single();
  if (error || !data) return 'free';
  return (data.subscription_status as 'active' | 'canceled' | 'free') || 'free';
}
