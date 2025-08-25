import { supabase } from './supabase';
import { UserProgress } from './questionBank';

export interface DashboardStats {
  total_sessions: number;
  total_questions: number;
  total_correct: number;
  accuracy: number;
  wellness_score: number;
}

export interface DashboardData {
  stats: DashboardStats;
  progress: UserProgress[];
}

export async function getDashboardData(userId: string): Promise<DashboardData | null> {
  try {
    console.log('📊 Fetching dashboard data for user:', userId);

    // Call the database function to get complete dashboard data
    const { data, error } = await supabase.rpc('get_user_dashboard_data', {
      target_user_id: userId
    });

    if (error) {
      console.error('❌ Error fetching dashboard data:', error);
      return null;
    }

    if (!data) {
      console.log('⚠️ No dashboard data found, returning defaults');
      return {
        stats: {
          total_sessions: 0,
          total_questions: 0,
          total_correct: 0,
          accuracy: 0,
          wellness_score: 50
        },
        progress: []
      };
    }

    console.log('✅ Dashboard data fetched:', data);
    return data as DashboardData;
  } catch (err) {
    console.error('❌ Exception fetching dashboard data:', err);
    return null;
  }
}

// Function to trigger mandala refresh by dispatching custom event
export function triggerMandalaRefresh() {
  console.log('🔄 Triggering mandala refresh...');
  
  // Dispatch custom event
  window.dispatchEvent(new CustomEvent('mandalaRefresh'));
  
  // Also update localStorage to trigger cross-component updates
  localStorage.setItem('mandalaLastUpdate', Date.now().toString());
  
  console.log('✅ Mandala refresh triggered');
}
