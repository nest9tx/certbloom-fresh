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
      'Math EC-6': '902',
      'TExES Core Subjects EC-6: Mathematics (902)': '902',
      'Elementary Mathematics': '902',
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
    
    // First, deactivate any existing active study plans for this user
    await adminSupabase
      .from('study_plans')
      .update({ is_active: false })
      .eq('user_id', user.id)
      .eq('is_active', true);

    const studyPlanData = {
      user_id: user.id,
      certification_id: certification.id,
      name: `Primary: ${certificationGoal}`,
      daily_study_minutes: 30,
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    // Create new study plan
    const { data: studyPlan, error: planError } = await adminSupabase
      .from('study_plans')
      .insert(studyPlanData)
      .select('id')
      .single();

    if (planError) {
      console.error('❌ Study plan creation error:', planError);
      // Log more details about the error
      console.error('❌ Study plan data attempted:', studyPlanData);
      console.error('❌ Full error details:', JSON.stringify(planError, null, 2));
      return NextResponse.json(
        { error: `Study plan creation failed: ${planError.message}. Details: ${planError.details || 'No additional details'}` },
        { status: 500 }
      );
    }

    console.log('✅ Certification goal and study plan updated successfully');

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
