'use client'

import React, { useState, useEffect } from 'react'
import { createClient } from '@supabase/supabase-js'

interface Concept {
  id: string
  name: string
  domain_name: string
  module_count: number
}

interface ConceptBrowserProps {
  onConceptSelect: (conceptId: string) => void
  selectedConceptId: string | null
  certificationGoal?: string | null
}

export default function ConceptBrowser({ onConceptSelect, selectedConceptId, certificationGoal }: ConceptBrowserProps) {
  const [concepts, setConcepts] = useState<Concept[]>([])
  const [loading, setLoading] = useState(true)
  const [groupedConcepts, setGroupedConcepts] = useState<Record<string, Concept[]>>({})

  useEffect(() => {
    const loadConcepts = async () => {
      try {
        if (certificationGoal === '902') {
          // Load real concepts from database for 902
          const supabase = createClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
          )

          const { data, error } = await supabase
            .from('concepts')
            .select(`
              id,
              name,
              domains!inner(name, order_index, certifications!inner(test_code)),
              learning_modules(id)
            `)
            .eq('domains.certifications.test_code', '902')
            .order('domains.order_index')

          if (error) {
            console.error('Database error:', error)
            throw error
          }

          const conceptsWithCounts = data?.map(concept => ({
            id: concept.id,
            name: concept.name,
            domain_name: ((concept.domains as { name: string }[])?.[0] || { name: 'Unknown' }).name,
            module_count: ((concept.learning_modules as { id: string }[]) || []).length
          })) || []

          setConcepts(conceptsWithCounts)

          // Group by domain
          const grouped = conceptsWithCounts.reduce((acc, concept) => {
            const domain = concept.domain_name
            if (!acc[domain]) acc[domain] = []
            acc[domain].push(concept)
            return acc
          }, {} as Record<string, Concept[]>)

          setGroupedConcepts(grouped)
        } else {
          // Use hardcoded concepts for other certifications
          const concepts = getConcepts(certificationGoal || '902')
          setConcepts(concepts)

          // Group by domain
          const grouped = concepts.reduce((acc, concept) => {
            const domain = concept.domain_name
            if (!acc[domain]) acc[domain] = []
            acc[domain].push(concept)
            return acc
          }, {} as Record<string, Concept[]>)

          setGroupedConcepts(grouped)
        }
      } catch (error) {
        console.error('Error loading concepts:', error)
        // Fallback to hardcoded data
        const concepts = getConcepts(certificationGoal || '902')
        setConcepts(concepts)
        const grouped = concepts.reduce((acc, concept) => {
          const domain = concept.domain_name
          if (!acc[domain]) acc[domain] = []
          acc[domain].push(concept)
          return acc
        }, {} as Record<string, Concept[]>)
        setGroupedConcepts(grouped)
      } finally {
        setLoading(false)
      }
    }

    loadConcepts()
  }, [certificationGoal])

  const getConcepts = (certification: string): Concept[] => {
    switch (certification) {
      case '902':
        return [
          // Domain 1: Number Concepts and Operations
          { id: '902-1', name: 'Place Value', domain_name: 'Number Concepts and Operations', module_count: 5 },
          { id: '902-2', name: 'Number Relationships', domain_name: 'Number Concepts and Operations', module_count: 5 },
          { id: '902-3', name: 'Addition and Subtraction', domain_name: 'Number Concepts and Operations', module_count: 5 },
          { id: '902-4', name: 'Multiplication and Division', domain_name: 'Number Concepts and Operations', module_count: 5 },
          
          // Domain 2: Patterns, Relationships, and Algebraic Reasoning
          { id: '902-5', name: 'Patterns and Sequences', domain_name: 'Patterns, Relationships, and Algebraic Reasoning', module_count: 5 },
          { id: '902-6', name: 'Algebraic Thinking', domain_name: 'Patterns, Relationships, and Algebraic Reasoning', module_count: 5 },
          { id: '902-7', name: 'Equations and Expressions', domain_name: 'Patterns, Relationships, and Algebraic Reasoning', module_count: 5 },
          { id: '902-8', name: 'Functions and Relationships', domain_name: 'Patterns, Relationships, and Algebraic Reasoning', module_count: 5 },
          
          // Domain 3: Geometry and Spatial Reasoning
          { id: '902-9', name: 'Geometric Shapes', domain_name: 'Geometry and Spatial Reasoning', module_count: 5 },
          { id: '902-10', name: 'Spatial Relationships', domain_name: 'Geometry and Spatial Reasoning', module_count: 5 },
          { id: '902-11', name: 'Measurement', domain_name: 'Geometry and Spatial Reasoning', module_count: 5 },
          { id: '902-12', name: 'Transformations', domain_name: 'Geometry and Spatial Reasoning', module_count: 5 },
          
          // Domain 4: Data Analysis and Personal Financial Literacy
          { id: '902-13', name: 'Data Collection', domain_name: 'Data Analysis and Personal Financial Literacy', module_count: 5 },
          { id: '902-14', name: 'Data Representation', domain_name: 'Data Analysis and Personal Financial Literacy', module_count: 5 },
          { id: '902-15', name: 'Statistical Analysis', domain_name: 'Data Analysis and Personal Financial Literacy', module_count: 5 },
          { id: '902-16', name: 'Financial Literacy', domain_name: 'Data Analysis and Personal Financial Literacy', module_count: 5 }
        ]
      case '391':
        return [
          { id: '391-1', name: 'Reading Comprehension', domain_name: 'English Language Arts', module_count: 0 },
          { id: '391-2', name: 'Writing Skills', domain_name: 'English Language Arts', module_count: 0 },
          { id: '391-3', name: 'Basic Math Operations', domain_name: 'Mathematics', module_count: 0 },
          { id: '391-4', name: 'Scientific Method', domain_name: 'Science', module_count: 0 },
          { id: '391-5', name: 'Social Studies Concepts', domain_name: 'Social Studies', module_count: 0 }
        ]
      default:
        return [
          { id: 'default-1', name: 'Coming Soon', domain_name: 'General Education', module_count: 0 }
        ]
    }
  }

  const getDomainIcon = (domainName: string) => {
    if (domainName.includes('Number')) return '🔢'
    if (domainName.includes('Patterns')) return '🔄'
    if (domainName.includes('Geometry')) return '📐'
    if (domainName.includes('Data')) return '📊'
    return '📚'
  }

  const getDomainColor = (domainName: string) => {
    if (domainName.includes('Number')) return 'from-blue-500 to-blue-600'
    if (domainName.includes('Patterns')) return 'from-purple-500 to-purple-600'
    if (domainName.includes('Geometry')) return 'from-green-500 to-green-600'
    if (domainName.includes('Data')) return 'from-orange-500 to-orange-600'
    return 'from-gray-500 to-gray-600'
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="mb-8 text-center">
        <h2 className="text-3xl font-bold text-gray-900 mb-2">Choose Your Learning Path</h2>
        <p className="text-gray-600">Select a mathematical concept to explore comprehensive learning modules</p>
        <div className="mt-4 text-sm text-blue-600 bg-blue-50 rounded-lg p-3 inline-block">
          🎯 {concepts.reduce((sum, c) => sum + c.module_count, 0)} learning modules across {Object.keys(groupedConcepts).length} domains
        </div>
      </div>

      <div className="space-y-8">
        {Object.entries(groupedConcepts).map(([domainName, domainConcepts]) => (
          <div key={domainName} className="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
            <div className={`bg-gradient-to-r ${getDomainColor(domainName)} p-6 text-white`}>
              <div className="flex items-center space-x-3">
                <div className="text-3xl">{getDomainIcon(domainName)}</div>
                <div>
                  <h3 className="text-xl font-bold">{domainName}</h3>
                  <p className="text-white/90">{domainConcepts.length} concepts • {domainConcepts.reduce((sum, c) => sum + c.module_count, 0)} modules</p>
                </div>
              </div>
            </div>

            <div className="p-6">
              <div className="grid md:grid-cols-2 gap-4">
                {domainConcepts.map((concept) => (
                  <button
                    key={concept.id}
                    onClick={() => onConceptSelect(concept.id)}
                    className={`p-4 rounded-lg border-2 text-left transition-all duration-200 hover:shadow-md ${
                      selectedConceptId === concept.id
                        ? 'border-blue-500 bg-blue-50 shadow-md'
                        : 'border-gray-200 hover:border-blue-300 hover:bg-gray-50'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <h4 className="font-semibold text-gray-900 mb-1">{concept.name}</h4>
                        <div className="flex items-center space-x-4 text-sm text-gray-600">
                          <span className="flex items-center space-x-1">
                            <span>📚</span>
                            <span>{concept.module_count} modules</span>
                          </span>
                          {concept.module_count === 5 && (
                            <span className="text-green-600 font-medium">✅ Complete</span>
                          )}
                        </div>
                      </div>
                      <div className="text-2xl">
                        {selectedConceptId === concept.id ? '👉' : '→'}
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>

      {selectedConceptId && (
        <div className="mt-8 text-center">
          <div className="bg-green-50 border border-green-200 rounded-lg p-4 inline-block">
            <p className="text-green-800 font-medium">
              ✨ Ready to explore! Scroll down to start your learning journey.
            </p>
          </div>
        </div>
      )}
    </div>
  )
}
