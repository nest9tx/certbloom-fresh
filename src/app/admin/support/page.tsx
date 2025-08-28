'use client';

import { useAuth } from '../../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';

interface SupportMessage {
  id: string;
  email: string;
  subject: string;
  message: string;
  created_at: string;
  status: 'open' | 'in_progress' | 'resolved';
}

export default function SupportPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [supportMessages] = useState<SupportMessage[]>([
    // Placeholder data - in a real app, this would come from a database
    {
      id: '1',
      email: 'teacher@example.com',
      subject: 'Question about EC-6 Math certification',
      message: 'I\'m having trouble understanding the place value concepts. Could you provide more examples?',
      created_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
      status: 'open'
    },
    {
      id: '2',
      email: 'student@school.edu',
      subject: 'Subscription billing question',
      message: 'I was charged twice for my subscription. Can you help me resolve this?',
      created_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
      status: 'in_progress'
    },
    {
      id: '3',
      email: 'future.teacher@university.edu',
      subject: 'Thank you for the platform!',
      message: 'This platform has been incredibly helpful for my certification prep. The mindful learning approach really works!',
      created_at: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(),
      status: 'resolved'
    }
  ]);

  const isAdmin = user?.email === 'admin@certbloom.com' || user?.email?.includes('@luminanova.com');

  useEffect(() => {
    if (!loading && !user) {
      router.push('/auth');
    } else if (!loading && user && !isAdmin) {
      router.push('/dashboard');
    }
  }, [user, loading, isAdmin, router]);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'open':
        return 'bg-red-100 text-red-800';
      case 'in_progress':
        return 'bg-yellow-100 text-yellow-800';
      case 'resolved':
        return 'bg-green-100 text-green-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusEmoji = (status: string) => {
    switch (status) {
      case 'open':
        return '🔴';
      case 'in_progress':
        return '🟡';
      case 'resolved':
        return '✅';
      default:
        return '⚪';
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

  const openTickets = supportMessages.filter(msg => msg.status === 'open').length;
  const inProgressTickets = supportMessages.filter(msg => msg.status === 'in_progress').length;

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
            <div className="flex items-center gap-4 mb-6">
              <div className="text-4xl">🎧</div>
              <div>
                <h1 className="text-3xl font-bold text-green-800">Support Center</h1>
                <p className="text-green-600">Manage user support requests and communications</p>
              </div>
            </div>

            {/* Stats Cards */}
            <div className="grid md:grid-cols-3 gap-6 mb-8">
              <div className="bg-gradient-to-r from-red-100 to-red-50 rounded-2xl p-6 border border-red-200/60 shadow-lg">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="text-lg font-semibold text-red-800 mb-2">Open Tickets</h3>
                    <div className="text-3xl font-bold text-red-700">{openTickets}</div>
                  </div>
                  <div className="text-5xl opacity-50">🔴</div>
                </div>
              </div>

              <div className="bg-gradient-to-r from-yellow-100 to-yellow-50 rounded-2xl p-6 border border-yellow-200/60 shadow-lg">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="text-lg font-semibold text-yellow-800 mb-2">In Progress</h3>
                    <div className="text-3xl font-bold text-yellow-700">{inProgressTickets}</div>
                  </div>
                  <div className="text-5xl opacity-50">🟡</div>
                </div>
              </div>

              <div className="bg-gradient-to-r from-green-100 to-green-50 rounded-2xl p-6 border border-green-200/60 shadow-lg">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="text-lg font-semibold text-green-800 mb-2">Total Messages</h3>
                    <div className="text-3xl font-bold text-green-700">{supportMessages.length}</div>
                  </div>
                  <div className="text-5xl opacity-50">📬</div>
                </div>
              </div>
            </div>
          </div>

          {/* Support Messages */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl border border-green-200/60 shadow-xl overflow-hidden">
            <div className="p-6 border-b border-green-200/60">
              <h3 className="text-xl font-semibold text-green-800">Recent Support Messages</h3>
              <p className="text-green-600 text-sm">Support requests and user communications</p>
            </div>

            <div className="divide-y divide-green-200/60">
              {supportMessages.map((message) => (
                <div key={message.id} className="p-6 hover:bg-green-50/50 transition-colors">
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-2">
                        <span className="font-medium text-green-800">{message.email}</span>
                        <span className={`px-2 py-1 text-xs rounded-full font-medium ${getStatusColor(message.status)}`}>
                          {getStatusEmoji(message.status)} {message.status.replace('_', ' ')}
                        </span>
                      </div>
                      <h4 className="font-medium text-gray-800 mb-2">{message.subject}</h4>
                      <p className="text-gray-600 text-sm mb-3 line-clamp-2">{message.message}</p>
                      <div className="text-xs text-gray-500">
                        {new Date(message.created_at).toLocaleDateString('en-US', {
                          weekday: 'short',
                          year: 'numeric',
                          month: 'short',
                          day: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit'
                        })}
                      </div>
                    </div>
                    <div className="flex gap-2 ml-4">
                      <button className="px-3 py-1 bg-blue-600 text-white text-xs rounded hover:bg-blue-700 transition-colors">
                        Reply
                      </button>
                      {message.status !== 'resolved' && (
                        <button className="px-3 py-1 bg-green-600 text-white text-xs rounded hover:bg-green-700 transition-colors">
                          Resolve
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Support Resources */}
          <div className="mt-8">
            <h3 className="text-xl font-semibold text-green-800 mb-6">Support Resources</h3>
            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
              <div className="bg-white/90 backdrop-blur-sm rounded-xl p-6 border border-green-200/60 shadow-lg">
                <div className="text-3xl mb-3">📚</div>
                <h4 className="font-semibold text-green-800 mb-2">Documentation</h4>
                <p className="text-green-600 text-sm mb-3">Create help documentation for users</p>
                <button className="text-green-600 hover:text-green-700 text-sm font-medium">
                  Coming Soon →
                </button>
              </div>

              <div className="bg-white/90 backdrop-blur-sm rounded-xl p-6 border border-green-200/60 shadow-lg">
                <div className="text-3xl mb-3">💬</div>
                <h4 className="font-semibold text-green-800 mb-2">Live Chat</h4>
                <p className="text-green-600 text-sm mb-3">Enable real-time support chat</p>
                <button className="text-green-600 hover:text-green-700 text-sm font-medium">
                  Coming Soon →
                </button>
              </div>

              <Link href="/admin/users" className="bg-white/90 backdrop-blur-sm rounded-xl p-6 border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105">
                <div className="text-3xl mb-3">👥</div>
                <h4 className="font-semibold text-green-800 mb-2">User Lookup</h4>
                <p className="text-green-600 text-sm mb-3">Find user accounts for support</p>
                <span className="text-green-600 hover:text-green-700 text-sm font-medium">
                  View Users →
                </span>
              </Link>

              <Link href="/contact" className="bg-white/90 backdrop-blur-sm rounded-xl p-6 border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105">
                <div className="text-3xl mb-3">📧</div>
                <h4 className="font-semibold text-green-800 mb-2">Contact Form</h4>
                <p className="text-green-600 text-sm mb-3">View public contact page</p>
                <span className="text-green-600 hover:text-green-700 text-sm font-medium">
                  View Page →
                </span>
              </Link>
            </div>
          </div>

          {/* Note about future implementation */}
          <div className="mt-8 bg-gradient-to-r from-blue-50 to-purple-50 border border-blue-200 rounded-2xl p-6">
            <div className="flex items-start space-x-4">
              <div className="text-3xl">🔧</div>
              <div>
                <h3 className="text-lg font-semibold text-blue-900 mb-2">Support System Development</h3>
                <p className="text-blue-800 mb-3">
                  This support center is currently showing placeholder data. In production, this would connect to:
                </p>
                <ul className="text-blue-700 text-sm space-y-1 pl-4">
                  <li>• Email integration for support tickets</li>
                  <li>• Database storage for support messages</li>
                  <li>• Status management and assignment system</li>
                  <li>• Email notifications for responses</li>
                  <li>• Integration with contact form submissions</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
