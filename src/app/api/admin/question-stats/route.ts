import { createClient } from '@supabase/supabase-js';
import { NextResponse } from 'next/server';

// Force dynamic rendering to prevent caching of database queries
export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    // Use service role key to bypass RLS
    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!
    );

    // Get questions with certification and topic info
    const { data: questions, error: questionsError } = await supabase
      .from('questions')
      .select(`
        certification_id, 
        difficulty_level,
        domain,
        concept,
        certifications(name),
        topics(name)
      `)
      .order('created_at', { ascending: false });

    if (questionsError) {
      console.error('Error fetching questions:', questionsError);
      return NextResponse.json({ error: 'Failed to fetch questions' }, { status: 500 });
    }

    console.log('API: Found questions:', questions?.length || 0);
    console.log('API: Sample question:', questions?.[0]);

    // Process statistics
    const stats = {
      total: questions?.length || 0,
      byDomain: {} as Record<string, number>,
      byCertification: {} as Record<string, number>,
      byDifficulty: {} as Record<string, number>
    };

    questions?.forEach(question => {
      // Count by topic name (use topic instead of old domain field)
      const topic = question.topics as unknown as { name: string } | null;
      if (topic?.name) {
        const topicName = topic.name;
        stats.byDomain[topicName] = (stats.byDomain[topicName] || 0) + 1;
      } else if (question.domain) {
        // Fallback to domain field for questions without topics
        stats.byDomain[question.domain] = (stats.byDomain[question.domain] || 0) + 1;
      }

      // Count by certification name
      const certification = question.certifications as unknown as { name: string } | null;
      if (certification?.name) {
        const certName = certification.name;
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
