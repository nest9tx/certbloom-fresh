'use client';

import { useAuth } from '../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import Link from 'next/link';

export default function DashboardPage() {
  const { user, loading, signOut } = useAuth();
  const router = useRouter();
  const [isSigningOut, setIsSigningOut] = useState(false);

  useEffect(() => {
    if (!loading && !user) {
      router.push('/auth');
    }
  }, [user, loading, router]);

  const handleSignOut = async () => {
    setIsSigningOut(true);
    await signOut();
    router.push('/');
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
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50">
      {/* Navigation */}
      <nav className="relative z-10 flex items-center justify-between p-6 bg-white/80 backdrop-blur-sm border-b border-green-200/50">
        <Link href="/" className="flex items-center space-x-3">
          <div className="text-3xl">🌸</div>
          <div className="text-2xl font-bold text-green-800">CertBloom</div>
        </Link>
        <div className="flex items-center space-x-6">
          <span className="text-green-600">Welcome, {user.user_metadata?.full_name || user.email}!</span>
          <button
            onClick={handleSignOut}
            disabled={isSigningOut}
            className="px-6 py-2 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors disabled:opacity-50"
          >
            {isSigningOut ? 'Signing Out...' : 'Sign Out'}
          </button>
        </div>
      </nav>

      {/* Main Content */}
      <div className="container mx-auto px-6 py-12">
        <div className="max-w-4xl mx-auto">
          {/* Welcome Section */}
          <div className="text-center mb-12">
            <div className="text-6xl mb-6">🌸</div>
            <h1 className="text-4xl font-light text-green-800 mb-4">
              Welcome to Your Learning Journey
            </h1>
            <p className="text-xl text-green-600 mb-8">
              Ready to bloom into your teaching certification with confidence?
            </p>
          </div>

          {/* Quick Stats */}
          <div className="grid md:grid-cols-3 gap-6 mb-12">
            <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-6 border border-green-200/50 text-center">
              <div className="text-3xl mb-3">📚</div>
              <h3 className="text-lg font-semibold text-green-800 mb-2">Study Sessions</h3>
              <p className="text-2xl font-bold text-green-600">0</p>
              <p className="text-sm text-green-500">Total completed</p>
            </div>

            <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-6 border border-green-200/50 text-center">
              <div className="text-3xl mb-3">🎯</div>
              <h3 className="text-lg font-semibold text-green-800 mb-2">Progress</h3>
              <p className="text-2xl font-bold text-green-600">0%</p>
              <p className="text-sm text-green-500">Certification ready</p>
            </div>

            <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-6 border border-green-200/50 text-center">
              <div className="text-3xl mb-3">🧘‍♀️</div>
              <h3 className="text-lg font-semibold text-green-800 mb-2">Wellness</h3>
              <p className="text-2xl font-bold text-green-600">-</p>
              <p className="text-sm text-green-500">Current level</p>
            </div>
          </div>

          {/* Action Cards */}
          <div className="grid md:grid-cols-2 gap-8 mb-12">
            <div className="bg-gradient-to-br from-green-100 to-green-50 rounded-2xl p-8 border border-green-200/50">
              <div className="text-4xl mb-4">🚀</div>
              <h3 className="text-2xl font-semibold text-green-800 mb-3">Start Your Practice</h3>
              <p className="text-green-600 mb-6">
                Begin with adaptive practice questions tailored to your learning style and certification goals.
              </p>
              <button className="w-full py-3 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors font-medium">
                Start Practice Session
              </button>
            </div>

            <div className="bg-gradient-to-br from-orange-100 to-orange-50 rounded-2xl p-8 border border-orange-200/50">
              <div className="text-4xl mb-4">⚙️</div>
              <h3 className="text-2xl font-semibold text-green-800 mb-3">Complete Your Profile</h3>
              <p className="text-green-600 mb-6">
                Tell us about your certification goals and learning preferences for a personalized experience.
              </p>
              <button className="w-full py-3 bg-orange-600 text-white rounded-xl hover:bg-orange-700 transition-colors font-medium">
                Set Up Profile
              </button>
            </div>
          </div>

          {/* Mindful Moment */}
          <div className="bg-gradient-to-r from-green-100 to-blue-100 rounded-2xl p-8 border border-green-200/50 text-center">
            <div className="text-4xl mb-4">🌸</div>
            <h3 className="text-2xl font-semibold text-green-800 mb-3">Your Daily Mindful Moment</h3>
            <p className="text-green-600 mb-6">
              Take a moment to center yourself before diving into your studies. Remember, this journey is about growth, not perfection.
            </p>
            <button className="px-8 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors font-medium">
              Begin Breathing Exercise
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
