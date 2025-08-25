'use client'

import React, { useState } from 'react'
import { ConceptWithContent, updateConceptProgress, getDifficultyLabel } from '../lib/conceptLearning'
import { useAuth } from '../../lib/auth-context'
import ContentRenderer from './ContentRenderer'

interface ConceptViewerProps {
  concept: ConceptWithContent
  onComplete?: () => void
  onBack?: () => void
}

export default function ConceptViewer({ concept, onComplete, onBack }: ConceptViewerProps) {
  const { user } = useAuth()
  const [currentContentIndex, setCurrentContentIndex] = useState(0)
  const [completedContent, setCompletedContent] = useState<Set<string>>(new Set())
  const [startTime] = useState(Date.now())

  const sortedContent = [...concept.content_items].sort((a, b) => a.order_index - b.order_index)
  const currentContent = sortedContent[currentContentIndex]
  const progress = concept.user_progress ? (Array.isArray(concept.user_progress) ? concept.user_progress[0] : concept.user_progress) : undefined

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const handleContentComplete = (_timeSpent: number) => {
    // Mark current content as completed
    const newCompleted = new Set(completedContent)
    newCompleted.add(currentContent.id)
    setCompletedContent(newCompleted)

    // Move to next content item or complete concept
    if (currentContentIndex < sortedContent.length - 1) {
      setCurrentContentIndex(currentContentIndex + 1)
    } else {
      handleConceptComplete()
    }
  }

  const handleConceptComplete = async () => {
    if (!user) return

    const totalTimeSpent = Math.floor((Date.now() - startTime) / 1000 / 60) // Convert to minutes
    const masteryIncrease = 0.2 // Each completion increases mastery by 20%
    const newMasteryLevel = Math.min((progress?.mastery_level || 0) + masteryIncrease, 1.0)
    const timesReviewed = (progress?.times_reviewed || 0) + 1

    try {
      await updateConceptProgress(user.id, concept.id, {
        mastery_level: newMasteryLevel,
        time_spent_minutes: (progress?.time_spent_minutes || 0) + totalTimeSpent,
        last_studied_at: new Date().toISOString(),
        times_reviewed: timesReviewed,
        is_mastered: newMasteryLevel >= 0.8 // Consider mastered at 80%
      })

      onComplete?.()
    } catch (error) {
      console.error('Error updating concept progress:', error)
    }
  }

  const navigateToContent = (index: number) => {
    setCurrentContentIndex(index)
  }

  const getMasteryColor = (level: number) => {
    if (level >= 0.8) return 'text-green-600'
    if (level >= 0.6) return 'text-yellow-600'
    if (level >= 0.4) return 'text-orange-600'
    return 'text-red-600'
  }

  return (
    <div className="max-w-4xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-4">
          {onBack && (
            <button
              onClick={onBack}
              className="flex items-center text-gray-600 hover:text-gray-900 transition-colors"
            >
              ← Back to Study Path
            </button>
          )}
          <div className="text-sm text-gray-500">
            Difficulty: {getDifficultyLabel(concept.difficulty_level)}
          </div>
        </div>

        <h1 className="text-3xl font-bold text-gray-900 mb-4">{concept.name}</h1>
        
        {concept.description && (
          <p className="text-lg text-gray-600 mb-6">{concept.description}</p>
        )}

        {/* Learning Objectives */}
        {concept.learning_objectives && concept.learning_objectives.length > 0 && (
          <div className="bg-blue-50 p-4 rounded-lg mb-6">
            <h3 className="font-semibold text-blue-900 mb-2">🎯 Learning Objectives</h3>
            <ul className="list-disc list-inside space-y-1">
              {concept.learning_objectives.map((objective, index) => (
                <li key={index} className="text-blue-800">{objective}</li>
              ))}
            </ul>
          </div>
        )}

        {/* Progress Indicator */}
        {progress && (
          <div className="bg-gray-50 p-4 rounded-lg mb-6">
            <div className="flex items-center justify-between mb-2">
              <span className="font-medium text-gray-700">Your Progress</span>
              <span className={`font-bold ${getMasteryColor(progress.mastery_level)}`}>
                {Math.round(progress.mastery_level * 100)}% Mastered
              </span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                style={{ width: `${progress.mastery_level * 100}%` }}
              />
            </div>
            <div className="flex justify-between text-sm text-gray-500 mt-2">
              <span>Studied {progress.times_reviewed} times</span>
              <span>{progress.time_spent_minutes} minutes total</span>
            </div>
          </div>
        )}

        {/* Content Navigation */}
        <div className="flex space-x-2 mb-6 overflow-x-auto">
          {sortedContent.map((content, index) => {
            const isCompleted = completedContent.has(content.id)
            const isCurrent = index === currentContentIndex
            
            return (
              <button
                key={content.id}
                onClick={() => navigateToContent(index)}
                className={`flex-shrink-0 px-4 py-2 rounded-lg border text-sm font-medium transition-colors ${
                  isCurrent
                    ? 'bg-blue-600 text-white border-blue-600'
                    : isCompleted
                    ? 'bg-green-100 text-green-800 border-green-300'
                    : 'bg-white text-gray-700 border-gray-300 hover:border-blue-400'
                }`}
              >
                {isCompleted && '✓ '}
                {content.title}
              </button>
            )
          })}
        </div>
      </div>

      {/* Current Content */}
      {currentContent && (
        <div className="mb-8">
          <ContentRenderer
            contentItem={currentContent}
            onComplete={handleContentComplete}
          />
        </div>
      )}

      {/* Navigation */}
      <div className="flex justify-between items-center">
        <button
          onClick={() => navigateToContent(Math.max(0, currentContentIndex - 1))}
          disabled={currentContentIndex === 0}
          className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-300 transition-colors"
        >
          ← Previous
        </button>

        <span className="text-sm text-gray-500">
          {currentContentIndex + 1} of {sortedContent.length}
        </span>

        <button
          onClick={() => {
            if (currentContentIndex < sortedContent.length - 1) {
              navigateToContent(currentContentIndex + 1)
            } else {
              handleConceptComplete()
            }
          }}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
        >
          {currentContentIndex < sortedContent.length - 1 ? 'Next →' : 'Complete Concept ✓'}
        </button>
      </div>

      {/* Estimated Time */}
      <div className="mt-6 text-center text-sm text-gray-500">
        Estimated time: {concept.estimated_study_minutes} minutes
      </div>
    </div>
  )
}
