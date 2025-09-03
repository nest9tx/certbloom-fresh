'use client'

import React, { useState, useEffect, useCallback } from 'react'
import { ContentItem, ContentData, recordContentEngagement, getQuestionsForConcept, Question } from '../lib/conceptLearning'
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
  
  // Practice session state
  const [practiceQuestions, setPracticeQuestions] = useState<Question[]>([])
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0)
  const [practiceAnswers, setPracticeAnswers] = useState<{[key: number]: number}>({})
  const [showPracticeResults, setShowPracticeResults] = useState(false)
  const [loadingQuestions, setLoadingQuestions] = useState(false)
  const [practiceStarted, setPracticeStarted] = useState(false)
  const [sessionResults, setSessionResults] = useState<{correct: number, total: number, percentage: number} | null>(null)
  const [currentQuestionAnswer, setCurrentQuestionAnswer] = useState<number | null>(null)
  const [showCurrentExplanation, setShowCurrentExplanation] = useState(false)

  // Reset state when content item changes to prevent persistence issues
  useEffect(() => {
    console.log('🔄 Content changed, resetting state');
    setSelectedAnswer(null);
    setShowExplanation(false);
  }, [contentItem.id]);

  // Calculate practice session results and save them
  const calculatePracticeResults = useCallback(async () => {
    let correct = 0
    const questionIds: string[] = []
    const userAnswers: number[] = []
    
    practiceQuestions.forEach((question, index) => {
      questionIds.push(question.id)
      userAnswers.push(practiceAnswers[index] || 0)
      
      // Check if the selected answer is correct using choice_order
      const selectedChoiceOrder = practiceAnswers[index]
      const selectedChoice = question.answer_choices?.find(choice => 
        choice.choice_order === selectedChoiceOrder
      )
      
      if (selectedChoice && selectedChoice.is_correct) {
        correct++
      }
    })
    
    const results = {
      correct,
      total: practiceQuestions.length,
      percentage: Math.round((correct / practiceQuestions.length) * 100)
    }
    
    // Save session results to database
    if (user && contentItem.concept_id) {
      try {
        console.log('💾 Saving session results...', {
          userId: user.id,
          conceptId: contentItem.concept_id,
          results
        })
        
        const sessionId = `session-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
        
        const response = await fetch('/api/complete-session', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            sessionId,
            userAnswers,
            questionIds,
            conceptId: contentItem.concept_id,
            userId: user.id
          })
        })
        
        if (response.ok) {
          const data = await response.json()
          console.log('✅ Session saved successfully:', data)
        } else {
          console.error('❌ Failed to save session:', await response.text())
        }
      } catch (error) {
        console.error('❌ Error saving session:', error)
      }
    }
    
    return results
  }, [practiceQuestions, practiceAnswers, user, contentItem.concept_id])

  // Handle results calculation and saving
  useEffect(() => {
    if (showPracticeResults && !sessionResults && practiceQuestions.length > 0) {
      calculatePracticeResults().then(results => {
        setSessionResults(results)
      })
    }
  }, [showPracticeResults, sessionResults, practiceQuestions.length, calculatePracticeResults])

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

  // Load questions for practice session
  const loadPracticeQuestions = async () => {
    if (!contentItem.concept_id) return
    
    setLoadingQuestions(true)
    try {
      const questions = await getQuestionsForConcept(contentItem.concept_id, 15, true) // 15 questions, shuffled
      setPracticeQuestions(questions)
      setCurrentQuestionIndex(0)
      setPracticeAnswers({})
      setShowPracticeResults(false)
      setPracticeStarted(true)
    } catch (error) {
      console.error('Error loading practice questions:', error)
    } finally {
      setLoadingQuestions(false)
    }
  }

  // Handle practice question answer selection (allows changing selection)
  const handleQuestionSelect = (questionIndex: number, choiceOrder: number) => {
    setCurrentQuestionAnswer(choiceOrder)
    setShowCurrentExplanation(false) // Reset explanation when selecting new answer
  }

  // Submit current question answer
  const handleSubmitAnswer = () => {
    if (!currentQuestionAnswer) return
    
    setPracticeAnswers(prev => ({
      ...prev,
      [currentQuestionIndex]: currentQuestionAnswer
    }))
    setShowCurrentExplanation(true)
  }

  // Move to next practice question
  const nextPracticeQuestion = () => {
    if (currentQuestionIndex < practiceQuestions.length - 1) {
      setCurrentQuestionIndex(currentQuestionIndex + 1)
      setCurrentQuestionAnswer(null)
      setShowCurrentExplanation(false)
    } else {
      setShowPracticeResults(true)
    }
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

  const renderPracticeQuestion = (content: ContentData) => {
    // Check if this is a full practice session
    if (content.session_type === 'full_concept_practice') {
      return (
        <div className="bg-green-50 border-l-4 border-green-400 p-6 rounded-r-lg">
          <h3 className="text-lg font-semibold text-green-900 mb-4">🎯 Full Practice Session</h3>
          <div className="text-gray-700 mb-4">
            <p>{content.description || `Complete a comprehensive practice session for ${contentItem.title}`}</p>
            <div className="mt-3 space-y-2">
              <div className="flex items-center text-sm text-gray-600">
                <span className="font-medium">📊 Questions:</span>
                <span className="ml-2">{content.target_question_count || 25} from test bank</span>
              </div>
              <div className="flex items-center text-sm text-gray-600">
                <span className="font-medium">⏱️ Time:</span>
                <span className="ml-2">~{content.estimated_minutes || 25} minutes</span>
              </div>
              <div className="flex items-center text-sm text-gray-600">
                <span className="font-medium">🎲 Format:</span>
                <span className="ml-2">Mixed difficulty levels</span>
              </div>
            </div>
          </div>
          <button
            onClick={() => {
              // Navigate to practice session for this specific concept with full session
              window.location.href = `/practice/session?concept=${contentItem.concept_id}&mode=full&questions=${content.target_question_count || 25}`;
            }}
            className="bg-green-600 text-white px-6 py-3 rounded-lg hover:bg-green-700 transition-colors font-semibold"
          >
            Start {content.target_question_count || 25}-Question Session →
          </button>
        </div>
      )
    }

    // Regular practice question (single question)
    return (
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
                    // Prevent auto-selection - only select if not already selected
                    if (selectedAnswer === null) {
                      setSelectedAnswer(index)
                      // Don't auto-show explanation - let user submit first
                    }
                  }}
                  className={`w-full text-left p-3 rounded-lg border-2 transition-colors font-medium ${
                    showExplanation
                      ? (index === content.correct
                          ? 'bg-green-100 border-green-500 text-green-900 font-bold'
                          : (selectedAnswer === index 
                              ? 'bg-red-100 border-red-500 text-red-900 font-bold'
                              : 'bg-gray-100 border-gray-400 text-gray-600'))
                      : (selectedAnswer === index
                          ? 'bg-blue-100 border-blue-500 text-blue-900 font-bold'
                          : 'bg-white border-gray-500 text-black font-semibold hover:border-purple-500 hover:bg-purple-50 hover:text-purple-900')
                  }`}
                  disabled={showExplanation}
                >
                  <span className="font-bold mr-2">{String.fromCharCode(65 + index)})</span> {answer}
                </button>
              ))}
            </div>
          )}
        </div>
      )}
      
      {/* Submit button when answer is selected but explanation not shown */}
      {selectedAnswer !== null && !showExplanation && (
        <div className="mt-4">
          <button
            onClick={() => setShowExplanation(true)}
            className="bg-purple-600 text-white px-6 py-2 rounded-lg hover:bg-purple-700 transition-colors font-medium"
          >
            Submit Answer
          </button>
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
  }

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

  const renderPracticeSession = () => {
    // If practice hasn't started, show the start screen
    if (!practiceStarted) {
      return (
        <div className="bg-green-50 border-l-4 border-green-400 p-6 rounded-r-lg">
          <h3 className="text-lg font-semibold text-green-900 mb-4">🎯 Practice Session</h3>
          <div className="text-gray-700 mb-4">
            <p>Ready to practice {contentItem.title}? This session will test your understanding with real exam questions.</p>
            <p className="text-sm text-gray-600 mt-2">You&apos;ll work through up to 15 questions to build mastery of this concept.</p>
          </div>
          <button
            onClick={loadPracticeQuestions}
            disabled={loadingQuestions}
            className="bg-green-600 text-white px-6 py-3 rounded-lg hover:bg-green-700 transition-colors font-semibold disabled:opacity-50"
          >
            {loadingQuestions ? 'Loading Questions...' : 'Start Practice Session →'}
          </button>
        </div>
      )
    }

    // If no questions loaded, show error
    if (practiceQuestions.length === 0) {
      return (
        <div className="bg-yellow-50 border-l-4 border-yellow-400 p-6 rounded-r-lg">
          <h3 className="text-lg font-semibold text-yellow-900 mb-4">⚠️ No Questions Available</h3>
          <div className="text-gray-700 mb-4">
            <p>There are no practice questions available for this concept yet.</p>
          </div>
          <button
            onClick={handleComplete}
            className="bg-yellow-600 text-white px-4 py-2 rounded-lg hover:bg-yellow-700 transition-colors"
          >
            Continue Learning ✓
          </button>
        </div>
      )
    }

    // Show results screen
    if (showPracticeResults) {
      if (!sessionResults) {
        return (
          <div className="bg-blue-50 border-l-4 border-blue-400 p-6 rounded-r-lg">
            <h3 className="text-lg font-semibold text-blue-900 mb-4">📊 Calculating Results...</h3>
            <div className="text-gray-700">
              <p>Please wait while we save your session results...</p>
            </div>
          </div>
        )
      }
      
      return (
        <div className="bg-blue-50 border-l-4 border-blue-400 p-6 rounded-r-lg">
          <h3 className="text-lg font-semibold text-blue-900 mb-4">📊 Practice Session Complete!</h3>
          <div className="text-gray-700 mb-4">
            <div className="bg-white p-4 rounded-lg border border-blue-200 mb-4">
              <h4 className="font-semibold text-blue-800 mb-2">Your Results:</h4>
              <p className="text-2xl font-bold text-blue-900">{sessionResults.correct}/{sessionResults.total} ({sessionResults.percentage}%)</p>
              <p className="text-sm text-gray-600 mt-1">
                {sessionResults.percentage >= 80 ? '🎉 Excellent work! You\'ve mastered this concept.' : 
                 sessionResults.percentage >= 60 ? '📈 Good progress! Review the questions you missed.' :
                 '📚 Keep practicing! Review the explanations and try again.'}
              </p>
            </div>
            <p>Your progress has been saved and your mastery level updated!</p>
          </div>
          <button
            onClick={handleComplete}
            className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors font-semibold"
          >
            Continue Learning ✓
          </button>
        </div>
      )
    }

    // Show current question
    const currentQuestion = practiceQuestions[currentQuestionIndex]
    
    return (
      <div className="bg-purple-50 border-l-4 border-purple-400 p-6 rounded-r-lg">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold text-purple-900">🎯 Practice Question {currentQuestionIndex + 1}/{practiceQuestions.length}</h3>
          <div className="bg-purple-200 px-3 py-1 rounded-full text-sm font-medium text-purple-800">
            Progress: {currentQuestionIndex + 1}/{practiceQuestions.length}
          </div>
        </div>
        
        <div className="bg-white p-4 rounded-lg border border-purple-200 mb-4">
          <h4 className="font-medium text-purple-800 mb-3">{currentQuestion.question_text}</h4>
          <div className="space-y-2">
            {currentQuestion.answer_choices?.sort((a, b) => a.choice_order - b.choice_order).map((choice) => {
              const choiceKey = String.fromCharCode(64 + choice.choice_order);
              let buttonClass = "w-full text-left p-3 rounded-lg border-2 transition-colors ";
              
              if (showCurrentExplanation) {
                // Show correct/incorrect after submission
                if (choice.is_correct) {
                  buttonClass += "border-green-500 bg-green-100 text-green-900 font-bold";
                } else if (choice.choice_order === currentQuestionAnswer && !choice.is_correct) {
                  buttonClass += "border-red-500 bg-red-100 text-red-900 font-bold";
                } else {
                  buttonClass += "border-gray-300 bg-gray-100 text-gray-700";
                }
              } else {
                // Allow selection before submission
                if (choice.choice_order === currentQuestionAnswer) {
                  buttonClass += "bg-purple-100 border-purple-500 text-purple-900 font-bold";
                } else {
                  buttonClass += "bg-white border-gray-300 text-gray-800 hover:border-purple-300 hover:bg-purple-50";
                }
              }
              
              return (
                <button
                  key={choice.choice_order}
                  onClick={() => handleQuestionSelect(currentQuestionIndex, choice.choice_order)}
                  disabled={showCurrentExplanation}
                  className={buttonClass}
                >
                  <span className="font-bold mr-2">{choiceKey})</span> {choice.choice_text}
                </button>
              );
            }) || (
              <div className="text-gray-500 italic">No answer choices available</div>
            )}
          </div>
        </div>

        {/* Show explanation after submission */}
        {showCurrentExplanation && (
          <div className="bg-blue-50 rounded-lg p-4 mb-4">
            <h4 className="font-semibold text-blue-800 mb-2">Explanation</h4>
            <p className="text-blue-700">{currentQuestion.explanation || 'No explanation available for this question.'}</p>
          </div>
        )}

        {/* Action buttons */}
        <div className="flex justify-between items-center">
          <div className="text-sm text-gray-600">
            Question {currentQuestionIndex + 1} of {practiceQuestions.length}
          </div>
          
          <div className="space-x-2">
            {!showCurrentExplanation && currentQuestionAnswer && (
              <button
                onClick={handleSubmitAnswer}
                className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition-colors font-medium"
              >
                Submit Answer
              </button>
            )}
            
            {showCurrentExplanation && (
              <button
                onClick={nextPracticeQuestion}
                className="bg-purple-600 text-white px-6 py-2 rounded-lg hover:bg-purple-700 transition-colors font-medium"
              >
                {currentQuestionIndex < practiceQuestions.length - 1 ? 'Next Question →' : 'View Results →'}
              </button>
            )}
          </div>
        </div>
      </div>
    )
  }

  const renderExplanation = () => (
    <div className="bg-blue-50 border-l-4 border-blue-400 p-6 rounded-r-lg">
      <h3 className="text-lg font-semibold text-blue-900 mb-4">📚 {contentItem.title}</h3>
      <div className="text-gray-700 mb-4">
        <p>{typeof contentItem.content === 'string' ? contentItem.content : 'Loading content...'}</p>
      </div>
      <button
        onClick={handleComplete}
        className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
      >
        Continue ✓
      </button>
    </div>
  )

  const renderReview = () => (
    <div className="bg-purple-50 border-l-4 border-purple-400 p-6 rounded-r-lg">
      <h3 className="text-lg font-semibold text-purple-900 mb-4">📝 {contentItem.title}</h3>
      <div className="text-gray-700 mb-4">
        <p>{typeof contentItem.content === 'string' ? contentItem.content : 'Loading content...'}</p>
      </div>
      <button
        onClick={handleComplete}
        className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors"
      >
        Complete Review ✓
      </button>
    </div>
  )

  const renderContent = () => {
    switch (contentItem.type) {
      case 'practice':
        return renderPracticeSession()
      case 'explanation':
        return renderExplanation()
      case 'review':
        return renderReview()
      case 'text_explanation':
        return typeof contentItem.content === 'object' ? renderTextExplanation(contentItem.content) : renderExplanation()
      case 'interactive_example':
        return typeof contentItem.content === 'object' ? renderInteractiveExample(contentItem.content) : renderExplanation()
      case 'practice_question':
        return typeof contentItem.content === 'object' ? renderPracticeQuestion(contentItem.content) : renderExplanation()
      case 'real_world_scenario':
        return typeof contentItem.content === 'object' ? renderRealWorldScenario(contentItem.content) : renderExplanation()
      case 'teaching_strategy':
        return typeof contentItem.content === 'object' ? renderTeachingStrategy(contentItem.content) : renderExplanation()
      case 'common_misconception':
        return typeof contentItem.content === 'object' ? renderCommonMisconception(contentItem.content) : renderExplanation()
      case 'memory_technique':
        return typeof contentItem.content === 'object' ? renderMemoryTechnique(contentItem.content) : renderExplanation()
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
