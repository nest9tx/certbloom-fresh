'use client';

import { useAuth } from '../../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';

interface Subscriber {
  id: string;
  email: string;
  subscription_status: string;
  stripe_customer_id: string | null;
  created_at: string;
  certification_goal: string | null;
}

interface SubscriberDetailModalProps {
  subscriber: Subscriber | null;
  isOpen: boolean;
  onClose: () => void;
}

function SubscriberDetailModal({ subscriber, isOpen, onClose }: SubscriberDetailModalProps) {
  if (!isOpen || !subscriber) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-2xl p-6 max-w-lg w-full max-h-[80vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold text-green-800">Pro Subscriber Details</h2>
          <button 
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700 text-2xl"
          >
            ×
          </button>
        </div>
        
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <div className="text-green-700 bg-green-50 p-2 rounded">{subscriber.email}</div>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Certification Goal</label>
            <div className="text-blue-600 bg-blue-50 p-2 rounded">
              {subscriber.certification_goal || 'Not set'}
            </div>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Stripe Customer ID</label>
            <div className="text-gray-600 bg-gray-50 p-2 rounded text-sm font-mono">
              {subscriber.stripe_customer_id || 'Not available'}
            </div>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Subscription Date</label>
            <div className="text-gray-600 bg-gray-50 p-2 rounded">
              {new Date(subscriber.created_at).toLocaleDateString('en-US', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric'
              })}
            </div>
          </div>
        </div>
        
        <div className="mt-6 flex justify-end">
          <button 
            onClick={onClose}
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
}

export default function SubscriptionsPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [subscribers, setSubscribers] = useState<Subscriber[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedSubscriber, setSelectedSubscriber] = useState<Subscriber | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

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
      fetchSubscribers();
    }
  }, [user, isAdmin]);

  const fetchSubscribers = async () => {
    setIsLoading(true);
    try {
      const { createClient } = await import('@supabase/supabase-js');
      const supabase = createClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
      );
      
      const { data: { session } } = await supabase.auth.getSession();
      const authHeader = session?.access_token ? `Bearer ${session.access_token}` : 'Bearer admin-access';

      const response = await fetch('/api/admin/users', {
        headers: { 'Authorization': authHeader }
      });
      
      if (response.ok) {
        const responseData = await response.json();
        console.log('👥 API response received:', responseData);
        
        // The API returns { users: [...], total: n }, so we need to extract the users array
        const allUsers = responseData.users || [];
        
        // Ensure allUsers is an array before filtering
        if (Array.isArray(allUsers)) {
          // Filter to only show Pro subscribers
          const proSubscribers = allUsers.filter((u: Subscriber) => u.subscription_status === 'active');
          console.log('💳 Pro subscribers found:', proSubscribers);
          setSubscribers(proSubscribers);
        } else {
          console.error('Users data is not an array:', allUsers);
          setSubscribers([]);
        }
      } else {
        console.error('Failed to fetch subscribers:', response.status, response.statusText);
      }
    } catch (error) {
      console.error('Error fetching subscribers:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleViewSubscriber = (subscriber: Subscriber) => {
    setSelectedSubscriber(subscriber);
    setIsModalOpen(true);
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
            <div className="flex items-center gap-4 mb-4">
              <div className="text-4xl">💳</div>
              <div>
                <h1 className="text-3xl font-bold text-green-800">Pro Subscriptions</h1>
                <p className="text-green-600">Manage and monitor Pro subscribers</p>
              </div>
            </div>

            {/* Stats Card */}
            <div className="bg-gradient-to-r from-purple-100 to-blue-100 rounded-2xl p-6 border border-purple-200/60 shadow-lg">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-lg font-semibold text-purple-800 mb-2">Active Pro Subscribers</h3>
                  <div className="text-3xl font-bold text-purple-700">
                    {isLoading ? '...' : subscribers.length}
                  </div>
                </div>
                <div className="text-5xl opacity-50">🌟</div>
              </div>
            </div>
          </div>

          {/* Subscribers List */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl border border-green-200/60 shadow-xl overflow-hidden">
            <div className="p-6 border-b border-green-200/60">
              <h3 className="text-xl font-semibold text-green-800">Pro Subscribers</h3>
              <p className="text-green-600 text-sm">Current active subscribers with Pro access</p>
            </div>

            {isLoading ? (
              <div className="p-8 text-center">
                <div className="text-4xl mb-4 animate-pulse">⏳</div>
                <p className="text-green-600">Loading subscribers...</p>
              </div>
            ) : subscribers.length === 0 ? (
              <div className="p-8 text-center">
                <div className="text-4xl mb-4">📭</div>
                <p className="text-gray-600">No Pro subscribers yet</p>
              </div>
            ) : (
              <div className="divide-y divide-green-200/60">
                {subscribers.map((subscriber, index) => (
                  <div key={subscriber.id} className="p-6 hover:bg-green-50/50 transition-colors">
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <div className="flex items-center gap-3 mb-2">
                          <span className="text-sm font-medium text-gray-500">#{index + 1}</span>
                          <span className="font-medium text-green-800">{subscriber.email}</span>
                          <span className="px-2 py-1 bg-purple-100 text-purple-800 text-xs rounded-full font-medium">
                            Pro
                          </span>
                        </div>
                        <div className="text-sm text-gray-600">
                          <span className="mr-4">
                            📚 {subscriber.certification_goal || 'No goal set'}
                          </span>
                          <span>
                            📅 Subscribed: {new Date(subscriber.created_at).toLocaleDateString()}
                          </span>
                        </div>
                      </div>
                      <button
                        onClick={() => handleViewSubscriber(subscriber)}
                        className="px-4 py-2 bg-green-600 text-white text-sm rounded-lg hover:bg-green-700 transition-colors"
                      >
                        View Details
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Quick Actions */}
          <div className="mt-8 grid md:grid-cols-3 gap-6">
            <Link href="/admin/users" className="bg-white/90 backdrop-blur-sm rounded-xl p-6 border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105">
              <div className="text-3xl mb-3">👥</div>
              <h4 className="font-semibold text-green-800 mb-2">All Users</h4>
              <p className="text-green-600 text-sm">View all registered users</p>
            </Link>
            
            <Link href="/admin" className="bg-white/90 backdrop-blur-sm rounded-xl p-6 border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105">
              <div className="text-3xl mb-3">📊</div>
              <h4 className="font-semibold text-green-800 mb-2">Dashboard</h4>
              <p className="text-green-600 text-sm">Return to admin overview</p>
            </Link>
            
            <Link href="/pricing" className="bg-white/90 backdrop-blur-sm rounded-xl p-6 border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105">
              <div className="text-3xl mb-3">💰</div>
              <h4 className="font-semibold text-green-800 mb-2">Pricing</h4>
              <p className="text-green-600 text-sm">View pricing plans</p>
            </Link>
          </div>
        </div>
      </div>

      {/* Subscriber Detail Modal */}
      <SubscriberDetailModal
        subscriber={selectedSubscriber}
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
    </div>
  );
}
