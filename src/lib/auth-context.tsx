'use client'

import React, { createContext, useContext, useEffect, useState } from 'react'
import { User } from '@supabase/supabase-js'
import { signUp as supabaseSignUp, signIn as supabaseSignIn, signOut as supabaseSignOut, getCurrentUser } from './supabase'

interface AuthContextType {
  user: User | null
  loading: boolean
  signUp: (email: string, password: string, fullName: string) => Promise<{ success: boolean; error?: string }>
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
  }, [])

  const signUp = async (email: string, password: string, fullName: string) => {
    const result = await supabaseSignUp(email, password, fullName)
    if (result.success && result.user) {
      setUser(result.user)
      // Create user profile in user_profiles table
      try {
        const { createUserProfile } = await import('./supabase')
        await createUserProfile(result.user.id, {
          email,
          full_name: fullName,
        })
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
