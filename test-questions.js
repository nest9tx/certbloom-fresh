// Test the question loading for certifications
import { createClient } from '@supabase/supabase-js';
import { config } from 'dotenv';

config();

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Missing environment variables');
  console.log('SUPABASE_URL:', supabaseUrl ? 'Set' : 'Missing');
  console.log('SUPABASE_KEY:', supabaseKey ? 'Set' : 'Missing');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function testQuestionLoading() {
  console.log('🔍 Testing question loading for all certifications...\n');

  // Get all certifications with their test codes
  const { data: certs, error: certsError } = await supabase
    .from('certifications')
    .select('id, name, test_code')
    .in('test_code', ['391', '901', '902', '903', '904', '905']);

  if (certsError) {
    console.error('❌ Error fetching certifications:', certsError);
    return;
  }

  console.log('📚 Found certifications:');
  certs?.forEach(cert => console.log(`  ${cert.test_code}: ${cert.name}`));
  console.log('');

  for (const cert of certs || []) {
    console.log(`\n🎯 Testing ${cert.test_code} (${cert.name}):`);
    
    // Get concepts for this certification
    const { data: concepts, error: conceptsError } = await supabase
      .from('concepts')
      .select(`
        id, 
        name,
        domains!inner(
          certification_id
        )
      `)
      .eq('domains.certification_id', cert.id)
      .limit(3); // Test first 3 concepts

    if (conceptsError) {
      console.error(`  ❌ Error fetching concepts:`, conceptsError);
      continue;
    }

    if (!concepts || concepts.length === 0) {
      console.log(`  ⚠️ No concepts found`);
      continue;
    }

    console.log(`  📋 Found ${concepts.length} concepts`);

    for (const concept of concepts) {
      // Test question loading
      const { data: questions, error: questionsError } = await supabase
        .from('questions')
        .select('id, question_text')
        .eq('concept_id', concept.id)
        .limit(3);

      if (questionsError) {
        console.error(`    ❌ Error fetching questions for ${concept.name}:`, questionsError);
        continue;
      }

      const questionCount = questions?.length || 0;
      console.log(`    ${questionCount > 0 ? '✅' : '❌'} ${concept.name}: ${questionCount} questions`);
      
      if (questionCount > 0) {
        questions?.forEach((q, i) => 
          console.log(`      ${i + 1}. ${q.question_text.substring(0, 60)}...`)
        );
      }
    }
  }
}

// Run the test
testQuestionLoading().catch(console.error);
