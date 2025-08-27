import { createClient } from '@supabase/supabase-js';
import { NextRequest, NextResponse } from 'next/server';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

export async function GET(request: NextRequest) {
  try {
    // Verify admin access
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // Get user statistics
    const { data: users, error: usersError } = await supabase
      .from('user_profiles')
      .select('id, subscription_status, created_at, last_activity')
      .order('created_at', { ascending: false });

    if (usersError) {
      console.error('Error fetching users:', usersError);
      return NextResponse.json({ error: 'Failed to fetch users' }, { status: 500 });
    }

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
      // Count active users (logged in within 30 days)
      if (user.last_activity && new Date(user.last_activity) > thirtyDaysAgo) {
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
