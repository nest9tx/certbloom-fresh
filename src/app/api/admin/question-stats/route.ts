import { createClient } from '@supabase/supabase-js';
import { NextRequest, NextResponse } from 'next/server';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

export async function GET(request: NextRequest) {
  try {
    // Verify admin access (you can enhance this with proper admin role checking)
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // Get question statistics with certification names
    const { data: questions, error: questionsError } = await supabase
      .from('questions')
      .select(`
        certification_id, 
        difficulty_level,
        certifications!inner(name)
      `)
      .order('created_at', { ascending: false });

    if (questionsError) {
      console.error('Error fetching questions:', questionsError);
      return NextResponse.json({ error: 'Failed to fetch questions' }, { status: 500 });
    }

    // Process statistics
    const stats = {
      total: questions?.length || 0,
      byDomain: {} as Record<string, number>,
      byCertification: {} as Record<string, number>,
      byDifficulty: {} as Record<string, number>
    };

    questions?.forEach(question => {
      // Count by certification name instead of domain
      if (question.certifications && question.certifications[0]?.name) {
        const certName = question.certifications[0].name;
        stats.byDomain[certName] = (stats.byDomain[certName] || 0) + 1;
      }

      // Count by certification name for the byCertification stats too
      if (question.certifications && question.certifications[0]?.name) {
        const certName = question.certifications[0].name;
        stats.byCertification[certName] = (stats.byCertification[certName] || 0) + 1;
      }

      // Count by difficulty
      if (question.difficulty_level) {
        stats.byDifficulty[question.difficulty_level] = (stats.byDifficulty[question.difficulty_level] || 0) + 1;
      }
    });

    return NextResponse.json(stats);

  } catch (error) {
    console.error('Error in question stats API:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
