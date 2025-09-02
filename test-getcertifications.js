import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('❌ Missing Supabase environment variables');
  process.exit(1);
}

// Use the same client as the app (anon key, not service role)
const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function testGetCertifications() {
  console.log('🧪 Testing getCertifications() function as used in study path...\n');

  try {
    // This replicates exactly what getCertifications() does in conceptLearning.ts
    const { data, error } = await supabase
      .from('certifications')
      .select('*')
      .order('name');

    if (error) {
      console.error('❌ Error from getCertifications():', error);
      return;
    }

    console.log('📋 getCertifications() returns:');
    console.log(`   Total certifications: ${data?.length || 0}`);
    
    if (data) {
      data.forEach((cert, index) => {
        console.log(`   ${index + 1}. ${cert.test_code || 'NO-CODE'}: ${cert.name}`);
        console.log(`      ID: ${cert.id}`);
        console.log(`      Description: ${cert.description || 'No description'}`);
        console.log('');
      });
    }

    // Check which ones have test codes that should be mappable
    const testCodesInMapping = ['391', '901', '902', '903', '904', '905'];
    const availableTestCodes = data?.filter(c => c.test_code && testCodesInMapping.includes(c.test_code)) || [];
    
    console.log('🎯 Certifications that SHOULD appear in study path:');
    availableTestCodes.forEach(cert => {
      console.log(`   ✅ ${cert.test_code}: ${cert.name}`);
    });

    console.log(`\n🔍 Expected in study path: ${availableTestCodes.length} certifications`);
    
    if (availableTestCodes.length < 5) {
      console.log('⚠️  Issue: Not all expected certifications are being returned by getCertifications()');
    } else {
      console.log('✅ All expected certifications are available from getCertifications()');
      console.log('   The issue must be elsewhere in the study path logic.');
    }

  } catch (error) {
    console.error('❌ Unexpected error:', error);
  }
}

testGetCertifications();
