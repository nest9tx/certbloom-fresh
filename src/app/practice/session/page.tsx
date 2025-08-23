'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '../../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { getRandomizedAdaptiveQuestions, recordQuestionAttempt } from '@/lib/randomizedQuestions';
import type { Question, QuestionAttempt, AnswerChoice } from '@/lib/questionBank';
import MoodSelector from '@/components/MoodSelector';
import { buildAdaptiveSession, getWisdomWhisper } from '@/lib/adaptiveLearning';
import type { AdaptiveSession, WisdomWhisper } from '@/lib/adaptiveLearning';

export default function PracticeSessionPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  
  // Mood and adaptive learning state
  const [selectedMood, setSelectedMood] = useState<string | null>(null);
  const [adaptiveSession, setAdaptiveSession] = useState<AdaptiveSession | null>(null);
  const [wisdomWhisper, setWisdomWhisper] = useState<WisdomWhisper | null>(null);
  const [sessionPhase, setSessionPhase] = useState<'mood-select' | 'practice' | 'break' | 'complete'>('mood-select');
  
  // Existing state
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [selectedAnswer, setSelectedAnswer] = useState<number | null>(null);
  const [showExplanation, setShowExplanation] = useState(false);
  const [answers, setAnswers] = useState<number[]>([]);
  const [sessionComplete, setSessionComplete] = useState(false);
  const [confidence, setConfidence] = useState<number | null>(null);
  const [showBreathing, setShowBreathing] = useState(false);
  const [breathingCount, setBreathingCount] = useState(0);
  const [subscriptionStatus, setSubscriptionStatus] = useState<'active' | 'canceled' | 'free'>('free');
  const [dailySessionCount, setDailySessionCount] = useState(0);
  const [userCertificationGoal, setUserCertificationGoal] = useState<string | null>(null);
  const [availableQuestions, setAvailableQuestions] = useState<Question[]>([]);
  const [isLoadingQuestions, setIsLoadingQuestions] = useState(true);
  const [sessionId] = useState(() => `session_${Date.now()}_${Math.random().toString(36).substring(2)}`);

  // Get today's date as a string for localStorage key
  const todayKey = new Date().toDateString();

  // Get session parameters from URL
  const [sessionType, setSessionType] = useState<'quick' | 'full' | 'custom'>('full');
  const [sessionLength, setSessionLength] = useState<number>(10);

  // Parse URL parameters on mount
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const urlParams = new URLSearchParams(window.location.search);
      const type = urlParams.get('type') as 'quick' | 'full' | 'custom' | null;
      const length = urlParams.get('length');
      
      if (type) setSessionType(type);
      if (length) setSessionLength(parseInt(length));
      
      // Set defaults based on type
      if (type === 'quick') {
        setSessionLength(5);
      } else if (type === 'full') {
        setSessionLength(15);
      }
    }
  }, []);

  // Fetch subscription status and certification goal
  useEffect(() => {
    async function fetchUserData() {
      if (user) {
        const { getSubscriptionStatus } = await import('../../../lib/getSubscriptionStatus');
        const { getUserCertificationGoal } = await import('../../../lib/getUserCertificationGoal');
        
        const [status, certificationGoal] = await Promise.all([
          getSubscriptionStatus(user.id),
          getUserCertificationGoal(user.id)
        ]);
        
        setSubscriptionStatus(status);
        setUserCertificationGoal(certificationGoal);
      }
    }
    fetchUserData();
  }, [user]);

  // Track daily sessions for free users
  useEffect(() => {
    if (user && subscriptionStatus === 'free') {
      const sessionKey = `dailySessions_${user.id}_${todayKey}`;
      const storedCount = localStorage.getItem(sessionKey);
      setDailySessionCount(storedCount ? parseInt(storedCount) : 0);
    }
  }, [user, subscriptionStatus, todayKey]);

  // Load questions from database based on certification OR use adaptive session
  useEffect(() => {
    async function loadQuestions() {
      if (subscriptionStatus !== null && user && userCertificationGoal) {
        setIsLoadingQuestions(true);
        try {
          // If we have an adaptive session, we still need to get full question data
          if (adaptiveSession && adaptiveSession.review_questions.length > 0) {
            // For adaptive sessions, get questions normally but limit to session length
            const result = await getRandomizedAdaptiveQuestions(
              user.id,
              userCertificationGoal,
              Math.min(sessionLength, adaptiveSession.review_questions.length + adaptiveSession.new_questions.length)
            );
            
            if (result.success && result.questions) {
              setAvailableQuestions(result.questions);
            } else {
              console.error('Error loading adaptive session questions');
              setAvailableQuestions([]);
            }
          } else {
            // Use URL-specified session length or defaults based on subscription
            const baseLength = sessionLength || (subscriptionStatus === 'active' ? 15 : 5);
            // For free users, ALWAYS enforce 5 question limit regardless of URL params
            const effectiveLength = subscriptionStatus === 'free' ? Math.min(baseLength, 5) : baseLength;
            
            console.log('🎯 Loading questions with settings:', {
              sessionType,
              sessionLength,
              subscriptionStatus,
              baseLength,
              effectiveLength
            });
            
            const result = await getRandomizedAdaptiveQuestions(
              user.id,
              userCertificationGoal,
              effectiveLength
            );
            
            if (result.success && result.questions) {
              // For free users, double-check and slice to 5 questions max
              const finalQuestions = subscriptionStatus === 'free' 
                ? result.questions.slice(0, 5) 
                : result.questions;
              
              setAvailableQuestions(finalQuestions);
              console.log('✅ Questions loaded:', {
                requested: effectiveLength,
                received: result.questions.length,
                final: finalQuestions.length,
                subscription: subscriptionStatus
              });
            } else {
              console.error('Error loading questions');
              setAvailableQuestions([]);
            }
          }
        } catch (error) {
          console.error('Error loading questions:', error);
          setAvailableQuestions([]);
        } finally {
          setIsLoadingQuestions(false);
        }
      }
    }
    
    loadQuestions();
  }, [subscriptionStatus, userCertificationGoal, user, adaptiveSession, sessionLength, sessionType]);

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
    if (selectedAnswer === null || !currentQ?.answer_choices) return;
    
    setAnswers([...answers, selectedAnswer]);
    setShowExplanation(true);
    
    // Record the attempt in the database
    if (user) {
      const isCorrect = currentQ.answer_choices[selectedAnswer]?.is_correct || false;
      const attempt: QuestionAttempt = {
        question_id: currentQ.id,
        selected_answer_id: currentQ.answer_choices[selectedAnswer]?.id || '',
        is_correct: isCorrect,
        time_spent_seconds: 0, // We could track this later
        confidence_level: confidence || 3 // Default to 3 if not set
      };
      
      recordQuestionAttempt(user.id, sessionId, attempt).catch((error: Error) => {
        console.error('Error recording question attempt:', error);
      });
    }
  };

  const handleNextQuestion = () => {
    if (selectedAnswer === null) return;
    
    if (currentQuestion < availableQuestions.length - 1) {
      setCurrentQuestion(currentQuestion + 1);
      setSelectedAnswer(null);
      setShowExplanation(false);
      setConfidence(null);
    } else {
      // Session complete - track it for free users
      if (user && subscriptionStatus === 'free') {
        const sessionKey = `dailySessions_${user.id}_${todayKey}`;
        const newCount = dailySessionCount + 1;
        localStorage.setItem(sessionKey, newCount.toString());
        setDailySessionCount(newCount);
      }
      
      // Save session data to database
      if (user) {
        const correctCount = answers.filter((answer, index) => {
          const question = availableQuestions[index];
          const selectedChoice = question?.answer_choices?.[answer];
          return selectedChoice?.is_correct || false;
        }).length;
        
        // Save session asynchronously (don't wait for it)
        const saveSession = async () => {
          try {
            const { supabase } = await import('../../../lib/supabase');
            await supabase
              .from('practice_sessions')
              .insert([
                {
                  user_id: user.id,
                  session_id: sessionId,
                  certification_name: userCertificationGoal || 'Unknown',
                  session_type: sessionType,
                  session_length: availableQuestions.length,
                  questions_attempted: answers.length,
                  questions_correct: correctCount,
                  mood: selectedMood,
                  completed_at: new Date().toISOString()
                }
              ]);
            
            console.log('✅ Session data saved to database');
          } catch (error) {
            console.error('❌ Error saving session data:', error);
          }
        };
        
        saveSession();
      }
      
      // Signal mandala to refresh on dashboard
      localStorage.setItem('sessionCompleted', Date.now().toString());
      
      setSessionComplete(true);
    }
  };

  const getScoreColor = (score: number) => {
    if (score >= 80) return 'text-green-600';
    if (score >= 60) return 'text-yellow-600';
    return 'text-orange-600';
  };

  // Handle mood selection and build adaptive session
  const handleMoodSelect = async (mood: string) => {
    setSelectedMood(mood);
    if (user && userCertificationGoal) {
      try {
        // Use URL-specified session length or default
        const effectiveLength = sessionLength || (subscriptionStatus === 'active' ? 15 : 5);
        
        // Build adaptive session based on mood
        const session = await buildAdaptiveSession(
          user.id,
          userCertificationGoal,
          mood,
          effectiveLength
        );
        setAdaptiveSession(session);
        
        // Get mood-appropriate wisdom whisper
        const whisper = await getWisdomWhisper(mood);
        setWisdomWhisper(whisper);
        
        // Move to practice phase
        setSessionPhase('practice');
      } catch (error) {
        console.error('Error building adaptive session:', error);
        // Fallback to existing question loading
        setSessionPhase('practice');
      }
    }
  };

  if (loading || isLoadingQuestions) {
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

  // Don't render until we have questions loaded and subscription status is known
  if (availableQuestions.length === 0 && subscriptionStatus !== null) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center max-w-md">
          <div className="text-6xl mb-4">📚</div>
          <h2 className="text-2xl font-semibold text-green-800 mb-4">No Questions Available</h2>
          {userCertificationGoal ? (
            <div>
              <p className="text-green-600 mb-4">
                We couldn&apos;t find questions for <strong>{userCertificationGoal}</strong> yet.
              </p>
              <p className="text-green-500 text-sm mb-6">
                Our team is working on adding more certification-specific questions. 
                In the meantime, you can practice with our general TExES questions.
              </p>
            </div>
          ) : (
            <div>
              <p className="text-green-600 mb-4">
                Please select your certification goal to get personalized questions.
              </p>
            </div>
          )}
          <div className="space-y-4">
            <Link 
              href="/settings"
              className="block px-6 py-3 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors"
            >
              {userCertificationGoal ? 'Change Certification' : 'Select Certification'}
            </Link>
            <Link 
              href="/dashboard"
              className="block px-6 py-3 border-2 border-green-600 text-green-600 rounded-xl hover:bg-green-50 transition-colors"
            >
              Back to Dashboard
            </Link>
          </div>
        </div>
      </div>
    );
  }

  // Still loading
  if (availableQuestions.length === 0) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4 animate-pulse">🌸</div>
          <p className="text-green-600">Preparing your personalized questions...</p>
          {userCertificationGoal && (
            <p className="text-green-500 text-sm mt-2">
              Loading questions for: {userCertificationGoal}
            </p>
          )}
        </div>
      </div>
    );
  }

  // Check daily session limit for free users
  const maxDailySessions = 3;
  const hasReachedDailyLimit = subscriptionStatus === 'free' && dailySessionCount >= maxDailySessions;

  // Show daily limit reached message for free users
  if (hasReachedDailyLimit) {
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

        {/* Daily Limit Reached */}
        <div className="container mx-auto px-6 py-12">
          <div className="max-w-2xl mx-auto text-center">
            <div className="text-6xl mb-6">🌱</div>
            <h1 className="text-4xl font-light text-green-800 mb-4">Daily Practice Complete!</h1>
            <p className="text-xl text-green-600 mb-8">
              You&apos;ve completed your 3 practice sessions for today. Your mind needs time to process and grow.
            </p>

            <div className="bg-gradient-to-r from-yellow-50 to-orange-50 border border-yellow-200 rounded-xl p-8 mb-8">
              <h3 className="text-2xl font-semibold text-green-800 mb-4">🌟 Ready for More?</h3>
              <p className="text-green-600 mb-6">
                With CertBloom Pro, you can access unlimited practice sessions, advanced analytics, 
                and personalized learning paths that adapt to your progress.
              </p>
              <Link 
                href="/pricing"
                className="inline-flex items-center px-6 py-3 bg-yellow-400 text-green-900 rounded-lg hover:bg-yellow-500 transition-colors font-medium text-lg"
              >
                🚀 Upgrade to Pro
              </Link>
            </div>

            <div className="bg-blue-50 rounded-xl p-6 mb-8">
              <h4 className="text-lg font-semibold text-green-800 mb-3">Mindful Learning</h4>
              <p className="text-green-600 italic">
                &quot;Rest is not idleness, and to lie sometimes on the grass under trees on a summer&apos;s day, 
                listening to the murmur of the water, or watching the clouds float across the sky, 
                is by no means a waste of time.&quot; - John Lubbock
              </p>
            </div>

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
                Check Again Tomorrow
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  const currentQ = availableQuestions[currentQuestion];
  
  // Calculate score based on correct answers
  const score = Math.round((answers.filter((answer, index) => {
    const question = availableQuestions[index];
    const selectedChoice = question?.answer_choices?.[answer];
    return selectedChoice?.is_correct || false;
  }).length / answers.length) * 100);
  
  const isFreePlan = subscriptionStatus !== 'active';

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

              {/* Free Plan Upgrade Invitation */}
              {isFreePlan && (
                <div className="bg-gradient-to-r from-yellow-50 to-orange-50 border border-yellow-200 rounded-xl p-6 mb-6">
                  <h4 className="text-lg font-semibold text-green-800 mb-3">🌟 Continue Your Journey</h4>
                  <p className="text-green-600 mb-4">
                    You&apos;ve completed your free practice questions! To unlock unlimited questions, 
                    detailed explanations, and advanced adaptive features, consider upgrading to CertBloom Pro.
                  </p>
                  <Link 
                    href="/pricing"
                    className="inline-flex items-center px-4 py-2 bg-yellow-400 text-green-900 rounded-lg hover:bg-yellow-500 transition-colors font-medium"
                  >
                    🚀 Upgrade to Pro
                  </Link>
                </div>
              )}

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
          
          {/* Mood Selection Phase */}
          {sessionPhase === 'mood-select' && (
            <div className="bg-white/95 backdrop-blur-sm rounded-2xl p-8 border border-violet-200/60 shadow-lg mb-8">
              <MoodSelector 
                onMoodSelect={handleMoodSelect}
                selectedMood={selectedMood || undefined}
              />
            </div>
          )}

          {/* Practice Phase */}
          {sessionPhase === 'practice' && (
            <>
              {/* Wisdom Whisper */}
              {wisdomWhisper && (
                <div className="bg-gradient-to-r from-amber-50 to-orange-50 border border-amber-200 rounded-xl p-4 mb-6">
                  <div className="flex items-center space-x-3">
                    <span className="text-xl">{wisdomWhisper.icon}</span>
                    <p className="text-amber-800 italic text-sm">
                      {wisdomWhisper.message}
                    </p>
                  </div>
                </div>
              )}
              
              {/* Progress Header */}
              <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-6 border border-green-200/60 shadow-lg mb-8">
                <div className="flex items-center justify-between mb-4">
                  <h1 className="text-2xl font-semibold text-green-800">
                    {sessionType === 'quick' ? 'Quick Practice Session' : 'Adaptive Practice Session'}
                  </h1>
              <button
                onClick={() => setShowBreathing(true)}
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm"
              >
                🧘 Mindful Pause
              </button>
            </div>
            
            {/* Certification Goal Display */}
            {userCertificationGoal && (
              <div className="bg-gradient-to-r from-green-50 to-blue-50 rounded-xl p-4 mb-4">
                <div className="flex items-center space-x-3">
                  <div className="text-2xl">🎯</div>
                  <div>
                    <p className="text-sm font-medium text-green-700">Studying for:</p>
                    <p className="text-green-800 font-semibold">{userCertificationGoal}</p>
                  </div>
                </div>
              </div>
            )}
            
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-4">
                <span className="text-green-600">
                  Question {currentQuestion + 1} of {availableQuestions.length}
                  {isFreePlan && <span className="text-yellow-600 ml-2">(Free: 5 questions)</span>}
                </span>
                <div className="w-48 bg-green-200 rounded-full h-2">
                  <div 
                    className="bg-gradient-to-r from-green-500 to-green-600 h-2 rounded-full transition-all duration-300"
                    style={{ width: `${((currentQuestion + 1) / availableQuestions.length) * 100}%` }}
                  ></div>
                </div>
              </div>
              <div className="text-sm text-green-600">
                Topic: <span className="font-medium">{currentQ.topic?.name || 'General'}</span>
              </div>
            </div>
          </div>

          {/* Question Card */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl mb-8">
            <div className="mb-6">
              <div className="flex items-center justify-between mb-4">
                <span className="bg-green-100 text-green-700 px-3 py-1 rounded-full text-sm font-medium">
                  {currentQ.difficulty_level.charAt(0).toUpperCase() + currentQ.difficulty_level.slice(1)}
                </span>
                <span className="text-green-600 text-sm">{currentQ.topic?.name || 'General'}</span>
              </div>
              
              <h2 className="text-xl text-gray-800 font-medium leading-relaxed">
                {currentQ.question_text}
              </h2>
            </div>

            {/* Answer Options */}
            <div className="space-y-3 mb-6">
              {currentQ.answer_choices?.map((choice: AnswerChoice, index: number) => {
                let buttonClass = "w-full p-4 text-left rounded-xl border-2 transition-all duration-200 ";
                
                if (showExplanation) {
                  if (choice.is_correct) {
                    buttonClass += "border-green-500 bg-green-50 text-green-800";
                  } else if (index === selectedAnswer && !choice.is_correct) {
                    buttonClass += "border-red-500 bg-red-50 text-red-800";
                  } else {
                    buttonClass += "border-gray-300 bg-gray-50 text-gray-600";
                  }
                } else {
                  if (index === selectedAnswer) {
                    buttonClass += "border-green-500 bg-green-50 text-green-800 transform scale-[1.02]";
                  } else {
                    buttonClass += "border-green-200/60 hover:border-green-400 hover:bg-green-50 text-gray-800 hover:text-green-800";
                  }
                }

                return (
                  <button
                    key={choice.id}
                    onClick={() => handleAnswerSelect(index)}
                    disabled={showExplanation}
                    className={buttonClass}
                  >
                    <span className="font-medium mr-3">{String.fromCharCode(65 + index)}.</span>
                    {choice.choice_text}
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
                  {currentQuestion < availableQuestions.length - 1 ? 'Next Question' : 'Complete Session'} →
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
            </>
          )}
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
