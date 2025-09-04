// Manually create study plan for testing
import { createClient } from '@supabase/supabase-js'
import { config } from 'dotenv'

// Load environment variables
config({ path: '.env.local' })

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

const supabase = createClient(supabaseUrl, supabaseKey)

async function createStudyPlanManually() {
  try {
    console.log('🛠️ Manually creating study plan for Math 902...');
    
    // Get the user
    const { data: profiles } = await supabase
      .from('user_profiles')
      .select('id, email, certification_goal')
      .eq('certification_goal', '902')
      .limit(1);
      
    if (!profiles || profiles.length === 0) {
      console.log('❌ No user found with certification goal "902"');
      return;
    }
    
    const user = profiles[0];
    console.log(`👤 Found user: ${user.email} (${user.id})`);
    
    // Get the certification
    const { data: cert } = await supabase
      .from('certifications')
      .select('id, name, test_code')
      .eq('test_code', '902')
      .single();
      
    if (!cert) {
      console.log('❌ Certification 902 not found');
      return;
    }
    
    console.log(`📚 Found certification: ${cert.name} (${cert.id})`);
    
    // Check if study plan already exists
    const { data: existingPlan } = await supabase
      .from('study_plans')
      .select('id, name, is_active')
      .eq('user_id', user.id)
      .eq('certification_id', cert.id)
      .single();
      
    if (existingPlan) {
      console.log(`📋 Study plan already exists: ${existingPlan.name} (Active: ${existingPlan.is_active})`);
      
      // Update it to be active
      const { error: updateError } = await supabase
        .from('study_plans')
        .update({ 
          is_active: true,
          updated_at: new Date().toISOString()
        })
        .eq('id', existingPlan.id);
        
      if (updateError) {
        console.error('❌ Error updating study plan:', updateError);
      } else {
        console.log('✅ Study plan updated to active');
      }
      return;
    }
    
    // Create new study plan
    const studyPlanData = {
      user_id: user.id,
      certification_id: cert.id,
      name: `Primary: 902`,
      daily_study_minutes: 30,
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    console.log('📝 Creating study plan with data:', studyPlanData);
    
    const { data: newPlan, error: createError } = await supabase
      .from('study_plans')
      .insert(studyPlanData)
      .select('id, name')
      .single();
      
    if (createError) {
      console.error('❌ Error creating study plan:', createError);
      console.error('❌ Error details:', JSON.stringify(createError, null, 2));
    } else {
      console.log(`✅ Study plan created successfully: ${newPlan.name} (${newPlan.id})`);
      console.log('🎉 User should now see "Your Learning Path is Ready" on dashboard');
    }
    
  } catch (error) {
    console.error('💥 Error:', error);
  }
}

createStudyPlanManually();
