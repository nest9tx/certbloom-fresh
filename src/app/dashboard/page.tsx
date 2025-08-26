'use client';

import { useAuth } from '../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import LearningMandala from '../../components/LearningMandala';
import IntuitiveGuidance from '../../components/IntuitiveGuidance';
import { DashboardData } from '../../lib/getDashboardData';

export default function DashboardPage() {
  const { user, loading, signOut } = useAuth();
  const router = useRouter();
  const [isSigningOut, setIsSigningOut] = useState(false);
  const [currentMood, setCurrentMood] = useState<string>('');
  const [showBreathing, setShowBreathing] = useState(false);
  const [breathingCount, setBreathingCount] = useState(0);
  const [subscriptionStatus, setSubscriptionStatus] = useState<'active' | 'canceled' | 'free'>('free');
  const [userCertificationGoal, setUserCertificationGoal] = useState<string | null>(null);
  const [showSuccessMessage, setShowSuccessMessage] = useState(false);
  const [structuredLearningPath, setStructuredLearningPath] = useState<{
    hasStructuredPath: boolean;
    certificationName?: string;
    certificationId?: string;
  }>({ hasStructuredPath: false });
  
  // Real dashboard data
  const [dashboardData, setDashboardData] = useState<DashboardData>({
    stats: {
      total_sessions: 0,
      total_questions: 0, 
      total_correct: 0,
      accuracy: 0,
      wellness_score: 50
    },
    progress: []
  });
  const [isLoadingDashboard, setIsLoadingDashboard] = useState(true);

  // Helper function to determine session time for wisdom whispers
  const getCurrentSessionTime = (): 'morning' | 'afternoon' | 'evening' => {
    const hour = new Date().getHours();
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  };

  // Check for success parameter from URL (client-side only)
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const urlParams = new URLSearchParams(window.location.search);
      const success = urlParams.get('success');
      if (success === 'true') {
        setShowSuccessMessage(true);
        // Remove the success parameter from URL
        const newUrl = window.location.pathname;
        router.replace(newUrl);
        // Hide success message after 5 seconds
        setTimeout(() => setShowSuccessMessage(false), 5000);
      }
    }
  }, [router]);

  // Fetch subscription status from Supabase
  useEffect(() => {
    async function fetchUserData() {
      if (user) {
        setIsLoadingDashboard(true);
        
        const { getSubscriptionStatus } = await import('../../lib/getSubscriptionStatus');
        const { getUserCertificationGoal } = await import('../../lib/getUserCertificationGoal');
        const { getDashboardData } = await import('../../lib/getDashboardData');
        const { getUserPrimaryLearningPath } = await import('../../lib/learningPathBridge');
        
        const [status, certificationGoal, dashboardStats, learningPath] = await Promise.all([
          getSubscriptionStatus(user.id),
          getUserCertificationGoal(user.id),
          getDashboardData(user.id),
          getUserPrimaryLearningPath(user.id)
        ]);
        
        console.log('📋 Fetched user data:', { status, certificationGoal, dashboardStats, learningPath });
        setSubscriptionStatus(status);
        setUserCertificationGoal(certificationGoal);
        
        // Store structured learning path info
        setStructuredLearningPath(learningPath);
        
        // If user has structured learning available, gently guide them there
        if (learningPath.hasStructuredPath) {
          console.log('🌸 User has structured learning path available:', learningPath.certificationName);
        }
        
        if (dashboardStats) {
          setDashboardData(dashboardStats);
        }
        
        setIsLoadingDashboard(false);
        
        // If user doesn't have a certification goal, check for pending one and restore it
        if (!certificationGoal) {
          console.log('⚠️ User has no certification goal, checking for backup...');
          
          const pendingCertification = localStorage.getItem('pendingCertification') || localStorage.getItem('selectedCertification');
          
          if (pendingCertification) {
            console.log('🔄 Found pending certification, restoring:', pendingCertification);
            try {
              const { updateUserCertificationGoal } = await import('../../lib/updateUserCertificationGoal');
              const result = await updateUserCertificationGoal(user.id, pendingCertification);
              
              if (result.success) {
                setUserCertificationGoal(pendingCertification);
                localStorage.removeItem('pendingCertification');
                localStorage.removeItem('selectedCertification');
                console.log('✅ Certification goal restored successfully');
              } else {
                console.error('❌ Failed to restore certification goal:', result.error);
              }
            } catch (err) {
              console.error('❌ Exception restoring certification goal:', err);
            }
          } else {
            console.log('💡 No pending certification found, user should select one');
          }
        }
      }
    }
    fetchUserData();
  }, [user]);

  // Add a focus listener to refresh data when user returns to the dashboard
  useEffect(() => {
    const handleFocus = async () => {
      if (user) {
        console.log('🔄 Dashboard focused, refreshing data...');
        const { getUserCertificationGoal } = await import('../../lib/getUserCertificationGoal');
        const { getSubscriptionStatus } = await import('../../lib/getSubscriptionStatus');
        const { getDashboardData } = await import('../../lib/getDashboardData');
        
        const [certificationGoal, status, dashboardStats] = await Promise.all([
          getUserCertificationGoal(user.id),
          getSubscriptionStatus(user.id),
          getDashboardData(user.id)
        ]);
        
        console.log('📋 Refreshed data:', { certificationGoal, status, dashboardStats });
        setUserCertificationGoal(certificationGoal);
        setSubscriptionStatus(status);
        
        if (dashboardStats) {
          setDashboardData(dashboardStats);
        }
      }
    };

    const handleVisibilityChange = async () => {
      if (!document.hidden && user) {
        console.log('🔄 Page visible, refreshing data...');
        const { getUserCertificationGoal } = await import('../../lib/getUserCertificationGoal');
        const { getSubscriptionStatus } = await import('../../lib/getSubscriptionStatus');
        const { getDashboardData } = await import('../../lib/getDashboardData');
        
        const [certificationGoal, status, dashboardStats] = await Promise.all([
          getUserCertificationGoal(user.id),
          getSubscriptionStatus(user.id),
          getDashboardData(user.id)
        ]);
        
        console.log('📋 Refreshed data:', { certificationGoal, status, dashboardStats });
        setUserCertificationGoal(certificationGoal);
        setSubscriptionStatus(status);
        
        if (dashboardStats) {
          setDashboardData(dashboardStats);
        }
      }
    };

    // Also listen for storage events (in case of multiple tabs)
    const handleStorageChange = async (e: StorageEvent) => {
      if (e.key === 'certificationUpdated' && user) {
        console.log('🔄 Storage event detected, refreshing certification goal...');
        const { getUserCertificationGoal } = await import('../../lib/getUserCertificationGoal');
        const certificationGoal = await getUserCertificationGoal(user.id);
        setUserCertificationGoal(certificationGoal);
        // Clear the storage flag
        localStorage.removeItem('certificationUpdated');
      }
    };

    window.addEventListener('focus', handleFocus);
    document.addEventListener('visibilitychange', handleVisibilityChange);
    window.addEventListener('storage', handleStorageChange);
    
    return () => {
      window.removeEventListener('focus', handleFocus);
      document.removeEventListener('visibilitychange', handleVisibilityChange);
      window.removeEventListener('storage', handleStorageChange);
    };
  }, [user]);

  const moodOptions = [
    { emoji: '😊', label: 'Energized', value: 'energized' },
    { emoji: '😌', label: 'Calm', value: 'calm' },
    { emoji: '😴', label: 'Tired', value: 'tired' },
    { emoji: '😰', label: 'Anxious', value: 'anxious' },
    { emoji: '🤔', label: 'Focused', value: 'focused' }
  ];

  useEffect(() => {
    if (!loading && !user) {
      console.log('🔐 No user found, redirecting to auth');
      router.push('/auth');
    }
  }, [user, loading, router]);

  const handleSignOut = async () => {
    setIsSigningOut(true);
    console.log('🚪 Starting sign out from dashboard...');
    
    try {
      await signOut();
      console.log('✅ Sign out completed, redirecting to home');
      router.push('/');
    } catch (error) {
      console.error('❌ Sign out error:', error);
    } finally {
      setIsSigningOut(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4 animate-pulse">🌸</div>
          <p className="text-green-600">Loading your learning journey...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return null; // Will redirect in useEffect
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 relative">
      {/* Subtle Background Elements - Contained */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-20 left-10 animate-pulse text-green-300 opacity-10 text-2xl">🌸</div>
        <div className="absolute bottom-32 left-1/4 animate-pulse text-yellow-300 opacity-10 text-3xl" style={{animationDelay: '2s'}}>✨</div>
      </div>

      {/* Navigation */}
      <nav className="relative z-10 bg-white/80 backdrop-blur-md border-b border-green-200/50">
        <div className="max-w-7xl mx-auto flex items-center justify-between p-6">
          <Link href="/" className="flex items-center space-x-3 group">
            <div className="w-10 h-10 transition-transform group-hover:scale-105">
              <Image src="/certbloom-logo.svg" alt="CertBloom" width={40} height={40} className="w-full h-full object-contain" />
            </div>
            <div className="text-2xl font-light text-green-800 tracking-wide">CertBloom</div>
          </Link>
          <div className="hidden md:flex items-center space-x-8">
            <Link href="/" className="text-green-700 hover:text-green-900 transition-colors font-medium">Home</Link>
            <Link href="/pricing" className="text-green-700 hover:text-green-900 transition-colors font-medium">Pricing</Link>
            <Link href="/settings" className="text-green-700 hover:text-green-900 transition-colors font-medium">Settings</Link>
            <Link href="/about" className="text-green-700 hover:text-green-900 transition-colors font-medium">About</Link>
            <Link href="/contact" className="text-green-700 hover:text-green-900 transition-colors font-medium">Contact</Link>
            <span className="text-green-600 font-medium text-sm">Welcome, {user.user_metadata?.full_name || user.email?.split('@')[0] || 'Learner'}!</span>
            <button
              onClick={handleSignOut}
              disabled={isSigningOut}
              className="px-6 py-2 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 disabled:opacity-50"
            >
              {isSigningOut ? 'Signing Out...' : 'Sign Out'}
            </button>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <div className="relative z-10 container mx-auto px-6 py-8">
        {/* Success Message */}
        {showSuccessMessage && (
          <div className="fixed top-4 right-4 bg-green-600 text-white px-6 py-3 rounded-lg shadow-lg z-50 animate-pulse">
            🎉 Upgrade successful! Welcome to CertBloom Pro!
          </div>
        )}
        
        {/* Subscription Badge/Button */}
        <div className="flex justify-end mb-4">
          {subscriptionStatus === 'active' ? (
            <span className="inline-flex items-center px-4 py-2 bg-green-600 text-white rounded-full text-sm font-semibold shadow-lg">
              <span className="mr-2">🌟</span> Upgraded: Full Access
            </span>
          ) : (
            <Link 
              href="/pricing"
              className="inline-flex items-center px-4 py-2 bg-yellow-400 text-green-900 rounded-full text-sm font-semibold shadow-lg hover:bg-yellow-500 transition-colors"
            >
              <span className="mr-2">🔒</span> Upgrade for Full Access
            </Link>
          )}
        </div>
        <div className="max-w-7xl mx-auto">
          
          {/* Personalized Welcome & Mood Check */}
          <div className="mb-12">
            <div className="text-center mb-8">
              <h1 className="text-4xl lg:text-5xl font-light text-green-800 mb-4">
                Your Learning Hub
              </h1>
              <p className="text-xl text-green-600 max-w-2xl mx-auto">
                Every step forward is a victory. Let&apos;s continue your journey with intention and grace.
              </p>
            </div>

            {/* Mood Check-in Card */}
            <div className="max-w-2xl mx-auto mb-8">
              <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
                <div className="text-center">
                  <div className="text-4xl mb-4">🌸</div>
                  <h3 className="text-2xl font-semibold text-green-800 mb-4">How are you feeling today?</h3>
                  <p className="text-green-600 mb-6">Your mood helps us create the perfect learning experience for you.</p>
                  
                  <div className="grid grid-cols-5 gap-4 mb-6">
                    {moodOptions.map((mood) => (
                      <button
                        key={mood.value}
                        onClick={() => {
                          setCurrentMood(mood.value);
                        }}
                        className={`flex flex-col items-center p-4 rounded-xl border-2 transition-all duration-200 transform hover:scale-105 ${
                          currentMood === mood.value 
                            ? 'border-green-500 bg-green-50' 
                            : 'border-green-200/60 hover:border-green-400 hover:bg-green-50'
                        }`}
                      >
                        <div className="text-3xl mb-2">{mood.emoji}</div>
                        <div className="text-sm text-green-700 font-medium">{mood.label}</div>
                      </button>
                    ))}
                  </div>
                  
                  <button
                    onClick={() => setShowBreathing(true)}
                    className="px-8 py-3 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-xl hover:from-blue-600 hover:to-blue-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105"
                  >
                    Take a Mindful Moment
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* Progress Overview */}
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
            {/* Certification Goal */}
            <div className="bg-gradient-to-br from-blue-100 to-blue-50 rounded-2xl p-6 border border-blue-200/60 shadow-lg">
              <div className="flex items-center justify-between mb-4">
                <div className="text-3xl">🎯</div>
                <Link 
                  href="/settings"
                  className="text-blue-600 hover:text-blue-800 text-sm"
                >
                  Change
                </Link>
              </div>
              <h3 className="text-lg font-semibold text-green-800 mb-2">Certification Goal</h3>
              {userCertificationGoal ? (
                <p className="text-blue-600 text-sm font-medium">{userCertificationGoal}</p>
              ) : (
                <div>
                  <p className="text-gray-500 text-sm mb-2">Not set</p>
                  <Link 
                    href="/settings"
                    className="text-xs text-blue-600 hover:text-blue-800 underline"
                  >
                    Choose your certification
                  </Link>
                </div>
              )}
            </div>

            {/* Study Sessions */}
            <div className="bg-gradient-to-br from-green-100 to-green-50 rounded-2xl p-6 border border-green-200/60 shadow-lg">
              <div className="flex items-center justify-between mb-4">
                <div className="text-3xl">🔥</div>
                <div className="text-right">
                  <div className="text-2xl font-bold text-green-700">
                    {isLoadingDashboard ? '...' : dashboardData.stats.total_sessions}
                  </div>
                  <div className="text-sm text-green-600">Sessions</div>
                </div>
              </div>
              <h3 className="text-lg font-semibold text-green-800 mb-2">Study Sessions</h3>
              <p className="text-green-600 text-sm">You&apos;re building great habits!</p>
            </div>

            {/* Question Accuracy */}
            <div className="bg-gradient-to-br from-orange-100 to-orange-50 rounded-2xl p-6 border border-orange-200/60 shadow-lg">
              <div className="flex items-center justify-between mb-4">
                <div className="text-3xl">📊</div>
                <div className="text-right">
                  <div className="text-2xl font-bold text-orange-700">
                    {isLoadingDashboard ? '...' : `${dashboardData.stats.accuracy}%`}
                  </div>
                  <div className="text-sm text-orange-600">
                    {isLoadingDashboard ? 'Loading...' : `${dashboardData.stats.total_correct}/${dashboardData.stats.total_questions}`}
                  </div>
                </div>
              </div>
              <h3 className="text-lg font-semibold text-green-800 mb-2">Accuracy Rate</h3>
              <div className="w-full bg-orange-200 rounded-full h-2">
                <div 
                  className="bg-gradient-to-r from-orange-500 to-orange-600 h-2 rounded-full transition-all duration-500"
                  style={{ width: `${isLoadingDashboard ? 0 : dashboardData.stats.accuracy}%` }}
                ></div>
              </div>
            </div>
          </div>

          {/* Structured Learning Path Invitation */}
          {structuredLearningPath.hasStructuredPath && (
            <div className="mb-8">
              <div className="bg-gradient-to-r from-blue-50 to-purple-50 border border-blue-200 rounded-2xl p-6 shadow-lg">
                <div className="flex items-start space-x-4">
                  <div className="flex-shrink-0">
                    <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                      <span className="text-2xl">🌸</span>
                    </div>
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="text-lg font-semibold text-blue-900 mb-2">
                      ✨ Structured Learning Path Available
                    </h3>
                    <p className="text-blue-800 mb-4">
                      Your <strong>{structuredLearningPath.certificationName || userCertificationGoal}</strong> certification 
                      now has concept-based learning with organized domains, mastery tracking, and personalized recommendations.
                    </p>
                    <div className="flex space-x-3">
                      <Link 
                        href="/study-path"
                        className="inline-flex items-center px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700 transition-colors"
                      >
                        Begin Structured Learning →
                      </Link>
                      <button className="inline-flex items-center px-4 py-2 bg-white text-blue-600 text-sm font-medium rounded-lg border border-blue-300 hover:bg-blue-50 transition-colors">
                        Continue Here
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Adaptive Learning Garden - Co-Creative Intelligence */}
          {userCertificationGoal && user && (
            <div className="mb-12">
              <div className="text-center mb-8">
                <h2 className="text-3xl font-bold text-gray-800 mb-3">Your Learning Garden 🌱</h2>
                <p className="text-gray-600 max-w-2xl mx-auto">
                  Witness your understanding bloom through conscious practice. Each question plants seeds of wisdom 
                  that flower into mastery.
                </p>
              </div>
              
              <div className="grid lg:grid-cols-2 gap-8">
                {/* Learning Mandala - Visual Journey */}
                <div className="bg-white/90 backdrop-blur-sm rounded-2xl border border-purple-200/60 shadow-xl overflow-hidden">
                  <div className="p-6">
                    <h3 className="text-xl font-semibold text-purple-800 mb-4 text-center">
                      Progress Mandala
                    </h3>
                    <p className="text-sm text-purple-600 text-center mb-6">
                      Your knowledge blooming in sacred geometry
                    </p>
                  </div>
                  <LearningMandala 
                    userId={user.id} 
                    certification={userCertificationGoal} 
                  />
                </div>

                {/* Intuitive Guidance - Wisdom Whispers */}
                <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-6 border border-blue-200/60 shadow-xl">
                  <h3 className="text-xl font-semibold text-blue-800 mb-4 text-center">
                    Wisdom Whispers
                  </h3>
                  <p className="text-sm text-blue-600 text-center mb-6">
                    Insights that emerge from your learning journey
                  </p>
                  <IntuitiveGuidance 
                    userId={user.id} 
                    certification={userCertificationGoal}
                    sessionTime={getCurrentSessionTime()}
                  />
                </div>
              </div>
            </div>
          )}

          {/* Main Action Grid */}
          <div className="grid lg:grid-cols-2 gap-8 mb-12">
            
            {/* Adaptive Study Session - Full Width */}
            <div className="lg:col-span-1 bg-gradient-to-br from-pink-100 to-purple-50 rounded-2xl p-8 border border-purple-200/60 shadow-lg">
              <div className="flex items-start gap-4 mb-6">
                <div className="text-4xl">🧠</div>
                <div className="flex-1">
                  <h3 className="text-xl font-bold text-purple-800 mb-2">Your Adaptive Study Session</h3>
                  <p className="text-purple-600 text-sm mb-4">
                    Based on your progress and mood, we&apos;ve prepared a personalized {subscriptionStatus === 'active' ? '15' : '5'}-minute session focusing on your growth areas.
                  </p>
                </div>
              </div>

              <div className="grid grid-cols-3 gap-4 mb-6">
                <div className="text-center p-4 bg-green-50 rounded-xl border border-green-200">
                  <div className="text-2xl mb-2">📚</div>
                  <div className="text-sm font-medium text-green-700">Content Review</div>
                  <div className="text-xs text-green-600">Key concepts</div>
                </div>
                <div className="text-center p-4 bg-orange-50 rounded-xl border border-orange-200">
                  <div className="text-2xl mb-2">❓</div>
                  <div className="text-sm font-medium text-orange-700">Practice Questions</div>
                  <div className="text-xs text-orange-600">{subscriptionStatus === 'active' ? '10-15' : '5'} questions</div>
                </div>
                <div className="text-center p-4 bg-blue-50 rounded-xl border border-blue-200">
                  <div className="text-2xl mb-2">🧘</div>
                  <div className="text-sm font-medium text-blue-700">Mindful Break</div>
                  <div className="text-xs text-blue-600">2 minutes</div>
                </div>
              </div>

              <div className="mb-6 p-3 bg-purple-50 rounded-lg border border-purple-200">
                <p className="text-xs text-purple-600">
                  <strong>Session Purpose:</strong> Adaptive learning that adjusts to your understanding level. 
                  {subscriptionStatus === 'free' 
                    ? ' Free accounts receive 5 focused questions.' 
                    : ' Pro members get extended 15-question sessions with detailed explanations.'
                  }
                </p>
              </div>

              <Link 
                href="/practice/session"
                className="block w-full py-4 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-[1.02] font-medium text-lg text-center"
              >
                Begin Your Journey ✨
              </Link>
            </div>

            {/* Quick Actions */}
            <div className="space-y-6">
              {/* Breathing Exercise */}
              <div className="bg-gradient-to-br from-blue-100 to-purple-50 rounded-2xl p-6 border border-blue-200/60 shadow-lg">
                <div className="text-3xl mb-3">🌸</div>
                <h4 className="text-lg font-semibold text-blue-800 mb-2">Breathing Exercise</h4>
                <p className="text-blue-600 text-sm mb-4">
                  Take a moment to center yourself with guided breathing.
                </p>
                <button 
                  onClick={() => setShowBreathing(true)}
                  className="w-full py-3 bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded-xl hover:from-blue-600 hover:to-purple-600 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105"
                >
                  3-Minute Reset
                </button>
              </div>

              {/* Quick Practice */}
              <div className="bg-gradient-to-br from-orange-100 to-yellow-50 rounded-2xl p-6 border border-orange-200/60 shadow-lg">
                <div className="text-3xl mb-3">⚡</div>
                <h4 className="text-lg font-semibold text-orange-800 mb-2">Quick Practice</h4>
                <p className="text-orange-600 text-sm mb-3">
                  5 targeted questions to keep your momentum going.
                </p>
                <div className="text-xs text-orange-700 mb-4">
                  <strong>Purpose:</strong> Short practice sessions for busy schedules. Perfect for maintaining consistency without time pressure.
                </div>
                <Link 
                  href="/practice/session?type=quick&length=5"
                  className="block w-full py-3 bg-gradient-to-r from-orange-500 to-yellow-500 text-white rounded-xl hover:from-orange-600 hover:to-yellow-600 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 text-center"
                >
                  Quick Quiz
                </Link>
              </div>
            </div>
          </div>

          {/* Learning Path Visualization */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl mb-12">
            <h3 className="text-2xl font-semibold text-green-800 mb-6 text-center">Your Learning Journey</h3>
            
            <div className="flex items-center justify-between max-w-4xl mx-auto">
              <div className="flex flex-col items-center text-center">
                <div className="w-16 h-16 bg-green-500 rounded-full flex items-center justify-center text-white text-2xl mb-3 shadow-lg">
                  ✓
                </div>
                <div className="text-sm font-medium text-green-700">Foundation</div>
                <div className="text-xs text-green-600">Complete</div>
              </div>
              
              <div className="flex-1 h-2 bg-green-200 mx-4 rounded-full overflow-hidden">
                <div className="h-full bg-gradient-to-r from-green-500 to-orange-400 w-3/4 rounded-full"></div>
              </div>
              
              <div className="flex flex-col items-center text-center">
                <div className="w-16 h-16 bg-orange-500 rounded-full flex items-center justify-center text-white text-2xl mb-3 shadow-lg animate-pulse">
                  🔄
                </div>
                <div className="text-sm font-medium text-orange-700">Core Practice</div>
                <div className="text-xs text-orange-600">In Progress</div>
              </div>
              
              <div className="flex-1 h-2 bg-gray-200 mx-4 rounded-full">
                <div className="h-full bg-gray-300 w-1/4 rounded-full"></div>
              </div>
              
              <div className="flex flex-col items-center text-center">
                <div className="w-16 h-16 bg-gray-300 rounded-full flex items-center justify-center text-gray-600 text-2xl mb-3">
                  🎯
                </div>
                <div className="text-sm font-medium text-gray-600">Mastery</div>
                <div className="text-xs text-gray-500">Coming Soon</div>
              </div>
              
              <div className="flex-1 h-2 bg-gray-200 mx-4 rounded-full"></div>
              
              <div className="flex flex-col items-center text-center">
                <div className="w-16 h-16 bg-gray-300 rounded-full flex items-center justify-center text-gray-600 text-2xl mb-3">
                  🏆
                </div>
                <div className="text-sm font-medium text-gray-600">Certification</div>
                <div className="text-xs text-gray-500">Goal</div>
              </div>
            </div>
          </div>

          {/* Mindful Reflection */}
          <div className="bg-gradient-to-r from-green-100 via-orange-50 to-yellow-100 rounded-2xl p-8 border border-green-200/60 shadow-lg text-center">
            <div className="text-4xl mb-4">🌱</div>
            <h3 className="text-2xl font-semibold text-green-800 mb-4">This Week&apos;s Reflection</h3>
            <p className="text-green-600 text-lg max-w-2xl mx-auto">
              &quot;Growth is not about perfection, but about progress. Every question answered, every concept understood, 
              and every moment of mindfulness brings you closer to your teaching dreams.&quot;
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
                Let&apos;s take a moment to breathe and center ourselves.
              </p>
              
              <div className="text-4xl font-bold text-blue-600 mb-6">{breathingCount}/6</div>
              
              <div className="space-y-4">
                <button
                  onClick={() => setBreathingCount(prev => Math.min(prev + 1, 6))}
                  className="w-full py-3 bg-blue-500 text-white rounded-xl hover:bg-blue-600 transition-colors"
                >
                  Breathe In... Hold... Breathe Out
                </button>
                
                {breathingCount >= 6 && (
                  <div className="text-green-600 font-medium">Perfect! You&apos;re centered and ready to learn.</div>
                )}
                
                <button
                  onClick={() => {
                    setShowBreathing(false);
                    setBreathingCount(0);
                  }}
                  className="w-full py-2 text-green-600 hover:text-green-700 transition-colors"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
