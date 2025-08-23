'use client';

import { useEffect } from 'react';
import { useAuth } from '../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';

export default function AnalyticsPage() {
  const { user, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !user) {
      router.push('/auth');
    }
  }, [user, loading, router]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4 animate-pulse">📈</div>
          <p className="text-green-600">Loading your growth insights...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return null;
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
      <div className="container mx-auto px-6 py-12">
        <div className="max-w-4xl mx-auto">
          {/* Header */}
          <div className="text-center mb-12">
            <div className="text-6xl mb-6">📈</div>
            <h1 className="text-4xl font-light text-green-800 mb-4">
              Growth Insights
            </h1>
            <p className="text-xl text-green-600">
              Track your learning progress and celebrate your achievements
            </p>
          </div>

          {/* Coming Soon Card */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-12 border border-green-200/60 shadow-xl text-center">
            <div className="text-8xl mb-6">🚧</div>
            <h2 className="text-3xl font-light text-green-800 mb-4">
              Coming Soon!
            </h2>
            <p className="text-lg text-green-600 mb-8 max-w-2xl mx-auto">
              We&apos;re building detailed analytics to help you understand your learning patterns, 
              track your progress across different topics, and optimize your study strategy.
            </p>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
              <div className="bg-green-50 rounded-xl p-6">
                <div className="text-3xl mb-3">📊</div>
                <h3 className="font-semibold text-green-800 mb-2">Performance Tracking</h3>
                <p className="text-sm text-green-600">Detailed breakdowns of your scores by topic and difficulty</p>
              </div>
              
              <div className="bg-orange-50 rounded-xl p-6">
                <div className="text-3xl mb-3">🎯</div>
                <h3 className="font-semibold text-orange-800 mb-2">Goal Progress</h3>
                <p className="text-sm text-orange-600">Visual progress toward your certification goals</p>
              </div>
              
              <div className="bg-yellow-50 rounded-xl p-6">
                <div className="text-3xl mb-3">🧠</div>
                <h3 className="font-semibold text-yellow-800 mb-2">Learning Patterns</h3>
                <p className="text-sm text-yellow-600">Insights into your optimal study times and methods</p>
              </div>
            </div>

            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link 
                href="/dashboard"
                className="px-8 py-3 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 font-medium"
              >
                Back to Dashboard
              </Link>
              <Link 
                href="/practice/session?type=quick"
                className="px-8 py-3 bg-gradient-to-r from-orange-500 to-orange-600 text-white rounded-xl hover:from-orange-600 hover:to-orange-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 font-medium"
              >
                Start Practice Session
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
