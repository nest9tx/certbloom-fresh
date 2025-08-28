import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

// Initialize Supabase client with service role
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

interface QuestionAttempt {
  userId: string;
  questionId: string;
  userAnswer: string;
  isCorrect: boolean;
  timeSpentSeconds: number;
  confidenceLevel?: number; // 1-5 scale
  hintUsed?: boolean;
  sessionId?: string;
}

export async function POST(request: NextRequest) {
  try {
    const body: QuestionAttempt = await request.json();
    const {
      userId,
      questionId,
      userAnswer,
      isCorrect,
      timeSpentSeconds,
      confidenceLevel = 3,
      hintUsed = false,
      sessionId
    } = body;

    if (!userId || !questionId || userAnswer === undefined || isCorrect === undefined) {
      return NextResponse.json(
        { error: 'Missing required fields: userId, questionId, userAnswer, isCorrect' },
        { status: 400 }
      );
    }

    // Get question details for enhanced tracking
    const { data: questionData, error: questionError } = await supabase
      .from('questions')
      .select('certification_area, domain, concept, difficulty_level, bloom_level')
      .eq('id', questionId)
      .single();

    if (questionError) {
      console.error('Error fetching question details:', questionError);
      return NextResponse.json(
        { error: 'Question not found' },
        { status: 404 }
      );
    }

    // Check for previous attempts to determine attempt number
    const { data: previousAttempts, error: attemptsError } = await supabase
      .from('enhanced_question_attempts')
      .select('attempt_number')
      .eq('user_id', userId)
      .eq('question_id', questionId)
      .order('attempt_number', { ascending: false })
      .limit(1);

    if (attemptsError) {
      console.error('Error checking previous attempts:', attemptsError);
    }

    const attemptNumber = (previousAttempts?.[0]?.attempt_number || 0) + 1;

    // Record the enhanced attempt
    const { data: attemptData, error: attemptError } = await supabase
      .from('enhanced_question_attempts')
      .insert({
        user_id: userId,
        question_id: questionId,
        user_answer: userAnswer,
        is_correct: isCorrect,
        time_spent_seconds: timeSpentSeconds,
        difficulty_at_attempt: questionData.difficulty_level,
        bloom_level_at_attempt: questionData.bloom_level,
        confidence_level: confidenceLevel,
        hint_used: hintUsed,
        attempt_number: attemptNumber,
        session_id: sessionId
      })
      .select()
      .single();

    if (attemptError) {
      console.error('Error recording attempt:', attemptError);
      return NextResponse.json(
        { error: 'Failed to record attempt' },
        { status: 500 }
      );
    }

    // Get updated progress for this concept
    const { data: updatedProgress, error: progressError } = await supabase
      .from('user_concept_progress')
      .select('*')
      .eq('user_id', userId)
      .eq('certification_area', questionData.certification_area)
      .eq('domain', questionData.domain)
      .eq('concept', questionData.concept)
      .single();

    if (progressError && progressError.code !== 'PGRST116') { // PGRST116 = no rows found
      console.error('Error fetching updated progress:', progressError);
    }

    // Get analytics for next question recommendations
    let nextQuestionSuggestion = null;
    try {
      const { data: suggestions, error: suggestionError } = await supabase
        .rpc('get_intelligent_question_sequence', {
          p_user_id: userId,
          p_certification_area: questionData.certification_area,
          p_session_length: 1,
          p_focus_weak_areas: !isCorrect // Focus on weak areas if they got it wrong
        });

      if (!suggestionError && suggestions && suggestions.length > 0) {
        nextQuestionSuggestion = suggestions[0];
      }
    } catch (suggestionErr) {
      console.log('Could not get next question suggestion:', suggestionErr);
    }

    return NextResponse.json({
      success: true,
      attempt: attemptData,
      progress: updatedProgress,
      nextQuestionSuggestion,
      feedback: {
        isCorrect,
        attemptNumber,
        conceptMastery: updatedProgress?.mastery_level || 'beginner',
        progressPercent: updatedProgress?.progress_percent || 0,
        encouragement: generateEncouragement(isCorrect, attemptNumber, updatedProgress?.mastery_level)
      }
    });

  } catch (error) {
    console.error('Error in attempt recording API:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// Helper function to generate encouraging feedback
function generateEncouragement(
  isCorrect: boolean, 
  attemptNumber: number, 
  masteryLevel?: string
): string {
  if (isCorrect) {
    if (attemptNumber === 1) {
      switch (masteryLevel) {
        case 'mastered':
          return "Excellent! Your mastery shines through. 🌟";
        case 'proficient':
          return "Perfect! You're demonstrating strong understanding. ✨";
        case 'developing':
          return "Great work! You're building solid foundations. 🌱";
        default:
          return "Well done! You're on the right path. 🌸";
      }
    } else {
      return "Success! Your persistence is paying off. Keep going! 💪";
    }
  } else {
    if (attemptNumber === 1) {
      return "No worries! This is part of learning. Let's explore this concept together. 🤔";
    } else {
      return "Learning takes time. Each attempt brings you closer to understanding. 🌱";
    }
  }
}

// GET endpoint for retrieving user's attempt history
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const userId = searchParams.get('userId');
  const questionId = searchParams.get('questionId');
  const certificationArea = searchParams.get('certificationArea');

  if (!userId) {
    return NextResponse.json(
      { error: 'Missing userId parameter' },
      { status: 400 }
    );
  }

  try {
    let query = supabase
      .from('enhanced_question_attempts')
      .select(`
        *,
        questions (
          question_text,
          certification_area,
          domain,
          concept,
          difficulty_level
        )
      `)
      .eq('user_id', userId)
      .order('attempted_at', { ascending: false });

    if (questionId) {
      query = query.eq('question_id', questionId);
    }

    if (certificationArea) {
      query = query.eq('questions.certification_area', certificationArea);
    }

    const { data: attempts, error } = await query.limit(50);

    if (error) {
      console.error('Error fetching attempt history:', error);
      return NextResponse.json(
        { error: 'Failed to fetch attempt history' },
        { status: 500 }
      );
    }

    return NextResponse.json({
      attempts: attempts || [],
      totalAttempts: attempts?.length || 0
    });

  } catch (error) {
    console.error('Error in GET attempt history:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
