'use client'

import React, { createContext, useContext, useEffect, useState } from 'react'
import { User } from '@supabase/supabase-js'
import { signUp as supabaseSignUp, signIn as supabaseSignIn, signOut as supabaseSignOut, getCurrentUser } from './supabase'

interface AuthContextType {
  user: User | null
  loading: boolean
  signUp: (email: string, password: string, fullName: string, certificationGoal?: string) => Promise<{ success: boolean; error?: string }>
  signIn: (email: string, password: string) => Promise<{ success: boolean; error?: string }>
  signOut: () => Promise<{ success: boolean; error?: string }>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Get initial session using our safe function
    const getInitialUser = async () => {
      try {
        const result = await getCurrentUser()
        if (result.success && result.user) {
          setUser(result.user)
        }
      } catch (error) {
        console.error('Error getting initial user:', error)
      } finally {
        setLoading(false)
      }
    }

    getInitialUser()

    // Set up auth state listener for real-time auth changes
    const setupAuthListener = async () => {
      const { supabase } = await import('./supabase')
      if (supabase) {
        const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
          if (session?.user) {
            setUser(session.user)
            
            // Check if user profile exists, create if it doesn't
            if (event === 'SIGNED_IN' || event === 'TOKEN_REFRESHED') {
              try {
                const { getUserProfile, createUserProfile } = await import('./supabase')
                const profileResult = await getUserProfile(session.user.id)
                
                if (!profileResult.success) {
                  // Profile doesn't exist, create it
                  console.log('🏗️ Creating missing user profile for:', session.user.email)
                  
                  // Try to get certification from multiple sources
                  const storedCertification = typeof window !== 'undefined' 
                    ? localStorage.getItem('selectedCertification') || localStorage.getItem('pendingCertification')
                    : null;
                  
                  await createUserProfile(session.user.id, {
                    email: session.user.email || '',
                    full_name: session.user.user_metadata?.full_name || '',
                    certification_goal: storedCertification || undefined,
                  })
                  
                  // Clear the stored certification after using it
                  if (storedCertification && typeof window !== 'undefined') {
                    localStorage.removeItem('selectedCertification');
                    localStorage.removeItem('pendingCertification');
                    console.log('✅ Used stored certification in profile creation:', storedCertification);
                  }
                } else {
                  console.log('✅ User profile already exists for:', session.user.email);
                  
                  // Check if we have a pending certification to update existing profile
                  const pendingCertification = typeof window !== 'undefined' 
                    ? localStorage.getItem('pendingCertification') || localStorage.getItem('selectedCertification')
                    : null;
                  
                  if (pendingCertification && (!profileResult.profile?.certification_goal || profileResult.profile.certification_goal === '')) {
                    console.log('🔄 Updating existing profile with pending certification:', pendingCertification);
                    const { updateUserProfile } = await import('./supabase');
                    await updateUserProfile(session.user.id, {
                      certification_goal: pendingCertification
                    });
                    
                    // Clear pending certifications
                    localStorage.removeItem('selectedCertification');
                    localStorage.removeItem('pendingCertification');
                    console.log('✅ Updated existing profile with certification:', pendingCertification);
                  }
                }
              } catch (err) {
                console.error('❌ Error checking/creating user profile:', err)
              }
            }
          } else {
            setUser(null)
          }
          setLoading(false)
        })

        return () => subscription.unsubscribe()
      }
    }

    setupAuthListener()
  }, [])

  const signUp = async (email: string, password: string, fullName: string, certificationGoal?: string) => {
    console.log('🔐 Auth context signup called with certification:', certificationGoal);
    
    const result = await supabaseSignUp(email, password, fullName)
    if (result.success && result.user) {
      // Don't set user state immediately - wait for email confirmation
      // setUser(result.user)
      
      // Create user profile in user_profiles table
      try {
        console.log('🏗️ Creating user profile for:', email, 'with certification:', certificationGoal)
        const { createUserProfile } = await import('./supabase')
        
        // Make sure we have the most current certification goal
        const finalCertificationGoal = certificationGoal || (typeof window !== 'undefined' ? localStorage.getItem('selectedCertification') : null);
        
        const profileResult = await createUserProfile(result.user.id, {
          email,
          full_name: fullName,
          certification_goal: finalCertificationGoal || undefined,
        })
        
        if (!profileResult.success) {
          console.error('❌ Error creating user profile:', profileResult.error)
          // Store certification in localStorage as backup if profile creation fails
          if (finalCertificationGoal && typeof window !== 'undefined') {
            localStorage.setItem('pendingCertification', finalCertificationGoal);
            console.log('💾 Stored certification as backup due to profile creation failure');
          }
        } else {
          console.log('✅ User profile created successfully for:', email, 'with certification:', finalCertificationGoal)
          // Keep certification in localStorage until email confirmation completes
          if (finalCertificationGoal && typeof window !== 'undefined') {
            localStorage.setItem('pendingCertification', finalCertificationGoal);
            console.log('💾 Keeping certification as backup until email confirmation');
          }
        }
      } catch (err) {
        console.error('❌ Exception creating user profile:', err)
        // Store certification in localStorage as backup
        const finalCertificationGoal = certificationGoal || (typeof window !== 'undefined' ? localStorage.getItem('selectedCertification') : null);
        if (finalCertificationGoal && typeof window !== 'undefined') {
          localStorage.setItem('pendingCertification', finalCertificationGoal);
          console.log('💾 Stored certification as backup due to exception');
        }
      }
    }
    return result
  }

  const signIn = async (email: string, password: string) => {
    const result = await supabaseSignIn(email, password)
    if (result.success && result.user) {
      setUser(result.user)
    }
    return result
  }

  const signOut = async () => {
    console.log('🚪 Starting sign out process...')
    try {
      const result = await supabaseSignOut()
      console.log('🔑 Supabase sign out result:', result)
      
      if (result.success) {
        setUser(null)
        console.log('✅ User state cleared, sign out successful')
      } else {
        console.error('❌ Sign out failed:', result.error)
      }
      return result
    } catch (error) {
      console.error('❌ Sign out exception:', error)
      return { success: false, error: 'An unexpected error occurred during sign out' }
    }
  }

  const value = {
    user,
    loading,
    signUp,
    signIn,
    signOut,
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
