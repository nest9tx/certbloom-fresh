import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function investigateQuestionLoading() {
  console.log('🔍 Investigating question loading across certifications...\n');
  
  // Get all certifications
  const { data: certs } = await supabase
    .from('certifications')
    .select('id, name, test_code')
    .in('test_code', ['902', '901', '903', '904', '905']);
  
  for (const cert of certs) {
    console.log(`🎯 ${cert.test_code}: ${cert.name}`);
    
    // Get concepts for this certification
    const { data: concepts } = await supabase
      .from('concepts')
      .select(`
        id, name,
        domains!inner(certification_id)
      `)
      .eq('domains.certification_id', cert.id);
      
    console.log(`  📝 Concepts: ${concepts?.length || 0}`);
    
    if (concepts?.length > 0) {
      // Check questions linked to these concepts
      const conceptIds = concepts.map(c => c.id);
      
      // Method 1: Direct concept_id link
      const { data: directQuestions } = await supabase
        .from('questions')
        .select('id, question, concept_id')
        .in('concept_id', conceptIds);
        
      console.log(`  ❓ Direct questions (concept_id): ${directQuestions?.length || 0}`);
      
      // Method 2: Check questions by certification_id
      const { data: certQuestions } = await supabase
        .from('questions')
        .select('id, question, certification_id, domain_id')
        .eq('certification_id', cert.id);
        
      console.log(`  ❓ Cert-based questions: ${certQuestions?.length || 0}`);
      
      // Method 3: Check questions table structure
      if (certQuestions?.length > 0) {
        const sample = certQuestions[0];
        console.log(`  📋 Sample question fields:`, Object.keys(sample));
        console.log(`  📋 Sample domain_id:`, sample.domain_id);
      }
      
      // Show breakdown by concept for first few
      if (directQuestions?.length > 0) {
        console.log(`  📝 Questions per concept:`);
        const questionsByConceptId = {};
        directQuestions.forEach(q => {
          if (!questionsByConceptId[q.concept_id]) questionsByConceptId[q.concept_id] = 0;
          questionsByConceptId[q.concept_id]++;
        });
        
        Object.entries(questionsByConceptId).slice(0, 3).forEach(([conceptId, count]) => {
          const concept = concepts.find(c => c.id === conceptId);
          console.log(`    - ${concept?.name}: ${count} questions`);
        });
      }
    }
    console.log('');
  }
}

investigateQuestionLoading().catch(console.error);
