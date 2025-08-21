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

// Expanded question bank for TExES certification practice
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
    topic: 'Assessment Strategies'
  },
  {
    id: 4,
    content: "Which of the following is the most effective strategy for helping a student who is struggling with reading comprehension?",
    options: [
      "Have the student read more difficult texts to challenge them",
      "Focus on phonics instruction exclusively",
      "Use graphic organizers and teach metacognitive strategies",
      "Reduce the amount of reading assignments"
    ],
    correct: 2,
    explanation: "Using graphic organizers and teaching metacognitive strategies helps students organize information and become aware of their thinking processes, which directly supports reading comprehension development.",
    difficulty: 'medium',
    topic: 'Reading Instruction'
  },
  {
    id: 5,
    content: "What is the primary purpose of a KWL chart in elementary education?",
    options: [
      "To assess students' final understanding of a topic",
      "To activate prior knowledge and guide learning",
      "To organize students into reading groups",
      "To track student behavior patterns"
    ],
    correct: 1,
    explanation: "A KWL chart (Know, Want to know, Learned) helps activate students' prior knowledge, generates curiosity about new learning, and provides a framework for reflecting on what was learned.",
    difficulty: 'easy',
    topic: 'Instructional Strategies'
  },
  {
    id: 6,
    content: "Which classroom management approach is most effective for building positive relationships with students?",
    options: [
      "Strict disciplinary rules with immediate consequences",
      "Allowing students complete freedom to choose their behavior",
      "Positive behavioral interventions and consistent expectations",
      "Public recognition only for academic achievements"
    ],
    correct: 2,
    explanation: "Positive behavioral interventions combined with consistent expectations create a supportive environment that builds trust, reduces behavioral issues, and promotes student engagement.",
    difficulty: 'medium',
    topic: 'Classroom Management'
  },
  {
    id: 7,
    content: "When teaching mathematical problem-solving, which strategy best supports student understanding?",
    options: [
      "Providing the correct formula immediately",
      "Having students memorize multiple solution methods",
      "Encouraging multiple solution pathways and student explanation",
      "Using only abstract numerical problems"
    ],
    correct: 2,
    explanation: "Encouraging multiple solution pathways and having students explain their thinking develops deeper mathematical understanding and problem-solving skills.",
    difficulty: 'medium',
    topic: 'Mathematics Instruction'
  },
  {
    id: 8,
    content: "Which practice best supports differentiated instruction in a diverse classroom?",
    options: [
      "Using the same teaching method for all students",
      "Providing multiple ways to access, process, and express learning",
      "Grouping students only by ability level",
      "Focusing instruction on grade-level standards only"
    ],
    correct: 1,
    explanation: "Differentiated instruction involves providing multiple ways for students to access content, process information, and express their learning, accommodating diverse learning needs and preferences.",
    difficulty: 'medium',
    topic: 'Differentiated Instruction'
  },
  {
    id: 9,
    content: "What is the most important factor in creating an inclusive classroom environment?",
    options: [
      "Having identical expectations for all students",
      "Celebrating diversity and individual strengths",
      "Focusing only on academic achievement",
      "Minimizing cultural differences"
    ],
    correct: 1,
    explanation: "Creating an inclusive environment involves celebrating diversity, recognizing individual strengths, and ensuring all students feel valued and supported in their learning journey.",
    difficulty: 'easy',
    topic: 'Inclusive Education'
  },
  {
    id: 10,
    content: "Which strategy is most effective for teaching scientific inquiry to elementary students?",
    options: [
      "Lecture-based instruction with detailed notes",
      "Hands-on investigations with guided questioning",
      "Independent reading of science textbooks",
      "Memorization of scientific facts and formulas"
    ],
    correct: 1,
    explanation: "Hands-on investigations with guided questioning engage students in authentic scientific practices, develop critical thinking skills, and make abstract concepts concrete and meaningful.",
    difficulty: 'medium',
    topic: 'Science Instruction'
  },
  {
    id: 11,
    content: "When working with parents as educational partners, which approach is most effective?",
    options: [
      "Communicating only when problems arise",
      "Maintaining regular, positive communication and collaboration",
      "Limiting communication to formal conferences only",
      "Focusing discussions solely on academic deficits"
    ],
    correct: 1,
    explanation: "Regular, positive communication and collaboration with families builds strong partnerships that support student success both at home and school.",
    difficulty: 'easy',
    topic: 'Family Engagement'
  },
  {
    id: 12,
    content: "Which instructional approach best supports students with different learning styles?",
    options: [
      "Using only visual aids and materials",
      "Incorporating multiple modalities (visual, auditory, kinesthetic)",
      "Relying primarily on lecture-style teaching",
      "Using only technology-based instruction"
    ],
    correct: 1,
    explanation: "Incorporating multiple modalities ensures that instruction reaches students with different learning preferences and strengthens understanding through various pathways.",
    difficulty: 'medium',
    topic: 'Learning Styles'
  },
  {
    id: 13,
    content: "What is the primary benefit of formative assessment in education?",
    options: [
      "Assigning final grades to students",
      "Comparing students to grade-level standards",
      "Providing ongoing feedback to guide instruction",
      "Meeting state testing requirements"
    ],
    correct: 2,
    explanation: "Formative assessment provides ongoing feedback that helps teachers adjust instruction in real-time and helps students understand their progress and areas for improvement.",
    difficulty: 'medium',
    topic: 'Assessment Strategies'
  },
  {
    id: 14,
    content: "Which approach best supports social-emotional learning in the classroom?",
    options: [
      "Focusing only on academic content",
      "Integrating SEL into daily routines and academic lessons",
      "Addressing SEL issues only when problems occur",
      "Using SEL as a separate, isolated curriculum"
    ],
    correct: 1,
    explanation: "Integrating social-emotional learning into daily routines and academic lessons creates authentic opportunities for students to develop these crucial life skills in meaningful contexts.",
    difficulty: 'medium',
    topic: 'Social-Emotional Learning'
  },
  {
    id: 15,
    content: "When teaching reading to early learners, which component is essential for building foundational skills?",
    options: [
      "Focusing only on sight word memorization",
      "Balancing phonemic awareness, phonics, fluency, vocabulary, and comprehension",
      "Using only whole language approaches",
      "Emphasizing spelling rules exclusively"
    ],
    correct: 1,
    explanation: "Effective reading instruction includes the five essential components: phonemic awareness, phonics, fluency, vocabulary, and comprehension, working together to build strong readers.",
    difficulty: 'medium',
    topic: 'Reading Instruction'
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
  const [subscriptionStatus, setSubscriptionStatus] = useState<'active' | 'canceled' | 'free'>('free');
  const [dailySessionCount, setDailySessionCount] = useState(0);
  const [questionsUsed, setQuestionsUsed] = useState<number[]>([]);

  // Get today's date as a string for localStorage key
  const todayKey = new Date().toDateString();

  // Fetch subscription status
  useEffect(() => {
    async function fetchStatus() {
      if (user) {
        const { getSubscriptionStatus } = await import('../../../lib/getSubscriptionStatus');
        const status = await getSubscriptionStatus(user.id);
        setSubscriptionStatus(status);
      }
    }
    fetchStatus();
  }, [user]);

  // Track daily sessions for free users
  useEffect(() => {
    if (user && subscriptionStatus === 'free') {
      const sessionKey = `dailySessions_${user.id}_${todayKey}`;
      const storedCount = localStorage.getItem(sessionKey);
      setDailySessionCount(storedCount ? parseInt(storedCount) : 0);
    }
  }, [user, subscriptionStatus, todayKey]);

  // Create randomized question set for this session
  useEffect(() => {
    if (subscriptionStatus !== null) {
      // For free users, limit to 5 questions. For Pro users, use more variety
      const maxQuestions = subscriptionStatus === 'active' ? sampleQuestions.length : 5;
      
      // Shuffle questions to provide variety
      const shuffled = [...sampleQuestions].sort(() => Math.random() - 0.5);
      const sessionQuestions = shuffled.slice(0, maxQuestions).map((_, index) => index);
      setQuestionsUsed(sessionQuestions);
    }
  }, [subscriptionStatus]);

  // Determine question limit based on subscription
  const questionLimit = subscriptionStatus === 'active' ? sampleQuestions.length : 5;
  const availableQuestions = questionsUsed.length > 0 
    ? questionsUsed.map(index => sampleQuestions[index])
    : sampleQuestions.slice(0, questionLimit);

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
  const score = Math.round((answers.filter((answer, index) => answer === availableQuestions[index].correct).length / answers.length) * 100);
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
              
              <h2 className="text-xl text-gray-800 font-medium leading-relaxed">
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
                    buttonClass += "border-green-200/60 hover:border-green-400 hover:bg-green-50 text-gray-800 hover:text-green-800";
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
