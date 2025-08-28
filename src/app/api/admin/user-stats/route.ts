import { createClient } from '@supabase/supabase-js';
import { NextResponse } from 'next/server';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

export async function GET() {
  try {
    // Temporarily allow all requests for debugging
    console.log('User stats API called');

    // Get user statistics (remove last_activity since it doesn't exist)
    const { data: users, error: usersError } = await supabase
      .from('user_profiles')
      .select('id, subscription_status, created_at')
      .order('created_at', { ascending: false });

    if (usersError) {
      console.error('Error fetching users:', usersError);
      return NextResponse.json({ error: 'Failed to fetch users' }, { status: 500 });
    }

    console.log('Found users:', users?.length || 0);

    // Calculate statistics
    const now = new Date();
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    const stats = {
      totalUsers: users?.length || 0,
      activeUsers: 0,
      subscriptions: {
        free: 0,
        pro: 0
      }
    };

    users?.forEach(user => {
      // Count active users (created within 30 days since we don't have last_activity)
      if (user.created_at && new Date(user.created_at) > thirtyDaysAgo) {
        stats.activeUsers++;
      }

      // Count subscription types
      if (user.subscription_status === 'active') {
        stats.subscriptions.pro++;
      } else {
        stats.subscriptions.free++;
      }
    });

    return NextResponse.json(stats);

  } catch (error) {
    console.error('Error in user stats API:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
