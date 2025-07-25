import { createClient } from '@supabase/supabase-js'

// These will be environment variables in production
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

// Only create client if we have the required environment variables and they're valid URLs
export const supabase = supabaseUrl && supabaseAnonKey && supabaseUrl.startsWith('https://') 
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null

// Types for our application
export interface UserProfile {
  id: string
  email: string
  full_name?: string
  certification_goal?: string
  alt_cert_program?: string
  study_style?: 'visual' | 'auditory' | 'kinesthetic' | 'reading'
  anxiety_level?: number
  created_at: string
  updated_at: string
}

export interface StudySession {
  id: string
  user_id: string
  certification_type: string
  questions_answered: number
  correct_answers: number
  duration_minutes: number
  wellness_rating_before?: number
  wellness_rating_after?: number
  created_at: string
}

// Authentication Functions
export async function signUp(email: string, password: string, fullName: string) {
  try {
    if (!supabase) {
      return { success: false, error: 'Supabase configuration is missing' }
    }

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
        }
      }
    })

    if (error) {
      return { success: false, error: error.message }
    }

    return { success: true, user: data.user }
  } catch (err) {
    console.error('Sign up error:', err)
    return { success: false, error: 'An unexpected error occurred' }
  }
}

export async function signIn(email: string, password: string) {
  try {
    if (!supabase) {
      return { success: false, error: 'Supabase configuration is missing' }
    }

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      return { success: false, error: error.message }
    }

    return { success: true, user: data.user }
  } catch (err) {
    console.error('Sign in error:', err)
    return { success: false, error: 'An unexpected error occurred' }
  }
}

export async function signOut() {
  try {
    if (!supabase) {
      return { success: false, error: 'Supabase configuration is missing' }
    }
    
    const { error } = await supabase.auth.signOut()
    if (error) {
      return { success: false, error: error.message }
    }
    return { success: true }
  } catch (err) {
    console.error('Sign out error:', err)
    return { success: false, error: 'An unexpected error occurred' }
  }
}

export async function getCurrentUser() {
  try {
    if (!supabase) {
      return { success: false, error: 'Supabase configuration is missing' }
    }
    
    const { data: { user }, error } = await supabase.auth.getUser()
    if (error) {
      return { success: false, error: error.message }
    }
    return { success: true, user }
  } catch (err) {
    console.error('Get current user error:', err)
    return { success: false, error: 'An unexpected error occurred' }
  }
}

// Profile Functions
export async function createUserProfile(userId: string, profileData: Partial<UserProfile>) {
  try {
    if (!supabase) {
      return { success: false, error: 'Supabase configuration is missing' }
    }
    
    const { data, error } = await supabase
      .from('user_profiles')
      .insert([
        {
          id: userId,
          ...profileData,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        }
      ])
      .select()

    if (error) {
      return { success: false, error: error.message }
    }

    return { success: true, data: data[0] }
  } catch (err) {
    console.error('Create user profile error:', err)
    return { success: false, error: 'An unexpected error occurred' }
  }
}

export async function getUserProfile(userId: string) {
  try {
    if (!supabase) {
      return { success: false, error: 'Supabase configuration is missing' }
    }
    
    const { data, error } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('id', userId)
      .single()

    if (error) {
      return { success: false, error: error.message }
    }

    return { success: true, profile: data }
  } catch (err) {
    console.error('Get user profile error:', err)
    return { success: false, error: 'An unexpected error occurred' }
  }
}

export async function updateUserProfile(userId: string, updates: Partial<UserProfile>) {
  try {
    if (!supabase) {
      return { success: false, error: 'Supabase configuration is missing' }
    }
    
    const { data, error } = await supabase
      .from('user_profiles')
      .update({
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .eq('id', userId)
      .select()

    if (error) {
      return { success: false, error: error.message }
    }

    return { success: true, profile: data[0] }
  } catch (err) {
    console.error('Update user profile error:', err)
    return { success: false, error: 'An unexpected error occurred' }
  }
}

// Study Session Functions
export async function createStudySession(sessionData: Omit<StudySession, 'id' | 'created_at'>) {
  try {
    if (!supabase) {
      return { success: false, error: 'Supabase configuration is missing' }
    }
    
    const { data, error } = await supabase
      .from('study_sessions')
      .insert([
        {
          ...sessionData,
          created_at: new Date().toISOString(),
        }
      ])
      .select()

    if (error) {
      return { success: false, error: error.message }
    }

    return { success: true, session: data[0] }
  } catch (err) {
    console.error('Create study session error:', err)
    return { success: false, error: 'An unexpected error occurred' }
  }
}

export async function getUserStudySessions(userId: string, limit = 10) {
  try {
    if (!supabase) {
      return { success: false, error: 'Supabase configuration is missing' }
    }
    
    const { data, error } = await supabase
      .from('study_sessions')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(limit)

    if (error) {
      return { success: false, error: error.message }
    }

    return { success: true, sessions: data }
  } catch (err) {
    console.error('Get user study sessions error:', err)
    return { success: false, error: 'An unexpected error occurred' }
  }
}

// Email signup function (keeping your existing one)
export async function signupForEarlyAccess(email: string) {
  try {
    if (!supabase) {
      return { success: false, error: 'Supabase configuration is missing' }
    }
    
    const { data, error } = await supabase
      .from('early_access_signups')
      .insert([
        { 
          email: email,
          signed_up_at: new Date().toISOString(),
          source: 'landing_page'
        }
      ])
      .select()

    if (error) {
      console.error('Error signing up for early access:', error)
      return { success: false, error: error.message }
    }

    return { success: true, data }
  } catch (error) {
    console.error('Unexpected error:', error)
    return { success: false, error: 'An unexpected error occurred' }
  }
}
