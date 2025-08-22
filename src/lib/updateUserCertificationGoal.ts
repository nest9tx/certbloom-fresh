import { supabase } from './supabase';

export async function updateUserCertificationGoal(userId: string, certificationGoal: string): Promise<{ success: boolean; error?: string }> {
  try {
    const { error } = await supabase
      .from('user_profiles')
      .update({ certification_goal: certificationGoal })
      .eq('id', userId);

    if (error) {
      console.error('Error updating user certification goal:', error);
      return { success: false, error: error.message };
    }

    return { success: true };
  } catch (error) {
    console.error('Error updating user certification goal:', error);
    return { success: false, error: 'An unexpected error occurred' };
  }
}
