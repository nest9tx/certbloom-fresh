import { createClient } from '@supabase/supabase-js';
import { NextResponse } from 'next/server';

// Force dynamic rendering to prevent caching
export const dynamic = 'force-dynamic';

export async function POST() {
  try {
    // Use service role key to bypass RLS for admin operations
    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!
    );

    console.log('🔧 Starting study path question integration fix...');

    // Step 1: Analyze current content vs questions
    const { data: analysisData, error: analysisError } = await supabase.rpc('analyze_concept_content');
    
    if (analysisError) {
      console.error('Analysis error:', analysisError);
    } else {
      console.log('📊 Analysis complete:', analysisData);
    }

    // Step 2: Get concepts that need content items (have questions but no content)
    const { data: conceptsNeedingContent, error: conceptsError } = await supabase
      .from('concepts')
      .select(`
        id,
        name,
        domain_id,
        domains!inner(
          certification_id,
          certifications!inner(test_code)
        )
      `)
      .eq('domains.certifications.test_code', '902');

    if (conceptsError) {
      console.error('Error fetching concepts:', conceptsError);
      return NextResponse.json({ error: 'Failed to fetch concepts' }, { status: 500 });
    }

    // Step 3: For each concept, check if it has questions but no content
    const contentItemsToCreate = [];
    
    for (const concept of conceptsNeedingContent || []) {
      // Check if concept has questions
      const { data: questions, error: questionsError } = await supabase
        .from('questions')
        .select('id')
        .eq('concept_id', concept.id)
        .limit(1);

      if (questionsError) {
        console.error(`Error checking questions for concept ${concept.name}:`, questionsError);
        continue;
      }

      // Check if concept has content items
      const { data: contentItems, error: contentError } = await supabase
        .from('content_items')
        .select('id')
        .eq('concept_id', concept.id)
        .limit(1);

      if (contentError) {
        console.error(`Error checking content for concept ${concept.name}:`, contentError);
        continue;
      }

      // If has questions but no content, create content items
      if (questions && questions.length > 0 && (!contentItems || contentItems.length === 0)) {
        console.log(`🆕 Creating content items for: ${concept.name}`);
        
        contentItemsToCreate.push(
          // Introduction
          {
            concept_id: concept.id,
            type: 'explanation',
            title: `Introduction to ${concept.name}`,
            content: `Welcome to ${concept.name}! This concept includes comprehensive practice questions to help you master key skills.`,
            order_index: 1,
            estimated_minutes: 5
          },
          // Practice Session
          {
            concept_id: concept.id,
            type: 'practice',
            title: `Practice Questions: ${concept.name}`,
            content: `Complete practice questions for ${concept.name}. This session includes varied difficulty levels to build mastery.`,
            order_index: 2,
            estimated_minutes: 20
          },
          // Review
          {
            concept_id: concept.id,
            type: 'review',
            title: `Review & Summary: ${concept.name}`,
            content: `Review key concepts and strategies for ${concept.name}. Reflect on areas of strength and opportunities for growth.`,
            order_index: 3,
            estimated_minutes: 10
          }
        );
      }
    }

    // Step 4: Insert all content items
    if (contentItemsToCreate.length > 0) {
      const { data: insertData, error: insertError } = await supabase
        .from('content_items')
        .insert(contentItemsToCreate)
        .select();

      if (insertError) {
        console.error('Error inserting content items:', insertError);
        return NextResponse.json({ error: 'Failed to create content items' }, { status: 500 });
      }

      console.log(`✅ Created ${insertData?.length || 0} content items`);
    }

    // Step 5: Verification - get final status
    const { data: verification, error: verificationError } = await supabase
      .from('concepts')
      .select(`
        id,
        name,
        content_items(id),
        questions:questions(id),
        domains!inner(
          certifications!inner(test_code)
        )
      `)
      .eq('domains.certifications.test_code', '902');

    if (verificationError) {
      console.error('Verification error:', verificationError);
    }

    const summary = verification?.map(concept => ({
      name: concept.name,
      content_items: concept.content_items?.length || 0,
      questions: concept.questions?.length || 0,
      status: (concept.questions?.length || 0) > 0 && (concept.content_items?.length || 0) > 0 
        ? 'READY' : 'NEEDS_WORK'
    }));

    return NextResponse.json({
      success: true,
      contentItemsCreated: contentItemsToCreate.length,
      summary,
      message: 'Study path question integration completed successfully!'
    });

  } catch (error) {
    console.error('Error in study path integration:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
