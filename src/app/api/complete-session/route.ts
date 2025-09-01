import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

// Create admin client for database operations
const adminSupabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);

export async function POST(request: NextRequest) {
  try {
    console.log('🎯 Session completion request received');
    
    const body = await request.json();
    const { sessionId, userAnswers, questionIds, conceptId, userId } = body;

    if (!sessionId || !userAnswers || !questionIds || !conceptId || !userId) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      );
    }

    console.log('📊 Processing session completion:', {
      sessionId,
      totalQuestions: questionIds.length,
      conceptId,
      userId
    });

    // Create session if it doesn't exist
    const { data: existingSession, error: sessionCheckError } = await adminSupabase
      .from('practice_sessions')
      .select('id')
      .eq('id', sessionId)
      .single();

    if (sessionCheckError && sessionCheckError.code !== 'PGRST116') {
      console.error('❌ Error checking session:', sessionCheckError);
      return NextResponse.json(
        { error: 'Error checking session' },
        { status: 500 }
      );
    }

    if (!existingSession) {
      // Create session if it doesn't exist
      const { data: studyPlan } = await adminSupabase
        .from('study_plans')
        .select('id')
        .eq('user_id', userId)
        .eq('is_active', true)
        .single();

      if (studyPlan) {
        await adminSupabase
          .from('practice_sessions')
          .insert({
            id: sessionId,
            study_plan_id: studyPlan.id,
            concept_id: conceptId,
            session_type: 'concept_practice',
            created_at: new Date().toISOString()
          });
      }
    }

    // Calculate results
    const totalQuestions = questionIds.length;
    let correctAnswers = 0;

    // Get correct answers for each question
    const { data: questions, error: questionsError } = await adminSupabase
      .from('questions')
      .select('id, correct_answer')
      .in('id', questionIds);

    if (questionsError) {
      console.error('❌ Error fetching questions:', questionsError);
      return NextResponse.json(
        { error: 'Error fetching questions' },
        { status: 500 }
      );
    }

    // Check answers
    questions?.forEach((question, index) => {
      if (question.correct_answer === userAnswers[index]) {
        correctAnswers++;
      }
    });

    const scorePercentage = Math.round((correctAnswers / totalQuestions) * 100);
    const masteryAchieved = scorePercentage >= 80;

    console.log('📈 Session results:', {
      totalQuestions,
      correctAnswers,
      scorePercentage,
      masteryAchieved
    });

    // Update session with results
    const { error: updateError } = await adminSupabase
      .from('practice_sessions')
      .update({
        score: scorePercentage,
        total_questions: totalQuestions,
        correct_answers: correctAnswers,
        question_ids: questionIds,
        user_answers: userAnswers,
        completed_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .eq('id', sessionId);

    if (updateError) {
      console.error('❌ Error updating session:', updateError);
      return NextResponse.json(
        { error: 'Error updating session' },
        { status: 500 }
      );
    }

    // Update user progress
    const { error: progressError } = await adminSupabase
      .rpc('update_user_progress_from_session', {
        p_user_id: userId,
        p_certification_area: 'Math EC-6', // Will be dynamic later
        p_domain: 'Practice Session',
        p_concept: 'General Concept',
        p_total_questions: totalQuestions,
        p_correct_answers: correctAnswers,
        p_session_id: sessionId
      });

    if (progressError) {
      console.error('⚠️ Warning: Progress update failed:', progressError);
      // Don't fail the request if progress update fails
    }

    console.log('✅ Session completed successfully');

    return NextResponse.json({
      success: true,
      results: {
        totalQuestions,
        correctAnswers,
        scorePercentage,
        masteryAchieved,
        sessionId
      },
      message: `Session completed: ${correctAnswers}/${totalQuestions} (${scorePercentage}%)`
    });

  } catch (error) {
    console.error('❌ Session completion error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
