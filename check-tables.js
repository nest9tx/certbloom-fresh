// Check actual table structure
import { createClient } from '@supabase/supabase-js'
import { config } from 'dotenv'

// Load environment variables
config({ path: '.env.local' })

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

const supabase = createClient(supabaseUrl, supabaseKey)

async function checkTableStructure() {
  try {
    console.log('\n🔍 Checking Table Structures...\n');
    
    // Check practice_tests table structure
    console.log('🧪 Practice Tests Table:');
    const { data: testData, error: testError } = await supabase
      .from('practice_tests')
      .select('*')
      .limit(1);
      
    if (testError) {
      console.log('❌ practice_tests error:', testError.message);
      
      // Try with different column names
      const { data: testData2, error: testError2 } = await supabase
        .from('practice_tests')
        .select('id, concept_id, name, description')
        .limit(1);
        
      if (testError2) {
        console.log('❌ Still error with name column:', testError2.message);
      } else {
        console.log('✅ Found test with name column:', testData2);
      }
    } else {
      console.log('✅ Tests found:', testData);
    }
    
    // Check concepts table structure
    console.log('\n🧠 Concepts Table:');
    const { data: conceptData, error: conceptError } = await supabase
      .from('concepts')
      .select('*')
      .limit(1);
      
    if (conceptError) {
      console.log('❌ concepts error:', conceptError.message);
      
      // Try with different column names
      const { data: conceptData2, error: conceptError2 } = await supabase
        .from('concepts')
        .select('id, name, description')
        .limit(1);
        
      if (conceptError2) {
        console.log('❌ Still error with name column:', conceptError2.message);
      } else {
        console.log('✅ Found concept with name column:', conceptData2);
      }
    } else {
      console.log('✅ Concepts found:', conceptData);
    }
    
    // List all tables to see what we have
    console.log('\n📋 Checking for learning-related tables...');
    
    const tables = ['learning_modules', 'practice_tests', 'question_bank', 'answer_choices', 'concepts', 'domains'];
    
    for (const table of tables) {
      const { data, error } = await supabase
        .from(table)
        .select('*')
        .limit(1);
        
      if (error) {
        console.log(`❌ ${table}: ${error.message}`);
      } else {
        console.log(`✅ ${table}: exists with ${Object.keys(data[0] || {}).length} columns`);
        if (data[0]) {
          console.log(`   Columns: ${Object.keys(data[0]).join(', ')}`);
        }
      }
    }
    
  } catch (error) {
    console.error('💥 Table structure check error:', error);
  }
}

checkTableStructure();
