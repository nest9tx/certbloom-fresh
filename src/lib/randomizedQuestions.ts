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
    console.log('🔍 Database connection test...');
    
    // First test basic database connectivity
    const { data: testData, error: testError } = await supabase
      .from('certifications')
      .select('id, name')
      .limit(1);
    
    if (testError) {
      console.error('❌ Database connectivity test failed:', testError);
      return getAdaptiveQuestions(userId, certification, limit);
    }
    
    console.log('✅ Database connectivity OK, found certifications:', testData?.length || 0);
    
    // Try the new randomized function
    const { data, error } = await supabase
      .rpc('get_randomized_adaptive_questions', {
        session_user_id: userId,
        certification_name: certification,
        session_length: limit,
        exclude_recent_hours: 2
      });

    if (error) {
      console.warn('⚠️ Randomized function error, falling back:', error.message);
      console.warn('⚠️ Error details:', error);
      return getAdaptiveQuestions(userId, certification, limit);
    }

    if (!data || data.length === 0) {
      console.log('📭 No randomized questions returned, trying fallback');
      return getAdaptiveQuestions(userId, certification, limit);
    }

    console.log('✅ Randomized questions found:', data.length);
    console.log('🔍 Sample question:', data[0]);
    
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
        console.warn('⚠️ Warning: Could not fetch choices for question', q.id, choicesError);
      }
      
      console.log(`🔍 Question ${q.id} has ${choices?.length || 0} answer choices`);
      
      questionsWithChoices.push({
        ...q,
        topic: {
          name: q.topic_name || 'General',
          description: q.topic_description || 'General Topic'
        },
        answer_choices: choices || []
      });
    }

    console.log('✅ Final questions with choices:', questionsWithChoices.length);
    return { success: true, questions: questionsWithChoices };
  } catch (err) {
    console.error('💥 Exception in randomized questions, using fallback:', err);
    return getAdaptiveQuestions(userId, certification, limit);
  }
}

// Re-export for convenience
export { recordQuestionAttempt };
