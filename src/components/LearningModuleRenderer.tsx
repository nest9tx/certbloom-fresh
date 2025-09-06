'use client'

import React, { useState, useEffect } from 'react'
import { createClient } from '@supabase/supabase-js'

// Types for our enhanced learning system
interface LearningModule {
  id: string
  concept_id: string
  module_type: 'concept_introduction' | 'teaching_demonstration' | 'interactive_tutorial' | 'classroom_scenario' | 'misconception_alert'
  title: string
  description: string
  content_data: {
    explanation?: string
    videoContent?: {
      title: string
      duration: string
      url?: string
    }
    interactiveElements?: Record<string, unknown>[]
  }
  learning_objectives: string[]
  success_criteria: string[]
  estimated_minutes: number
  teaching_tips: string[]
  common_misconceptions: string[]
  classroom_applications: string[]
  difficulty_level: number
}

interface PracticeTest {
  id: string
  concept_id: string
  title: string
  description: string
  question_count: number
  time_limit_minutes: number
  passing_score: number
}

interface LearningModuleRendererProps {
  conceptId: string
}

export default function LearningModuleRenderer({ conceptId }: LearningModuleRendererProps) {
  const [modules, setModules] = useState<LearningModule[]>([])
  const [practiceTests, setPracticeTests] = useState<PracticeTest[]>([])
  const [selectedModule, setSelectedModule] = useState<LearningModule | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const loadData = async () => {
      try {
        setLoading(true)
        
        const supabase = createClient(
          process.env.NEXT_PUBLIC_SUPABASE_URL!,
          process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
        )
        
        // Load learning modules for this concept
        const { data: modulesData, error: modulesError } = await supabase
          .from('learning_modules')
          .select('*')
          .eq('concept_id', conceptId)
          .order('order_index')

        if (modulesError) throw modulesError

        // Load practice tests for this concept
        const { data: testsData, error: testsError } = await supabase
          .from('practice_tests')
          .select('*')
          .eq('concept_id', conceptId)

        if (testsError) throw testsError

        setModules(modulesData || [])
        setPracticeTests(testsData || [])
        
        // Auto-select first module if available
        if (modulesData && modulesData.length > 0) {
          setSelectedModule(modulesData[0])
        }

      } catch (err) {
        console.error('Error loading learning content:', err)
        setError(err instanceof Error ? err.message : 'Failed to load content')
      } finally {
        setLoading(false)
      }
    }
    
    loadData()
  }, [conceptId])

  const getModuleIcon = (moduleType: string) => {
    switch (moduleType) {
      case 'concept_introduction': return '📚'
      case 'teaching_demonstration': return '👩‍🏫'
      case 'interactive_tutorial': return '🎯'
      case 'classroom_scenario': return '🏫'
      case 'misconception_alert': return '⚠️'
      default: return '📖'
    }
  }

  const getModuleColor = (moduleType: string) => {
    switch (moduleType) {
      case 'concept_introduction': return 'from-blue-500 to-blue-600'
      case 'teaching_demonstration': return 'from-green-500 to-green-600'
      case 'interactive_tutorial': return 'from-purple-500 to-purple-600'
      case 'classroom_scenario': return 'from-orange-500 to-orange-600'
      case 'misconception_alert': return 'from-red-500 to-red-600'
      default: return 'from-gray-500 to-gray-600'
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading enhanced learning modules...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-xl p-6 m-4">
        <div className="flex items-center space-x-3">
          <div className="text-2xl">❌</div>
          <div>
            <h3 className="text-lg font-semibold text-red-800">Error Loading Content</h3>
            <p className="text-red-600">{error}</p>
          </div>
        </div>
      </div>
    )
  }

  if (modules.length === 0) {
    return (
      <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-6 m-4">
        <div className="flex items-center space-x-3">
          <div className="text-2xl">🚧</div>
          <div>
            <h3 className="text-lg font-semibold text-yellow-800">Content Coming Soon</h3>
            <p className="text-yellow-600">Enhanced learning modules are being prepared for this concept.</p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="max-w-7xl mx-auto p-6">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Enhanced Learning Experience</h1>
        <p className="text-gray-600">Teacher preparation focused content with comprehensive learning modules</p>
      </div>

      <div className="grid lg:grid-cols-3 gap-8">
        {/* Module Selection Sidebar */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
            <div className="bg-gradient-to-r from-blue-600 to-purple-600 p-4">
              <h2 className="text-lg font-semibold text-white">Learning Modules</h2>
            </div>
            
            <div className="p-4 space-y-3">
              {modules.map((module) => (
                <button
                  key={module.id}
                  onClick={() => setSelectedModule(module)}
                  className={`w-full text-left p-4 rounded-lg border-2 transition-all duration-200 ${
                    selectedModule?.id === module.id
                      ? 'border-blue-500 bg-blue-50'
                      : 'border-gray-200 hover:border-blue-300 hover:bg-gray-50'
                  }`}
                >
                  <div className="flex items-start space-x-3">
                    <div className="text-2xl flex-shrink-0">
                      {getModuleIcon(module.module_type)}
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="font-medium text-gray-900 text-sm leading-tight">
                        {module.title}
                      </h3>
                      <p className="text-xs text-gray-500 mt-1 line-clamp-2">
                        {module.description}
                      </p>
                      <div className="flex items-center justify-between mt-2">
                        <span className="text-xs text-blue-600 font-medium">
                          {module.estimated_minutes} min
                        </span>
                        <span className="text-xs text-gray-400">
                          Level {module.difficulty_level}
                        </span>
                      </div>
                    </div>
                  </div>
                </button>
              ))}
            </div>

            {/* Practice Tests Section */}
            {practiceTests.length > 0 && (
              <div className="border-t border-gray-200 p-4">
                <h3 className="font-medium text-gray-900 mb-3">Practice Assessments</h3>
                {practiceTests.map((test) => (
                  <div
                    key={test.id}
                    className="p-3 bg-green-50 border border-green-200 rounded-lg mb-2"
                  >
                    <div className="flex items-center space-x-2">
                      <span className="text-lg">🧪</span>
                      <div>
                        <h4 className="text-sm font-medium text-green-800">{test.title}</h4>
                        <p className="text-xs text-green-600">
                          {test.question_count} questions • {test.time_limit_minutes} min
                        </p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Main Content Area */}
        <div className="lg:col-span-2">
          {selectedModule && (
            <div className="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
              {/* Module Header */}
              <div className={`bg-gradient-to-r ${getModuleColor(selectedModule.module_type)} p-6 text-white`}>
                <div className="flex items-center space-x-4">
                  <div className="text-4xl">
                    {getModuleIcon(selectedModule.module_type)}
                  </div>
                  <div>
                    <h2 className="text-2xl font-bold">{selectedModule.title}</h2>
                    <p className="text-white/90 mt-1">{selectedModule.description}</p>
                  </div>
                </div>
              </div>

              {/* Module Content */}
              <div className="p-6">
                {/* Learning Objectives */}
                {selectedModule.learning_objectives && selectedModule.learning_objectives.length > 0 && (
                  <div className="mb-6">
                    <h3 className="text-lg font-semibold text-gray-900 mb-3">🎯 Learning Objectives</h3>
                    <ul className="space-y-2">
                      {selectedModule.learning_objectives.map((objective, index) => (
                        <li key={index} className="flex items-start space-x-2">
                          <span className="text-green-500 mt-1">✓</span>
                          <span className="text-gray-700">{objective}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                )}

                {/* Main Content */}
                <div className="mb-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-3">📖 Content</h3>
                  <div className="prose max-w-none">
                    {selectedModule.content_data?.explanation && (
                      <p className="text-gray-700 leading-relaxed mb-4">
                        {selectedModule.content_data.explanation}
                      </p>
                    )}
                    
                    {selectedModule.content_data?.videoContent && (
                      <div className="bg-gray-100 rounded-lg p-4 mb-4">
                        <p className="text-sm text-gray-600">
                          🎥 Video Content: {selectedModule.content_data.videoContent.title}
                        </p>
                        <p className="text-xs text-gray-500 mt-1">
                          Duration: {selectedModule.content_data.videoContent.duration}
                        </p>
                      </div>
                    )}
                  </div>
                </div>

                {/* Teaching Tips */}
                {selectedModule.teaching_tips && selectedModule.teaching_tips.length > 0 && (
                  <div className="mb-6">
                    <h3 className="text-lg font-semibold text-gray-900 mb-3">💡 Teaching Tips</h3>
                    <div className="bg-blue-50 rounded-lg p-4">
                      <ul className="space-y-2">
                        {selectedModule.teaching_tips.map((tip, index) => (
                          <li key={index} className="flex items-start space-x-2">
                            <span className="text-blue-500 mt-1">💡</span>
                            <span className="text-blue-800">{tip}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                )}

                {/* Common Misconceptions */}
                {selectedModule.common_misconceptions && selectedModule.common_misconceptions.length > 0 && (
                  <div className="mb-6">
                    <h3 className="text-lg font-semibold text-gray-900 mb-3">⚠️ Common Misconceptions</h3>
                    <div className="bg-red-50 rounded-lg p-4">
                      <ul className="space-y-2">
                        {selectedModule.common_misconceptions.map((misconception, index) => (
                          <li key={index} className="flex items-start space-x-2">
                            <span className="text-red-500 mt-1">⚠️</span>
                            <span className="text-red-800">{misconception}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                )}

                {/* Classroom Applications */}
                {selectedModule.classroom_applications && selectedModule.classroom_applications.length > 0 && (
                  <div className="mb-6">
                    <h3 className="text-lg font-semibold text-gray-900 mb-3">🏫 Classroom Applications</h3>
                    <div className="bg-green-50 rounded-lg p-4">
                      <ul className="space-y-2">
                        {selectedModule.classroom_applications.map((application, index) => (
                          <li key={index} className="flex items-start space-x-2">
                            <span className="text-green-500 mt-1">🏫</span>
                            <span className="text-green-800">{application}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                )}

                {/* Success Criteria */}
                {selectedModule.success_criteria && selectedModule.success_criteria.length > 0 && (
                  <div className="mb-6">
                    <h3 className="text-lg font-semibold text-gray-900 mb-3">🏆 Success Criteria</h3>
                    <div className="grid gap-2">
                      {selectedModule.success_criteria.map((criteria, index) => (
                        <div key={index} className="flex items-center space-x-2 p-2 bg-purple-50 rounded">
                          <input type="checkbox" className="rounded text-purple-600" />
                          <span className="text-purple-800">{criteria}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
