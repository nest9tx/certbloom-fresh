// Debug utility to test question randomization and data flow
// Run this in browser console on practice session page

async function debugQuestionSystem() {
  console.log('🔍 Debugging CertBloom Question System...');
  
  // Test 1: Check localStorage for user data
  console.log('\n📦 LocalStorage Data:');
  const sessionData = localStorage.getItem('lastSessionCompleted');
  console.log('Last Session:', sessionData ? JSON.parse(sessionData) : 'None');
  
  // Test 2: Check if we can access the question function
  console.log('\n🎯 Testing Question Randomization:');
  try {
    const { getRandomizedAdaptiveQuestions } = await import('/src/lib/randomizedQuestions.js');
    console.log('✅ Question function imported successfully');
    
    // Test with sample parameters (you'll need to replace with real user ID)
    const testUserId = 'test-user-id';
    const testCertification = 'EC-6 Core Subjects';
    
    const result = await getRandomizedAdaptiveQuestions(testUserId, testCertification, 5);
    console.log('Question API Result:', result);
    
    if (result.success && result.questions) {
      console.log(`✅ Got ${result.questions.length} questions`);
      result.questions.forEach((q, i) => {
        console.log(`Question ${i + 1}: ${q.question_text.substring(0, 50)}...`);
      });
    } else {
      console.log('❌ No questions returned');
    }
  } catch (error) {
    console.error('❌ Error testing questions:', error);
  }
  
  // Test 3: Check Supabase connection
  console.log('\n🗄️ Testing Database Connection:');
  try {
    const { supabase } = await import('/src/lib/supabase.js');
    
    // Test basic query
    const { data: questions, error } = await supabase
      .from('questions')
      .select('id, question_text')
      .limit(3);
    
    if (error) {
      console.error('❌ Database error:', error);
    } else {
      console.log(`✅ Database connected - found ${questions?.length || 0} questions`);
    }
    
    // Test function call directly
    const { data: funcResult, error: funcError } = await supabase
      .rpc('get_randomized_adaptive_questions', {
        session_user_id: 'test-user-id',
        certification_name: 'EC-6 Core Subjects',
        session_length: 3,
        exclude_recent_hours: 24
      });
    
    if (funcError) {
      console.error('❌ Function call error:', funcError);
    } else {
      console.log(`✅ Function returned ${funcResult?.length || 0} questions`);
    }
    
  } catch (error) {
    console.error('❌ Database connection error:', error);
  }
  
  // Test 4: Check user progress data
  console.log('\n📊 Testing User Progress Data:');
  try {
    const { supabase } = await import('/src/lib/supabase.js');
    const { data: progress, error } = await supabase
      .from('user_progress')
      .select('*')
      .limit(5);
    
    if (error) {
      console.error('❌ Progress query error:', error);
    } else {
      console.log(`✅ Found ${progress?.length || 0} progress records`);
      if (progress && progress.length > 0) {
        progress.forEach((p, i) => {
          console.log(`Progress ${i + 1}: ${p.topic} - ${Math.round(p.mastery_level * 100)}% mastery`);
        });
      }
    }
  } catch (error) {
    console.error('❌ Error checking user progress:', error);
  }
  
  console.log('\n🎯 Debug complete! Check results above.');
}

// Auto-run if in browser
if (typeof window !== 'undefined') {
  window.debugQuestionSystem = debugQuestionSystem;
  console.log('💡 Debug function loaded! Run debugQuestionSystem() in console to test.');
} else {
  // Export for Node.js
  module.exports = { debugQuestionSystem };
}
