'use client'

import React, { useState, useEffect } from 'react'
import { useAuth } from '../../../lib/auth-context'
import LearningModuleRenderer from '../../components/LearningModuleRenderer'
import ConceptBrowser from '../../components/ConceptBrowser'
import Link from 'next/link'

export default function EnhancedLearningPage() {
  const { user, loading } = useAuth()
  const [userCertificationGoal, setUserCertificationGoal] = useState<string | null>(null)
  const [conceptId, setConceptId] = useState<string | null>(null)
  const [loadingUserData, setLoadingUserData] = useState(true)

  // Get certification name for display
  const getCertificationDisplayName = (goal: string) => {
    const certMap: Record<string, string> = {
      '902': 'TExES Core Subjects EC-6: Mathematics (902)',
      '391': 'TExES Core Subjects EC-6 (391)',
      '901': 'TExES Core Subjects EC-6: English Language Arts (901)',
      '903': 'TExES Core Subjects EC-6: Social Studies (903)',
      '904': 'TExES Core Subjects EC-6: Science (904)'
    };
    return certMap[goal] || goal;
  };

  // Fetch user's certification goal
  useEffect(() => {
    // Map certification goals to concept IDs and subject-specific content
    const certificationToConceptMap: Record<string, { conceptId: string; subjectNote: string }> = {
      '902': { 
        conceptId: 'c1111111-1111-1111-1111-111111111111', 
        subjectNote: 'Math content' 
      },
      '903': { 
        conceptId: 'social-studies-placeholder', 
        subjectNote: 'Social Studies content coming soon' 
      },
      '901': { 
        conceptId: 'ela-placeholder', 
        subjectNote: 'English Language Arts content coming soon' 
      },
      '904': { 
        conceptId: 'science-placeholder', 
        subjectNote: 'Science content coming soon' 
      },
      '391': { 
        conceptId: 'ec6-comprehensive-placeholder', 
        subjectNote: 'EC-6 Comprehensive content coming soon' 
      },
    }

    async function fetchUserCertificationGoal() {
      if (user) {
        try {
          const { getUserCertificationGoal } = await import('../../lib/getUserCertificationGoal')
          const goal = await getUserCertificationGoal(user.id)
          setUserCertificationGoal(goal)
          
          // Set the concept ID based on certification goal
          if (goal && certificationToConceptMap[goal]) {
            setConceptId(certificationToConceptMap[goal].conceptId)
          } else {
            // Default to Place Value concept if no specific mapping
            setConceptId('c1111111-1111-1111-1111-111111111111')
          }
        } catch (error) {
          console.error('Error fetching certification goal:', error)
          // Default to Place Value concept on error
          setConceptId('c1111111-1111-1111-1111-111111111111')
        } finally {
          setLoadingUserData(false)
        }
      } else {
        setLoadingUserData(false)
      }
    }

    fetchUserCertificationGoal()
  }, [user])

  if (loading || loadingUserData) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading enhanced learning experience...</p>
        </div>
      </div>
    )
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 flex items-center justify-center">
        <div className="text-center max-w-md mx-auto p-6">
          <div className="text-6xl mb-4">🔒</div>
          <h1 className="text-2xl font-bold text-gray-900 mb-4">Sign In Required</h1>
          <p className="text-gray-600 mb-6">Please sign in to access the enhanced learning experience with comprehensive teacher preparation modules.</p>
          <Link 
            href="/auth" 
            className="inline-block px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
          >
            Sign In
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50">
      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-md border-b border-gray-200">
        <div className="max-w-7xl mx-auto flex items-center justify-between p-6">
          <Link href="/dashboard" className="flex items-center space-x-3 group">
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
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Concept Mastery</h3>
            <p className="text-gray-600 text-sm">
              Deep dive into educational concepts with structured learning progressions and clear success criteria.
            </p>
          </div>
          
          <div className="bg-white/70 backdrop-blur-sm rounded-xl p-6 border border-white/50 shadow-lg">
            <div className="text-3xl mb-3">👩‍🏫</div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Teaching Strategies</h3>
            <p className="text-gray-600 text-sm">
              Learn proven classroom techniques and teaching demonstrations from experienced educators.
            </p>
          </div>
          
          <div className="bg-white/70 backdrop-blur-sm rounded-xl p-6 border border-white/50 shadow-lg">
            <div className="text-3xl mb-3">🏫</div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Real Scenarios</h3>
            <p className="text-gray-600 text-sm">
              Practice with authentic classroom challenges and learn to handle diverse learning situations.
            </p>
          </div>
        </div>
      </div>

      {/* Main Learning Module Content */}
      {conceptId ? (
        <LearningModuleRenderer conceptId={conceptId} />
      ) : (
        <ConceptBrowser 
          onConceptSelect={setConceptId}
          selectedConceptId={conceptId}
        />
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
