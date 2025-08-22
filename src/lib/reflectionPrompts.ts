import { supabase } from './supabase';

export interface ReflectionPrompt {
  id: string;
  prompt_text: string;
  category: 'mindfulness' | 'progress' | 'motivation' | 'growth' | 'balance';
  week_range: 'all' | 'early' | 'mid' | 'late';
  active: boolean;
  created_at: string;
}

/**
 * Get a random reflection prompt based on the current week number
 */
export async function getWeeklyReflectionPrompt(
  weekNumber?: number
): Promise<{ success: boolean; prompt?: ReflectionPrompt; error?: string }> {
  try {
    // Determine week range based on week number (1-52)
    let weekRange = 'all';
    if (weekNumber) {
      if (weekNumber <= 13) {
        weekRange = 'early';
      } else if (weekNumber <= 39) {
        weekRange = 'mid';
      } else {
        weekRange = 'late';
      }
    }

    // Get prompts for the appropriate week range or 'all'
    const { data, error } = await supabase
      .from('reflection_prompts')
      .select('*')
      .eq('active', true)
      .in('week_range', ['all', weekRange]);

    if (error) {
      console.error('Error fetching reflection prompts:', error);
      return { success: false, error: error.message };
    }

    if (!data || data.length === 0) {
      return { success: false, error: 'No reflection prompts found' };
    }

    // Select a random prompt
    const randomPrompt = data[Math.floor(Math.random() * data.length)];

    return { success: true, prompt: randomPrompt };
  } catch (err) {
    console.error('Exception fetching reflection prompt:', err);
    return { success: false, error: 'An unexpected error occurred' };
  }
}

/**
 * Get reflection prompts by category
 */
export async function getReflectionPromptsByCategory(
  category: 'mindfulness' | 'progress' | 'motivation' | 'growth' | 'balance'
): Promise<{ success: boolean; prompts?: ReflectionPrompt[]; error?: string }> {
  try {
    const { data, error } = await supabase
      .from('reflection_prompts')
      .select('*')
      .eq('category', category)
      .eq('active', true);

    if (error) {
      console.error('Error fetching reflection prompts by category:', error);
      return { success: false, error: error.message };
    }

    return { success: true, prompts: data || [] };
  } catch (err) {
    console.error('Exception fetching reflection prompts by category:', err);
    return { success: false, error: 'An unexpected error occurred' };
  }
}
