'use client'

import React, { useState, useEffect } from 'react'
import { getCertifications, Certification } from '../../lib/conceptLearning'
import { useAuth } from '../../../lib/auth-context'
import StudyPathDashboard from '@/components/StudyPathDashboard'
import Link from 'next/link'
import Image from 'next/image'
import { useSearchParams } from 'next/navigation'

function StudyPathContent() {
  const { user } = useAuth()
  const searchParams = useSearchParams()
  const certIdFromUrl = searchParams?.get('certId') || null
  
  const [certifications, setCertifications] = useState<Certification[]>([])
  const [selectedCertification, setSelectedCertification] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadCertifications()
  }, [])

  useEffect(() => {
    // Auto-select certification if certId is provided in URL
    if (certIdFromUrl && certifications.length > 0) {
      const cert = certifications.find(c => c.id === certIdFromUrl)
      if (cert) {
        console.log('🎯 Auto-selecting certification from URL:', cert.name, cert.test_code)
        setSelectedCertification(certIdFromUrl)
      } else {
        console.log('❌ Certification not found for ID:', certIdFromUrl)
      }
    }
  }, [certIdFromUrl, certifications])

  const loadCertifications = async () => {
    try {
      const certs = await getCertifications()
      setCertifications(certs)
      
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
              {certifications.map((cert) => {
                // Check if this certification has structured content
                // For now, we'll check if it has domains/concepts
                const hasStructuredContent = true // We'll make all available for testing
                
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

                    <div className="mt-3 text-xs font-medium">
                      {cert.test_code === '902' ? (
                        <span className="text-green-600">✅ Fully structured</span>
                      ) : (
                        <span className="text-blue-600">🚧 Basic structure ready</span>
                      )}
                    </div>
                  </div>
                )
              })}
            </div>

            {/* Demo Info */}
            <div className="mt-12 bg-blue-50 border border-blue-200 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-blue-900 mb-2">
                🚀 All EC-6 Certifications Now Available!
              </h3>
              <p className="text-blue-800 mb-4">
                We&apos;ve set up basic structure for all EC-6 certifications. Each includes:
              </p>
              <ul className="list-disc list-inside text-blue-700 space-y-1 mb-4">
                <li><strong>391 (Core Subjects):</strong> ELA, Math, Social Studies, Science domains</li>
                <li><strong>901 (ELA):</strong> Reading, Language Arts, Writing, Literature domains</li>
                <li><strong>902 (Math):</strong> Fully developed with multiple concepts and content</li>
                <li><strong>903 (Social Studies):</strong> History, Geography, Government, Economics domains</li>
                <li><strong>904 (Science):</strong> Physical, Life, Earth/Space, Scientific Inquiry domains</li>
                <li><strong>905 (Fine Arts/Health/PE):</strong> All 8 domains we set up earlier</li>
              </ul>
              
              {certifications.length === 0 && (
                <div className="bg-yellow-100 border border-yellow-300 rounded-lg p-4 mt-4">
                  <p className="text-yellow-800">
                    <strong>🔧 Setup Required:</strong> Run our comprehensive setup script to populate all certifications.
                  </p>
                </div>
              )}
              
              <p className="text-sm text-blue-600 font-medium">
                ✨ Session completion now works properly for all certifications!
              </p>
            </div>
          </div>
        ) : (
          // Study Path Dashboard
          <div>
            <div className="mb-6">
              <Link
                href="/dashboard"
                className="flex items-center text-gray-600 hover:text-gray-900 transition-colors"
              >
                ← Back to Dashboard
              </Link>
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
