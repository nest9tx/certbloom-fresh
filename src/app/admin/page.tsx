'use client';

import { useAuth } from '../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';

interface QuestionStats {
  total: number;
  byDomain: Record<string, number>;
  byCertification: Record<string, number>;
  byDifficulty: Record<string, number>;
}

interface UserStats {
  totalUsers: number;
  activeUsers: number;
  subscriptions: {
    free: number;
    pro: number;
  };
}

export default function AdminDashboard() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [isLoadingStats, setIsLoadingStats] = useState(true);
  const [questionStats, setQuestionStats] = useState<QuestionStats>({
    total: 0,
    byDomain: {},
    byCertification: {},
    byDifficulty: {}
  });
  const [userStats, setUserStats] = useState<UserStats>({
    totalUsers: 0,
    activeUsers: 0,
    subscriptions: { free: 0, pro: 0 }
  });

  // Check if user is admin
  const isAdmin = user?.email === 'admin@certbloom.com' || user?.email?.includes('@luminanova.com');

  useEffect(() => {
    if (!loading && !user) {
      router.push('/auth');
    } else if (!loading && user && !isAdmin) {
      router.push('/dashboard');
    }
  }, [user, loading, isAdmin, router]);

  useEffect(() => {
    if (user && isAdmin) {
      fetchStats();
    }
  }, [user, isAdmin]);

  const fetchStats = async () => {
    setIsLoadingStats(true);
    try {
      // Fetch question and user statistics
      const [questionRes, userRes] = await Promise.all([
        fetch('/api/admin/question-stats'),
        fetch('/api/admin/user-stats')
      ]);
      
      if (questionRes.ok) {
        const qStats = await questionRes.json();
        setQuestionStats(qStats);
      }
      
      if (userRes.ok) {
        const uStats = await userRes.json();
        setUserStats(uStats);
      }
    } catch (error) {
      console.error('Error fetching admin stats:', error);
    } finally {
      setIsLoadingStats(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4 animate-pulse">🌸</div>
          <p className="text-green-600">Loading admin sanctuary...</p>
        </div>
      </div>
    );
  }

  if (!user || !isAdmin) {
    return null;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50">
      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-md border-b border-green-200/50">
        <div className="max-w-7xl mx-auto flex items-center justify-between p-6">
          <Link href="/" className="flex items-center space-x-3 group">
            <div className="w-10 h-10 transition-transform group-hover:scale-105">
              <Image src="/certbloom-logo.svg" alt="CertBloom" width={40} height={40} className="w-full h-full object-contain" />
            </div>
            <div className="text-2xl font-light text-green-800 tracking-wide">CertBloom Admin</div>
          </Link>
          <div className="flex items-center space-x-4">
            <Link href="/dashboard" className="text-green-700 hover:text-green-900 transition-colors font-medium">
              User Dashboard
            </Link>
            <span className="text-green-600 font-medium text-sm">Admin: {user.email}</span>
          </div>
        </div>
      </nav>

      <div className="container mx-auto px-6 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-green-800 mb-2">Admin Dashboard</h1>
          <p className="text-green-600">Content management and system oversight sanctuary</p>
        </div>

        {/* Quick Stats Overview */}
        <div className="grid md:grid-cols-4 gap-6 mb-8">
          <div className="bg-gradient-to-br from-blue-100 to-blue-50 rounded-2xl p-6 border border-blue-200/60 shadow-lg">
            <div className="text-3xl mb-3">📚</div>
            <h3 className="text-lg font-semibold text-blue-800 mb-2">Total Questions</h3>
            <div className="text-2xl font-bold text-blue-700">
              {isLoadingStats ? '...' : questionStats.total.toLocaleString()}
            </div>
          </div>

          <div className="bg-gradient-to-br from-green-100 to-green-50 rounded-2xl p-6 border border-green-200/60 shadow-lg">
            <div className="text-3xl mb-3">👥</div>
            <h3 className="text-lg font-semibold text-green-800 mb-2">Total Users</h3>
            <div className="text-2xl font-bold text-green-700">
              {isLoadingStats ? '...' : userStats.totalUsers.toLocaleString()}
            </div>
          </div>

          <div className="bg-gradient-to-br from-purple-100 to-purple-50 rounded-2xl p-6 border border-purple-200/60 shadow-lg">
            <div className="text-3xl mb-3">🌟</div>
            <h3 className="text-lg font-semibold text-purple-800 mb-2">Pro Subscribers</h3>
            <div className="text-2xl font-bold text-purple-700">
              {isLoadingStats ? '...' : userStats.subscriptions.pro.toLocaleString()}
            </div>
          </div>

          <div className="bg-gradient-to-br from-orange-100 to-orange-50 rounded-2xl p-6 border border-orange-200/60 shadow-lg">
            <div className="text-3xl mb-3">📈</div>
            <h3 className="text-lg font-semibold text-orange-800 mb-2">Active Users</h3>
            <div className="text-2xl font-bold text-orange-700">
              {isLoadingStats ? '...' : userStats.activeUsers.toLocaleString()}
            </div>
          </div>
        </div>

        {/* Main Admin Actions */}
        <div className="grid lg:grid-cols-2 gap-8 mb-8">
          {/* Question Management */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
            <div className="flex items-start gap-4 mb-6">
              <div className="text-4xl">📝</div>
              <div className="flex-1">
                <h3 className="text-xl font-bold text-green-800 mb-2">Question Management</h3>
                <p className="text-green-600 text-sm mb-4">
                  Create, edit, and organize questions for the adaptive learning system.
                </p>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4 mb-6">
              <Link href="/admin/content-overview" className="text-center p-4 bg-purple-50 rounded-xl border border-purple-200 hover:bg-purple-100 transition-colors">
                <div className="text-2xl mb-2">📊</div>
                <div className="text-sm font-medium text-purple-700">Content Progress</div>
              </Link>
              <Link href="/admin/questions/new" className="text-center p-4 bg-blue-50 rounded-xl border border-blue-200 hover:bg-blue-100 transition-colors">
                <div className="text-2xl mb-2">➕</div>
                <div className="text-sm font-medium text-blue-700">Add Question</div>
              </Link>
              <Link href="/admin/questions" className="text-center p-4 bg-green-50 rounded-xl border border-green-200 hover:bg-green-100 transition-colors">
                <div className="text-2xl mb-2">�</div>
                <div className="text-sm font-medium text-green-700">Manage Questions</div>
              </Link>
              <Link href="/admin/questions/import" className="text-center p-4 bg-orange-50 rounded-xl border border-orange-200 hover:bg-orange-100 transition-colors">
                <div className="text-2xl mb-2">📤</div>
                <div className="text-sm font-medium text-orange-700">Bulk Import</div>
              </Link>
              <Link href="/admin/diagnostics" className="text-center p-4 bg-yellow-50 rounded-xl border border-yellow-200 hover:bg-yellow-100 transition-colors">
                <div className="text-2xl mb-2">🔍</div>
                <div className="text-sm font-medium text-yellow-700">Diagnostics</div>
              </Link>
            </div>

            <Link 
              href="/admin/questions"
              className="block w-full py-3 bg-gradient-to-r from-green-600 to-blue-600 text-white rounded-xl hover:from-green-700 hover:to-blue-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-[1.02] font-medium text-center"
            >
              Manage Question Bank →
            </Link>
          </div>

          {/* User Management */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
            <div className="flex items-start gap-4 mb-6">
              <div className="text-4xl">👥</div>
              <div className="flex-1">
                <h3 className="text-xl font-bold text-green-800 mb-2">User Management</h3>
                <p className="text-green-600 text-sm mb-4">
                  Monitor user progress, manage subscriptions, and provide support.
                </p>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4 mb-6">
              <Link href="/admin/users" className="text-center p-4 bg-blue-50 rounded-xl border border-blue-200 hover:bg-blue-100 transition-colors">
                <div className="text-2xl mb-2">👤</div>
                <div className="text-sm font-medium text-blue-700">View Users</div>
              </Link>
              <Link href="/admin/subscriptions" className="text-center p-4 bg-green-50 rounded-xl border border-green-200 hover:bg-green-100 transition-colors">
                <div className="text-2xl mb-2">💳</div>
                <div className="text-sm font-medium text-green-700">Subscriptions</div>
              </Link>
              <Link href="/admin/analytics" className="text-center p-4 bg-purple-50 rounded-xl border border-purple-200 hover:bg-purple-100 transition-colors">
                <div className="text-2xl mb-2">📊</div>
                <div className="text-sm font-medium text-purple-700">Analytics</div>
              </Link>
              <Link href="/admin/support" className="text-center p-4 bg-orange-50 rounded-xl border border-orange-200 hover:bg-orange-100 transition-colors">
                <div className="text-2xl mb-2">🎧</div>
                <div className="text-sm font-medium text-orange-700">Support</div>
              </Link>
            </div>

            <Link 
              href="/admin/users"
              className="block w-full py-3 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl hover:from-purple-700 hover:to-blue-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-[1.02] font-medium text-center"
            >
              Manage Users →
            </Link>
          </div>
        </div>

        {/* Content Statistics */}
        <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
          <h3 className="text-2xl font-semibold text-green-800 mb-6">Content Overview</h3>
          
          <div className="grid md:grid-cols-3 gap-6">
            {/* By Certification */}
            <div>
              <h4 className="text-lg font-medium text-green-700 mb-4">Questions by Certification</h4>
              <div className="space-y-2">
                {Object.entries(questionStats.byCertification).map(([cert, count]) => (
                  <div key={cert} className="flex justify-between items-center p-3 bg-green-50 rounded-lg">
                    <span className="text-sm text-green-700">{cert}</span>
                    <span className="font-medium text-green-800">{count}</span>
                  </div>
                ))}
                {Object.keys(questionStats.byCertification).length === 0 && (
                  <div className="text-sm text-gray-500 italic">No questions yet</div>
                )}
              </div>
            </div>

            {/* By Domain */}
            <div>
              <h4 className="text-lg font-medium text-blue-700 mb-4">Questions by Domain</h4>
              <div className="space-y-2">
                {Object.entries(questionStats.byDomain).map(([domain, count]) => (
                  <div key={domain} className="flex justify-between items-center p-3 bg-blue-50 rounded-lg">
                    <span className="text-sm text-blue-700">{domain}</span>
                    <span className="font-medium text-blue-800">{count}</span>
                  </div>
                ))}
                {Object.keys(questionStats.byDomain).length === 0 && (
                  <div className="text-sm text-gray-500 italic">No questions yet</div>
                )}
              </div>
            </div>

            {/* By Difficulty */}
            <div>
              <h4 className="text-lg font-medium text-purple-700 mb-4">Questions by Difficulty</h4>
              <div className="space-y-2">
                {Object.entries(questionStats.byDifficulty).map(([difficulty, count]) => (
                  <div key={difficulty} className="flex justify-between items-center p-3 bg-purple-50 rounded-lg">
                    <span className="text-sm text-purple-700 capitalize">{difficulty}</span>
                    <span className="font-medium text-purple-800">{count}</span>
                  </div>
                ))}
                {Object.keys(questionStats.byDifficulty).length === 0 && (
                  <div className="text-sm text-gray-500 italic">No questions yet</div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
