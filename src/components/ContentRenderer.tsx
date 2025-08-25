'use client'

import React, { useState, useEffect } from 'react'
import { ContentItem, ContentData, recordContentEngagement } from '../lib/conceptLearning'
import { useAuth } from '../../lib/auth-context'

interface ContentRendererProps {
  contentItem: ContentItem
  onComplete?: (timeSpent: number) => void
}

export default function ContentRenderer({ contentItem, onComplete }: ContentRendererProps) {
  const { user } = useAuth()
  const [startTime] = useState(Date.now())
  const [selectedAnswer, setSelectedAnswer] = useState<number | null>(null)
  const [showExplanation, setShowExplanation] = useState(false)

  // Track engagement when component unmounts or content changes
  useEffect(() => {
    return () => {
      if (user) {
        const timeSpent = Math.floor((Date.now() - startTime) / 1000)
        if (timeSpent > 5) { // Only track if spent more than 5 seconds
          recordContentEngagement(user.id, contentItem.id, timeSpent)
        }
      }
    }
  }, [contentItem.id, startTime, user])

  const handleComplete = () => {
    const timeSpent = Math.floor((Date.now() - startTime) / 1000)
    onComplete?.(timeSpent)
  }

  const renderTextExplanation = (content: ContentData) => (
    <div className="prose max-w-none">
      <div className="bg-blue-50 border-l-4 border-blue-400 p-6 rounded-r-lg">
        <h3 className="text-lg font-semibold text-blue-900 mb-4">📚 Understanding the Concept</h3>
        {content.sections && (
          <div className="space-y-4">
            {content.sections.map((section, index) => (
              <div key={index} className="text-gray-700">
                <h4 className="font-medium text-blue-800 mb-2">• {section}</h4>
              </div>
            ))}
          </div>
        )}
        <button
          onClick={handleComplete}
          className="mt-6 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
        >
          Mark as Read ✓
        </button>
      </div>
    </div>
  )

  const renderInteractiveExample = (content: ContentData) => (
    <div className="bg-green-50 border-l-4 border-green-400 p-6 rounded-r-lg">
      <h3 className="text-lg font-semibold text-green-900 mb-4">🔍 Step-by-Step Example</h3>
      {content.steps && (
        <div className="space-y-3 mb-4">
          {content.steps.map((step, index) => (
            <div key={index} className="flex items-start space-x-3">
              <span className="bg-green-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold">
                {index + 1}
              </span>
              <span className="text-gray-700">{step}</span>
            </div>
          ))}
        </div>
      )}
      {content.example && (
        <div className="bg-white p-4 rounded-lg border border-green-200 mb-4">
          <h4 className="font-medium text-green-800 mb-2">Example:</h4>
          <code className="text-lg font-mono text-green-700">{content.example}</code>
        </div>
      )}
      <button
        onClick={handleComplete}
        className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors"
      >
        Got it! ✓
      </button>
    </div>
  )

  const renderPracticeQuestion = (content: ContentData) => (
    <div className="bg-purple-50 border-l-4 border-purple-400 p-6 rounded-r-lg">
      <h3 className="text-lg font-semibold text-purple-900 mb-4">🎯 Practice Question</h3>
      {content.question && (
        <div className="mb-4">
          <h4 className="font-medium text-purple-800 mb-3">{content.question}</h4>
          {content.answers && (
            <div className="space-y-2">
              {content.answers.map((answer, index) => (
                <button
                  key={index}
                  onClick={() => {
                    setSelectedAnswer(index)
                    setShowExplanation(true)
                  }}
                  className={`w-full text-left p-3 rounded-lg border transition-colors ${
                    selectedAnswer === index
                      ? selectedAnswer === content.correct
                        ? 'bg-green-100 border-green-400 text-green-800'
                        : 'bg-red-100 border-red-400 text-red-800'
                      : 'bg-white border-gray-300 hover:border-purple-400'
                  }`}
                  disabled={selectedAnswer !== null}
                >
                  <span className="font-medium">{String.fromCharCode(65 + index)})</span> {answer}
                </button>
              ))}
            </div>
          )}
        </div>
      )}
      {showExplanation && content.explanation && (
        <div className="bg-white p-4 rounded-lg border border-purple-200 mb-4">
          <h4 className="font-medium text-purple-800 mb-2">Explanation:</h4>
          <p className="text-gray-700">{content.explanation}</p>
        </div>
      )}
      {showExplanation && (
        <button
          onClick={handleComplete}
          className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors"
        >
          Continue Learning ✓
        </button>
      )}
    </div>
  )

  const renderRealWorldScenario = (content: ContentData) => (
    <div className="bg-orange-50 border-l-4 border-orange-400 p-6 rounded-r-lg">
      <h3 className="text-lg font-semibold text-orange-900 mb-4">🌍 Real-World Application</h3>
      {content.scenario && (
        <div className="text-gray-700 mb-4">
          <p>{content.scenario}</p>
        </div>
      )}
      <button
        onClick={handleComplete}
        className="bg-orange-600 text-white px-4 py-2 rounded-lg hover:bg-orange-700 transition-colors"
      >
        Understood ✓
      </button>
    </div>
  )

  const renderTeachingStrategy = (content: ContentData) => (
    <div className="bg-teal-50 border-l-4 border-teal-400 p-6 rounded-r-lg">
      <h3 className="text-lg font-semibold text-teal-900 mb-4">👩‍🏫 Teaching Strategy</h3>
      {content.strategy && (
        <div className="text-gray-700 mb-4">
          <p>{content.strategy}</p>
        </div>
      )}
      <button
        onClick={handleComplete}
        className="bg-teal-600 text-white px-4 py-2 rounded-lg hover:bg-teal-700 transition-colors"
      >
        Apply This ✓
      </button>
    </div>
  )

  const renderCommonMisconception = (content: ContentData) => (
    <div className="bg-red-50 border-l-4 border-red-400 p-6 rounded-r-lg">
      <h3 className="text-lg font-semibold text-red-900 mb-4">⚠️ Common Misconception</h3>
      {content.misconception && (
        <div className="text-gray-700 mb-4">
          <p>{content.misconception}</p>
        </div>
      )}
      <button
        onClick={handleComplete}
        className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors"
      >
        Avoid This Mistake ✓
      </button>
    </div>
  )

  const renderMemoryTechnique = (content: ContentData) => (
    <div className="bg-indigo-50 border-l-4 border-indigo-400 p-6 rounded-r-lg">
      <h3 className="text-lg font-semibold text-indigo-900 mb-4">🧠 Memory Technique</h3>
      {content.technique && (
        <div className="text-gray-700 mb-4">
          <p>{content.technique}</p>
        </div>
      )}
      <button
        onClick={handleComplete}
        className="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition-colors"
      >
        Remember This ✓
      </button>
    </div>
  )

  const renderContent = () => {
    switch (contentItem.type) {
      case 'text_explanation':
        return renderTextExplanation(contentItem.content)
      case 'interactive_example':
        return renderInteractiveExample(contentItem.content)
      case 'practice_question':
        return renderPracticeQuestion(contentItem.content)
      case 'real_world_scenario':
        return renderRealWorldScenario(contentItem.content)
      case 'teaching_strategy':
        return renderTeachingStrategy(contentItem.content)
      case 'common_misconception':
        return renderCommonMisconception(contentItem.content)
      case 'memory_technique':
        return renderMemoryTechnique(contentItem.content)
      default:
        return <div>Unknown content type: {contentItem.type}</div>
    }
  }

  return (
    <div className="mb-6">
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-lg font-medium text-gray-900">{contentItem.title}</h3>
        <span className="text-sm text-gray-500">~{contentItem.estimated_minutes} min</span>
      </div>
      {renderContent()}
    </div>
  )
}
