import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

export async function POST(request: NextRequest) {
  try {
    const { certificationGoal } = await request.json();

    if (!certificationGoal) {
      return NextResponse.json(
        { error: 'Certification goal is required' },
        { status: 400 }
      );
    }

    // Get the authorization token from headers
    const authHeader = request.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: 'Missing or invalid authorization header' },
        { status: 401 }
      );
    }

    const token = authHeader.replace('Bearer ', '');
    
    // Create client with the user's JWT token for authentication
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
    const userSupabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: {
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    });
    
    // Verify the token and get user
    const { data: { user }, error: authError } = await userSupabase.auth.getUser();
    
    if (authError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    console.log('🎯 Updating certification goal for user:', user.id, 'to:', certificationGoal);

    // Create service role client for bypassing RLS
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;
    const adminSupabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    });

    // Step 1: Update user_profiles (using service role to ensure it works)
    const { error: profileError } = await adminSupabase
      .from('user_profiles')
      .update({ 
        certification_goal: certificationGoal,
        updated_at: new Date().toISOString()
      })
      .eq('id', user.id);

    if (profileError) {
      console.error('❌ Profile update error:', profileError);
      return NextResponse.json(
        { error: `Profile update failed: ${profileError.message}` },
        { status: 500 }
      );
    }

    // Step 2: Check if this certification has structured content
    const CERTIFICATION_MAPPING = {
      // Math EC-6 (902)
      'Math EC-6': '902',
      'TExES Core Subjects EC-6: Mathematics (902)': '902',
      'Elementary Mathematics': '902',
      
      // ELA EC-6 (901)
      'ELA EC-6': '901',
      'TExES Core Subjects EC-6: English Language Arts (901)': '901',
      'English Language Arts EC-6': '901',
      
      // Core Subjects EC-6 (391)
      'EC-6 Core Subjects': '391',
      'TExES Core Subjects EC-6 (391)': '391',
      'Core Subjects EC-6': '391',
      
      // Social Studies EC-6 (903)
      'Social Studies EC-6': '903',
      'TExES Core Subjects EC-6: Social Studies (903)': '903',
      
      // Science EC-6 (904)
      'Science EC-6': '904',
      'TExES Core Subjects EC-6: Science (904)': '904',
      
      // Fine Arts EC-6 (905)
      'Fine Arts EC-6': '905',
      'TExES Core Subjects EC-6: Fine Arts, Health and PE (905)': '905'
    };

    const testCode = CERTIFICATION_MAPPING[certificationGoal as keyof typeof CERTIFICATION_MAPPING];
    
    if (!testCode) {
      // No structured content yet - just return success
      return NextResponse.json({
        success: true,
        hasStructuredContent: false,
        message: 'Certification goal updated successfully'
      });
    }

    // Step 3: Find the certification in our concept-based learning system
    const { data: certification, error: certError } = await adminSupabase
      .from('certifications')
      .select('id, name')
      .eq('test_code', testCode)
      .single();

    if (certError || !certification) {
      console.log('🔍 No certification found for test code:', testCode, 'Error:', certError);
      return NextResponse.json({
        success: true,
        hasStructuredContent: false,
        message: 'Certification goal updated successfully (no structured content yet)'
      });
    }

    // Step 4: Create or update study plan (using service role to bypass RLS)
    
    console.log('🎯 About to create/update study plan for user:', user.id, 'certification:', certification.id);
    
    // First, deactivate any existing active study plans for this user (for other certifications)
    const { error: deactivateError } = await adminSupabase
      .from('study_plans')
      .update({ is_active: false })
      .eq('user_id', user.id)
      .neq('certification_id', certification.id)
      .eq('is_active', true);

    if (deactivateError) {
      console.error('❌ Error deactivating existing study plans:', deactivateError);
      // Continue anyway - this is not critical
    }

    // Check if a study plan already exists for this user and certification
    const { data: existingPlan, error: checkError } = await adminSupabase
      .from('study_plans')
      .select('id')
      .eq('user_id', user.id)
      .eq('certification_id', certification.id)
      .single();

    if (checkError && checkError.code !== 'PGRST116') {
      // PGRST116 means "no rows found" which is fine
      console.error('❌ Error checking existing study plan:', checkError);
      return NextResponse.json(
        { error: `Error checking existing study plan: ${checkError.message}` },
        { status: 500 }
      );
    }

    let studyPlan;

    if (existingPlan) {
      // Update existing study plan
      console.log('📝 Updating existing study plan:', existingPlan.id);
      
      const updateName = `Primary: ${certificationGoal || certification.name || 'Math 902'}`;
      console.log('📝 Updating study plan name to:', updateName);
      
      const { data: updatedPlan, error: updateError } = await adminSupabase
        .from('study_plans')
        .update({
          name: updateName,
          daily_study_minutes: 30,
          is_active: true,
          updated_at: new Date().toISOString()
        })
        .eq('id', existingPlan.id)
        .select('id')
        .single();

      if (updateError) {
        console.error('❌ Study plan update error:', updateError);
        return NextResponse.json(
          { error: `Study plan update failed: ${updateError.message}` },
          { status: 500 }
        );
      }

      studyPlan = updatedPlan;
      console.log('✅ Study plan updated successfully:', studyPlan.id);

    } else {
      // Create new study plan
      console.log('📝 Creating new study plan for certification:', certificationGoal);
      
      const studyPlanName = `Primary: ${certificationGoal || certification.name || 'Math 902'}`;
      console.log('📝 Study plan name will be:', studyPlanName);
      
      const studyPlanData = {
        user_id: user.id,
        certification_id: certification.id,
        name: studyPlanName,
        daily_study_minutes: 30,
        is_active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };

      console.log('📝 Study plan data to insert:', JSON.stringify(studyPlanData, null, 2));

      const { data: newPlan, error: createError } = await adminSupabase
        .from('study_plans')
        .insert(studyPlanData)
        .select('id')
        .single();

      if (createError) {
        console.error('❌ Study plan creation error:', createError);
        console.error('❌ Study plan data attempted:', studyPlanData);
        console.error('❌ Full error details:', JSON.stringify(createError, null, 2));
        
        return NextResponse.json(
          { 
            error: `Study plan creation failed: ${createError.message}`, 
            details: createError.details || 'No additional details',
            code: createError.code || 'Unknown error code'
          },
          { status: 500 }
        );
      }

      studyPlan = newPlan;
      console.log('✅ Study plan created successfully:', studyPlan.id);
    }

    return NextResponse.json({
      success: true,
      hasStructuredContent: true,
      studyPlanId: studyPlan.id,
      certificationName: certification.name,
      message: 'Certification goal updated successfully'
    });

  } catch (error) {
    console.error('❌ Error updating certification goal:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
