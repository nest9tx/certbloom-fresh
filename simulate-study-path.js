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

const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Simulate the getCertifications function from conceptLearning.ts
async function getCertifications() {
  const { data, error } = await supabase
    .from('certifications')
    .select('*')
    .order('name')

  if (error) throw error
  return data || []
}

async function simulateStudyPathLoad() {
  console.log('🔍 SIMULATING STUDY PATH PAGE LOAD');
  console.log('===================================\n');

  try {
    console.log('1. Loading certifications with getCertifications()...');
    const certs = await getCertifications();
    
    console.log(`   ✅ Loaded ${certs.length} certifications\n`);
    
    console.log('2. Processing certifications for study path display:');
    
    const validCerts = certs.filter(cert => {
      // Filter out certifications without test codes (these are old/invalid)
      return cert.test_code && cert.test_code.trim() !== '';
    });
    
    console.log(`   📋 Valid certifications (with test codes): ${validCerts.length}`);
    
    validCerts.forEach(cert => {
      const hasStructuredContent = true; // As set in the study path code
      const statusText = cert.test_code === '902' ? '✅ Fully structured' : '🚧 Basic structure ready';
      
      console.log(`   📚 ${cert.test_code}: ${cert.name}`);
      console.log(`      Status: ${statusText}`);
      console.log(`      Button: ${hasStructuredContent ? 'Start Learning →' : 'Coming Soon'}`);
      console.log('');
    });
    
    console.log('3. Study path should display:');
    console.log(`   🎯 ${validCerts.length} certification cards`);
    console.log(`   🔴 All should have "Start Learning →" buttons`);
    
    if (validCerts.length < 5) {
      console.log('\n⚠️  WARNING: Expected 6 certifications (391, 901, 902, 903, 904, 905)');
      console.log('   This suggests the issue is in the data');
    } else {
      console.log('\n✅ Expected certifications are present');
      console.log('   If study path shows only Math, the issue is in the browser/UI');
    }
    
    // Check the exact mapping that should work
    console.log('\n4. Testing certification mapping:');
    const CERTIFICATION_MAPPING = {
      'Math EC-6': '902', 
      'TExES Core Subjects EC-6: Mathematics (902)': '902',
      'Elementary Mathematics': '902',
      'ELA EC-6': '901',
      'TExES Core Subjects EC-6: English Language Arts (901)': '901',
      'English Language Arts EC-6': '901',
      'EC-6 Core Subjects': '391',
      'TExES Core Subjects EC-6 (391)': '391',
      'Core Subjects EC-6': '391',
      'Social Studies EC-6': '903',
      'TExES Core Subjects EC-6: Social Studies (903)': '903',
      'Science EC-6': '904',
      'TExES Core Subjects EC-6: Science (904)': '904',
      'Fine Arts EC-6': '905',
      'TExES Core Subjects EC-6: Fine Arts, Health and PE (905)': '905'
    };
    
    validCerts.forEach(cert => {
      const mappedNames = Object.keys(CERTIFICATION_MAPPING).filter(
        name => CERTIFICATION_MAPPING[name] === cert.test_code
      );
      
      if (mappedNames.length > 0) {
        console.log(`   ✅ ${cert.test_code} mapped from: ${mappedNames.join(', ')}`);
      } else {
        console.log(`   ❌ ${cert.test_code} has no mapping entries`);
      }
    });

  } catch (error) {
    console.error('❌ Error simulating study path:', error);
  }
}

simulateStudyPathLoad();
