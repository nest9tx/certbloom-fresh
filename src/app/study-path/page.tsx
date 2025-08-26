'use client'

import React, { useState, useEffect } from 'react'
import { getCertifications, Certification } from '../../lib/conceptLearning'
import { useAuth } from '../../../lib/auth-context'
import StudyPathDashboard from '@/components/StudyPathDashboard'
import Link from 'next/link'
import Image from 'next/image'

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
      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-md border-b border-green-200/50">
        <div className="max-w-7xl mx-auto flex items-center justify-between p-6">
          <Link href="/dashboard" className="flex items-center space-x-3 group">
            <div className="w-10 h-10 transition-transform group-hover:scale-105">
              <Image src="/certbloom-logo.svg" alt="CertBloom" width={40} height={40} className="w-full h-full object-contain" />
            </div>
            <div className="text-2xl font-light text-green-800 tracking-wide">CertBloom</div>
          </Link>
          <div className="hidden md:flex items-center space-x-8">
            <Link href="/dashboard" className="text-green-700 hover:text-green-900 transition-colors font-medium">
              ← Dashboard
            </Link>
            <Link href="/pricing" className="text-green-700 hover:text-green-900 transition-colors font-medium">Pricing</Link>
            <Link href="/settings" className="text-green-700 hover:text-green-900 transition-colors font-medium">Settings</Link>
            <span className="text-green-600 font-medium text-sm">Welcome, {user?.user_metadata?.full_name || user?.email?.split('@')[0] || 'Learner'}!</span>
          </div>
        </div>
      </nav>

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
              {certifications.filter(cert => cert.test_code === '902').map((cert) => {
                // Only show certifications with structured content
                const hasStructuredContent = true
                
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
                🚀 Welcome to CertBloom&apos;s Concept-Based Learning!
              </h3>
              <p className="text-blue-800 mb-4">
                We&apos;ve transformed from random question practice to structured, mastery-based learning. 
                Currently available: <strong>Elementary Mathematics (EC-6)</strong> with:
              </p>
              <ul className="list-disc list-inside text-blue-700 space-y-1 mb-4">
                <li><strong>3 Learning Domains:</strong> Number Operations, Patterns & Algebra, Geometry</li>
                <li><strong>6 Core Concepts:</strong> From place value to area & perimeter</li>
                <li><strong>Multi-Modal Content:</strong> Explanations, examples, practice, real-world scenarios</li>
                <li><strong>Progress Tracking:</strong> Mastery levels and personalized recommendations</li>
              </ul>
              
              {certifications.filter(cert => cert.test_code === '902').length === 0 && (
                <div className="bg-yellow-100 border border-yellow-300 rounded-lg p-4 mt-4">
                  <p className="text-yellow-800">
                    <strong>🔧 Setup Required:</strong> The Elementary Mathematics certification needs to be added to your database. 
                    Please run the concept-learning-schema.sql file in your Supabase SQL Editor first.
                  </p>
                </div>
              )}
              
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
