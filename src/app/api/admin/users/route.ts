import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

export async function GET() {
  try {
    // Use service role key to bypass RLS
    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!
    );

    // Get all user profiles
    const { data: users, error } = await supabase
      .from('user_profiles')
      .select('id, email, subscription_status, created_at, certification_goal, stripe_customer_id')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching users:', error);
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    console.log('API: Fetched', users?.length || 0, 'users');

    return NextResponse.json({ 
      users: users || [],
      total: users?.length || 0 
    });

  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
