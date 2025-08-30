#!/usr/bin/env node

import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://ujsxqrkvjniwekwewdqj.supabase.co',
  process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqc3hxcmt2am5pd2Vrd2V3ZHFqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNjU4MDQyNSwiZXhwIjoyMDQyMTU2NDI1fQ.6TDzSTFJnVtxKNUqYShBrwGsqhTdcvHYV1IH9h5KVRI'
);

async function fixStudyPath() {
  console.log('🔧 Starting study path question integration fix...');

  try {
    // Get concepts that need content items (have questions but no content)
    const { data: conceptsData, error: conceptsError } = await supabase
      .from('concepts')
      .select(`
        id,
        name,
        domains!inner(
          certification_id,
          certifications!inner(test_code)
        )
      `)
      .eq('domains.certifications.test_code', '902');

    if (conceptsError) {
      console.error('Error fetching concepts:', conceptsError);
      return;
    }

    console.log(`📋 Found ${conceptsData?.length || 0} Math 902 concepts`);

    // For each concept, check if it has questions but no content
    const contentItemsToCreate = [];
    
    for (const concept of conceptsData || []) {
      console.log(`🔍 Checking concept: ${concept.name}`);
      
      // Check if concept has questions
      const { data: questions, error: questionsError } = await supabase
        .from('questions')
        .select('id')
        .eq('concept_id', concept.id)
        .limit(1);

      if (questionsError) {
        console.error(`❌ Error checking questions for concept ${concept.name}:`, questionsError);
        continue;
      }

      // Check if concept has content items
      const { data: contentItems, error: contentError } = await supabase
        .from('content_items')
        .select('id')
        .eq('concept_id', concept.id)
        .limit(1);

      if (contentError) {
        console.error(`❌ Error checking content for concept ${concept.name}:`, contentError);
        continue;
      }

      // If has questions but no content, create content items
      if (questions && questions.length > 0 && (!contentItems || contentItems.length === 0)) {
        console.log(`✨ Creating content items for: ${concept.name}`);
        
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
      } else if (contentItems && contentItems.length > 0) {
        console.log(`✅ ${concept.name} already has content items`);
      } else {
        console.log(`⚠️ ${concept.name} has no questions and no content`);
      }
    }

    // Insert all content items
    if (contentItemsToCreate.length > 0) {
      console.log(`📝 Inserting ${contentItemsToCreate.length} content items...`);
      
      const { data: insertData, error: insertError } = await supabase
        .from('content_items')
        .insert(contentItemsToCreate)
        .select();

      if (insertError) {
        console.error('❌ Error inserting content items:', insertError);
        return;
      }

      console.log(`✅ Created ${insertData?.length || 0} content items successfully!`);
    } else {
      console.log('ℹ️ No content items needed to be created');
    }

    // Verification
    console.log('🔍 Verifying results...');
    
    const { data: verification, error: verificationError } = await supabase
      .from('concepts')
      .select(`
        id,
        name,
        content_items!left(id),
        domains!inner(
          certifications!inner(test_code)
        )
      `)
      .eq('domains.certifications.test_code', '902');

    if (verificationError) {
      console.error('❌ Verification error:', verificationError);
    } else {
      console.log('\n📊 Final Status:');
      verification?.forEach(concept => {
        const contentCount = concept.content_items?.length || 0;
        const status = contentCount > 0 ? '✅ READY' : '❌ NO CONTENT';
        console.log(`  ${concept.name}: ${contentCount} content items ${status}`);
      });
    }

    console.log('\n🎉 Study path integration fix completed!');

  } catch (error) {
    console.error('💥 Fatal error:', error);
  }
}

fixStudyPath();
