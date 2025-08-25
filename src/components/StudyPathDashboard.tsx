'use client'

import React, { useState, useEffect } from 'react'
import { 
  CertificationWithStructure, 
  StudyPlan,
  getCertificationWithFullStructure,
  getUserStudyPlan,
  createStudyPlan,
  getDifficultyLabel 
} from '@/lib/conceptLearning'
import { useAuth } from '@/lib/auth-context'
import ConceptViewer from './ConceptViewer'

interface StudyPathDashboardProps {
  certificationId: string
}

export default function StudyPathDashboard({ certificationId }: StudyPathDashboardProps) {
  const { user } = useAuth()
  const [certification, setCertification] = useState<CertificationWithStructure | null>(null)
  const [studyPlan, setStudyPlan] = useState<StudyPlan | null>(null)
  const [selectedConcept, setSelectedConcept] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const loadDataForEffect = async () => {
      if (!user || !certificationId) return

      try {
        setLoading(true)
        setError(null)

        // Load certification structure and user progress
        const certData = await getCertificationWithFullStructure(certificationId, user.id)
        setCertification(certData)

        // Load or create study plan
        let plan = await getUserStudyPlan(user.id, certificationId)
        if (!plan) {
          plan = await createStudyPlan(user.id, certificationId)
        }
        setStudyPlan(plan)

      } catch (err) {
        console.error('Error loading study path data:', err)
        setError('Failed to load study path. Please try again.')
      } finally {
        setLoading(false)
      }
    }

    loadDataForEffect()
  }, [user, certificationId])

  const loadData = async () => {
    if (!user) return

    try {
      setLoading(true)
      setError(null)

      // Load certification structure and user progress
      const certData = await getCertificationWithFullStructure(certificationId, user.id)
      setCertification(certData)

      // Load or create study plan
      let plan = await getUserStudyPlan(user.id, certificationId)
      if (!plan) {
        plan = await createStudyPlan(user.id, certificationId)
      }
      setStudyPlan(plan)

    } catch (err) {
      console.error('Error loading study path data:', err)
      setError('Failed to load study path. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const getConceptProgress = (conceptId: string) => {
    const concept = certification?.domains
      .flatMap(d => d.concepts)
      .find(c => c.id === conceptId)
    
    return concept?.user_progress ? 
      (Array.isArray(concept.user_progress) ? concept.user_progress[0] : concept.user_progress) 
      : undefined
  }

  const getOverallProgress = () => {
    if (!certification) return { completed: 0, total: 0, percentage: 0 }

    const allConcepts = certification.domains.flatMap(d => d.concepts)
    const completed = allConcepts.filter(c => {
      const progress = getConceptProgress(c.id)
      return progress?.is_mastered || false
    }).length

    return {
      completed,
      total: allConcepts.length,
      percentage: allConcepts.length > 0 ? Math.round((completed / allConcepts.length) * 100) : 0
    }
  }

  const getNextRecommendedConcept = () => {
    if (!certification) return null

    // Find first unmastered concept
    for (const domain of certification.domains) {
      for (const concept of domain.concepts.sort((a, b) => a.order_index - b.order_index)) {
        const progress = getConceptProgress(concept.id)
        if (!progress?.is_mastered) {
          return concept
        }
      }
    }
    return null
  }

  const handleConceptComplete = () => {
    setSelectedConcept(null)
    loadData() // Reload to update progress
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading your study path...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-6">
        <h3 className="text-red-800 font-medium mb-2">Error Loading Study Path</h3>
        <p className="text-red-600 mb-4">{error}</p>
        <button
          onClick={loadData}
          className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors"
        >
          Try Again
        </button>
      </div>
    )
  }

  if (!certification) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-600">Study path not found.</p>
      </div>
    )
  }

  // Show concept viewer if a concept is selected
  if (selectedConcept) {
    const concept = certification.domains
      .flatMap(d => d.concepts)
      .find(c => c.id === selectedConcept)

    if (concept) {
      return (
        <ConceptViewer
          concept={concept}
          onComplete={handleConceptComplete}
          onBack={() => setSelectedConcept(null)}
        />
      )
    }
  }

  const overallProgress = getOverallProgress()
  const nextConcept = getNextRecommendedConcept()

  return (
    <div className="max-w-6xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">{certification.name}</h1>
        <p className="text-gray-600 mb-6">{certification.description}</p>

        {/* Overall Progress */}
        <div className="bg-gradient-to-r from-blue-50 to-purple-50 p-6 rounded-lg mb-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold text-gray-900">Your Progress</h2>
            <span className="text-2xl font-bold text-blue-600">
              {overallProgress.percentage}%
            </span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-3 mb-4">
            <div
              className="bg-gradient-to-r from-blue-600 to-purple-600 h-3 rounded-full transition-all duration-300"
              style={{ width: `${overallProgress.percentage}%` }}
            />
          </div>
          <div className="flex justify-between text-sm text-gray-600">
            <span>{overallProgress.completed} of {overallProgress.total} concepts mastered</span>
            {studyPlan && (
              <span>Daily goal: {studyPlan.daily_study_minutes} minutes</span>
            )}
          </div>
        </div>

        {/* Next Recommended */}
        {nextConcept && (
          <div className="bg-green-50 border border-green-200 p-6 rounded-lg mb-6">
            <h3 className="font-semibold text-green-900 mb-2">🎯 Continue Learning</h3>
            <p className="text-green-800 mb-3">Ready to tackle your next concept?</p>
            <button
              onClick={() => setSelectedConcept(nextConcept.id)}
              className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition-colors"
            >
              Study: {nextConcept.name} →
            </button>
          </div>
        )}
      </div>

      {/* Domains and Concepts */}
      <div className="space-y-8">
        {certification.domains.map((domain) => (
          <div key={domain.id} className="bg-white border border-gray-200 rounded-lg overflow-hidden">
            {/* Domain Header */}
            <div className="bg-gray-50 px-6 py-4 border-b">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">{domain.name}</h3>
                  <p className="text-sm text-gray-600">{domain.description}</p>
                </div>
                <div className="text-right">
                  <div className="text-sm text-gray-500">Weight: {domain.weight_percentage}%</div>
                  <div className="text-xs text-gray-400">Domain {domain.code}</div>
                </div>
              </div>
            </div>

            {/* Concepts */}
            <div className="p-6">
              <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                {domain.concepts
                  .sort((a, b) => a.order_index - b.order_index)
                  .map((concept) => {
                    const progress = getConceptProgress(concept.id)
                    const isMastered = progress?.is_mastered || false
                    const masteryLevel = progress?.mastery_level || 0

                    return (
                      <button
                        key={concept.id}
                        onClick={() => setSelectedConcept(concept.id)}
                        className={`text-left p-4 rounded-lg border transition-all hover:shadow-md ${
                          isMastered
                            ? 'bg-green-50 border-green-200 hover:border-green-300'
                            : masteryLevel > 0
                            ? 'bg-yellow-50 border-yellow-200 hover:border-yellow-300'
                            : 'bg-gray-50 border-gray-200 hover:border-blue-300'
                        }`}
                      >
                        <div className="flex items-start justify-between mb-2">
                          <h4 className="font-medium text-gray-900 pr-2">{concept.name}</h4>
                          {isMastered && (
                            <span className="text-green-600 text-xl">✓</span>
                          )}
                        </div>

                        {concept.description && (
                          <p className="text-sm text-gray-600 mb-3 line-clamp-2">
                            {concept.description}
                          </p>
                        )}

                        <div className="space-y-2">
                          {/* Progress Bar */}
                          <div className="w-full bg-gray-200 rounded-full h-2">
                            <div
                              className={`h-2 rounded-full transition-all duration-300 ${
                                isMastered ? 'bg-green-500' : 'bg-blue-500'
                              }`}
                              style={{ width: `${masteryLevel * 100}%` }}
                            />
                          </div>

                          <div className="flex justify-between text-xs text-gray-500">
                            <span>{getDifficultyLabel(concept.difficulty_level)}</span>
                            <span>~{concept.estimated_study_minutes}min</span>
                          </div>

                          {progress && (
                            <div className="text-xs text-gray-500">
                              Studied {progress.times_reviewed} times
                            </div>
                          )}
                        </div>
                      </button>
                    )
                  })}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
