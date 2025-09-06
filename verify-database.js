// Verify database content after schema enhancement
import { createClient } from '@supabase/supabase-js'
import { config } from 'dotenv'

// Load environment variables
config({ path: '.env.local' })

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

console.log('🔧 Environment check:', { 
  hasUrl: !!supabaseUrl, 
  hasKey: !!supabaseKey 
});

const supabase = createClient(supabaseUrl, supabaseKey)

async function verifyDatabase() {
  try {
    console.log('\n🔍 Verifying Enhanced Database Content...\n');
    
    // 1. Check learning_modules table
    console.log('📚 Learning Modules:');
    const { data: modules, error: moduleError } = await supabase
      .from('learning_modules')
      .select('id, concept_id, module_type, title')
      .limit(10);
      
    if (moduleError) {
      console.log('❌ learning_modules table not found or error:', moduleError.message);
    } else {
      console.log(`✅ Found ${modules?.length || 0} learning modules`);
      modules?.forEach(module => {
        console.log(`   - ${module.module_type}: ${module.title}`);
      });
    }
    
    // 2. Check practice_tests table
    console.log('\n🧪 Practice Tests:');
    const { data: tests, error: testError } = await supabase
      .from('practice_tests')
      .select('id, concept_id, title, question_count')
      .limit(10);
      
    if (testError) {
      console.log('❌ practice_tests table not found or error:', testError.message);
    } else {
      console.log(`✅ Found ${tests?.length || 0} practice tests`);
      tests?.forEach(test => {
        console.log(`   - ${test.title}: ${test.question_count} questions`);
      });
    }
    
    // 3. Check question_bank table
    console.log('\n❓ Question Bank:');
    const { data: questions, error: questionError } = await supabase
      .from('question_bank')
      .select('id, practice_test_id, question_text, difficulty_level')
      .limit(10);
      
    if (questionError) {
      console.log('❌ question_bank table not found or error:', questionError.message);
    } else {
      console.log(`✅ Found ${questions?.length || 0} questions`);
      questions?.forEach(question => {
        console.log(`   - ${question.difficulty_level}: ${question.question_text?.substring(0, 50)}...`);
      });
    }
    
    // 4. Check answer_choices table
    console.log('\n🎯 Answer Choices:');
    const { data: choices, error: choiceError } = await supabase
      .from('answer_choices')
      .select('id, question_id, choice_text, is_correct')
      .limit(20);
      
    if (choiceError) {
      console.log('❌ answer_choices table not found or error:', choiceError.message);
    } else {
      console.log(`✅ Found ${choices?.length || 0} answer choices`);
      const correctChoices = choices?.filter(c => c.is_correct)?.length || 0;
      console.log(`   - ${correctChoices} correct answers out of ${choices?.length || 0} total choices`);
    }
    
    // 5. Check concepts table to see Place Value
    console.log('\n🧠 Concepts (Place Value):');
    const { data: concepts, error: conceptError } = await supabase
      .from('concepts')
      .select('id, name, description')
      .ilike('name', '%place%value%');
      
    if (conceptError) {
      console.log('❌ concepts table error:', conceptError.message);
    } else {
      console.log(`✅ Found ${concepts?.length || 0} Place Value concepts`);
      concepts?.forEach(concept => {
        console.log(`   - ${concept.name}: ${concept.description?.substring(0, 100)}...`);
      });
    }
    
    // 6. Overall summary
    console.log('\n📊 Summary:');
    console.log(`• Learning Modules: ${modules?.length || 0}`);
    console.log(`• Practice Tests: ${tests?.length || 0}`);
    console.log(`• Questions: ${questions?.length || 0}`);
    console.log(`• Answer Choices: ${choices?.length || 0}`);
    console.log(`• Place Value Concepts: ${concepts?.length || 0}`);
    
    // 7. Check if old content structure is still intact
    console.log('\n🔗 Legacy Content Check:');
    const { data: oldContent, error: oldError } = await supabase
      .from('content_items')
      .select('id, title, content_type')
      .limit(5);
      
    if (oldError) {
      console.log('ℹ️ Old content_items table not accessible or missing');
    } else {
      console.log(`✅ Legacy content preserved: ${oldContent?.length || 0} items`);
    }
    
  } catch (error) {
    console.error('💥 Database verification error:', error);
  }
}

verifyDatabase();
