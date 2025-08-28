import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error('❌ Missing environment variables');
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function fixSessionCompletion() {
    try {
        console.log('🔧 Fixing session completion and progress tracking...');
        
        // Check if the function already exists
        const { data: existingFunctions } = await supabase
            .from('pg_proc')
            .select('proname')
            .eq('proname', 'handle_concept_progress_update');
            
        if (existingFunctions && existingFunctions.length > 0) {
            console.log('✅ handle_concept_progress_update function already exists');
        } else {
            console.log('⚠️  handle_concept_progress_update function missing - this might be the issue!');
        }
        
        // Test with a simple progress update
        console.log('🧪 Testing progress tracking...');
        
        // Get a user to test with
        const { data: users, error: userError } = await supabase
            .from('auth.users')
            .select('id')
            .limit(1);
            
        if (userError) {
            console.log('❌ Could not fetch users for testing:', userError);
            return;
        }
        
        if (!users || users.length === 0) {
            console.log('⚠️  No users found for testing');
            return;
        }
        
        const testUserId = users[0].id;
        console.log('🧪 Testing with user ID:', testUserId);
        
        // Get a concept to test with
        const { data: concepts, error: conceptError } = await supabase
            .from('concepts')
            .select('id, name')
            .limit(1);
            
        if (conceptError || !concepts || concepts.length === 0) {
            console.log('❌ Could not fetch concepts for testing:', conceptError);
            return;
        }
        
        const testConceptId = concepts[0].id;
        console.log('🧪 Testing with concept:', concepts[0].name, testConceptId);
        
        // Try to call the function directly
        const { data: functionResult, error: functionError } = await supabase.rpc('handle_concept_progress_update', {
            target_user_id: testUserId,
            target_concept_id: testConceptId,
            new_mastery_level: 0.5,
            new_time_spent: 10,
            new_times_reviewed: 1,
            set_mastered: false
        });
        
        if (functionError) {
            console.log('❌ Function call failed:', functionError);
            console.log('🚨 This is likely why progress is not saving!');
        } else {
            console.log('✅ Function call succeeded:', functionResult);
        }
        
        // Check RLS policies
        console.log('🔒 Checking concept_progress table policies...');
        const { data: policies, error: policyError } = await supabase
            .from('pg_policies')
            .select('*')
            .eq('tablename', 'concept_progress');
            
        if (policyError) {
            console.log('⚠️  Could not check policies:', policyError);
        } else {
            console.log('📋 Found policies:', policies?.length || 0);
            policies?.forEach(policy => {
                console.log(`  - ${policy.policyname}: ${policy.cmd}`);
            });
        }
        
    } catch (error) {
        console.error('❌ Error testing session completion:', error);
    }
}

fixSessionCompletion();
