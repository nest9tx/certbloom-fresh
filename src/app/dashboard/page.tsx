'use client';

import { useAuth } from '../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import CertificationGoalSelector from '../../components/CertificationGoalSelector';

export default function DashboardPage() {
  const { user, loading, signOut } = useAuth();
  const router = useRouter();
  const [isSigningOut, setIsSigningOut] = useState(false);
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
  const [isLoadingDashboard, setIsLoadingDashboard] = useState(true);
  const [showCertificationSelector, setShowCertificationSelector] = useState(false);

  // Check for success parameter from URL (client-side only)
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const urlParams = new URLSearchParams(window.location.search);
      const success = urlParams.get('success');
      if (success === 'true') {
        setShowSuccessMessage(true);
        const newUrl = window.location.pathname;
        router.replace(newUrl);
        setTimeout(() => setShowSuccessMessage(false), 5000);
      }
    }
  }, [router]);

  // Fetch user data
  useEffect(() => {
    async function fetchUserData() {
      if (user) {
        setIsLoadingDashboard(true);
        
        const { getSubscriptionStatus } = await import('../../lib/getSubscriptionStatus');
        const { getUserCertificationGoal } = await import('../../lib/getUserCertificationGoal');
        const { getUserPrimaryLearningPath } = await import('../../lib/learningPathBridge');
        
        const [status, certificationGoal, learningPath] = await Promise.all([
          getSubscriptionStatus(user.id),
          getUserCertificationGoal(user.id),
          getUserPrimaryLearningPath(user.id)
        ]);
        
        console.log('📋 Fetched user data:', { status, certificationGoal, learningPath });
        setSubscriptionStatus(status);
        setUserCertificationGoal(certificationGoal);
        setStructuredLearningPath(learningPath);
        
        setIsLoadingDashboard(false);
      }
    }

    if (user) {
      fetchUserData();
    }
  }, [user]);

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

  // Helper function to check if certification goal has structured content
  const hasCompatibleCertification = (goal: string | null): boolean => {
    if (!goal) return false;
    return goal.includes('Math EC-6') || goal.includes('Mathematics (902)') || goal.includes('Elementary Mathematics');
  };

  const handleCertificationGoalUpdated = (newGoal: string) => {
    setUserCertificationGoal(newGoal);
    // Refresh the structured learning path after goal update
    if (user) {
      fetchUserLearningPath();
    }
  };

  const fetchUserLearningPath = async () => {
    if (!user) return;
    
    try {
      const { getUserPrimaryLearningPath } = await import('../../lib/learningPathBridge');
      const learningPath = await getUserPrimaryLearningPath(user.id);
      setStructuredLearningPath(learningPath);
    } catch (error) {
      console.error('Error fetching learning path:', error);
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
    return null;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 relative">
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
        
        {/* Subscription Badge */}
        <div className="flex justify-end mb-4">
          {subscriptionStatus === 'active' ? (
            <span className="inline-flex items-center px-4 py-2 bg-green-600 text-white rounded-full text-sm font-semibold shadow-lg">
              <span className="mr-2">🌟</span> Upgraded: Full Access
            </span>
          ) : (
            <Link 
              href="/pricing"
              className="inline-flex items-center px-4 py-2 bg-gradient-to-r from-purple-500 to-purple-600 text-white rounded-full text-sm font-semibold shadow-lg hover:from-purple-600 hover:to-purple-700 transition-all duration-200 transform hover:scale-105"
            >
              <span className="mr-2">🚀</span> Upgrade to Pro
            </Link>
          )}
        </div>

        {/* Header Cards - Learning Progress Overview */}
        <div className="grid md:grid-cols-3 gap-6 mb-8">
          {/* Certification Goal */}
          <div className="bg-gradient-to-br from-blue-100 to-blue-50 rounded-2xl p-6 border border-blue-200/60 shadow-lg">
            <div className="flex items-center justify-between mb-4">
              <div className="text-3xl">🎯</div>
              <button 
                onClick={() => setShowCertificationSelector(true)}
                className="text-blue-600 hover:text-blue-800 text-sm transition-colors"
              >
                Change
              </button>
            </div>
            <h3 className="text-lg font-semibold text-green-800 mb-2">Certification Goal</h3>
            {userCertificationGoal ? (
              <p className="text-blue-600 text-sm font-medium">{userCertificationGoal}</p>
            ) : (
              <div>
                <p className="text-gray-500 text-sm mb-2">Not set</p>
                <button 
                  onClick={() => setShowCertificationSelector(true)}
                  className="text-xs text-blue-600 hover:text-blue-800 underline transition-colors"
                >
                  Choose your certification
                </button>
              </div>
            )}
          </div>

          {/* Concepts Mastered */}
          <div className="bg-gradient-to-br from-green-100 to-green-50 rounded-2xl p-6 border border-green-200/60 shadow-lg">
            <div className="flex items-center justify-between mb-4">
              <div className="text-3xl">🌱</div>
              <div className="text-right">
                <div className="text-2xl font-bold text-green-700">
                  {isLoadingDashboard ? '...' : '0'}
                </div>
                <div className="text-sm text-green-600">of 9 concepts</div>
              </div>
            </div>
            <h3 className="text-lg font-semibold text-green-800 mb-2">Concepts Mastered</h3>
            <p className="text-green-600 text-sm">Your knowledge is growing!</p>
          </div>

          {/* Learning Progress */}
          <div className="bg-gradient-to-br from-purple-100 to-purple-50 rounded-2xl p-6 border border-purple-200/60 shadow-lg">
            <div className="flex items-center justify-between mb-4">
              <div className="text-3xl">📈</div>
              <div className="text-right">
                <div className="text-2xl font-bold text-purple-700">
                  {isLoadingDashboard ? '...' : '0%'}
                </div>
                <div className="text-sm text-purple-600">Overall Progress</div>
              </div>
            </div>
            <h3 className="text-lg font-semibold text-green-800 mb-2">Learning Progress</h3>
            <div className="w-full bg-purple-200 rounded-full h-2">
              <div 
                className="bg-gradient-to-r from-purple-500 to-purple-600 h-2 rounded-full transition-all duration-500"
                style={{ width: `0%` }}
              ></div>
            </div>
          </div>
        </div>

        {/* Structured Learning Path Invitation */}
        {(structuredLearningPath.hasStructuredPath || hasCompatibleCertification(userCertificationGoal)) && (
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
                    Your <strong>{structuredLearningPath.certificationName || userCertificationGoal || 'Elementary Mathematics (EC-6)'}</strong> certification 
                    now has concept-based learning with organized domains, mastery tracking, and personalized recommendations.
                  </p>
                  <div className="flex space-x-3">
                    <Link 
                      href="/study-path"
                      className="inline-flex items-center px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700 transition-colors"
                    >
                      Begin Structured Learning →
                    </Link>
                    {subscriptionStatus === 'free' && (
                      <Link 
                        href="/pricing"
                        className="inline-flex items-center px-4 py-2 bg-gradient-to-r from-purple-500 to-purple-600 text-white text-sm font-medium rounded-lg hover:from-purple-600 hover:to-purple-700 transition-colors"
                      >
                        Unlock Pro Features
                      </Link>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Concept-Based Learning Options */}
        <div className="grid lg:grid-cols-2 gap-8 mb-12">
          
          {/* Primary Learning Path */}
          <div className="lg:col-span-1 bg-gradient-to-br from-green-100 to-blue-50 rounded-2xl p-8 border border-green-200/60 shadow-lg">
            <div className="flex items-start gap-4 mb-6">
              <div className="text-4xl">🎯</div>
              <div className="flex-1">
                <h3 className="text-xl font-bold text-green-800 mb-2">Concept-Based Learning</h3>
                <p className="text-green-600 text-sm mb-4">
                  Master concepts step-by-step with personalized learning paths, progress tracking, and adaptive recommendations.
                </p>
              </div>
            </div>

            <div className="grid grid-cols-3 gap-4 mb-6">
              <div className="text-center p-4 bg-blue-50 rounded-xl border border-blue-200">
                <div className="text-2xl mb-2">📖</div>
                <div className="text-sm font-medium text-blue-700">Learn</div>
                <div className="text-xs text-blue-600">Explanations</div>
              </div>
              <div className="text-center p-4 bg-purple-50 rounded-xl border border-purple-200">
                <div className="text-2xl mb-2">🔧</div>
                <div className="text-sm font-medium text-purple-700">Practice</div>
                <div className="text-xs text-purple-600">Interactive</div>
              </div>
              <div className="text-center p-4 bg-green-50 rounded-xl border border-green-200">
                <div className="text-2xl mb-2">✅</div>
                <div className="text-sm font-medium text-green-700">Master</div>
                <div className="text-xs text-green-600">Track Progress</div>
              </div>
            </div>

            {subscriptionStatus === 'free' && (
              <div className="mb-6 p-3 bg-yellow-50 rounded-lg border border-yellow-200">
                <p className="text-xs text-yellow-700">
                  <strong>Free Tier:</strong> Access to 3 concepts and basic content.
                  <Link href="/pricing" className="text-blue-600 hover:text-blue-700 ml-1 underline">
                    Upgrade for full access
                  </Link>
                </p>
              </div>
            )}

            <Link 
              href="/study-path"
              className="block w-full py-4 bg-gradient-to-r from-green-600 to-blue-600 text-white rounded-xl hover:from-green-700 hover:to-blue-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-[1.02] font-medium text-lg text-center"
            >
              Continue Learning Journey ✨
            </Link>
          </div>

          {/* Quick Actions */}
          <div className="space-y-6">
            {/* Mindful Learning */}
            <div className="bg-gradient-to-br from-purple-100 to-pink-50 rounded-2xl p-6 border border-purple-200/60 shadow-lg">
              <div className="text-3xl mb-3">🌸</div>
              <h4 className="text-lg font-semibold text-purple-800 mb-2">Mindful Learning</h4>
              <p className="text-purple-600 text-sm mb-4">
                Take a moment to center yourself before studying.
              </p>
              <button 
                onClick={() => setShowBreathing(true)}
                className="w-full py-3 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-xl hover:from-purple-600 hover:to-pink-600 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105"
              >
                3-Minute Reset
              </button>
            </div>

            {/* Progress Review */}
            <div className="bg-gradient-to-br from-orange-100 to-yellow-50 rounded-2xl p-6 border border-orange-200/60 shadow-lg">
              <div className="text-3xl mb-3">📊</div>
              <h4 className="text-lg font-semibold text-orange-800 mb-2">Progress Review</h4>
              <p className="text-orange-600 text-sm mb-3">
                See your concept mastery and learning insights.
              </p>
              <div className="text-xs text-orange-700 mb-4">
                <strong>Track:</strong> Concept mastery, time spent, and personalized recommendations.
              </div>
              <Link 
                href="/analytics"
                className="block w-full py-3 bg-gradient-to-r from-orange-500 to-yellow-500 text-white rounded-xl hover:from-orange-600 hover:to-yellow-600 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 text-center"
              >
                View Analytics
              </Link>
            </div>
          </div>
        </div>

        {/* Concept Mastery Journey */}
        <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl mb-12">
          <h3 className="text-2xl font-semibold text-green-800 mb-6 text-center">Your Concept Mastery Journey</h3>
          
          <div className="flex items-center justify-between max-w-4xl mx-auto">
            <div className="flex flex-col items-center text-center">
              <div className="w-16 h-16 bg-green-500 rounded-full flex items-center justify-center text-white text-2xl mb-3 shadow-lg">
                📖
              </div>
              <div className="text-sm font-medium text-green-700">Foundations</div>
              <div className="text-xs text-green-600">3 concepts</div>
            </div>
            
            <div className="flex-1 h-2 bg-green-200 mx-4 rounded-full overflow-hidden">
              <div className="h-full bg-gradient-to-r from-green-500 to-blue-400 w-1/4 rounded-full"></div>
            </div>
            
            <div className="flex flex-col items-center text-center">
              <div className="w-16 h-16 bg-blue-400 rounded-full flex items-center justify-center text-white text-2xl mb-3 shadow-lg">
                🔧
              </div>
              <div className="text-sm font-medium text-blue-700">Applications</div>
              <div className="text-xs text-blue-600">3 concepts</div>
            </div>
            
            <div className="flex-1 h-2 bg-gray-200 mx-4 rounded-full">
              <div className="h-full bg-gray-300 w-0 rounded-full"></div>
            </div>
            
            <div className="flex flex-col items-center text-center">
              <div className="w-16 h-16 bg-gray-300 rounded-full flex items-center justify-center text-gray-600 text-2xl mb-3">
                🎯
              </div>
              <div className="text-sm font-medium text-gray-600">Advanced</div>
              <div className="text-xs text-gray-500">3 concepts</div>
            </div>
            
            <div className="flex-1 h-2 bg-gray-200 mx-4 rounded-full"></div>
            
            <div className="flex flex-col items-center text-center">
              <div className="w-16 h-16 bg-gray-300 rounded-full flex items-center justify-center text-gray-600 text-2xl mb-3">
                🏆
              </div>
              <div className="text-sm font-medium text-gray-600">Mastery</div>
              <div className="text-xs text-gray-500">Certification Ready</div>
            </div>
          </div>

          {subscriptionStatus === 'free' && (
            <div className="mt-6 p-4 bg-gradient-to-r from-purple-50 to-blue-50 rounded-lg border border-purple-200 text-center">
              <p className="text-sm text-purple-700 mb-2">
                🌟 <strong>Free tier:</strong> Access to Foundation concepts only
              </p>
              <Link 
                href="/pricing"
                className="inline-flex items-center px-4 py-2 bg-gradient-to-r from-purple-500 to-purple-600 text-white text-sm font-medium rounded-lg hover:from-purple-600 hover:to-purple-700 transition-colors"
              >
                Unlock All Concepts →
              </Link>
            </div>
          )}
        </div>

        {/* Mindful Reflection */}
        <div className="bg-gradient-to-r from-green-100 via-orange-50 to-yellow-100 rounded-2xl p-8 border border-green-200/60 shadow-lg text-center">
          <div className="text-4xl mb-4">🌱</div>
          <h3 className="text-2xl font-semibold text-green-800 mb-4">This Week&apos;s Reflection</h3>
          <p className="text-green-600 text-lg max-w-2xl mx-auto">
            &quot;Growth is not about perfection, but about progress. Every concept mastered, every insight gained, 
            and every moment of mindfulness brings you closer to your teaching dreams.&quot;
          </p>
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

      {/* Certification Goal Selector Modal */}
      <CertificationGoalSelector
        isOpen={showCertificationSelector}
        onClose={() => setShowCertificationSelector(false)}
        currentGoal={userCertificationGoal}
        onGoalUpdated={handleCertificationGoalUpdated}
      />
    </div>
  );
}
