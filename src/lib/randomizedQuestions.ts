import { supabase } from './supabase';
import { getAdaptiveQuestions, recordQuestionAttempt } from './questionBank';

// Simple function to use the new database randomization
export async function getRandomizedAdaptiveQuestions(
  userId: string, 
  certification: string, 
  limit: number = 10
) {
  try {
    console.log('🎯 Attempting randomized questions for:', { userId, certification, limit });
    
    // Try the new randomized function first
    const { data, error } = await supabase
      .rpc('get_randomized_adaptive_questions', {
        session_user_id: userId,
        certification_name: certification,
        session_length: limit,
        exclude_recent_hours: 2
      });

    if (error) {
      console.warn('⚠️ Randomized function error, falling back:', error.message);
      return getAdaptiveQuestions(userId, certification, limit);
    }

    if (!data || data.length === 0) {
      console.log('📭 No randomized questions returned, trying fallback');
      return getAdaptiveQuestions(userId, certification, limit);
    }

    console.log('✅ Randomized questions found:', data.length);
    
    // Transform to match expected format and get answer choices
    const questionsWithChoices = [];
    
    for (const q of data) {
      // Get answer choices for this question
      const { data: choices, error: choicesError } = await supabase
        .from('answer_choices')
        .select('*')
        .eq('question_id', q.id)
        .order('choice_order');
      
      if (choicesError) {
        console.warn('Warning: Could not fetch choices for question', q.id, choicesError);
      }
      
      questionsWithChoices.push({
        ...q,
        topic: {
          name: q.topic_name || 'General',
          description: q.topic_description || 'General Topic'
        },
        answer_choices: choices || []
      });
    }

    return { success: true, questions: questionsWithChoices };
  } catch (err) {
    console.error('💥 Exception in randomized questions, using fallback:', err);
    return getAdaptiveQuestions(userId, certification, limit);
  }
}

// Re-export for convenience
export { recordQuestionAttempt };
