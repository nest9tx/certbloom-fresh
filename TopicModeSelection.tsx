// PROTOTYPE: Dual-Mode Study Interface
// This shows how to separate Study Mode vs Practice Mode

import React from 'react'

interface TopicModeSelectionProps {
  topicName: string
  studyMaterialsCount: number
  practiceQuestionsCount: number
  onModeSelect: (mode: 'study' | 'practice') => void
}

export default function TopicModeSelection({ 
  topicName, 
  studyMaterialsCount, 
  practiceQuestionsCount,
  onModeSelect 
}: TopicModeSelectionProps) {
  const handleModeSelect = (mode: 'study' | 'practice') => {
    onModeSelect(mode)
  }

  return (
    <div className="max-w-4xl mx-auto p-6">
      <div className="text-center mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">{topicName}</h1>
        <p className="text-lg text-gray-600">How would you like to approach this topic?</p>
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        {/* Study Mode */}
        <div className="bg-blue-50 border-2 border-blue-200 rounded-xl p-6 hover:border-blue-400 transition-colors cursor-pointer"
             onClick={() => handleModeSelect('study')}>
          <div className="text-center">
            <div className="w-16 h-16 bg-blue-500 rounded-full flex items-center justify-center mx-auto mb-4">
              <span className="text-2xl">📚</span>
            </div>
            <h2 className="text-2xl font-bold text-blue-900 mb-2">Study Mode</h2>
            <p className="text-blue-700 mb-4">Learn the concepts first</p>
            
            <div className="bg-white rounded-lg p-4 mb-4">
              <h3 className="font-semibold text-blue-800 mb-2">What you&apos;ll do:</h3>
              <ul className="text-sm text-blue-700 text-left space-y-1">
                <li>• Review concept explanations</li>
                <li>• See worked examples</li>
                <li>• Quick understanding checks</li>
                <li>• Build confidence before testing</li>
              </ul>
            </div>

            <div className="text-sm text-blue-600">
              {studyMaterialsCount} study materials available
            </div>

            <button className="mt-4 bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors font-medium">
              Start Learning 📖
            </button>
          </div>
        </div>

        {/* Practice Mode */}
        <div className="bg-green-50 border-2 border-green-200 rounded-xl p-6 hover:border-green-400 transition-colors cursor-pointer"
             onClick={() => handleModeSelect('practice')}>
          <div className="text-center">
            <div className="w-16 h-16 bg-green-500 rounded-full flex items-center justify-center mx-auto mb-4">
              <span className="text-2xl">🎯</span>
            </div>
            <h2 className="text-2xl font-bold text-green-900 mb-2">Practice Mode</h2>
            <p className="text-green-700 mb-4">Test your knowledge</p>
            
            <div className="bg-white rounded-lg p-4 mb-4">
              <h3 className="font-semibold text-green-800 mb-2">What you&apos;ll do:</h3>
              <ul className="text-sm text-green-700 text-left space-y-1">
                <li>• Answer exam-style questions</li>
                <li>• No interruptions or hints</li>
                <li>• Immediate performance feedback</li>
                <li>• Mirrors actual test experience</li>
              </ul>
            </div>

            <div className="text-sm text-green-600">
              {practiceQuestionsCount} practice questions available
            </div>

            <button className="mt-4 bg-green-600 text-white px-6 py-3 rounded-lg hover:bg-green-700 transition-colors font-medium">
              Start Practice 🚀
            </button>
          </div>
        </div>
      </div>

      {/* Recommendation */}
      <div className="mt-8 bg-amber-50 border border-amber-200 rounded-lg p-4">
        <div className="flex items-start">
          <span className="text-2xl mr-3">💡</span>
          <div>
            <h3 className="font-semibold text-amber-800 mb-1">Recommendation</h3>
            <p className="text-amber-700 text-sm">
              New to this topic? Start with <strong>Study Mode</strong> to build understanding, 
              then switch to <strong>Practice Mode</strong> to test your knowledge.
              Already familiar? Jump straight into <strong>Practice Mode</strong> for exam preparation.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

// Usage Example:
// <TopicModeSelection 
//   topicName="Number Concepts and Operations"
//   studyMaterialsCount={8}
//   practiceQuestionsCount={45}
//   onModeSelect={(mode) => {
//     if (mode === 'study') {
//       // Navigate to study materials (content_items)
//     } else {
//       // Navigate to practice questions (questions table)
//     }
//   }}
// />
