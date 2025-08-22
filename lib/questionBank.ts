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
  tags?: string[];
  cognitive_level?: string;
  limit?: number;
  excludeAnswered?: boolean;
  userId?: string;
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
    let query = supabase
      .from('questions')
      .select(`
        *,
        topic:topics(name, description),
        answer_choices(*)
      `)
      .eq('active', true);

    // Apply filters
    if (filters.certification) {
      const { data: cert } = await supabase
        .from('certifications')
        .select('id')
        .eq('name', filters.certification)
        .single();
      
      if (cert) {
        query = query.eq('certification_id', cert.id);
      }
    }

    if (filters.topic) {
      const { data: topic } = await supabase
        .from('topics')
        .select('id')
        .eq('name', filters.topic)
        .single();
      
      if (topic) {
        query = query.eq('topic_id', topic.id);
      }
    }

    if (filters.difficulty) {
      query = query.eq('difficulty_level', filters.difficulty);
    }

    if (filters.cognitive_level) {
      query = query.eq('cognitive_level', filters.cognitive_level);
    }

    if (filters.tags && filters.tags.length > 0) {
      query = query.contains('tags', filters.tags);
    }

    // Exclude questions user has already answered correctly if specified
    if (filters.excludeAnswered && filters.userId) {
      const { data: answeredQuestions } = await supabase
        .from('user_question_attempts')
        .select('question_id')
        .eq('user_id', filters.userId)
        .eq('is_correct', true);

      if (answeredQuestions && answeredQuestions.length > 0) {
        const answeredIds = answeredQuestions.map(a => a.question_id);
        query = query.not('id', 'in', `(${answeredIds.join(',')})`);
      }
    }

    if (filters.limit) {
      query = query.limit(filters.limit);
    }

    const { data, error } = await query;

    if (error) {
      console.error('Error fetching questions:', error);
      return { success: false, error: error.message };
    }

    return { success: true, questions: data || [] };
  } catch (err) {
    console.error('Exception fetching questions:', err);
    return { success: false, error: 'An unexpected error occurred' };
  }
}

/**
 * Gets adaptive questions based on user's progress and performance
 */
export async function getAdaptiveQuestions(userId: string, certification: string, limit: number = 10) {
  try {
    // Get user's progress to understand weak areas
    const { data: progress } = await supabase
      .from('user_progress')
      .select('*')
      .eq('user_id', userId);

    // Get certification ID
    const { data: cert } = await supabase
      .from('certifications')
      .select('id')
      .eq('name', certification)
      .single();

    if (!cert) {
      return { success: false, error: 'Certification not found' };
    }

    // Determine which topics need more practice
    const weakTopics = progress?.filter(p => p.mastery_level < 0.7 || p.needs_review) || [];
    
    let query = supabase
      .from('questions')
      .select(`
        *,
        topic:topics(name, description),
        answer_choices(*)
      `)
      .eq('certification_id', cert.id)
      .eq('active', true);

    // Focus on weak topics if they exist
    if (weakTopics.length > 0) {
      const topicNames = weakTopics.map(t => t.topic);
      
      // Get topic IDs
      const { data: topics } = await supabase
        .from('topics')
        .select('id')
        .in('name', topicNames);

      if (topics && topics.length > 0) {
        const topicIds = topics.map(t => t.id);
        query = query.in('topic_id', topicIds);
      }
    }

    // Adjust difficulty based on overall performance
    const avgMastery = progress?.reduce((sum, p) => sum + p.mastery_level, 0) / (progress?.length || 1);
    
    if (avgMastery < 0.5) {
      query = query.eq('difficulty_level', 'easy');
    } else if (avgMastery < 0.8) {
      query = query.in('difficulty_level', ['easy', 'medium']);
    }
    // For high performers, include all difficulties

    // Exclude recently answered questions
    const { data: recentAttempts } = await supabase
      .from('user_question_attempts')
      .select('question_id')
      .eq('user_id', userId)
      .gte('created_at', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()); // Last 24 hours

    if (recentAttempts && recentAttempts.length > 0) {
      const recentIds = recentAttempts.map(a => a.question_id);
      query = query.not('id', 'in', `(${recentIds.join(',')})`);
    }

    query = query.limit(limit);

    const { data, error } = await query;

    if (error) {
      console.error('Error fetching adaptive questions:', error);
      return { success: false, error: error.message };
    }

    // Randomize the questions
    const shuffled = data?.sort(() => Math.random() - 0.5) || [];

    return { success: true, questions: shuffled };
  } catch (err) {
    console.error('Exception fetching adaptive questions:', err);
    return { success: false, error: 'An unexpected error occurred' };
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
      console.error('Error recording attempt:', error);
      return { success: false, error: error.message };
    }

    // Update user progress
    await updateUserProgress(userId, attempt);

    return { success: true, data };
  } catch (err) {
    console.error('Exception recording attempt:', err);
    return { success: false, error: 'An unexpected error occurred' };
  }
}

/**
 * Updates user progress based on question attempt
 */
async function updateUserProgress(userId: string, attempt: QuestionAttempt) {
  try {
    // Get the question's topic
    const { data: question } = await supabase
      .from('questions')
      .select(`
        id,
        topics!inner(name)
      `)
      .eq('id', attempt.question_id)
      .single();

    if (!question?.topics?.[0]?.name) return;

    const topicName = question.topics[0].name;

    // Get current progress for this topic
    const { data: currentProgress } = await supabase
      .from('user_progress')
      .select('*')
      .eq('user_id', userId)
      .eq('topic', topicName)
      .single();

    const questionsAttempted = (currentProgress?.questions_attempted || 0) + 1;
    const questionsCorrect = (currentProgress?.questions_correct || 0) + (attempt.is_correct ? 1 : 0);
    const masteryLevel = questionsCorrect / questionsAttempted;

    const progressData = {
      user_id: userId,
      topic: topicName,
      mastery_level: masteryLevel,
      questions_attempted: questionsAttempted,
      questions_correct: questionsCorrect,
      last_practiced: new Date().toISOString(),
      needs_review: masteryLevel < 0.7 || (!attempt.is_correct && questionsAttempted > 3)
    };

    if (currentProgress) {
      await supabase
        .from('user_progress')
        .update(progressData)
        .eq('id', currentProgress.id);
    } else {
      await supabase
        .from('user_progress')
        .insert(progressData);
    }
  } catch (err) {
    console.error('Error updating user progress:', err);
  }
}

/**
 * Gets user's progress across all topics
 */
export async function getUserProgress(userId: string, certification?: string) {
  try {
    let query = supabase
      .from('user_progress')
      .select('*')
      .eq('user_id', userId)
      .order('last_practiced', { ascending: false });

    // If certification specified, filter by topics from that certification
    if (certification) {
      const { data: cert } = await supabase
        .from('certifications')
        .select('id')
        .eq('name', certification)
        .single();

      if (cert) {
        const { data: topics } = await supabase
          .from('topics')
          .select('name')
          .eq('certification_id', cert.id);

        if (topics) {
          const topicNames = topics.map(t => t.name);
          query = query.in('topic', topicNames);
        }
      }
    }

    const { data, error } = await query;

    if (error) {
      console.error('Error fetching user progress:', error);
      return { success: false, error: error.message };
    }

    return { success: true, progress: data };
  } catch (err) {
    console.error('Exception fetching user progress:', err);
    return { success: false, error: 'An unexpected error occurred' };
  }
}
