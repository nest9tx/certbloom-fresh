import { createClient } from '@supabase/supabase-js';
import { config } from 'dotenv';

config();

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL, 
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function checkQuestionStructure() {
  console.log('🔍 Checking questions table structure...\n');
  
  // Get a sample question to see structure
  const { data: sampleQuestions, error } = await supabase
    .from('questions')
    .select('*')
    .limit(3);
    
  if (error) {
    console.error('❌ Error:', error);
    return;
  }
  
  if (sampleQuestions?.length > 0) {
    console.log('📋 Sample question fields:');
    console.log(Object.keys(sampleQuestions[0]));
    console.log('\n📋 Sample question data:');
    sampleQuestions.forEach((q, i) => {
      console.log(`Question ${i + 1}:`);
      console.log(`  ID: ${q.id}`);
      console.log(`  Question: ${q.question?.substring(0, 60) || q.question_text?.substring(0, 60) || 'N/A'}...`);
      console.log(`  Concept ID: ${q.concept_id || 'NULL'}`);
      console.log(`  Certification ID: ${q.certification_id || 'NULL'}`);
      console.log(`  Domain ID: ${q.domain_id || 'NULL'}`);
      console.log(`  Answer A: ${q.answer_a || q.option_a || 'NULL'}`);
      console.log(`  Answer B: ${q.answer_b || q.option_b || 'NULL'}`);
      console.log('');
    });
  }
  
  // Count total questions
  const { count, error: countError } = await supabase
    .from('questions')
    .select('*', { count: 'exact', head: true });
    
  if (!countError) {
    console.log(`📊 Total questions in database: ${count}`);
  }
  
  // Check for questions with concept_id
  const { count: conceptLinkedCount } = await supabase
    .from('questions')
    .select('*', { count: 'exact', head: true })
    .not('concept_id', 'is', null);
    
  console.log(`📊 Questions with concept_id linked: ${conceptLinkedCount}`);
  
  // Get certification names to understand structure
  const { data: certs } = await supabase
    .from('certifications')
    .select('id, name, test_code')
    .in('test_code', ['902', '901', '903', '904', '905']);
    
  if (certs) {
    console.log('\n📚 Available certifications:');
    certs.forEach(cert => {
      console.log(`  ${cert.test_code}: ${cert.name} (${cert.id})`);
    });
  }
}

checkQuestionStructure().catch(console.error);
