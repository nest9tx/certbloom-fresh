import { supabase } from './supabase';
import { getAdaptiveQuestions, recordQuestionAttempt } from './questionBank';

// Simple function to use the new database randomization
export async function getRandomizedAdaptiveQuestions(
  userId: string, 
  certification: string, 
  limit: number = 10
) {
  try {
    console.log('Attempting randomized questions for:', { userId, certification, limit });
    
    const { data, error } = await supabase
      .rpc('get_randomized_adaptive_questions', {
        session_user_id: userId,
        certification_name: certification,
        session_length: limit,
        exclude_recent_hours: 2
      });

    if (error) {
      console.error('Randomized function error:', error);
      // Fallback to original function
      return getAdaptiveQuestions(userId, certification, limit);
    }

    if (!data || data.length === 0) {
      console.log('No randomized questions returned, falling back to original');
      return getAdaptiveQuestions(userId, certification, limit);
    }

    console.log('Randomized questions found:', data.length);
    
    // Fetch answer choices for the questions
    const questionIds = data.map((q: { id: number }) => q.id);
    const { data: choices } = await supabase
      .from('answer_choices')
      .select('*')
      .in('question_id', questionIds)
      .order('choice_order');

    // Transform to match expected format
    const questionsWithChoices = data.map((q: { id: number; topic_name: string; topic_description: string }) => ({
      ...q,
      topic: {
        name: q.topic_name,
        description: q.topic_description
      },
      answer_choices: choices?.filter(c => c.question_id === q.id) || []
    }));

    return { success: true, questions: questionsWithChoices };
  } catch (err) {
    console.error('Exception in randomized questions:', err);
    return getAdaptiveQuestions(userId, certification, limit);
  }
}

// Re-export for convenience
export { recordQuestionAttempt };
