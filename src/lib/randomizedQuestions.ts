import { supabase } from './supabase';

// Enhanced function to use the new database randomization
export async function getRandomizedAdaptiveQuestions(
  userId: string, 
  certification: string, 
  limit: number = 10,
  excludeRecentHours: number = 2
) {
  try {
    const { data, error } = await supabase
      .rpc('get_randomized_adaptive_questions', {
        session_user_id: userId,
        certification_name: certification,
        session_length: limit,
        exclude_recent_hours: excludeRecentHours
      });

    if (error) {
      console.error('Error fetching randomized questions:', error);
      // Fallback to original function if new one fails
      return getAdaptiveQuestions(userId, certification, limit);
    }

    // Transform the data to include answer_choices
    if (data && data.length > 0) {
      const questionIds = data.map((q: any) => q.id);
      
      // Fetch answer choices for these questions
      const { data: choices, error: choicesError } = await supabase
        .from('answer_choices')
        .select('*')
        .in('question_id', questionIds)
        .order('choice_order');

      if (choicesError) {
        console.error('Error fetching answer choices:', choicesError);
        return { success: false, error: choicesError.message };
      }

      // Attach answer choices to questions
      const questionsWithChoices = data.map((q: any) => ({
        ...q,
        topic: {
          name: q.topic_name,
          description: q.topic_description
        },
        answer_choices: choices?.filter(c => c.question_id === q.id) || []
      }));

      return { success: true, questions: questionsWithChoices };
    }

    return { success: true, questions: [] };
  } catch (err) {
    console.error('Exception in randomized questions:', err);
    // Fallback to original function
    return getAdaptiveQuestions(userId, certification, limit);
  }
}

// Re-export existing functions for backward compatibility
export * from './questionBank';
