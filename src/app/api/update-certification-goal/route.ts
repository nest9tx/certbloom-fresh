import { NextRequest, NextResponse } from 'next/server';
import { setupUserLearningPath } from '../../../lib/learningPathBridge';

export async function POST(request: NextRequest) {
  try {
    const { certificationGoal } = await request.json();

    if (!certificationGoal) {
      return NextResponse.json(
        { error: 'Certification goal is required' },
        { status: 400 }
      );
    }

    // Get the authorization token from headers
    const authHeader = request.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: 'Missing or invalid authorization header' },
        { status: 401 }
      );
    }

    const token = authHeader.replace('Bearer ', '');
    
    // Verify the token and get user
    const { supabase } = await import('../../../lib/supabase');
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    
    if (authError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    console.log('🎯 Updating certification goal for user:', user.id, 'to:', certificationGoal);

    // Use the existing setupUserLearningPath function to handle both
    // the user_profiles update AND structured learning path creation
    const result = await setupUserLearningPath({
      userId: user.id,
      certificationGoal: certificationGoal,
      isPrimary: true
    });

    if (!result.success) {
      return NextResponse.json(
        { error: result.error || 'Failed to update certification goal' },
        { status: 500 }
      );
    }

    console.log('✅ Certification goal updated successfully:', result);

    return NextResponse.json({
      success: true,
      hasStructuredContent: result.hasStructuredContent,
      studyPlanId: result.studyPlanId,
      message: 'Certification goal updated successfully'
    });

  } catch (error) {
    console.error('❌ Error updating certification goal:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
