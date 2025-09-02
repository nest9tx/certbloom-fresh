import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing Supabase environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function checkCertificationStructure() {
  console.log('🔍 Checking certification structure...\n');

  try {
    // Get all certifications
    const { data: certifications, error: certError } = await supabase
      .from('certifications')
      .select('id, name, test_code')
      .order('test_code');

    if (certError) {
      console.error('❌ Error fetching certifications:', certError);
      return;
    }

    console.log('📚 Available certifications:');
    for (const cert of certifications) {
      console.log(`\n${cert.test_code}: ${cert.name}`);
      
      // Check domains for this certification
      const { data: domains, error: domainError } = await supabase
        .from('domains')
        .select('id, name, order_index')
        .eq('certification_id', cert.id)
        .order('order_index');

      if (domainError) {
        console.error(`  ❌ Error fetching domains: ${domainError.message}`);
        continue;
      }

      if (!domains || domains.length === 0) {
        console.log('  ❌ No domains found');
        continue;
      }

      console.log(`  ✅ Domains (${domains.length}):`);
      for (const domain of domains) {
        // Check concepts for this domain
        const { data: concepts, error: conceptError } = await supabase
          .from('concepts')
          .select('id, name')
          .eq('domain_id', domain.id);

        if (conceptError) {
          console.error(`    ❌ Error fetching concepts: ${conceptError.message}`);
          continue;
        }

        console.log(`    - ${domain.name} (${concepts?.length || 0} concepts)`);
        
        // For Math, show a few sample concepts
        if (cert.test_code === '902' && concepts && concepts.length > 0) {
          console.log(`      Sample concepts: ${concepts.slice(0, 3).map(c => c.name).join(', ')}...`);
        }
      }
    }

    // Summary
    console.log('\n📊 SUMMARY:');
    const mathCert = certifications.find(c => c.test_code === '902');
    if (mathCert) {
      const { data: mathDomains } = await supabase
        .from('domains')
        .select('id')
        .eq('certification_id', mathCert.id);
      
      console.log(`✅ Math (902) has ${mathDomains?.length || 0} domains - fully structured`);
    }

    const otherCerts = certifications.filter(c => c.test_code !== '902');
    for (const cert of otherCerts) {
      const { data: domains } = await supabase
        .from('domains')
        .select('id')
        .eq('certification_id', cert.id);
      
      const status = domains && domains.length > 0 ? '✅ structured' : '❌ needs setup';
      console.log(`${status} ${cert.test_code} has ${domains?.length || 0} domains`);
    }

  } catch (error) {
    console.error('❌ Unexpected error:', error);
  }
}

checkCertificationStructure();
