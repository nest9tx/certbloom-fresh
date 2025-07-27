'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '../../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';

interface Question {
  id: number;
  content: string;
  options: string[];
  correct: number;
  explanation: string;
  difficulty: 'easy' | 'medium' | 'hard';
  topic: string;
}

// Sample adaptive questions
const sampleQuestions: Question[] = [
  {
    id: 1,
    content: "According to Piaget's theory of cognitive development, during which stage do children develop the ability to think logically about concrete objects?",
    options: [
      "Sensorimotor stage",
      "Preoperational stage", 
      "Concrete operational stage",
      "Formal operational stage"
    ],
    correct: 2,
    explanation: "The concrete operational stage (ages 7-11) is when children develop logical thinking about concrete objects and situations.",
    difficulty: 'medium',
    topic: 'Child Development'
  },
  {
    id: 2,
    content: "What is the most effective strategy for supporting English Language Learners in a mainstream classroom?",
    options: [
      "Speak more slowly and loudly",
      "Use visual aids and scaffolding techniques",
      "Separate them from English-speaking students",
      "Only use their native language"
    ],
    correct: 1,
    explanation: "Visual aids and scaffolding techniques help ELLs understand content while developing English proficiency.",
    difficulty: 'medium',
    topic: 'English Language Learners'
  },
  {
    id: 3,
    content: "Which assessment type is most appropriate for measuring student growth over time?",
    options: [
      "Summative assessment only",
      "Formative assessment only",
      "Combination of formative and summative assessments",
      "Standardized tests only"
    ],
    correct: 2,
    explanation: "A combination allows for ongoing feedback (formative) and final evaluation (summative) to track growth.",
    difficulty: 'easy',
    topic: 'Assessment'
  }
];

export default function PracticeSessionPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [selectedAnswer, setSelectedAnswer] = useState<number | null>(null);
  const [showExplanation, setShowExplanation] = useState(false);
  const [answers, setAnswers] = useState<number[]>([]);
  const [sessionComplete, setSessionComplete] = useState(false);
  const [confidence, setConfidence] = useState<number | null>(null);
  const [showBreathing, setShowBreathing] = useState(false);
  const [breathingCount, setBreathingCount] = useState(0);

  useEffect(() => {
    if (!loading && !user) {
      router.push('/auth');
    }
  }, [user, loading, router]);

  const handleAnswerSelect = (answerIndex: number) => {
    if (showExplanation) return;
    setSelectedAnswer(answerIndex);
  };

  const handleSubmitAnswer = () => {
    if (selectedAnswer === null) return;
    
    setAnswers([...answers, selectedAnswer]);
    setShowExplanation(true);
  };

  const handleNextQuestion = () => {
    if (currentQuestion < sampleQuestions.length - 1) {
      setCurrentQuestion(currentQuestion + 1);
      setSelectedAnswer(null);
      setShowExplanation(false);
      setConfidence(null);
    } else {
      setSessionComplete(true);
    }
  };

  const getScoreColor = (score: number) => {
    if (score >= 80) return 'text-green-600';
    if (score >= 60) return 'text-yellow-600';
    return 'text-orange-600';
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4 animate-pulse">🌸</div>
          <p className="text-green-600">Loading your practice session...</p>
        </div>
      </div>
    );
  }

  if (!user) return null;

  const currentQ = sampleQuestions[currentQuestion];
  const score = Math.round((answers.filter((answer, index) => answer === sampleQuestions[index].correct).length / answers.length) * 100);

  if (sessionComplete) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50">
        {/* Navigation */}
        <nav className="relative z-10 bg-white/80 backdrop-blur-md border-b border-green-200/50">
          <div className="max-w-7xl mx-auto flex items-center justify-between p-6">
            <Link href="/" className="flex items-center space-x-3 group">
              <div className="w-10 h-10 transition-transform group-hover:scale-105">
                <Image src="/certbloom-logo.svg" alt="CertBloom" width={40} height={40} className="w-full h-full object-contain" />
              </div>
              <div className="text-2xl font-light text-green-800 tracking-wide">CertBloom</div>
            </Link>
            <Link href="/dashboard" className="text-green-600 hover:text-green-700 font-medium">
              ← Back to Dashboard
            </Link>
          </div>
        </nav>

        {/* Session Complete */}
        <div className="container mx-auto px-6 py-12">
          <div className="max-w-2xl mx-auto text-center">
            <div className="text-6xl mb-6">🌟</div>
            <h1 className="text-4xl font-light text-green-800 mb-4">Session Complete!</h1>
            <p className="text-xl text-green-600 mb-8">
              Beautiful work! You&apos;ve completed your adaptive practice session.
            </p>

            {/* Results */}
            <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl mb-8">
              <h3 className="text-2xl font-semibold text-green-800 mb-6">Your Results</h3>
              
              <div className="grid grid-cols-3 gap-6 mb-6">
                <div className="text-center">
                  <div className={`text-3xl font-bold mb-2 ${getScoreColor(score)}`}>{score}%</div>
                  <div className="text-green-600 text-sm">Accuracy</div>
                </div>
                <div className="text-center">
                  <div className="text-3xl font-bold text-blue-600 mb-2">{answers.length}</div>
                  <div className="text-green-600 text-sm">Questions</div>
                </div>
                <div className="text-center">
                  <div className="text-3xl font-bold text-orange-600 mb-2">~5</div>
                  <div className="text-green-600 text-sm">Minutes</div>
                </div>
              </div>

              {/* Adaptive Insights */}
              <div className="bg-green-50 rounded-xl p-6 mb-6">
                <h4 className="text-lg font-semibold text-green-800 mb-3">Adaptive Insights</h4>
                <div className="text-left space-y-2">
                  <p className="text-green-600">🎯 <strong>Strength:</strong> Child Development concepts</p>
                  <p className="text-green-600">📚 <strong>Focus Area:</strong> Assessment strategies</p>
                  <p className="text-green-600">🌱 <strong>Next Session:</strong> We&apos;ll emphasize assessment and add more scaffolding</p>
                </div>
              </div>

              {/* Mindful Reflection */}
              <div className="bg-blue-50 rounded-xl p-6">
                <h4 className="text-lg font-semibold text-green-800 mb-3">Mindful Reflection</h4>
                <p className="text-green-600 italic">
                  &quot;Learning is a journey, not a destination. Each question you engaged with today 
                  has planted seeds of knowledge that will bloom into wisdom.&quot;
                </p>
              </div>
            </div>

            {/* Next Steps */}
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link
                href="/dashboard"
                className="px-8 py-3 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105"
              >
                Return to Dashboard
              </Link>
              <button
                onClick={() => window.location.reload()}
                className="px-8 py-3 border-2 border-green-600 text-green-600 rounded-xl hover:bg-green-50 transition-all duration-200 shadow-lg hover:shadow-xl"
              >
                Another Session
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50">
      {/* Navigation */}
      <nav className="relative z-10 bg-white/80 backdrop-blur-md border-b border-green-200/50">
        <div className="max-w-7xl mx-auto flex items-center justify-between p-6">
          <Link href="/" className="flex items-center space-x-3 group">
            <div className="w-10 h-10 transition-transform group-hover:scale-105">
              <Image src="/certbloom-logo.svg" alt="CertBloom" width={40} height={40} className="w-full h-full object-contain" />
            </div>
            <div className="text-2xl font-light text-green-800 tracking-wide">CertBloom</div>
          </Link>
          <Link href="/dashboard" className="text-green-600 hover:text-green-700 font-medium">
            ← Back to Dashboard
          </Link>
        </div>
      </nav>

      {/* Main Content */}
      <div className="container mx-auto px-6 py-8">
        <div className="max-w-4xl mx-auto">
          
          {/* Progress Header */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-6 border border-green-200/60 shadow-lg mb-8">
            <div className="flex items-center justify-between mb-4">
              <h1 className="text-2xl font-semibold text-green-800">Adaptive Practice Session</h1>
              <button
                onClick={() => setShowBreathing(true)}
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm"
              >
                🧘 Mindful Pause
              </button>
            </div>
            
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-4">
                <span className="text-green-600">Question {currentQuestion + 1} of {sampleQuestions.length}</span>
                <div className="w-48 bg-green-200 rounded-full h-2">
                  <div 
                    className="bg-gradient-to-r from-green-500 to-green-600 h-2 rounded-full transition-all duration-300"
                    style={{ width: `${((currentQuestion + 1) / sampleQuestions.length) * 100}%` }}
                  ></div>
                </div>
              </div>
              <div className="text-sm text-green-600">
                Topic: <span className="font-medium">{currentQ.topic}</span>
              </div>
            </div>
          </div>

          {/* Question Card */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl mb-8">
            <div className="mb-6">
              <div className="flex items-center justify-between mb-4">
                <span className="bg-green-100 text-green-700 px-3 py-1 rounded-full text-sm font-medium">
                  {currentQ.difficulty.charAt(0).toUpperCase() + currentQ.difficulty.slice(1)}
                </span>
                <span className="text-green-600 text-sm">{currentQ.topic}</span>
              </div>
              
              <h2 className="text-xl text-green-800 leading-relaxed">
                {currentQ.content}
              </h2>
            </div>

            {/* Answer Options */}
            <div className="space-y-3 mb-6">
              {currentQ.options.map((option, index) => {
                let buttonClass = "w-full p-4 text-left rounded-xl border-2 transition-all duration-200 ";
                
                if (showExplanation) {
                  if (index === currentQ.correct) {
                    buttonClass += "border-green-500 bg-green-50 text-green-800";
                  } else if (index === selectedAnswer && index !== currentQ.correct) {
                    buttonClass += "border-red-500 bg-red-50 text-red-800";
                  } else {
                    buttonClass += "border-gray-300 bg-gray-50 text-gray-600";
                  }
                } else {
                  if (index === selectedAnswer) {
                    buttonClass += "border-green-500 bg-green-50 text-green-800 transform scale-[1.02]";
                  } else {
                    buttonClass += "border-green-200/60 hover:border-green-400 hover:bg-green-50";
                  }
                }

                return (
                  <button
                    key={index}
                    onClick={() => handleAnswerSelect(index)}
                    disabled={showExplanation}
                    className={buttonClass}
                  >
                    <span className="font-medium mr-3">{String.fromCharCode(65 + index)}.</span>
                    {option}
                  </button>
                );
              })}
            </div>

            {/* Explanation */}
            {showExplanation && (
              <div className="bg-blue-50 rounded-xl p-6 mb-6">
                <h3 className="text-lg font-semibold text-green-800 mb-2">Explanation</h3>
                <p className="text-green-600">{currentQ.explanation}</p>
              </div>
            )}

            {/* Confidence Check */}
            {showExplanation && confidence === null && (
              <div className="bg-orange-50 rounded-xl p-6 mb-6">
                <h3 className="text-lg font-semibold text-green-800 mb-3">How confident were you in your answer?</h3>
                <div className="flex space-x-3">
                  {[1, 2, 3, 4, 5].map((level) => (
                    <button
                      key={level}
                      onClick={() => setConfidence(level)}
                      className="px-4 py-2 bg-white border-2 border-orange-200 rounded-lg hover:border-orange-400 hover:bg-orange-50 transition-all"
                    >
                      {level}
                    </button>
                  ))}
                </div>
                <p className="text-orange-600 text-sm mt-2">1 = Not confident, 5 = Very confident</p>
              </div>
            )}

            {/* Action Buttons */}
            <div className="flex justify-center">
              {!showExplanation ? (
                <button
                  onClick={handleSubmitAnswer}
                  disabled={selectedAnswer === null}
                  className="px-8 py-3 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Submit Answer
                </button>
              ) : (
                <button
                  onClick={handleNextQuestion}
                  disabled={confidence === null}
                  className="px-8 py-3 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {currentQuestion < sampleQuestions.length - 1 ? 'Next Question' : 'Complete Session'} →
                </button>
              )}
            </div>
          </div>

          {/* Adaptive Tip */}
          <div className="bg-gradient-to-r from-green-100 to-blue-100 rounded-2xl p-6 border border-green-200/60 shadow-lg text-center">
            <div className="text-3xl mb-3">💡</div>
            <h3 className="text-lg font-semibold text-green-800 mb-2">Adaptive Learning Tip</h3>
            <p className="text-green-600">
              Notice how each question builds on your responses? Our algorithm adapts to help you learn more effectively 
              by focusing on areas where you need the most support.
            </p>
          </div>
        </div>
      </div>

      {/* Breathing Exercise Modal */}
      {showBreathing && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-6">
          <div className="bg-white rounded-2xl p-8 max-w-md w-full shadow-2xl">
            <div className="text-center">
              <div className="text-6xl mb-6 animate-pulse">🌸</div>
              <h3 className="text-2xl font-semibold text-green-800 mb-4">Mindful Breathing</h3>
              <p className="text-green-600 mb-6">
                Take a moment to reset your mind before continuing.
              </p>
              
              <div className="text-4xl font-bold text-blue-600 mb-6">{breathingCount}/3</div>
              
              <div className="space-y-4">
                <button
                  onClick={() => setBreathingCount(prev => Math.min(prev + 1, 3))}
                  className="w-full py-3 bg-blue-500 text-white rounded-xl hover:bg-blue-600 transition-colors"
                >
                  Breathe In... Hold... Breathe Out
                </button>
                
                {breathingCount >= 3 && (
                  <div className="text-green-600 font-medium">Perfect! You&apos;re refreshed and ready to continue.</div>
                )}
                
                <button
                  onClick={() => {
                    setShowBreathing(false);
                    setBreathingCount(0);
                  }}
                  className="w-full py-2 text-green-600 hover:text-green-700 transition-colors"
                >
                  Continue Learning
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
