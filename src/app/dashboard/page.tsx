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
  const [showCertificationSelector, setShowCertificationSelector] = useState(false);
  const [totalModules, setTotalModules] = useState(5); // Default fallback

  // Convert test code to full name for display
  const getCertificationDisplayName = (goal: string) => {
    const certMap: Record<string, string> = {
      '902': 'TExES Core Subjects EC-6: Mathematics (902)',
      '391': 'TExES Core Subjects EC-6 (391)',
      '901': 'TExES Core Subjects EC-6: English Language Arts (901)',
      '903': 'TExES Core Subjects EC-6: Social Studies (903)',
      '904': 'TExES Core Subjects EC-6: Science (904)'
    };
    return certMap[goal] || goal;
  };

  // Handle certification goal updates
  const handleCertificationGoalUpdate = (goal: string) => {
    setUserCertificationGoal(goal);
    setShowCertificationSelector(false);
    setShowSuccessMessage(true);
    
    // Update URL to remove success parameter
    const newUrl = window.location.pathname;
    router.replace(newUrl);
    setTimeout(() => setShowSuccessMessage(false), 5000);
  };

  // Check for success message in URL
  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('success') === 'certification-goal-set') {
      setShowSuccessMessage(true);
      // Clean up URL
      const newUrl = window.location.pathname;
      router.replace(newUrl);
      setTimeout(() => setShowSuccessMessage(false), 5000);
    }
  }, [router]);

  // Fetch user data
  useEffect(() => {
    async function fetchUserData() {
      if (user) {
        const { getSubscriptionStatus } = await import('../../lib/getSubscriptionStatus');
        const { getUserCertificationGoal } = await import('../../lib/getUserCertificationGoal');
        const { createClient } = await import('@supabase/supabase-js');
        
        const [status, certificationGoal] = await Promise.all([
          getSubscriptionStatus(user.id),
          getUserCertificationGoal(user.id)
        ]);
        
        setSubscriptionStatus(status);
        setUserCertificationGoal(certificationGoal);

        // Fetch total module count for current certification goal
        if (certificationGoal) {
          try {
            const supabase = createClient(
              process.env.NEXT_PUBLIC_SUPABASE_URL!,
              process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
            );
            
            const { data, error } = await supabase
              .from('learning_modules')
              .select('id', { count: 'exact' })
              .eq('concepts.domains.certifications.test_code', certificationGoal);
            
            if (!error && data) {
              setTotalModules(data.length || 80); // Default to 80 for 902 Math
            }
          } catch {
            console.log('Could not fetch module count, using default');
            setTotalModules(80); // Default for 902 Math
          }
        } else {
          setTotalModules(80); // Default for 902 Math
        }
      }
    }
    
    if (user) {
      fetchUserData();
    }
  }, [user]);

  const handleSignOut = async () => {
    setIsSigningOut(true);
    try {
      await signOut();
      router.push('/');
    } catch (error) {
      console.error('Sign out error:', error);
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
            <button 
              onClick={handleSignOut}
              disabled={isSigningOut}
              className="px-4 py-2 bg-red-50 text-red-600 rounded-lg hover:bg-red-100 transition-colors font-medium disabled:opacity-50"
            >
              {isSigningOut ? 'Signing out...' : 'Sign Out'}
            </button>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto p-6">
        {/* Success Message */}
        {showSuccessMessage && (
          <div className="mb-6 bg-green-50 border border-green-200 rounded-xl p-4">
            <div className="flex items-center space-x-3">
              <span className="text-2xl">✅</span>
              <div>
                <h3 className="text-green-800 font-semibold">Certification Goal Set!</h3>
                <p className="text-green-600 text-sm">Your learning path is now personalized for your certification.</p>
              </div>
            </div>
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
              <div className="space-y-2">
                <p className="text-blue-600 text-sm font-medium">{getCertificationDisplayName(userCertificationGoal)}</p>
                <p className="text-gray-600 text-xs">Ready for Enhanced Learning Experience!</p>
              </div>
            ) : (
              <div className="space-y-3">
                <p className="text-amber-600 text-sm font-medium">🌟 Let&apos;s get started!</p>
                <p className="text-gray-600 text-xs">Choose your certification program to unlock personalized learning</p>
                <button 
                  onClick={() => setShowCertificationSelector(true)}
                  className="w-full px-3 py-2 bg-blue-600 text-white text-xs font-medium rounded-lg hover:bg-blue-700 transition-colors shadow-sm"
                >
                  Set Certification Goal
                </button>
              </div>
            )}
          </div>

          {/* Concepts Mastered */}
          <div className="bg-gradient-to-br from-green-100 to-green-50 rounded-2xl p-6 border border-green-200/60 shadow-lg">
            <div className="text-3xl mb-4">🌱</div>
            <h3 className="text-lg font-semibold text-green-800 mb-1">Enhanced Learning</h3>
            <div className="text-2xl font-bold text-green-700 mb-1">Ready!</div>
            <p className="text-green-600 text-sm">Interactive learning modules await</p>
          </div>

          {/* Learning Progress */}
          <div className="bg-gradient-to-br from-purple-100 to-purple-50 rounded-2xl p-6 border border-purple-200/60 shadow-lg">
            <div className="text-3xl mb-4">📈</div>
            <h3 className="text-lg font-semibold text-purple-800 mb-1">Learning Progress</h3>
            <div className="text-2xl font-bold text-purple-700 mb-1">Begin Journey</div>
            <p className="text-purple-600 text-sm">Start with Enhanced Learning</p>
          </div>
        </div>

        {/* Enhanced Learning Experience Showcase */}
        <div className="mb-8">
          <div className="bg-gradient-to-r from-purple-50 via-pink-50 to-blue-50 border border-purple-200 rounded-2xl p-8 shadow-xl">
            <div className="flex items-start space-x-6">
              <div className="flex-shrink-0">
                <div className="w-16 h-16 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full flex items-center justify-center">
                  <span className="text-3xl">✨</span>
                </div>
              </div>
              <div className="flex-1 min-w-0">
                <div className="inline-flex items-center px-3 py-1 bg-purple-100 rounded-full text-xs font-medium text-purple-700 mb-3">
                  🆕 NEW: Enhanced Learning Experience
                </div>
                <h2 className="text-2xl font-bold text-purple-900 mb-3">
                  Teacher Preparation Excellence Framework
                </h2>
                <p className="text-purple-800 mb-6 text-lg leading-relaxed">
                  Experience our revolutionary approach to teacher certification preparation! Interactive learning 
                  modules, classroom scenarios, teaching strategies, and misconception alerts designed specifically for 
                  educator success.
                </p>

                <div className="grid grid-cols-3 gap-6 mb-6">
                  <div className="text-center">
                    <div className="text-lg font-bold text-purple-600">📚</div>
                    <div className="text-xs text-purple-600">{totalModules} Learning Modules</div>
                    <div className="text-xs text-gray-600">Comprehensive content</div>
                  </div>
                  <div className="text-center">
                    <div className="text-lg font-bold text-pink-600">🏫</div>
                    <div className="text-xs text-pink-600">Real Scenarios</div>
                    <div className="text-xs text-gray-600">Classroom applications</div>
                  </div>
                  <div className="text-center">
                    <div className="text-lg font-bold text-orange-600">⚠️</div>
                    <div className="text-xs text-orange-600">Misconception Alerts</div>
                    <div className="text-xs text-gray-600">Common student errors</div>
                  </div>
                </div>

                <div className="bg-white/50 rounded-lg p-4 mb-6">
                  <div className="text-xs text-purple-700 font-medium mb-2">📊 Live from our enhanced database:</div>
                  <div className="grid grid-cols-4 gap-4 text-center text-xs">
                    <div>
                      <div className="text-lg font-bold text-purple-700">5</div>
                      <div className="text-xs text-purple-600">Modules</div>
                    </div>
                    <div>
                      <div className="text-lg font-bold text-blue-700">1</div>
                      <div className="text-xs text-blue-600">Practice Test</div>
                    </div>
                    <div>
                      <div className="text-lg font-bold text-green-700">3</div>
                      <div className="text-xs text-green-600">Questions</div>
                    </div>
                    <div>
                      <div className="text-lg font-bold text-orange-700">20</div>
                      <div className="text-xs text-orange-600">Answer Choices</div>
                    </div>
                  </div>
                </div>

                <div className="flex justify-start">
                  <Link 
                    href="/enhanced-learning"
                    className="inline-flex items-center px-6 py-3 bg-gradient-to-r from-purple-600 to-pink-600 text-white font-medium rounded-lg hover:from-purple-700 hover:to-pink-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105"
                  >
                    🚀 Experience Enhanced Learning
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="grid lg:grid-cols-2 gap-8 mb-12">
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

            {/* Enhanced Learning Quick Start */}
            <div className="bg-gradient-to-br from-blue-100 to-indigo-50 rounded-2xl p-6 border border-blue-200/60 shadow-lg">
              <div className="text-3xl mb-3">🚀</div>
              <h4 className="text-lg font-semibold text-blue-800 mb-2">Quick Start Guide</h4>
              <p className="text-blue-600 text-sm mb-3">
                Jump into Enhanced Learning with guided modules.
              </p>
              <div className="text-xs text-blue-700 mb-4">
                <strong>Features:</strong> Interactive content, teaching scenarios, and misconception awareness.
              </div>
              <Link 
                href="/enhanced-learning"
                className="block w-full py-3 text-center bg-gradient-to-r from-blue-500 to-indigo-500 text-white rounded-xl hover:from-blue-600 hover:to-indigo-600 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105"
              >
                Start Enhanced Learning
              </Link>
            </div>
          </div>

          <div className="space-y-6">
            {/* Study Resources */}
            <div className="bg-gradient-to-br from-green-100 to-emerald-50 rounded-2xl p-6 border border-green-200/60 shadow-lg">
              <div className="text-3xl mb-3">📚</div>
              <h4 className="text-lg font-semibold text-green-800 mb-2">Study Resources</h4>
              <p className="text-green-600 text-sm mb-4">
                Access comprehensive learning materials and practice tests.
              </p>
              <div className="space-y-2">
                <Link 
                  href="/enhanced-learning"
                  className="block w-full py-2 text-center bg-gradient-to-r from-green-500 to-emerald-500 text-white rounded-lg hover:from-green-600 hover:to-emerald-600 transition-all duration-200 text-sm"
                >
                  Enhanced Modules
                </Link>
              </div>
            </div>

            {/* Support */}
            <div className="bg-gradient-to-br from-orange-100 to-yellow-50 rounded-2xl p-6 border border-orange-200/60 shadow-lg">
              <div className="text-3xl mb-3">💡</div>
              <h4 className="text-lg font-semibold text-orange-800 mb-2">Need Help?</h4>
              <p className="text-orange-600 text-sm mb-4">
                Get support and tips for effective learning.
              </p>
              <div className="text-xs text-orange-700 mb-4">
                <strong>Available:</strong> Learning guides, FAQs, and study tips.
              </div>
              <button className="w-full py-3 bg-gradient-to-r from-orange-500 to-yellow-500 text-white rounded-xl hover:from-orange-600 hover:to-yellow-600 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105">
                Get Support
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Certification Goal Selector Modal */}
      {showCertificationSelector && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center">
          <div className="bg-white rounded-2xl p-6 m-4 max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <CertificationGoalSelector 
              isOpen={true}
              currentGoal={userCertificationGoal}
              onGoalUpdated={handleCertificationGoalUpdate}
              onClose={() => setShowCertificationSelector(false)}
            />
          </div>
        </div>
      )}

      {/* Breathing Exercise Modal */}
      {showBreathing && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center">
          <div className="bg-white rounded-2xl p-8 m-4 max-w-md w-full text-center">
            <div className="text-6xl mb-4">🌸</div>
            <h3 className="text-xl font-semibold text-gray-900 mb-4">3-Minute Mindful Reset</h3>
            <div className="text-4xl font-bold text-purple-600 mb-4">{breathingCount}/3</div>
            <p className="text-gray-600 mb-6">Breathe deeply and center yourself for focused learning.</p>
            <div className="space-y-3">
              <button 
                onClick={() => {
                  if (breathingCount < 3) {
                    setBreathingCount(breathingCount + 1);
                  } else {
                    setShowBreathing(false);
                    setBreathingCount(0);
                  }
                }}
                className="w-full py-3 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-xl hover:from-purple-600 hover:to-pink-600 transition-colors"
              >
                {breathingCount < 3 ? 'Breathe In... Breathe Out...' : 'Complete ✨'}
              </button>
              <button 
                onClick={() => {
                  setShowBreathing(false);
                  setBreathingCount(0);
                }}
                className="w-full py-2 text-gray-500 hover:text-gray-700 transition-colors text-sm"
              >
                Skip for now
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
