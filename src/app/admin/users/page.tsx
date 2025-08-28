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
}

interface UserDetailModalProps {
  user: User | null;
  isOpen: boolean;
  onClose: () => void;
}

function UserDetailModal({ user, isOpen, onClose }: UserDetailModalProps) {
  if (!isOpen || !user) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-2xl p-6 max-w-lg w-full max-h-[80vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold text-green-800">User Details</h2>
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
            <div className="text-green-700 bg-green-50 p-2 rounded">{user.email}</div>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">User ID</label>
            <div className="text-gray-600 bg-gray-50 p-2 rounded text-sm font-mono">{user.id}</div>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Subscription Status</label>
            <div className={`inline-flex px-3 py-1 rounded-full text-sm font-medium ${
              user.subscription_status === 'active' 
                ? 'bg-green-100 text-green-800' 
                : 'bg-gray-100 text-gray-800'
            }`}>
              {user.subscription_status === 'active' ? 'Pro' : 'Free'}
            </div>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Account Created</label>
            <div className="text-gray-600 bg-gray-50 p-2 rounded">
              {new Date(user.created_at).toLocaleDateString('en-US', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
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

export default function UsersPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [users, setUsers] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
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
      fetchUsers();
    }
  }, [user, isAdmin]);

  const fetchUsers = async () => {
    try {
      setIsLoading(true);
      
      console.log('Fetching users via API...');
      
      const response = await fetch('/api/admin/users', {
        headers: {
          'Content-Type': 'application/json',
        },
      });
      
      if (!response.ok) {
        console.error('API response not ok:', response.status, response.statusText);
        setUsers([]);
        return;
      }
      
      const result = await response.json();
      console.log('API Response:', result);
      console.log('Number of users from API:', result.users?.length || 0);
      
      setUsers(result.users || []);
    } catch (error) {
      console.error('Error fetching users:', error);
      setUsers([]);
    } finally {
      setIsLoading(false);
    }
  };  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4 animate-pulse">🌸</div>
          <p className="text-green-600">Loading user sanctuary...</p>
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
          <Link href="/admin" className="flex items-center space-x-3 group">
            <div className="w-10 h-10 transition-transform group-hover:scale-105">
              <Image src="/certbloom-logo.svg" alt="CertBloom" width={40} height={40} className="w-full h-full object-contain" />
            </div>
            <div className="text-2xl font-light text-green-800 tracking-wide">User Management</div>
          </Link>
          <div className="flex items-center space-x-4">
            <Link href="/admin" className="text-green-700 hover:text-green-900 transition-colors font-medium">
              ← Back to Admin
            </Link>
          </div>
        </div>
      </nav>

      <div className="container mx-auto px-6 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-green-800 mb-2">User Management</h1>
          <p className="text-green-600">Monitor user progress and manage accounts</p>
        </div>

        {/* Stats */}
        <div className="grid md:grid-cols-3 gap-6 mb-8">
          <div className="bg-gradient-to-br from-blue-100 to-blue-50 rounded-2xl p-6 border border-blue-200/60 shadow-lg">
            <div className="text-3xl mb-3">👥</div>
            <h3 className="text-lg font-semibold text-blue-800 mb-2">Total Users</h3>
            <div className="text-2xl font-bold text-blue-700">
              {isLoading ? '...' : users.length.toLocaleString()}
            </div>
          </div>

          <div className="bg-gradient-to-br from-green-100 to-green-50 rounded-2xl p-6 border border-green-200/60 shadow-lg">
            <div className="text-3xl mb-3">🌟</div>
            <h3 className="text-lg font-semibold text-green-800 mb-2">Pro Users</h3>
            <div className="text-2xl font-bold text-green-700">
              {isLoading ? '...' : users.filter(u => u.subscription_status === 'active').length.toLocaleString()}
            </div>
          </div>

          <div className="bg-gradient-to-br from-purple-100 to-purple-50 rounded-2xl p-6 border border-purple-200/60 shadow-lg">
            <div className="text-3xl mb-3">🆓</div>
            <h3 className="text-lg font-semibold text-purple-800 mb-2">Free Users</h3>
            <div className="text-2xl font-bold text-purple-700">
              {isLoading ? '...' : users.filter(u => u.subscription_status !== 'active').length.toLocaleString()}
            </div>
          </div>
        </div>

        {/* Users Table */}
        <div className="bg-white/90 backdrop-blur-sm rounded-2xl border border-green-200/60 shadow-xl overflow-hidden">
          <div className="p-6 border-b border-green-200/60">
            <h2 className="text-xl font-semibold text-green-800">All Users</h2>
          </div>
          
          {isLoading ? (
            <div className="p-8 text-center">
              <div className="text-4xl mb-4">🌸</div>
              <p className="text-green-600">Loading users...</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-green-50">
                  <tr>
                    <th className="text-left p-4 font-medium text-green-800">Email</th>
                    <th className="text-left p-4 font-medium text-green-800">Subscription</th>
                    <th className="text-left p-4 font-medium text-green-800">Created</th>
                    <th className="text-left p-4 font-medium text-green-800">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {users.map((user, index) => (
                    <tr key={user.id} className={index % 2 === 0 ? 'bg-white' : 'bg-green-50/30'}>
                      <td className="p-4 text-green-700">{user.email}</td>
                      <td className="p-4">
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                          user.subscription_status === 'active' 
                            ? 'bg-green-100 text-green-800' 
                            : 'bg-gray-100 text-gray-800'
                        }`}>
                          {user.subscription_status === 'active' ? 'Pro' : 'Free'}
                        </span>
                      </td>
                      <td className="p-4 text-green-600">
                        {new Date(user.created_at).toLocaleDateString()}
                      </td>
                      <td className="p-4">
                        <button 
                          onClick={() => {
                            setSelectedUser(user);
                            setIsModalOpen(true);
                          }}
                          className="text-blue-600 hover:text-blue-800 text-sm font-medium hover:underline transition-colors"
                        >
                          View Details
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              
              {users.length === 0 && (
                <div className="p-8 text-center">
                  <div className="text-4xl mb-4">👥</div>
                  <p className="text-gray-500">No users found</p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
      
      {/* User Detail Modal */}
      <UserDetailModal 
        user={selectedUser}
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setSelectedUser(null);
        }}
      />
    </div>
  );
}
