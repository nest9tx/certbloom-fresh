'use client';

import { useAuth } from '../../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';

interface User {
  id: string;
  email: string;
  subscription_status: string;
  created_at: string;
  certification_goal?: string;
}

interface AnalyticsData {
  userGrowth: {
    totalUsers: number;
    newUsersThisWeek: number;
    newUsersThisMonth: number;
  };
  questionUsage: {
    totalQuestions: number;
    questionsByDomain: Record<string, number>;
    questionsByCertification: Record<string, number>;
  };
  subscriptions: {
    totalPro: number;
    conversionRate: number;
    revenue: {
      monthly: number;
      yearly: number;
    };
  };
  certificationGoals: Record<string, number>;
}

export default function AnalyticsPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [analytics, setAnalytics] = useState<AnalyticsData | null>(null);
  const [isLoading, setIsLoading] = useState(true);

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
      fetchAnalytics();
    }
  }, [user, isAdmin]);

  const fetchAnalytics = async () => {
    setIsLoading(true);
    try {
      const { createClient } = await import('@supabase/supabase-js');
      const supabase = createClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
      );
      
      const { data: { session } } = await supabase.auth.getSession();
      const authHeader = session?.access_token ? `Bearer ${session.access_token}` : 'Bearer admin-access';

      // Fetch analytics data from multiple endpoints
      const [userStatsRes, questionStatsRes, usersRes] = await Promise.all([
        fetch('/api/admin/user-stats', { headers: { 'Authorization': authHeader } }),
        fetch('/api/admin/question-stats', { headers: { 'Authorization': authHeader } }),
        fetch('/api/admin/users', { headers: { 'Authorization': authHeader } })
      ]);

      if (userStatsRes.ok && questionStatsRes.ok && usersRes.ok) {
        const [userStats, questionStats, usersData] = await Promise.all([
          userStatsRes.json(),
          questionStatsRes.json(),
          usersRes.json()
        ]);

        // Extract users array from the API response
        const users = usersData.users || [];
        console.log('📊 Analytics data:', { userStats, questionStats, usersCount: users.length });

        // Calculate analytics from the data
        const now = new Date();
        const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        const oneMonthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

        const newUsersThisWeek = users.filter((u: User) => new Date(u.created_at) >= oneWeekAgo).length;
        const newUsersThisMonth = users.filter((u: User) => new Date(u.created_at) >= oneMonthAgo).length;

        // Count certification goals
        const certificationGoals: Record<string, number> = {};
        users.forEach((u: User) => {
          if (u.certification_goal) {
            certificationGoals[u.certification_goal] = (certificationGoals[u.certification_goal] || 0) + 1;
          }
        });

        // Calculate realistic revenue estimate
        // Note: This is simplified - in production you'd want to track actual subscription types
        const proUsers = userStats.subscriptions.pro || 0;
        // Assume 70% monthly ($29), 30% yearly ($99/12 = $8.25/month)
        const estimatedMonthlyRevenue = Math.round((proUsers * 0.7 * 29) + (proUsers * 0.3 * 8.25));

        const analyticsData: AnalyticsData = {
          userGrowth: {
            totalUsers: userStats.totalUsers,
            newUsersThisWeek,
            newUsersThisMonth
          },
          questionUsage: {
            totalQuestions: questionStats.total,
            questionsByDomain: questionStats.byDomain || {},
            questionsByCertification: questionStats.byCertification || {}
          },
          subscriptions: {
            totalPro: userStats.subscriptions.pro,
            conversionRate: userStats.totalUsers > 0 ? (userStats.subscriptions.pro / userStats.totalUsers) * 100 : 0,
            revenue: {
              monthly: estimatedMonthlyRevenue,
              yearly: estimatedMonthlyRevenue * 12
            }
          },
          certificationGoals
        };

        setAnalytics(analyticsData);
      }
    } catch (error) {
      console.error('Error fetching analytics:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (loading || (user && !isAdmin)) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4 animate-pulse">🔐</div>
          <p className="text-green-600">Checking admin access...</p>
        </div>
      </div>
    );
  }

  if (!user || !isAdmin) return null;

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50">
      {/* Navigation */}
      <nav className="relative z-10 bg-white/80 backdrop-blur-md border-b border-green-200/50">
        <div className="max-w-7xl mx-auto flex items-center justify-between p-6">
          <Link href="/" className="flex items-center space-x-3 group">
            <div className="w-10 h-10 transition-transform group-hover:scale-105">
              <Image src="/certbloom-logo.svg" alt="CertBloom" width={40} height={40} className="w-full h-full object-contain" />
            </div>
            <div className="text-2xl font-light text-green-800 tracking-wide">CertBloom Admin</div>
          </Link>
          <div className="flex items-center space-x-4">
            <Link href="/admin" className="text-green-700 hover:text-green-900 transition-colors font-medium">
              ← Back to Admin
            </Link>
            <Link href="/dashboard" className="text-green-700 hover:text-green-900 transition-colors font-medium">
              Dashboard
            </Link>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <div className="container mx-auto px-6 py-8">
        <div className="max-w-6xl mx-auto">
          {/* Header */}
          <div className="mb-8">
            <div className="flex items-center gap-4">
              <div className="text-4xl">📊</div>
              <div>
                <h1 className="text-3xl font-bold text-green-800">Analytics Dashboard</h1>
                <p className="text-green-600">Platform insights and growth metrics</p>
              </div>
            </div>
          </div>

          {isLoading ? (
            <div className="text-center py-12">
              <div className="text-6xl mb-4 animate-pulse">📈</div>
              <p className="text-green-600">Loading analytics...</p>
            </div>
          ) : !analytics ? (
            <div className="text-center py-12">
              <div className="text-6xl mb-4">⚠️</div>
              <p className="text-red-600">Failed to load analytics data</p>
            </div>
          ) : (
            <div className="space-y-8">
              {/* User Growth Metrics */}
              <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-6 border border-green-200/60 shadow-xl">
                <h2 className="text-xl font-semibold text-green-800 mb-6">User Growth</h2>
                <div className="grid md:grid-cols-3 gap-6">
                  <div className="text-center p-4 bg-blue-50 rounded-xl">
                    <div className="text-3xl font-bold text-blue-700 mb-2">
                      {analytics.userGrowth.totalUsers}
                    </div>
                    <div className="text-sm text-blue-600">Total Users</div>
                  </div>
                  <div className="text-center p-4 bg-green-50 rounded-xl">
                    <div className="text-3xl font-bold text-green-700 mb-2">
                      {analytics.userGrowth.newUsersThisWeek}
                    </div>
                    <div className="text-sm text-green-600">New This Week</div>
                  </div>
                  <div className="text-center p-4 bg-purple-50 rounded-xl">
                    <div className="text-3xl font-bold text-purple-700 mb-2">
                      {analytics.userGrowth.newUsersThisMonth}
                    </div>
                    <div className="text-sm text-purple-600">New This Month</div>
                  </div>
                </div>
              </div>

              {/* Subscription Metrics */}
              <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-6 border border-green-200/60 shadow-xl">
                <h2 className="text-xl font-semibold text-green-800 mb-6">Subscription Metrics</h2>
                <div className="grid md:grid-cols-3 gap-6">
                  <div className="text-center p-4 bg-yellow-50 rounded-xl">
                    <div className="text-3xl font-bold text-yellow-700 mb-2">
                      {analytics.subscriptions.totalPro}
                    </div>
                    <div className="text-sm text-yellow-600">Pro Subscribers</div>
                  </div>
                  <div className="text-center p-4 bg-orange-50 rounded-xl">
                    <div className="text-3xl font-bold text-orange-700 mb-2">
                      {analytics.subscriptions.conversionRate.toFixed(1)}%
                    </div>
                    <div className="text-sm text-orange-600">Conversion Rate</div>
                  </div>
                  <div className="text-center p-4 bg-green-50 rounded-xl">
                    <div className="text-3xl font-bold text-green-700 mb-2">
                      ${(analytics.subscriptions.revenue.monthly + analytics.subscriptions.revenue.yearly).toLocaleString()}
                    </div>
                    <div className="text-sm text-green-600">Est. Monthly Revenue</div>
                  </div>
                </div>
              </div>

              {/* Content Metrics */}
              <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-6 border border-green-200/60 shadow-xl">
                <h2 className="text-xl font-semibold text-green-800 mb-6">Content Overview</h2>
                <div className="grid md:grid-cols-2 gap-6">
                  <div>
                    <h3 className="font-medium text-gray-800 mb-3">Questions by Domain</h3>
                    <div className="space-y-2">
                      {Object.entries(analytics.questionUsage.questionsByDomain).map(([domain, count]) => (
                        <div key={domain} className="flex justify-between items-center p-2 bg-gray-50 rounded">
                          <span className="text-sm text-gray-700">{domain}</span>
                          <span className="font-medium text-gray-900">{count}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                  <div>
                    <h3 className="font-medium text-gray-800 mb-3">Popular Certifications</h3>
                    <div className="space-y-2">
                      {Object.entries(analytics.certificationGoals)
                        .sort(([,a], [,b]) => b - a)
                        .slice(0, 5)
                        .map(([cert, count]) => (
                        <div key={cert} className="flex justify-between items-center p-2 bg-gray-50 rounded">
                          <span className="text-sm text-gray-700">{cert}</span>
                          <span className="font-medium text-gray-900">{count}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              {/* Quick Actions */}
              <div className="grid md:grid-cols-3 gap-6">
                <Link href="/admin/users" className="bg-white/90 backdrop-blur-sm rounded-xl p-6 border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105">
                  <div className="text-3xl mb-3">👥</div>
                  <h4 className="font-semibold text-green-800 mb-2">User Management</h4>
                  <p className="text-green-600 text-sm">View and manage all users</p>
                </Link>
                
                <Link href="/admin/subscriptions" className="bg-white/90 backdrop-blur-sm rounded-xl p-6 border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105">
                  <div className="text-3xl mb-3">💳</div>
                  <h4 className="font-semibold text-green-800 mb-2">Subscriptions</h4>
                  <p className="text-green-600 text-sm">Manage Pro subscribers</p>
                </Link>
                
                <Link href="/admin/questions" className="bg-white/90 backdrop-blur-sm rounded-xl p-6 border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105">
                  <div className="text-3xl mb-3">📝</div>
                  <h4 className="font-semibold text-green-800 mb-2">Questions</h4>
                  <p className="text-green-600 text-sm">Manage question bank</p>
                </Link>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
