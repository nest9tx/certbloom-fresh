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

async function generateDatabaseStatusReport() {
  console.log('🔍 CERTBLOOM DATABASE STATUS REPORT');
  console.log('=====================================\n');

  try {
    // Get all certifications with their structure
    const { data: certifications, error: certError } = await supabase
      .from('certifications')
      .select(`
        id,
        name,
        test_code,
        description
      `)
      .order('test_code');

    if (certError) {
      console.error('❌ Error fetching certifications:', certError);
      return;
    }

    console.log(`📚 CERTIFICATIONS FOUND: ${certifications.length}\n`);

    for (const cert of certifications) {
      console.log(`🎯 ${cert.test_code || 'NO-CODE'}: ${cert.name}`);
      console.log(`   Description: ${cert.description || 'No description'}`);

      // Get domains for this certification
      const { data: domains, error: domainError } = await supabase
        .from('domains')
        .select('id, name, order_index, weight_percentage')
        .eq('certification_id', cert.id)
        .order('order_index');

      if (domainError) {
        console.log(`   ❌ Error fetching domains: ${domainError.message}`);
        continue;
      }

      if (!domains || domains.length === 0) {
        console.log('   ❌ NO DOMAINS');
        console.log('');
        continue;
      }

      console.log(`   ✅ DOMAINS (${domains.length}):`);

      let totalConcepts = 0;
      let totalQuestions = 0;

      for (const domain of domains) {
        console.log(`      📂 ${domain.name} (weight: ${domain.weight_percentage || 0}%)`);

        // Get concepts for this domain
        const { data: concepts, error: conceptError } = await supabase
          .from('concepts')
          .select('id, name, difficulty_level')
          .eq('domain_id', domain.id);

        if (conceptError) {
          console.log(`         ❌ Error fetching concepts: ${conceptError.message}`);
          continue;
        }

        if (!concepts || concepts.length === 0) {
          console.log('         ❌ No concepts');
          continue;
        }

        totalConcepts += concepts.length;
        console.log(`         💡 CONCEPTS (${concepts.length}):`);

        for (const concept of concepts.slice(0, 3)) { // Show first 3 concepts
          console.log(`            - ${concept.name} (difficulty: ${concept.difficulty_level || 'N/A'})`);

          // Check for questions in this concept
          const { data: questions, error: questionError } = await supabase
            .from('questions')
            .select('id, difficulty_level')
            .eq('concept_id', concept.id);

          if (!questionError && questions) {
            totalQuestions += questions.length;
            if (questions.length > 0) {
              console.log(`              📝 ${questions.length} questions`);
            }
          }
        }

        if (concepts.length > 3) {
          console.log(`            ... and ${concepts.length - 3} more concepts`);
        }
      }

      console.log(`   📊 TOTALS: ${totalConcepts} concepts, ${totalQuestions} questions`);
      console.log('');
    }

    // Summary section
    console.log('📋 SUMMARY FOR STUDY PATH AVAILABILITY');
    console.log('=====================================');

    const structuredCerts = [];
    const basicCerts = [];
    const emptyCerts = [];

    for (const cert of certifications) {
      const { data: domains } = await supabase
        .from('domains')
        .select('id')
        .eq('certification_id', cert.id);

      if (!domains || domains.length === 0) {
        emptyCerts.push(cert);
        continue;
      }

      // Check if has substantial content
      let totalQuestions = 0;
      for (const domain of domains) {
        const { data: concepts } = await supabase
          .from('concepts')
          .select('id')
          .eq('domain_id', domain.id);

        if (concepts) {
          for (const concept of concepts) {
            const { data: questions } = await supabase
              .from('questions')
              .select('id')
              .eq('concept_id', concept.id);
            
            if (questions) {
              totalQuestions += questions.length;
            }
          }
        }
      }

      if (totalQuestions > 50) {
        structuredCerts.push({ ...cert, questionCount: totalQuestions });
      } else {
        basicCerts.push({ ...cert, questionCount: totalQuestions, domainCount: domains.length });
      }
    }

    console.log('\n🎯 READY FOR STUDY PATH (50+ questions):');
    structuredCerts.forEach(cert => {
      console.log(`   ✅ ${cert.test_code}: ${cert.name} (${cert.questionCount} questions)`);
    });

    console.log('\n⚠️  BASIC STRUCTURE (domains but few questions):');
    basicCerts.forEach(cert => {
      console.log(`   🔶 ${cert.test_code}: ${cert.name} (${cert.domainCount} domains, ${cert.questionCount} questions)`);
    });

    console.log('\n❌ NO STRUCTURE:');
    emptyCerts.forEach(cert => {
      console.log(`   ❌ ${cert.test_code || 'NO-CODE'}: ${cert.name}`);
    });

    console.log('\n🔧 CERTIFICATION MAPPING STATUS:');
    console.log('The following test codes should appear in study path:');
    const testCodesWithStructure = [...structuredCerts, ...basicCerts].map(c => c.test_code).filter(Boolean);
    testCodesWithStructure.forEach(code => {
      console.log(`   ✅ ${code} - mapped and has structure`);
    });

  } catch (error) {
    console.error('❌ Unexpected error:', error);
  }
}

generateDatabaseStatusReport();
