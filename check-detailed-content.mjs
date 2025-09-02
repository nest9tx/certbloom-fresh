import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function checkDetailedContent() {
  const { data: certs } = await supabase
    .from('certifications')
    .select('id, name, test_code')
    .in('test_code', ['902', '901', '903', '904', '905']);
    
  for (const cert of certs) {
    console.log(`\n🎯 ${cert.test_code}: ${cert.name}`);
    console.log('='.repeat(50));
    
    // Get concepts for this certification
    const { data: concepts } = await supabase
      .from('concepts')
      .select(`
        id, name,
        domains!inner(name, certification_id),
        content_items(id, title, content_type)
      `)
      .eq('domains.certification_id', cert.id);
      
    console.log(`📝 Total concepts: ${concepts?.length || 0}`);
    
    let totalContentItems = 0;
    const contentByType = {};
    
    (concepts || []).forEach(concept => {
      const itemCount = concept.content_items?.length || 0;
      totalContentItems += itemCount;
      
      console.log(`  • ${concept.name} (${concept.domains.name}): ${itemCount} items`);
      
      concept.content_items?.forEach(item => {
        if (!contentByType[item.content_type]) contentByType[item.content_type] = 0;
        contentByType[item.content_type]++;
      });
    });
    
    console.log(`📊 Total content items: ${totalContentItems}`);
    console.log('Content types:', contentByType);
  }
}

checkDetailedContent().catch(console.error);
