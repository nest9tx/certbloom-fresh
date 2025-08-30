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

    // Get questions with concept, domain, and certification info using current schema
    const { data: questionsData, error: questionsError } = await supabase
      .from('questions')
      .select(`
        id,
        concept_id,
        difficulty_level,
        created_at
      `)
      .order('created_at', { ascending: false });

    if (questionsError) {
      console.error('Error fetching questions:', questionsError);
      return NextResponse.json({ error: 'Failed to fetch questions' }, { status: 500 });
    }

    // Get concept details separately for better type safety
    const { data: conceptsData, error: conceptsError } = await supabase
      .from('concepts')
      .select(`
        id,
        name,
        domains(
          name,
          certifications(
            name,
            test_code
          )
        )
      `);

    if (conceptsError) {
      console.error('Error fetching concepts:', conceptsError);
      return NextResponse.json({ error: 'Failed to fetch concepts' }, { status: 500 });
    }

    console.log('API: Found questions:', questionsData?.length || 0);
    console.log('API: Found concepts:', conceptsData?.length || 0);

    // Create concept lookup map
    const conceptMap = new Map();
    conceptsData?.forEach(concept => {
      conceptMap.set(concept.id, concept);
    });

    // Process statistics
    const stats = {
      total: questionsData?.length || 0,
      byDomain: {} as Record<string, number>,
      byCertification: {} as Record<string, number>,
      byDifficulty: {} as Record<string, number>
    };

    questionsData?.forEach(question => {
      const concept = conceptMap.get(question.concept_id);
      
      // Count by domain name
      if (concept?.domains?.name) {
        const domainName = concept.domains.name;
        stats.byDomain[domainName] = (stats.byDomain[domainName] || 0) + 1;
      }

      // Count by certification name
      if (concept?.domains?.certifications?.name) {
        const certName = concept.domains.certifications.name;
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
