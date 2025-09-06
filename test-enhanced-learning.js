// Test Enhanced Learning Experience with actual data
import { createClient } from '@supabase/supabase-js'
import { config } from 'dotenv'

// Load environment variables
config({ path: '.env.local' })

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

const supabase = createClient(supabaseUrl, supabaseKey)

async function testEnhancedLearning() {
  try {
    console.log('\n🚀 Testing Enhanced Learning Experience...\n');
    
    const PLACE_VALUE_CONCEPT_ID = 'c1111111-1111-1111-1111-111111111111'
    
    // Test loading learning modules for Place Value concept
    console.log('📚 Loading Learning Modules for Place Value...');
    const { data: modules, error: moduleError } = await supabase
      .from('learning_modules')
      .select('*')
      .eq('concept_id', PLACE_VALUE_CONCEPT_ID)
      .order('order_index')

    if (moduleError) {
      console.log('❌ Module Error:', moduleError.message);
      return;
    }

    console.log(`✅ Found ${modules?.length || 0} learning modules:`);
    modules?.forEach((module, index) => {
      console.log(`   ${index + 1}. ${module.module_type}: ${module.title}`);
      console.log(`      - Duration: ${module.estimated_minutes} minutes`);
      console.log(`      - Level: ${module.difficulty_level}`);
      console.log(`      - Teaching Tips: ${module.teaching_tips?.length || 0}`);
      console.log(`      - Misconceptions: ${module.common_misconceptions?.length || 0}`);
      console.log(`      - Applications: ${module.classroom_applications?.length || 0}`);
    });

    // Test loading practice tests
    console.log('\n🧪 Loading Practice Tests...');
    const { data: tests, error: testError } = await supabase
      .from('practice_tests')
      .select('*')
      .eq('concept_id', PLACE_VALUE_CONCEPT_ID)

    if (testError) {
      console.log('❌ Test Error:', testError.message);
    } else {
      console.log(`✅ Found ${tests?.length || 0} practice tests:`);
      tests?.forEach((test, index) => {
        console.log(`   ${index + 1}. ${test.title}`);
        console.log(`      - Questions: ${test.question_count}`);
        console.log(`      - Time Limit: ${test.time_limit_minutes} minutes`);
        console.log(`      - Passing Score: ${test.passing_score}%`);
        console.log(`      - Adaptive: ${test.difficulty_adaptation ? 'Yes' : 'No'}`);
      });
    }

    // Test loading questions
    console.log('\n❓ Loading Questions...');
    const { data: questions, error: questionError } = await supabase
      .from('question_bank')
      .select('id, question_text, difficulty_level, teaching_context, misconception_addressed')
      .eq('concept_id', PLACE_VALUE_CONCEPT_ID)
      .limit(5)

    if (questionError) {
      console.log('❌ Question Error:', questionError.message);
    } else {
      console.log(`✅ Found ${questions?.length || 0} questions:`);
      questions?.forEach((question, index) => {
        console.log(`   ${index + 1}. Level ${question.difficulty_level}: ${question.question_text?.substring(0, 80)}...`);
        if (question.teaching_context) {
          console.log(`      📝 Teaching Context: ${question.teaching_context.substring(0, 60)}...`);
        }
        if (question.misconception_addressed) {
          console.log(`      ⚠️ Addresses: ${question.misconception_addressed.substring(0, 60)}...`);
        }
      });
    }

    console.log('\n🎉 Enhanced Learning Experience Test Complete!');
    console.log('\n📊 Summary:');
    console.log(`• Learning Modules: ${modules?.length || 0}`);
    console.log(`• Practice Tests: ${tests?.length || 0}`);
    console.log(`• Questions: ${questions?.length || 0}`);
    console.log('\n🌐 Frontend URLs to test:');
    console.log('• Dashboard: http://localhost:3000/dashboard');
    console.log('• Enhanced Learning: http://localhost:3000/enhanced-learning');
    console.log('• Study Path: http://localhost:3000/study-path');

  } catch (error) {
    console.error('💥 Test failed:', error);
  }
}

testEnhancedLearning();
