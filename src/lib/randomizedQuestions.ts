import { supabase } from './supabase';
import { getAdaptiveQuestions, recordQuestionAttempt, type Question } from './questionBank';

// Simple function to use the new database randomization
export async function getRandomizedAdaptiveQuestions(
  userId: string, 
  certification: string, 
  limit: number = 10
) {
  try {
    console.log('🎯 Attempting randomized questions for:', { userId, certification, limit });
    console.log('🔍 Database connection test...');
    
    // First test basic database connectivity
    const { data: testData, error: testError } = await supabase
      .from('questions')
      .select('id, question_text')
      .limit(1);
    
    if (testError) {
      console.error('❌ Database connectivity test failed:', testError);
      return getAdaptiveQuestions(userId, certification, limit);
    }
    
    console.log('✅ Database connectivity OK, found questions:', testData?.length || 0);
    
    // Try the simple fallback function first
    const { data: simpleData, error: simpleError } = await supabase
      .rpc('get_simple_questions', { session_length: limit });
    
    if (!simpleError && simpleData && simpleData.length > 0) {
      console.log('✅ Using simple questions function:', simpleData.length);
      const questionsWithChoices = await addAnswerChoicesToQuestions(simpleData);
      return { success: true, questions: questionsWithChoices };
    }
    
    // Try the new randomized function with longer exclusion window
    const { data, error } = await supabase
      .rpc('get_randomized_adaptive_questions', {
        session_user_id: userId,
        certification_name: certification,
        session_length: limit,
        exclude_recent_hours: 24 // Exclude questions from last 24 hours for better variety
      });

    if (error) {
      console.warn('⚠️ Randomized function error, falling back:', error.message);
      console.warn('⚠️ Error details:', error);
      return getAdaptiveQuestions(userId, certification, limit);
    }

    if (!data || data.length === 0) {
      console.log('📭 No randomized questions returned, trying with shorter exclusion');
      // Try again with shorter exclusion if no questions found
      const { data: fallbackData, error: fallbackError } = await supabase
        .rpc('get_randomized_adaptive_questions', {
          session_user_id: userId,
          certification_name: certification,
          session_length: limit,
          exclude_recent_hours: 1 // Just exclude last hour as minimal exclusion
        });
      
      if (fallbackError || !fallbackData || fallbackData.length === 0) {
        console.log('📭 Still no questions, using standard fallback');
        return getAdaptiveQuestions(userId, certification, limit);
      }
      
      console.log('✅ Fallback randomized questions found:', fallbackData.length);
      const questionsWithChoices = await addAnswerChoicesToQuestions(fallbackData);
      return { success: true, questions: questionsWithChoices };
    }

    console.log('✅ Randomized questions found:', data.length);
    console.log('🔍 Sample question:', data[0]);
    
    const questionsWithChoices = await addAnswerChoicesToQuestions(data);
    return { success: true, questions: questionsWithChoices };
  } catch (err) {
    console.error('💥 Exception in randomized questions, using fallback:', err);
    return getAdaptiveQuestions(userId, certification, limit);
  }
}

// Helper function to add answer choices to questions
async function addAnswerChoicesToQuestions(questions: Record<string, unknown>[]): Promise<Question[]> {
  const questionsWithChoices: Question[] = [];
  
  for (const q of questions) {
    // Get answer choices for this question
    const { data: choices, error: choicesError } = await supabase
      .from('answer_choices')
      .select('*')
      .eq('question_id', q.id)
      .order('choice_order');
    
    if (choicesError) {
      console.warn('⚠️ Warning: Could not fetch choices for question', q.id, choicesError);
    }
    
    console.log(`🔍 Question ${q.id} has ${choices?.length || 0} answer choices`);
    
    questionsWithChoices.push({
      id: q.id as string,
      question_text: q.question_text as string,
      explanation: q.explanation as string,
      difficulty_level: q.difficulty_level as string,
      topic: {
        name: (q.topic_name as string) || 'General',
        description: (q.topic_description as string) || 'General Topic'
      },
      answer_choices: choices || [],
      created_at: q.created_at as string
    } as Question);
  }

  console.log('✅ Final questions with choices:', questionsWithChoices.length);
  return questionsWithChoices;
}

// Re-export for convenience
export { recordQuestionAttempt };
