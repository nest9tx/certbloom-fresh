import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

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

async function fixUserStudyPlans() {
  console.log('🔧 Fixing user study plans...\n');
  
  // Get all users with certification goals
  const { data: users } = await supabase
    .from('user_profiles')
    .select('id, email, certification_goal')
    .not('certification_goal', 'is', null);
    
  console.log(`📋 Found ${users?.length || 0} users with certification goals`);
  
  for (const user of users || []) {
    console.log(`\n👤 Processing ${user.email} (Goal: ${user.certification_goal})`);
    
    const testCode = CERTIFICATION_MAPPING[user.certification_goal];
    if (!testCode) {
      console.log(`  ⚠️  No mapping found for certification: ${user.certification_goal}`);
      continue;
    }
    
    // Find certification
    const { data: certification } = await supabase
      .from('certifications')
      .select('id, name')
      .eq('test_code', testCode)
      .single();
      
    if (!certification) {
      console.log(`  ❌ No certification found for test code: ${testCode}`);
      continue;
    }
    
    console.log(`  🎯 Certification: ${certification.name} (${testCode})`);
    
    // Check if they have an active study plan
    const { data: activePlan } = await supabase
      .from('study_plans')
      .select('id, name, is_active')
      .eq('user_id', user.id)
      .eq('certification_id', certification.id)
      .eq('is_active', true)
      .single();
      
    if (activePlan) {
      console.log(`  ✅ Already has active study plan: ${activePlan.name}`);
      continue;
    }
    
    // Check if they have an inactive study plan we can reactivate
    const { data: existingPlan } = await supabase
      .from('study_plans')
      .select('id, name, is_active')
      .eq('user_id', user.id)
      .eq('certification_id', certification.id)
      .single();
      
    if (existingPlan) {
      // Reactivate existing plan
      const { error: updateError } = await supabase
        .from('study_plans')
        .update({ 
          is_active: true,
          name: `Primary: ${user.certification_goal}`,
          updated_at: new Date().toISOString()
        })
        .eq('id', existingPlan.id);
        
      if (updateError) {
        console.log(`  ❌ Error reactivating plan: ${updateError.message}`);
      } else {
        console.log(`  🔄 Reactivated existing study plan: ${existingPlan.id}`);
      }
    } else {
      // Create new study plan
      const { data: newPlan, error: createError } = await supabase
        .from('study_plans')
        .insert({
          user_id: user.id,
          certification_id: certification.id,
          name: `Primary: ${user.certification_goal}`,
          daily_study_minutes: 30,
          is_active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
        .select('id')
        .single();
        
      if (createError) {
        console.log(`  ❌ Error creating plan: ${createError.message}`);
      } else {
        console.log(`  ✨ Created new study plan: ${newPlan.id}`);
      }
    }
  }
  
  console.log('\n🎉 Study plan fix complete!');
}

fixUserStudyPlans().catch(console.error);
