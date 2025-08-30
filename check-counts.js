import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config({ path: '.env.local' });

console.log('Script starting...');

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

console.log('Supabase client created');

async function checkCertifications() {
  console.log('🔍 Checking all certifications...');
  
  // Get all certifications
  const { data: certs } = await supabase
    .from('certifications')
    .select('id, name, test_code')
    .order('name');
    
  console.log('📚 Available certifications:');
  certs?.forEach(cert => {
    console.log(`  - ${cert.test_code}: ${cert.name}`);
  });
  
  // Look for EC-6 specifically
  const ec6Math = certs?.find(cert => 
    cert.test_code?.includes('EC-6') || 
    cert.name?.toLowerCase().includes('ec-6') ||
    cert.name?.toLowerCase().includes('elementary')
  );
  
  if (ec6Math) {
    console.log(`\n✅ Found EC-6 Math: ${ec6Math.name} (Test Code: ${ec6Math.test_code})`);
    
    // Check if it has domains and concepts
    const { data: domains } = await supabase
      .from('domains')
      .select('id, name')
      .eq('certification_id', ec6Math.id);
      
    console.log(`📖 EC-6 Math domains: ${domains?.length || 0}`);
    domains?.forEach(domain => console.log(`  - ${domain.name}`));
    
    if (domains?.length > 0) {
      // Check concepts in first domain
      const { data: concepts } = await supabase
        .from('concepts')
        .select('id, name')
        .eq('domain_id', domains[0].id)
        .limit(5);
        
      console.log(`\n🧠 Sample concepts in ${domains[0].name}:`);
      concepts?.forEach(concept => console.log(`  - ${concept.name}`));
      
      // Check if these concepts have questions
      if (concepts?.length > 0) {
        const { data: questions } = await supabase
          .from('questions')
          .select('id')
          .eq('concept_id', concepts[0].id);
          
        console.log(`\n❓ Questions for '${concepts[0].name}': ${questions?.length || 0}`);
        
        // Check content items
        const { data: contentItems } = await supabase
          .from('content_items')
          .select('type, title')
          .eq('concept_id', concepts[0].id);
          
        console.log(`📄 Content items for '${concepts[0].name}': ${contentItems?.length || 0}`);
        contentItems?.forEach(item => console.log(`  - ${item.type}: ${item.title}`));
      }
    }
  } else {
    console.log('\n❌ No EC-6 Math certification found');
    console.log('Available test codes:', certs?.map(c => c.test_code).join(', '));
  }
}

checkCertifications().catch(console.error);
