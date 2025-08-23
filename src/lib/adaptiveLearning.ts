import { supabase } from './supabase';

// 🌸 Sacred Types for Consciousness-Aware Learning
export interface MoodConfig {
  mood: string;
  review_percentage: number;
  new_learning_percentage: number;
  application_percentage: number;
  include_mindful_break: boolean;
  include_challenge: boolean;
  session_intensity: 'gentle' | 'balanced' | 'deep' | 'energized';
  wisdom_whisper_category: string;
}

export interface WisdomWhisper {
  message: string;
  icon: string;
  category: string;
  mood_context: string;
  trigger_condition: string;
}

export interface AdaptiveSession {
  mood: string;
  session_type: string;
  include_mindful_break: boolean;
  include_challenge: boolean;
  review_questions: Array<{
    question_id: string;
    topic: string;
    petal_stage: string;
    bloom_level: string;
    question_text: string;
    difficulty_level: number;
  }>;
  new_questions: Array<{
    question_id: string;
    topic: string;
    difficulty: number;
    question_text: string;
    petal_stage: string;
  }>;
  wisdom_whisper: {
    message: string;
    icon: string;
  };
  generated_at: string;
}

export interface EnhancedUserProgress {
  user_id: string;
  topic: string;
  mastery_level: number;
  questions_attempted: number;
  questions_correct: number;
  last_practiced: string;
  needs_review: boolean;
  petal_stage: 'dormant' | 'budding' | 'blooming' | 'radiant';
  bloom_level: 'comprehension' | 'application' | 'analysis' | 'evaluation';
  confidence_trend: number;
  energy_level: number;
}

// 🌱 Sacred Database Functions

/**
 * Get all available mood configurations for session planning
 */
export async function getMoodConfigurations(): Promise<MoodConfig[]> {
  const { data, error } = await supabase
    .from('mood_session_configs')
    .select('*')
    .order('mood');

  if (error) {
    console.error('Error fetching mood configurations:', error);
    throw error;
  }

  return data || [];
}

/**
 * Build an adaptive learning session based on user mood and learning state
 */
export async function buildAdaptiveSession(
  userId: string,
  certificationName: string,
  userMood: string = 'calm',
  sessionLength: number = 10
): Promise<AdaptiveSession> {
  const { data, error } = await supabase
    .rpc('build_adaptive_session', {
      session_user_id: userId,
      certification_name: certificationName,
      user_mood: userMood,
      session_length: sessionLength
    });

  if (error) {
    console.error('Error building adaptive session:', error);
    throw error;
  }

  return data;
}

/**
 * Get a contextual wisdom whisper based on mood and learning state
 */
export async function getWisdomWhisper(
  userMood: string = 'any',
  learningContext: string = 'any'
): Promise<WisdomWhisper> {
  const { data, error } = await supabase
    .rpc('get_wisdom_whisper', {
      user_mood: userMood,
      learning_context: learningContext
    });

  if (error) {
    console.error('Error fetching wisdom whisper:', error);
    throw error;
  }

  return data?.[0] || {
    message: 'Trust in your journey of becoming.',
    icon: '✨',
    category: 'gentle',
    mood_context: 'any',
    trigger_condition: 'any'
  };
}

/**
 * Update user progress with consciousness-aware tracking
 */
export async function updateUserProgressWithPetals(
  userId: string,
  topicName: string,
  wasCorrect: boolean,
  confidenceLevel: number = 3
): Promise<void> {
  const { error } = await supabase
    .rpc('update_user_progress_with_petals', {
      session_user_id: userId,
      topic_name: topicName,
      was_correct: wasCorrect,
      confidence_level: confidenceLevel
    });

  if (error) {
    console.error('Error updating user progress with petals:', error);
    throw error;
  }
}

/**
 * Get enhanced user progress with petal stages and bloom levels
 */
export async function getEnhancedUserProgress(userId: string): Promise<EnhancedUserProgress[]> {
  const { data, error } = await supabase
    .from('user_progress')
    .select(`
      user_id,
      topic,
      mastery_level,
      questions_attempted,
      questions_correct,
      last_practiced,
      needs_review,
      petal_stage,
      bloom_level,
      confidence_trend,
      energy_level
    `)
    .eq('user_id', userId)
    .order('mastery_level', { ascending: false });

  if (error) {
    console.error('Error fetching enhanced user progress:', error);
    throw error;
  }

  return data || [];
}

/**
 * Update petal stage for a specific topic
 */
export async function updatePetalStage(userId: string, topicName: string): Promise<string> {
  const { data, error } = await supabase
    .rpc('update_petal_stage', {
      user_id: userId,
      topic_name: topicName
    });

  if (error) {
    console.error('Error updating petal stage:', error);
    throw error;
  }

  return data;
}

/**
 * Progress bloom level for a topic
 */
export async function progressBloomLevel(
  userId: string,
  topicName: string,
  wasCorrect: boolean
): Promise<string> {
  const { data, error } = await supabase
    .rpc('progress_bloom_level', {
      user_id: userId,
      topic_name: topicName,
      was_correct: wasCorrect
    });

  if (error) {
    console.error('Error progressing bloom level:', error);
    throw error;
  }

  return data;
}

// 🌊 Utilities for Sacred Technology

/**
 * Calculate petal color based on stage
 */
export function getPetalColor(stage: string): string {
  const baseColors = {
    dormant: '#e5e7eb', // gray-200
    budding: '#fbbf24', // amber-400
    blooming: '#34d399', // emerald-400
    radiant: '#f59e0b'   // amber-500
  };

  return baseColors[stage as keyof typeof baseColors] || baseColors.dormant;
}

/**
 * Get mood-appropriate session message
 */
export function getMoodMessage(mood: string): string {
  const messages = {
    calm: 'Let\'s explore with peaceful curiosity',
    tired: 'Gentle practice honors your energy',
    anxious: 'Each breath brings clarity and confidence',
    focused: 'Your concentration creates space for deep learning',
    energized: 'Your enthusiasm lights the path to mastery'
  };

  return messages[mood as keyof typeof messages] || messages.calm;
}

/**
 * Calculate optimal break timing based on mood and intensity
 */
export function calculateBreakTiming(
  mood: string,
  sessionIntensity: string,
  questionIndex: number,
  totalQuestions: number
): boolean {
  const moodBreakFactors = {
    tired: 0.3,    // More frequent breaks
    anxious: 0.4,  // Regular breaks for grounding
    calm: 0.5,     // Balanced breaks
    focused: 0.6,  // Fewer breaks when focused
    energized: 0.7 // Minimal breaks when energized
  };

  const intensityFactors = {
    gentle: 0.3,
    balanced: 0.5,
    deep: 0.7,
    energized: 0.8
  };

  const moodFactor = moodBreakFactors[mood as keyof typeof moodBreakFactors] || 0.5;
  const intensityFactor = intensityFactors[sessionIntensity as keyof typeof intensityFactors] || 0.5;
  
  const breakThreshold = Math.floor(totalQuestions * moodFactor * intensityFactor);
  
  return questionIndex > 0 && questionIndex % Math.max(3, breakThreshold) === 0;
}
