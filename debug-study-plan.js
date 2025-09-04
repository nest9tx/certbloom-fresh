// Debug study plan status
import { createClient } from '@supabase/supabase-js'
import { config } from 'dotenv'

// Load environment variables
config({ path: '.env.local' })

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY // Use service role for debugging

console.log('🔧 Environment check:', { 
  hasUrl: !!supabaseUrl, 
  hasKey: !!supabaseKey 
});

const supabase = createClient(supabaseUrl, supabaseKey)

async function debugStudyPlan() {
  try {
    console.log('🔍 Checking study plan status...');
    
    // Get user profile first
    const { data: profiles, error: profileError } = await supabase
      .from('user_profiles')
      .select('id, email, certification_goal')
      .order('created_at', { ascending: false })
      .limit(5);
      
    if (profileError) {
      console.error('❌ Error fetching profiles:', profileError);
      return;
    }
    
    console.log('👥 Recent user profiles:');
    profiles?.forEach(profile => {
      console.log(`  ${profile.email}: ${profile.certification_goal} (ID: ${profile.id})`);
    });
    
    // Check the most recent user with 902 goal
    const user902 = profiles?.find(p => p.certification_goal === '902');
    if (!user902) {
      console.log('❌ No user found with certification goal "902"');
      return;
    }
    
    console.log(`\n🎯 Checking study plans for user: ${user902.email} (${user902.id})`);
    
    // Check study plans for this user
    const { data: studyPlans, error: planError } = await supabase
      .from('study_plans')
      .select(`
        id,
        user_id,
        certification_id,
        name,
        is_active,
        created_at,
        certifications (
          id,
          name,
          test_code
        )
      `)
      .eq('user_id', user902.id);
      
    if (planError) {
      console.error('❌ Error fetching study plans:', planError);
      return;
    }
    
    console.log(`📋 Study plans for this user: ${studyPlans?.length || 0}`);
    studyPlans?.forEach(plan => {
      console.log(`  - ${plan.name} (Active: ${plan.is_active})`);
      console.log(`    Certification: ${plan.certifications?.name} (${plan.certifications?.test_code})`);
      console.log(`    ID: ${plan.id}`);
      console.log(`    Created: ${plan.created_at}`);
    });
    
    // Check if there's an active plan for 902
    const activePlan = studyPlans?.find(p => p.is_active && p.certifications?.test_code === '902');
    if (activePlan) {
      console.log(`\n✅ Found active plan for 902: ${activePlan.name}`);
      console.log('   This should make hasStructuredPath = true');
    } else {
      console.log(`\n❌ No active plan found for 902`);
      console.log('   This explains why hasStructuredPath = false');
    }
    
    // Check certifications table
    console.log('\n📚 Checking available certifications:');
    const { data: certs } = await supabase
      .from('certifications')
      .select('id, name, test_code')
      .order('test_code');
      
    const cert902 = certs?.find(c => c.test_code === '902');
    if (cert902) {
      console.log(`✅ Certification 902 exists: ${cert902.name} (ID: ${cert902.id})`);
    } else {
      console.log('❌ Certification 902 not found in database');
    }
    
  } catch (error) {
    console.error('💥 Debug error:', error);
  }
}

debugStudyPlan();
