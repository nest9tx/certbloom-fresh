// Question Bank Module - Database Integration for CertBloom
import { supabase } from './supabase';

export interface Question {
  id: string;
  certification_id: string;
  topic_id: string;
  question_text: string;
  question_type: 'multiple_choice' | 'true_false' | 'essay' | 'fill_blank';
  difficulty_level: 'easy' | 'medium' | 'hard';
  explanation: string;
  rationale?: string;
  cognitive_level: 'knowledge' | 'comprehension' | 'application' | 'analysis' | 'synthesis' | 'evaluation';
  tags: string[];
  active: boolean;
  created_at: string;
  topic?: {
    name: string;
    description: string;
  };
  answer_choices?: AnswerChoice[];
}

export interface AnswerChoice {
  id: string;
  question_id: string;
  choice_text: string;
  is_correct: boolean;
  choice_order: number;
  explanation?: string;
}

export interface UserProgress {
  id: string;
  user_id: string;
  topic: string;
  mastery_level: number;
  questions_attempted: number;
  questions_correct: number;
  last_practiced: string;
  streak_days: number;
  needs_review: boolean;
  difficulty_preference?: string;
  created_at: string;
  updated_at: string;
}

export interface QuestionFilters {
  certification?: string;
  topic?: string;
  difficulty?: 'easy' | 'medium' | 'hard';
  cognitive_level?: string;
  tags?: string[];
  limit?: number;
}

export interface QuestionAttempt {
  question_id: string;
  selected_answer_id: string;
  is_correct: boolean;
  time_spent_seconds: number;
  confidence_level: number;
}

/**
 * Fetches questions based on filters with optional answer choices
 */
export async function getQuestions(filters: QuestionFilters = {}) {
  try {
    // TODO: Implement database query
    console.log('getQuestions called with filters:', filters);
    return { success: true, questions: [] };
  } catch (error) {
    console.error('Error fetching questions:', error);
    return { success: false, error: 'Failed to fetch questions' };
  }
}

/**
 * Fetches adaptive questions for a user based on their performance
 */
export async function getAdaptiveQuestions(
  userId: string,
  certification: string,
  maxQuestions: number = 10
) {
  try {
    console.log('getAdaptiveQuestions called for user:', userId, 'certification:', certification);
    
    // First, get the certification ID
    const { data: certData, error: certError } = await supabase
      .from('certifications')
      .select('id')
      .eq('name', certification)
      .single();

    if (certError || !certData) {
      console.error('Error finding certification:', certification, certError);
      return { success: false, error: `Certification '${certification}' not found` };
    }

    // Get questions for this certification with answer choices
    const { data: questions, error } = await supabase
      .from('questions')
      .select(`
        *,
        topic:topics(name, description),
        answer_choices(*)
      `)
      .eq('certification_id', certData.id)
      .eq('active', true)
      .limit(maxQuestions);

    if (error) {
      console.error('Database error fetching questions:', error);
      return { success: false, error: 'Failed to fetch questions from database' };
    }

    if (!questions || questions.length === 0) {
      console.log('No questions found for certification:', certification);
      return { success: true, questions: [] };
    }

    console.log(`Found ${questions.length} questions for certification: ${certification}`);
    return { success: true, questions };
    
  } catch (error) {
    console.error('Error fetching adaptive questions:', error);
    return { success: false, error: 'Failed to fetch adaptive questions' };
  }
}

/**
 * Records a user's attempt at answering a question
 */
export async function recordQuestionAttempt(
  userId: string,
  sessionId: string,
  attempt: QuestionAttempt
) {
  try {
    console.log('recordQuestionAttempt called:', { userId, sessionId, attempt });
    
    const { data, error } = await supabase
      .from('user_question_attempts')
      .insert({
        user_id: userId,
        session_id: sessionId,
        question_id: attempt.question_id,
        selected_answer_id: attempt.selected_answer_id,
        is_correct: attempt.is_correct,
        time_spent_seconds: attempt.time_spent_seconds,
        confidence_level: attempt.confidence_level
      });

    if (error) {
      console.error('Database error recording attempt:', error);
      return { success: false, error: 'Failed to record question attempt' };
    }

    console.log('Question attempt recorded successfully:', data);
    return { success: true };
    
  } catch (error) {
    console.error('Error recording question attempt:', error);
    return { success: false, error: 'Failed to record attempt' };
  }
}

/**
 * Gets user progress for topics
 */
export async function getUserProgress(
  userId: string,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars  
  certification?: string
) {
  try {
    // TODO: Implement database query
    console.log('getUserProgress called for user:', userId);
    return { success: true, progress: [] };
  } catch (error) {
    console.error('Error fetching user progress:', error);
    return { success: false, error: 'Failed to fetch progress' };
  }
}
