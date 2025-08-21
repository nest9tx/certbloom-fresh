import { supabase } from './supabase';

export async function getUserCertificationGoal(userId: string): Promise<string | null> {
  try {
    const { data, error } = await supabase
      .from('user_profiles')
      .select('certification_goal')
      .eq('id', userId)
      .single();

    if (error) {
      console.error('Error fetching user certification goal:', error);
      return null;
    }

    return data?.certification_goal || null;
  } catch (error) {
    console.error('Error fetching user certification goal:', error);
    return null;
  }
}
