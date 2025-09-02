import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function findLinkedConcepts() {
  // Find which concepts have questions
  const { data: questionsWithConcepts } = await supabase
    .from('questions')
    .select('concept_id')
    .not('concept_id', 'is', null);

  const questionConceptIds = [...new Set(questionsWithConcepts?.map(q => q.concept_id) || [])];

  // Get details about these concepts
  const { data: linkedConcepts } = await supabase
    .from('concepts')
    .select(`
      id, name,
      domains!inner(name, certification_id, certifications(name, test_code))
    `)
    .in('id', questionConceptIds);

  console.log('🎯 Concepts that have questions linked:');
  
  for (const concept of linkedConcepts || []) {
    const cert = concept.domains.certifications;
    console.log(`  - ${concept.name} (Domain: ${concept.domains.name})`);
    console.log(`    Certification: ${cert.test_code} - ${cert.name}`);
    
    // Count questions for this concept
    const { count } = await supabase
      .from('questions')
      .select('*', { count: 'exact', head: true })
      .eq('concept_id', concept.id);
    console.log(`    Questions: ${count}`);
    console.log('');
  }
}

findLinkedConcepts().catch(console.error);
