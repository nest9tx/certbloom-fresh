import { createClient } from '@supabase/supabase-js'

// Function to validate URL format
function isValidUrl(string: string): boolean {
  try {
    new URL(string);
    return true;
  } catch {
    return false;
  }
}

// Get environment variables with validation
const rawSupabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const rawSupabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

// Validate and sanitize environment variables
const supabaseUrl = rawSupabaseUrl && isValidUrl(rawSupabaseUrl) 
  ? rawSupabaseUrl 
  : 'https://placeholder.supabase.co'

const supabaseAnonKey = rawSupabaseAnonKey && rawSupabaseAnonKey.length > 10 
  ? rawSupabaseAnonKey 
  : 'placeholder-key-placeholder-key-placeholder-key'

// Log warnings for invalid configuration (only in development)
if (process.env.NODE_ENV === 'development') {
  if (!rawSupabaseUrl || !isValidUrl(rawSupabaseUrl)) {
    console.warn('NEXT_PUBLIC_SUPABASE_URL is missing or invalid:', rawSupabaseUrl)
  }
  if (!rawSupabaseAnonKey || rawSupabaseAnonKey.length <= 10) {
    console.warn('NEXT_PUBLIC_SUPABASE_ANON_KEY is missing or invalid')
  }
}

// Create the client with validated values
export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Service role client for admin operations (bypasses RLS) 
const rawServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY
const supabaseServiceKey = rawServiceKey && rawServiceKey.length > 10 
  ? rawServiceKey 
  : 'placeholder-service-key'

export const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

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
    // Check if we have valid Supabase configuration
    if (!rawSupabaseUrl || !isValidUrl(rawSupabaseUrl) || !rawSupabaseAnonKey) {
      return { success: false, error: 'Supabase configuration is missing or invalid. Please contact support.' }
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
    // Check if we have valid Supabase configuration
    if (!rawSupabaseUrl || !isValidUrl(rawSupabaseUrl) || !rawSupabaseAnonKey) {
      return { success: false, error: 'Supabase configuration is missing or invalid. Please contact support.' }
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
    // Check if we have valid Supabase configuration
    if (!rawSupabaseUrl || !isValidUrl(rawSupabaseUrl) || !rawSupabaseAnonKey) {
      return { success: false, error: 'Supabase configuration is missing or invalid. Please contact support.' }
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
    // Check if we have valid Supabase configuration
    if (!rawSupabaseUrl || !isValidUrl(rawSupabaseUrl) || !rawSupabaseAnonKey) {
      return { success: false, error: 'Supabase configuration is missing or invalid. Please contact support.' }
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
    console.log('🏗️ Creating user profile with admin client for:', userId, profileData);
    
    // Use admin client to bypass RLS for initial profile creation
    const { data, error } = await supabaseAdmin
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
      console.error('❌ Error creating user profile:', error);
      return { success: false, error: error.message }
    }

    console.log('✅ User profile created successfully:', data[0]);
    return { success: true, data: data[0] }
  } catch (err) {
    console.error('❌ Exception creating user profile:', err)
    return { success: false, error: 'An unexpected error occurred' }
  }
}

export async function getUserProfile(userId: string) {
  try {
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
