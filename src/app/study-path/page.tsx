'use client'

import React, { useState, useEffect } from 'react'
import { getCertifications, Certification } from '../../lib/conceptLearning'
import { useAuth } from '../../../lib/auth-context'
import StudyPathDashboard from '@/components/StudyPathDashboard'

function StudyPathContent() {
  const { user } = useAuth()
  const [certifications, setCertifications] = useState<Certification[]>([])
  const [selectedCertification, setSelectedCertification] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadCertifications()
  }, [])

  const loadCertifications = async () => {
    try {
      const certs = await getCertifications()
      setCertifications(certs)
      
      // Don't auto-select - let user choose from available certifications
      console.log('Available certifications:', certs.map(c => ({ id: c.id, name: c.name, test_code: c.test_code })))
    } catch (error) {
      console.error('Error loading certifications:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading certifications...</p>
        </div>
      </div>
    )
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-gray-900 mb-4">Sign In Required</h1>
          <p className="text-gray-600">Please sign in to access your personalized study paths.</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-8">
        {!selectedCertification ? (
          // Certification Selection
          <div className="max-w-4xl mx-auto">
            <div className="text-center mb-8">
              <h1 className="text-4xl font-bold text-gray-900 mb-4">
                🌸 Structured Learning Paths
              </h1>
              <p className="text-lg text-gray-600">
                Choose your certification to begin concept-based learning
              </p>
            </div>

            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
              {certifications.map((cert) => {
                // Temporarily make all certifications available for testing
                const hasStructuredContent = true // cert.test_code === '160' // Elementary Mathematics
                
                return (
                  <div
                    key={cert.id}
                    className={`bg-white rounded-lg border p-6 transition-all hover:shadow-lg ${
                      hasStructuredContent 
                        ? 'border-blue-200 hover:border-blue-400' 
                        : 'border-gray-200 opacity-60'
                    }`}
                  >
                    <h3 className="text-lg font-semibold text-gray-900 mb-2">
                      {cert.name}
                    </h3>
                    
                    {cert.description && (
                      <p className="text-gray-600 mb-4 text-sm">
                        {cert.description}
                      </p>
                    )}

                    <div className="flex items-center justify-between">
                      <span className="text-sm text-gray-500">
                        Test Code: {cert.test_code}
                      </span>
                      
                      {hasStructuredContent ? (
                        <button
                          onClick={() => setSelectedCertification(cert.id)}
                          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                        >
                          Start Learning →
                        </button>
                      ) : (
                        <span className="text-xs text-gray-400 bg-gray-100 px-3 py-1 rounded-full">
                          Coming Soon
                        </span>
                      )}
                    </div>

                    {hasStructuredContent && (
                      <div className="mt-3 text-xs text-green-600 font-medium">
                        ✨ New: Concept-based learning available!
                      </div>
                    )}
                  </div>
                )
              })}
            </div>

            {/* Demo Info */}
            <div className="mt-12 bg-blue-50 border border-blue-200 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-blue-900 mb-2">
                🚀 Welcome to the New CertBloom Experience!
              </h3>
              <p className="text-blue-800 mb-4">
                We&apos;ve transformed from random question practice to structured, concept-based learning. 
                Currently featuring Elementary Mathematics (EC-6) with:
              </p>
              <ul className="list-disc list-inside text-blue-700 space-y-1 mb-4">
                <li>Organized learning domains and concepts</li>
                <li>Multi-modal content (explanations, examples, practice)</li>
                <li>Progress tracking and mastery levels</li>
                <li>Personalized study recommendations</li>
              </ul>
              <p className="text-sm text-blue-600">
                More certifications will be migrated to this new system soon!
              </p>
            </div>
          </div>
        ) : (
          // Study Path Dashboard
          <div>
            <div className="mb-6">
              <button
                onClick={() => setSelectedCertification(null)}
                className="flex items-center text-gray-600 hover:text-gray-900 transition-colors"
              >
                ← Back to Certifications
              </button>
            </div>
            <StudyPathDashboard certificationId={selectedCertification} />
          </div>
        )}
      </div>
    </div>
  )
}

export default function StudyPathPage() {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    )
  }

  return <StudyPathContent />
}
