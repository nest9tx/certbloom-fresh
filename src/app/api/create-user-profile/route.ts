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

export async function POST(request: NextRequest) {
  try {
    const { userId, email, fullName, certificationGoal } = await request.json()

    console.log('🏗️ API: Creating user profile for:', userId, email)

    // Create user profile using admin client
    const { data, error } = await supabaseAdmin
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

    if (error) {
      console.error('❌ API: Error creating user profile:', error)
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 400 }
      )
    }

    console.log('✅ API: User profile created successfully:', data[0])
    return NextResponse.json({ success: true, data: data[0] })

  } catch (error) {
    console.error('❌ API: Exception creating user profile:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
