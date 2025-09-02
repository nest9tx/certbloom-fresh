// Compare content structure between certifications
import { config } from 'dotenv';
import { createClient } from '@supabase/supabase-js';

config({ path: '.env.local' });

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function compareContentStructure() {
  console.log('🔍 Comparing content structure between certifications...\n');
  
  const testCodes = ['902', '391', '901', '903', '904', '905'];
  
  for (const code of testCodes) {
    console.log(`=== ${code} ${code === '902' ? '(WORKING - BASELINE)' : '(NEEDS CONTENT)'} ===`);
    
    // Get certification
    const { data: cert } = await supabase
      .from('certifications')
      .select('id, name, test_code')
      .eq('test_code', code)
      .single();
    
    if (!cert) {
      console.log('❌ Certification not found');
      continue;
    }
    
    console.log(`📋 Certification: ${cert.name}`);
    
    // Check domains
    const { data: domains } = await supabase
      .from('domains')
      .select('id, name, code')
      .eq('certification_id', cert.id);
    
    console.log(`📁 Domains: ${domains?.length || 0}`);
    if (domains) {
      domains.forEach(d => console.log(`   - ${d.name} (${d.code})`));
    }
    
    // Check concepts per domain
    let totalConcepts = 0;
    let totalContentItems = 0;
    
    if (domains) {
      for (const domain of domains) {
        const { data: concepts } = await supabase
          .from('concepts')
          .select('id, name')
          .eq('domain_id', domain.id);
        
        const conceptCount = concepts?.length || 0;
        totalConcepts += conceptCount;
        
        // Check content items for concepts in this domain
        if (concepts && concepts.length > 0) {
          const { data: contentItems } = await supabase
            .from('content_items')
            .select('id, type, title')
            .in('concept_id', concepts.map(c => c.id));
          
          const contentCount = contentItems?.length || 0;
          totalContentItems += contentCount;
          
          console.log(`   📝 ${domain.name}: ${conceptCount} concepts, ${contentCount} content items`);
          
          // Show sample content for Math 902
          if (code === '902' && contentItems && contentItems.length > 0) {
            console.log(`       Sample content types: ${contentItems.slice(0, 3).map(c => c.type).join(', ')}`);
          }
        }
      }
    }
    
    console.log(`📊 Total: ${totalConcepts} concepts, ${totalContentItems} content items`);
    
    // Check questions
    const { data: questions } = await supabase
      .from('questions')
      .select('id')
      .eq('certification_id', cert.id);
    
    console.log(`❓ Questions: ${questions?.length || 0}`);
    
    // Summary
    const hasRichContent = totalContentItems > 0;
    console.log(`🎯 Ready for learning: ${hasRichContent ? '✅ YES' : '❌ NO - needs content items'}`);
    console.log('');
  }
}

compareContentStructure().catch(console.error);
