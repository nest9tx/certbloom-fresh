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
                  console.log('Creating missing user profile for:', session.user.email)
                  await createUserProfile(session.user.id, {
                    email: session.user.email || '',
                    full_name: session.user.user_metadata?.full_name || '',
                  })
                }
              } catch (err) {
                console.error('Error checking/creating user profile:', err)
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
    const result = await supabaseSignUp(email, password, fullName)
    if (result.success && result.user) {
      // Don't set user state immediately - wait for email confirmation
      // setUser(result.user)
      
      // Create user profile in user_profiles table
      try {
        const { createUserProfile } = await import('./supabase')
        const profileResult = await createUserProfile(result.user.id, {
          email,
          full_name: fullName,
          certification_goal: certificationGoal,
        })
        
        if (!profileResult.success) {
          console.error('Error creating user profile:', profileResult.error)
          // Still return success for signup, but log the profile creation error
        } else {
          console.log('User profile created successfully for:', email)
        }
      } catch (err) {
        console.error('Error creating user profile:', err)
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
    const result = await supabaseSignOut()
    if (result.success) {
      setUser(null)
    }
    return result
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
