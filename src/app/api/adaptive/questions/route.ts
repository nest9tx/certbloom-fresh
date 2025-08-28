import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

// Initialize Supabase client with service role
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

interface AdaptiveQuestion {
  question_id: string;
  question_text: string;
  difficulty_level: string;
  domain: string;
  concept: string;
  recommended_reason: string;
  priority_score: number;
}

interface QuestionDetail {
  id: string;
  question_text: string;
  question_type: string;
  options?: string[];
  correct_answer: string;
  explanation: string;
  difficulty_level: string;
  domain: string;
  concept: string;
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { 
      userId, 
      certificationArea, 
      sessionLength = 10, 
      focusWeakAreas = true 
    } = body;

    if (!userId || !certificationArea) {
      return NextResponse.json(
        { error: 'Missing required fields: userId, certificationArea' },
        { status: 400 }
      );
    }

    // Call the intelligent question selection function
    const { data: questions, error } = await supabase
      .rpc('get_intelligent_question_sequence', {
        p_user_id: userId,
        p_certification_area: certificationArea,
        p_session_length: sessionLength,
        p_focus_weak_areas: focusWeakAreas
      });

    if (error) {
      console.error('Error getting adaptive questions:', error);
      // Fallback to simple question selection if adaptive function fails
      const { data: fallbackQuestions, error: fallbackError } = await supabase
        .from('questions')
        .select('id, question_text, difficulty_level, domain, concept, options, correct_answer, explanation')
        .eq('certification_area', certificationArea)
        .limit(sessionLength);

      if (fallbackError) {
        return NextResponse.json(
          { error: 'Failed to fetch questions' },
          { status: 500 }
        );
      }

      return NextResponse.json({
        questions: fallbackQuestions?.map(q => ({
          question_id: q.id,
          question_text: q.question_text,
          difficulty_level: q.difficulty_level,
          domain: q.domain,
          concept: q.concept,
          options: q.options,
          correct_answer: q.correct_answer,
          explanation: q.explanation,
          recommended_reason: 'Standard practice question',
          priority_score: 2
        })) || [],
        isAdaptive: false,
        message: 'Using standard question selection'
      });
    }

    // Get full question details for the selected questions
    const questionIds = (questions as AdaptiveQuestion[])?.map(q => q.question_id) || [];
    
    if (questionIds.length === 0) {
      return NextResponse.json({
        questions: [],
        isAdaptive: true,
        message: 'No suitable questions found for current progress level'
      });
    }

    const { data: fullQuestions, error: detailError } = await supabase
      .from('questions')
      .select('id, question_text, question_type, options, correct_answer, explanation, difficulty_level, domain, concept')
      .in('id', questionIds);

    if (detailError) {
      console.error('Error fetching question details:', detailError);
      return NextResponse.json(
        { error: 'Failed to fetch question details' },
        { status: 500 }
      );
    }

    // Merge adaptive metadata with question details
    const enrichedQuestions = (questions as AdaptiveQuestion[])?.map(adaptiveQ => {
      const fullQ = (fullQuestions as QuestionDetail[])?.find(fq => fq.id === adaptiveQ.question_id);
      return {
        ...fullQ,
        recommended_reason: adaptiveQ.recommended_reason,
        priority_score: adaptiveQ.priority_score,
        adaptive_metadata: {
          domain: adaptiveQ.domain,
          concept: adaptiveQ.concept,
          difficulty_level: adaptiveQ.difficulty_level
        }
      };
    }) || [];

    return NextResponse.json({
      questions: enrichedQuestions,
      isAdaptive: true,
      sessionLength: enrichedQuestions.length,
      message: `Selected ${enrichedQuestions.length} personalized questions based on your learning progress`
    });

  } catch (error) {
    console.error('Error in adaptive questions API:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// GET endpoint for testing/debugging
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const userId = searchParams.get('userId');
  const certificationArea = searchParams.get('certificationArea');

  if (!userId || !certificationArea) {
    return NextResponse.json(
      { error: 'Missing query parameters: userId, certificationArea' },
      { status: 400 }
    );
  }

  try {
    // Get user's current progress for debugging
    const { data: userProgress, error } = await supabase
      .from('user_concept_progress')
      .select('*')
      .eq('user_id', userId)
      .eq('certification_area', certificationArea);

    if (error) {
      console.error('Error fetching user progress:', error);
      return NextResponse.json(
        { error: 'Failed to fetch user progress' },
        { status: 500 }
      );
    }

    return NextResponse.json({
      userProgress: userProgress || [],
      message: 'User progress data for adaptive learning debugging'
    });

  } catch (error) {
    console.error('Error in GET adaptive questions:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
