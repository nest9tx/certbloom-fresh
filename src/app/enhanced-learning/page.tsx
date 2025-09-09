'use client'

import React, { useState, useEffect } from 'react'
import { useAuth } from '../../../lib/auth-context'
import LearningModuleRenderer from '../../components/LearningModuleRenderer'
import ConceptBrowser from '../../components/ConceptBrowser'
import Link from 'next/link'

export default function EnhancedLearningPage() {
  const { user, loading } = useAuth()
  const [conceptId, setConceptId] = useState<string | null>(null)
  const [userCertificationGoal, setUserCertificationGoal] = useState<string | null>(null)

  // Fetch user's certification goal
  useEffect(() => {
    async function fetchCertificationGoal() {
      if (user) {
        try {
          const { getUserCertificationGoal } = await import('../../lib/getUserCertificationGoal')
          const goal = await getUserCertificationGoal(user.id)
          setUserCertificationGoal(goal)
        } catch (error) {
          console.error('Error fetching certification goal:', error)
          setUserCertificationGoal('902') // Default to 902
        }
      }
    }
    
    if (user) {
      fetchCertificationGoal()
    }
  }, [user])

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading Enhanced Learning Experience...</p>
        </div>
      </div>
    )
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 flex items-center justify-center">
        <div className="text-center max-w-md mx-auto px-6">
          <div className="text-6xl mb-4">🔐</div>
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Authentication Required</h2>
          <p className="text-gray-600 mb-6">
            Please sign in to access the Enhanced Learning Experience.
          </p>
          <Link 
            href="/login" 
            className="inline-block px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
          >
            Sign In
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-sm border-b border-gray-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <Link href="/" className="flex items-center space-x-3 group">
              <div className="w-10 h-10 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center group-hover:scale-110 transition-transform">
                <span className="text-white font-bold text-lg">CB</span>
              </div>
              <span className="text-xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                CertBloom
              </span>
            </Link>
            
            <div className="flex items-center space-x-4">
              <Link 
                href="/dashboard" 
                className="text-gray-600 hover:text-gray-900 transition-colors"
              >
                Dashboard
              </Link>
              <div className="w-8 h-8 bg-gradient-to-r from-green-400 to-blue-500 rounded-full flex items-center justify-center">
                <span className="text-white font-medium text-sm">
                  {user.email?.[0]?.toUpperCase()}
                </span>
              </div>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <div className="max-w-7xl mx-auto px-6 pt-12 pb-8">
        <div className="text-center mb-12">
          <div className="inline-flex items-center px-4 py-2 bg-gradient-to-r from-blue-100 to-purple-100 rounded-full text-sm font-medium text-blue-700 mb-4">
            ✨ Enhanced Learning Experience
          </div>
          <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
            Teacher Preparation
            <span className="block bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
              Excellence Framework
            </span>
          </h1>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto leading-relaxed">
            Experience comprehensive learning modules designed specifically for teacher certification success. 
            From concept introduction to classroom application, every module prepares you for real-world teaching excellence.
          </p>
        </div>

        {/* Feature Highlights */}
        <div className="grid md:grid-cols-3 gap-6 mb-12">
          <div className="bg-white/70 backdrop-blur-sm rounded-xl p-6 border border-white/50 shadow-lg">
            <div className="text-3xl mb-3">📚</div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">5 Learning Modules</h3>
            <p className="text-gray-600 text-sm">
              Comprehensive content delivery through concept introduction, teaching strategies, tutorials, scenarios, and misconception alerts.
            </p>
          </div>
          
          <div className="bg-white/70 backdrop-blur-sm rounded-xl p-6 border border-white/50 shadow-lg">
            <div className="text-3xl mb-3">🏫</div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Real Scenarios</h3>
            <p className="text-gray-600 text-sm">
              Practice with authentic classroom challenges and learn to handle diverse learning situations.
            </p>
          </div>

          <div className="bg-white/70 backdrop-blur-sm rounded-xl p-6 border border-white/50 shadow-lg">
            <div className="text-3xl mb-3">⚠️</div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Misconception Alerts</h3>
            <p className="text-gray-600 text-sm">
              Identify and address common student errors with targeted intervention strategies.
            </p>
          </div>
        </div>
      </div>

      {/* Main Content */}
      {conceptId ? (
        <LearningModuleRenderer conceptId={conceptId} />
      ) : (
        <ConceptBrowser 
          onConceptSelect={setConceptId}
          selectedConceptId={conceptId}
          certificationGoal={userCertificationGoal}
        />
      )}

      {/* Back Button */}
      {conceptId && (
        <div className="max-w-7xl mx-auto px-6 py-8">
          <div className="text-center">
            <button
              onClick={() => setConceptId(null)}
              className="inline-flex items-center space-x-2 px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors font-medium"
            >
              <span>←</span>
              <span>Back to Concept Browser</span>
            </button>
          </div>
        </div>
      )}

      {/* Footer */}
      <footer className="bg-white/50 backdrop-blur-sm border-t border-gray-200 mt-16 py-8">
        <div className="max-w-7xl mx-auto px-6 text-center">
          <p className="text-gray-600">
            🌸 Enhanced Learning Experience • Preparing Teachers for Excellence
          </p>
          <div className="mt-4 space-x-6">
            <Link href="/dashboard" className="text-sm text-blue-600 hover:text-blue-700">
              Back to Dashboard
            </Link>
            <Link href="/analytics" className="text-sm text-blue-600 hover:text-blue-700">
              Progress Analytics
            </Link>
          </div>
        </div>
      </footer>
    </div>
  )
}
