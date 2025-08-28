/**
 * Fresh Practice Session Component - Clean Approach
 * Addresses: light answer choices, auto-selection, duplicates, session completion
 */
'use client';

import { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../../../lib/auth-context';
import Link from 'next/link';
import { getRandomizedAdaptiveQuestions, recordQuestionAttempt } from '@/lib/randomizedQuestions';
import type { Question, QuestionAttempt, AnswerChoice } from '@/lib/questionBank';

interface SessionState {
  questions: Question[];
  currentIndex: number;
  selectedAnswer: number | null;
  showExplanation: boolean;
  answers: number[];
  isComplete: boolean;
  sessionId: string;
}

export default function FreshPracticeSession() {
  const { user, loading } = useAuth();
  const router = useRouter();
  
  // Core session state
  const [sessionState, setSessionState] = useState<SessionState>({
    questions: [],
    currentIndex: 0,
    selectedAnswer: null,
    showExplanation: false,
    answers: [],
    isComplete: false,
    sessionId: `session_${Date.now()}_${Math.random().toString(36).substring(2)}`
  });
  
  // Loading and meta state
  const [isLoading, setIsLoading] = useState(true);
  const [userCertificationGoal, setUserCertificationGoal] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Load questions on mount
  useEffect(() => {
    async function loadFreshQuestions() {
      if (!user) return;
      
      console.log('🆕 Loading fresh questions for new session');
      setIsLoading(true);
      setError(null);
      
      try {
        // For now, use a default certification goal - can be enhanced later
        const certGoal = 'TExES Core Subjects EC-6: Mathematics (902)';
        setUserCertificationGoal(certGoal);
        
        // Load fresh questions
        const result = await getRandomizedAdaptiveQuestions(
          user.id,
          certGoal || 'TExES Core Subjects EC-6: Mathematics (902)',
          10
        );
        
        if (result.success && result.questions && result.questions.length > 0) {
          // Ensure completely fresh questions with no duplicates
          const uniqueQuestions = result.questions.filter((question, index, self) => 
            index === self.findIndex(q => q.id === question.id)
          );
          
          setSessionState(prev => ({
            ...prev,
            questions: uniqueQuestions,
            currentIndex: 0,
            selectedAnswer: null,
            showExplanation: false,
            answers: [],
            isComplete: false
          }));
          
          console.log('✅ Fresh questions loaded:', uniqueQuestions.length);
        } else {
          setError('No questions available. Please try again.');
        }
      } catch (err) {
        console.error('❌ Error loading questions:', err);
        setError('Failed to load questions. Please try again.');
      } finally {
        setIsLoading(false);
      }
    }
    
    loadFreshQuestions();
  }, [user]);

  // Reset answer state when question changes
  useEffect(() => {
    setSessionState(prev => ({
      ...prev,
      selectedAnswer: null,
      showExplanation: false
    }));
    console.log('🔄 Question changed, state reset');
  }, [sessionState.currentIndex]);

  // Handle answer selection with strict controls
  const handleAnswerSelect = useCallback((answerIndex: number) => {
    // Prevent selection if explanation is showing
    if (sessionState.showExplanation) {
      console.log('🚫 Selection blocked - explanation showing');
      return;
    }
    
    // Prevent double selection
    if (sessionState.selectedAnswer !== null) {
      console.log('🚫 Selection blocked - already selected');
      return;
    }
    
    console.log('✅ Answer selected:', answerIndex);
    setSessionState(prev => ({
      ...prev,
      selectedAnswer: answerIndex
    }));
  }, [sessionState.showExplanation, sessionState.selectedAnswer]);

  // Submit answer and show explanation
  const handleSubmitAnswer = useCallback(() => {
    if (sessionState.selectedAnswer === null) return;
    
    const currentQ = sessionState.questions[sessionState.currentIndex];
    if (!currentQ?.answer_choices) return;
    
    console.log('📝 Submitting answer:', sessionState.selectedAnswer);
    
    // Record the attempt
    if (user) {
      const isCorrect = currentQ.answer_choices[sessionState.selectedAnswer]?.is_correct || false;
      const attempt: QuestionAttempt = {
        question_id: currentQ.id,
        selected_answer_id: currentQ.answer_choices[sessionState.selectedAnswer]?.id || '',
        is_correct: isCorrect,
        time_spent_seconds: 0,
        confidence_level: 3
      };
      
      recordQuestionAttempt(user.id, sessionState.sessionId, attempt).catch((error: Error) => {
        console.warn('⚠️ Question attempt not recorded:', error.message);
      });
    }
    
    // Show explanation and record answer
    setSessionState(prev => ({
      ...prev,
      showExplanation: true,
      answers: [...prev.answers, prev.selectedAnswer!]
    }));
  }, [sessionState.selectedAnswer, sessionState.questions, sessionState.currentIndex, sessionState.sessionId, user]);

  // Move to next question or complete session
  const handleNext = useCallback(() => {
    if (sessionState.currentIndex < sessionState.questions.length - 1) {
      console.log('➡️ Moving to next question');
      setSessionState(prev => ({
        ...prev,
        currentIndex: prev.currentIndex + 1,
        selectedAnswer: null,
        showExplanation: false
      }));
    } else {
      console.log('🎯 Session complete');
      setSessionState(prev => ({
        ...prev,
        isComplete: true
      }));
    }
  }, [sessionState.currentIndex, sessionState.questions.length]);

  // Redirect if not authenticated
  useEffect(() => {
    if (!loading && !user) {
      router.push('/auth');
    }
  }, [user, loading, router]);

  // Loading state
  if (loading || isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto mb-4"></div>
          <p className="text-green-600">Loading fresh questions...</p>
        </div>
      </div>
    );
  }

  // Error state
  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50 flex items-center justify-center">
        <div className="bg-white rounded-xl p-8 shadow-lg text-center max-w-md">
          <div className="text-red-500 text-4xl mb-4">⚠️</div>
          <h2 className="text-xl font-semibold text-gray-800 mb-4">Oops!</h2>
          <p className="text-gray-600 mb-6">{error}</p>
          <button
            onClick={() => window.location.reload()}
            className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  // Session complete state
  if (sessionState.isComplete) {
    const correctCount = sessionState.answers.filter((answer, index) => {
      const question = sessionState.questions[index];
      const selectedChoice = question?.answer_choices?.[answer];
      return selectedChoice?.is_correct || false;
    }).length;
    
    const score = Math.round((correctCount / sessionState.answers.length) * 100);

    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50">
        <nav className="bg-white/80 backdrop-blur-md border-b border-green-200/50 p-4">
          <Link href="/dashboard" className="text-green-600 hover:text-green-700">
            ← Back to Dashboard
          </Link>
        </nav>
        
        <div className="container mx-auto px-6 py-12">
          <div className="max-w-2xl mx-auto text-center">
            <div className="text-6xl mb-6">🌟</div>
            <h1 className="text-4xl font-light text-green-800 mb-4">Session Complete!</h1>
            <p className="text-xl text-green-600 mb-8">Great work! You&apos;ve completed your practice session.</p>

            <div className="bg-white rounded-2xl p-8 shadow-xl mb-8">
              <h3 className="text-2xl font-semibold text-green-800 mb-6">Your Results</h3>
              
              <div className="grid grid-cols-3 gap-6 mb-6">
                <div className="text-center">
                  <div className="text-3xl font-bold text-green-600 mb-2">{score}%</div>
                  <div className="text-gray-600 text-sm">Accuracy</div>
                </div>
                <div className="text-center">
                  <div className="text-3xl font-bold text-blue-600 mb-2">{sessionState.answers.length}</div>
                  <div className="text-gray-600 text-sm">Questions</div>
                </div>
                <div className="text-center">
                  <div className="text-3xl font-bold text-orange-600 mb-2">{correctCount}</div>
                  <div className="text-gray-600 text-sm">Correct</div>
                </div>
              </div>
            </div>

            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link
                href={userCertificationGoal ? `/study-path/${encodeURIComponent(userCertificationGoal)}` : '/dashboard'}
                className="px-8 py-3 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors"
              >
                Continue Learning
              </Link>
              <Link
                href="/dashboard"
                className="px-8 py-3 border-2 border-green-600 text-green-600 rounded-xl hover:bg-green-50 transition-colors"
              >
                Dashboard
              </Link>
              <button
                onClick={() => window.location.reload()}
                className="px-6 py-3 border border-gray-300 text-gray-600 rounded-xl hover:bg-gray-50 transition-colors"
              >
                New Session
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Main practice interface
  const currentQ = sessionState.questions[sessionState.currentIndex];
  if (!currentQ) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50 flex items-center justify-center">
        <div className="text-center">
          <p className="text-green-600">No questions available.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50">
      <nav className="bg-white/80 backdrop-blur-md border-b border-green-200/50 p-4">
        <div className="flex justify-between items-center">
          <Link href="/dashboard" className="text-green-600 hover:text-green-700">
            ← Back to Dashboard
          </Link>
          <div className="text-green-600">
            Question {sessionState.currentIndex + 1} of {sessionState.questions.length}
          </div>
        </div>
      </nav>

      <div className="container mx-auto px-6 py-8">
        <div className="max-w-4xl mx-auto">
          <div className="bg-white rounded-2xl p-8 shadow-xl">
            <h2 className="text-2xl font-semibold text-gray-900 mb-6 leading-relaxed">
              {currentQ.question_text}
            </h2>

            <div className="space-y-4 mb-8">
              {currentQ.answer_choices?.map((choice: AnswerChoice, index: number) => {
                let buttonClass = "w-full p-4 text-left rounded-xl border-2 transition-all duration-200 font-medium ";
                
                if (sessionState.showExplanation) {
                  if (choice.is_correct) {
                    buttonClass += "border-green-500 bg-green-100 text-green-900 font-bold";
                  } else if (index === sessionState.selectedAnswer && !choice.is_correct) {
                    buttonClass += "border-red-500 bg-red-100 text-red-900 font-bold";
                  } else {
                    buttonClass += "border-gray-300 bg-gray-100 text-gray-700";
                  }
                } else {
                  if (index === sessionState.selectedAnswer) {
                    buttonClass += "border-green-600 bg-green-100 text-green-900 font-bold shadow-lg transform scale-[1.02]";
                  } else {
                    // MAXIMUM CONTRAST - black text on white background
                    buttonClass += "border-gray-500 bg-white text-black font-semibold hover:border-green-500 hover:bg-green-50 hover:text-green-900 shadow-md";
                  }
                }

                return (
                  <button
                    key={choice.id}
                    onClick={() => handleAnswerSelect(index)}
                    disabled={sessionState.showExplanation}
                    className={buttonClass}
                  >
                    <div className="flex items-center">
                      <span className="font-bold mr-4 text-xl">{String.fromCharCode(65 + index)}.</span>
                      <span className="text-lg leading-relaxed">{choice.choice_text}</span>
                    </div>
                  </button>
                );
              })}
            </div>

            {/* Explanation */}
            {sessionState.showExplanation && (
              <div className="bg-blue-50 rounded-xl p-6 mb-6">
                <h3 className="text-lg font-semibold text-blue-800 mb-2">Explanation</h3>
                <p className="text-blue-700">{currentQ.explanation}</p>
              </div>
            )}

            {/* Action buttons */}
            <div className="flex justify-end space-x-4">
              {!sessionState.showExplanation && sessionState.selectedAnswer !== null && (
                <button
                  onClick={handleSubmitAnswer}
                  className="px-6 py-3 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors font-medium"
                >
                  Submit Answer
                </button>
              )}
              
              {sessionState.showExplanation && (
                <button
                  onClick={handleNext}
                  className="px-6 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors font-medium"
                >
                  {sessionState.currentIndex < sessionState.questions.length - 1 ? 'Next Question' : 'Complete Session'}
                </button>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
