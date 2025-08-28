// Test if our database functions exist and work properly
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing Supabase environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function testProgressFunctions() {
  try {
    console.log('🧪 Testing database functions...');
    
    // Test if handle_concept_progress_update function exists
    const { error: funcError } = await supabase
      .rpc('handle_concept_progress_update', {
        target_user_id: '00000000-0000-0000-0000-000000000000', // Dummy UUID
        target_concept_id: '00000000-0000-0000-0000-000000000000',
        new_mastery_level: 0.5
      });
    
    if (funcError && funcError.code === '42883') {
      console.log('❌ Function handle_concept_progress_update does NOT exist');
      console.log('📝 You need to apply the SQL fix in Supabase dashboard:');
      console.log('   1. Go to Supabase SQL Editor');
      console.log('   2. Copy/paste contents of fix-session-completion.sql');
      console.log('   3. Click Run');
    } else if (funcError && funcError.message.includes('invalid input syntax for type uuid')) {
      console.log('✅ Function handle_concept_progress_update EXISTS (dummy UUID test failed as expected)');
    } else if (funcError) {
      console.log('⚠️  Function exists but has an error:', funcError.message);
    } else {
      console.log('✅ Function handle_concept_progress_update EXISTS and works');
    }

    // Test debug function
    const { data: debugData, error: debugError } = await supabase
      .rpc('debug_progress_update', {
        target_user_id: '00000000-0000-0000-0000-000000000000',
        target_concept_id: '00000000-0000-0000-0000-000000000000'
      });
    
    if (debugError && debugError.code === '42883') {
      console.log('❌ Debug function does NOT exist');
    } else {
      console.log('✅ Debug function exists');
      console.log('Debug result:', debugData);
    }

  } catch (err) {
    console.error('❌ Test error:', err);
  }
}

testProgressFunctions();
