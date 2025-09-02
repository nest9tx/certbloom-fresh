import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function checkContentStructure() {
  console.log('🔍 Checking content structure for different certifications...\n');
  
  // First get certification IDs by test codes
  const { data: certs, error: certError } = await supabase
    .from('certifications')
    .select('id, name, test_code')
    .in('test_code', ['902', '901', '903', '904', '905']);
    
  if (certError) {
    console.error('Error fetching certifications:', certError);
    return;
  }
  
  console.log('📋 Available certifications:');
  certs.forEach(c => {
    console.log(`  ${c.test_code}: ${c.name} (ID: ${c.id})`);
  });
  
  const certIds = certs.map(c => c.id);
  
  // Check domains for these certifications
  const { data: domains, error: domainError } = await supabase
    .from('domains')
    .select('id, name, certification_id')
    .in('certification_id', certIds)
    .order('certification_id', { ascending: true });
    
  if (domainError) {
    console.error('Error fetching domains:', domainError);
    return;
  }
    
  console.log('\n📚 DOMAINS by certification:');
  const domainsByCert = {};
  (domains || []).forEach(d => {
    const cert = certs.find(c => c.id === d.certification_id);
    const testCode = cert ? cert.test_code : d.certification_id;
    if (!domainsByCert[testCode]) domainsByCert[testCode] = [];
    domainsByCert[testCode].push(d.name);
  });
  Object.entries(domainsByCert).forEach(([cert, doms]) => {
    console.log(`  ${cert}: ${doms.length} domains - ${doms.join(', ')}`);
  });

  // Check concepts
  const { data: concepts } = await supabase
    .from('concepts')
    .select('id, name, domain_id, domains(certification_id)')
    .in('domains.certification_id', certIds)
    .order('domains(certification_id)', { ascending: true });
    
  console.log('\n🧠 CONCEPTS by certification:');
  const conceptsByCert = {};
  (concepts || []).forEach(c => {
    if (c.domains && c.domains.certification_id) {
      const cert = certs.find(cert => cert.id === c.domains.certification_id);
      const testCode = cert ? cert.test_code : c.domains.certification_id;
      if (!conceptsByCert[testCode]) conceptsByCert[testCode] = [];
      conceptsByCert[testCode].push(c.name);
    }
  });
  Object.entries(conceptsByCert).forEach(([cert, concepts]) => {
    console.log(`  ${cert}: ${concepts.length} concepts`);
  });

  // Check content items
  const { data: contentItems } = await supabase
    .from('content_items')
    .select('id, title, concept_id, concepts(domain_id, domains(certification_id))')
    .in('concepts.domains.certification_id', certIds)
    .order('concepts(domains(certification_id))', { ascending: true });
    
  console.log('\n📖 CONTENT ITEMS by certification:');
  const contentByCert = {};
  (contentItems || []).forEach(c => {
    if (c.concepts && c.concepts.domains && c.concepts.domains.certification_id) {
      const cert = certs.find(cert => cert.id === c.concepts.domains.certification_id);
      const testCode = cert ? cert.test_code : c.concepts.domains.certification_id;
      if (!contentByCert[testCode]) contentByCert[testCode] = [];
      contentByCert[testCode].push(c.title);
    }
  });
  Object.entries(contentByCert).forEach(([cert, items]) => {
    console.log(`  ${cert}: ${items.length} items`);
  });

  // Check specific 902 content to see what makes it different
  console.log('\n🔬 DEEP DIVE: 902 Math content structure:');
  const mathCert = certs.find(c => c.test_code === '902');
  if (mathCert) {
    const { data: mathConcepts } = await supabase
      .from('concepts')
      .select(`
        id, name,
        domains!inner(name, certification_id),
        content_items(id, title, content_type)
      `)
      .eq('domains.certification_id', mathCert.id);
      
    (mathConcepts || []).forEach(concept => {
      console.log(`  📝 ${concept.name} (${concept.domains.name}): ${concept.content_items.length} items`);
      concept.content_items.forEach(item => {
        console.log(`    - ${item.title} (${item.content_type})`);
      });
    });
  }

  // Check one of the other certifications for comparison
  console.log('\n🔬 COMPARISON: 901 ELA content structure:');
  const elaCert = certs.find(c => c.test_code === '901');
  if (elaCert) {
    const { data: elaConcepts } = await supabase
      .from('concepts')
      .select(`
        id, name,
        domains!inner(name, certification_id),
        content_items(id, title, content_type)
      `)
      .eq('domains.certification_id', elaCert.id);
      
    (elaConcepts || []).forEach(concept => {
      console.log(`  📝 ${concept.name} (${concept.domains.name}): ${concept.content_items.length} items`);
      concept.content_items.forEach(item => {
        console.log(`    - ${item.title} (${item.content_type})`);
      });
    });
  }
}

checkContentStructure().catch(console.error);
