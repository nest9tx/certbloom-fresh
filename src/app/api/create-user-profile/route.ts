import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

// Server-side supabase client with service role
const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
)

// Map existing certification names to concept-based learning certification IDs
const CERTIFICATION_MAPPING = {
  'Math EC-6': '902',
  'TExES Core Subjects EC-6: Mathematics (902)': '902',
  'Elementary Mathematics': '902',
  'TExES Core Subjects EC-6: Mathematics': '902',
  'EC-6 Mathematics': '902',
  'Mathematics EC-6': '902'
  // Add more mappings as we build out other certifications
} as Record<string, string>

export async function POST(request: NextRequest) {
  try {
    const { userId, email, fullName, certificationGoal } = await request.json()

    console.log('🏗️ API: Creating user profile for:', userId, email, 'with cert:', certificationGoal)
    console.log('🔍 SIGNUP DEBUG: Received userId type:', typeof userId)
    console.log('🔍 SIGNUP DEBUG: Received userId value:', userId)

    // Verify the user ID format
    if (!userId || typeof userId !== 'string') {
      console.error('❌ API: Invalid userId provided:', userId)
      return NextResponse.json(
        { success: false, error: 'Invalid user ID provided' },
        { status: 400 }
      )
    }

    // Check if profile already exists
    console.log('🔍 SIGNUP DEBUG: Checking if user profile already exists...')
    const { data: existingProfile, error: checkError } = await supabaseAdmin
      .from('user_profiles')
      .select('id, email, certification_goal')
      .eq('id', userId)
      .maybeSingle() // Use maybeSingle() instead of single() to avoid errors when no record exists

    console.log('🔍 SIGNUP DEBUG: Existing profile check:', { existingProfile, checkError })

    // Only treat as an error if it's not a "no rows" error
    if (checkError && checkError.code !== 'PGRST116') {
      console.error('❌ API: Error checking existing profile:', checkError)
      return NextResponse.json(
        { success: false, error: 'Error checking existing profile: ' + checkError.message },
        { status: 500 }
      )
    }

    let data, error

    if (existingProfile) {
      console.log('✨ Profile exists - updating with new certification goal')
      // Update existing profile
      const updateResult = await supabaseAdmin
        .from('user_profiles')
        .update({
          email,
          full_name: fullName || '',
          certification_goal: certificationGoal || null,
          updated_at: new Date().toISOString(),
        })
        .eq('id', userId)
        .select()

      data = updateResult.data
      error = updateResult.error
    } else {
      console.log('🏗️ No existing profile - creating new one')
      // Create new profile
      const insertResult = await supabaseAdmin
        .from('user_profiles')
        .insert([
          {
            id: userId,
            email,
            full_name: fullName || '',
            certification_goal: certificationGoal || null,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          }
        ])
        .select()

      data = insertResult.data
      error = insertResult.error
    }

    if (error) {
      console.error('❌ API: Error creating/updating user profile:', error)
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 400 }
      )
    }

    if (!data || data.length === 0) {
      console.error('❌ API: No data returned from profile operation')
      return NextResponse.json(
        { success: false, error: 'No profile data returned' },
        { status: 400 }
      )
    }

    console.log('✅ API: User profile created/updated successfully:', data[0])

    // 🌸 Create structured study plan if available
    console.log('🔍 SIGNUP DEBUG: Starting study plan creation check...');
    console.log('🔍 SIGNUP DEBUG: certificationGoal received:', certificationGoal);
    console.log('🔍 SIGNUP DEBUG: typeof certificationGoal:', typeof certificationGoal);
    console.log('🔍 SIGNUP DEBUG: certificationGoal truthy?', !!certificationGoal);
    
    if (certificationGoal) {
      try {
        console.log('🔍 SIGNUP DEBUG: Checking mapping for:', certificationGoal);
        const testCode = CERTIFICATION_MAPPING[certificationGoal]
        console.log('🔍 SIGNUP DEBUG: Found test code:', testCode);
        
        if (testCode) {
          console.log('🌱 Creating structured study plan for:', certificationGoal, 'with test code:', testCode)
          
          // Find the certification in our concept-based learning system
          console.log('🔍 SIGNUP DEBUG: Looking for certification with test_code:', testCode);
          const { data: certification, error: certError } = await supabaseAdmin
            .from('certifications')
            .select('id, name')
            .eq('test_code', testCode)
            .single()

          console.log('🔍 SIGNUP DEBUG: Certification query result:', { certification, certError });

          if (!certError && certification) {
            console.log('🔍 SIGNUP DEBUG: Found certification, creating study plan...');
            // Create the study plan
            const { data: studyPlan, error: planError } = await supabaseAdmin
              .from('study_plans')
              .insert({
                user_id: userId,
                certification_id: certification.id,
                name: `Primary: ${certification.name}`,
                daily_study_minutes: 30,
                is_active: true,
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
              })
              .select()
              .single()

            console.log('🔍 SIGNUP DEBUG: Study plan creation result:', { studyPlan, planError });

            if (!planError && studyPlan) {
              console.log('🎯 Structured study plan created successfully!', studyPlan.name)
            } else {
              console.log('⚠️ Could not create study plan:', planError?.message)
              console.log('⚠️ Full plan error:', planError)
            }
          } else {
            console.log('📝 No structured content available for:', certificationGoal)
            console.log('📝 Certification error details:', certError)
          }
        } else {
          console.log('📋 Certification not yet mapped to structured learning:', certificationGoal)
          console.log('📋 Available mappings:', Object.keys(CERTIFICATION_MAPPING))
        }
      } catch (structuredError) {
        console.error('⚠️ Error creating structured study plan (non-critical):', structuredError)
        // Don't fail the profile creation if study plan creation fails
      }
    }

    return NextResponse.json({ success: true, data: data[0] })

  } catch (error) {
    console.error('❌ API: Exception creating user profile:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
