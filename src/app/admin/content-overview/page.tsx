'use client';

import { useAuth } from '../../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';

interface ContentProgress {
  certification: string;
  domains: {
    name: string;
    foundation: number;
    application: number;
    advanced: number;
    total: number;
    target: number;
  }[];
  totalQuestions: number;
  targetQuestions: number;
  completionPercentage: number;
}

export default function ContentOverviewPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [progressData, setProgressData] = useState<ContentProgress[]>([]);
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
      fetchProgressData();
    }
  }, [user, isAdmin]);

  const fetchProgressData = async () => {
    setIsLoading(true);
    try {
      const response = await fetch('/api/admin/content-progress');
      if (response.ok) {
        const data = await response.json();
        setProgressData(data);
      }
    } catch (error) {
      console.error('Error fetching progress data:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // Calculate overall progress
  const overallStats = progressData.reduce((acc, cert) => {
    acc.totalQuestions += cert.totalQuestions;
    acc.targetQuestions += cert.targetQuestions;
    return acc;
  }, { totalQuestions: 0, targetQuestions: 0 });

  const overallCompletion = overallStats.targetQuestions > 0 
    ? Math.round((overallStats.totalQuestions / overallStats.targetQuestions) * 100)
    : 0;

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4 animate-pulse">🌸</div>
          <p className="text-green-600">Loading content overview...</p>
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
            <div className="text-2xl font-light text-green-800 tracking-wide">Content Overview</div>
          </Link>
          <div className="flex items-center space-x-4">
            <Link href="/admin" className="text-green-700 hover:text-green-900 transition-colors font-medium">
              ← Admin Dashboard
            </Link>
          </div>
        </div>
      </nav>

      <div className="container mx-auto px-6 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-green-800 mb-2">Content Creation Progress</h1>
          <p className="text-green-600">Track progress toward your complete question bank vision</p>
        </div>

        {/* Current Status Notice */}
        <div className="mb-8 bg-gradient-to-r from-amber-50 to-orange-50 border border-amber-200 rounded-2xl p-6">
          <div className="flex items-start space-x-4">
            <div className="text-3xl">🚧</div>
            <div>
              <h3 className="text-lg font-semibold text-amber-900 mb-2">Content Tracking System</h3>
              <p className="text-amber-800 mb-3">
                This page is designed to track progress as you build out your complete question bank across certifications and domains.
                Currently showing basic metrics from existing questions.
              </p>
              <div className="text-amber-700 text-sm">
                <strong>Future functionality:</strong> Set targets per certification/domain, track upload progress, identify content gaps
              </div>
            </div>
          </div>
        </div>

        {/* Overall Progress */}
        <div className="bg-gradient-to-r from-blue-50 to-purple-50 rounded-2xl p-8 border border-blue-200/60 shadow-lg mb-8">
          <h2 className="text-2xl font-semibold text-blue-800 mb-6 text-center">🎯 Overall Progress</h2>
          
          <div className="grid md:grid-cols-3 gap-6 mb-6">
            <div className="text-center p-6 bg-white/70 rounded-xl">
              <div className="text-3xl font-bold text-blue-700">{overallStats.totalQuestions}</div>
              <div className="text-sm text-blue-600">Current Questions</div>
            </div>
            <div className="text-center p-6 bg-white/70 rounded-xl">
              <div className="text-3xl font-bold text-green-700">{overallStats.targetQuestions}</div>
              <div className="text-sm text-green-600">Target Questions</div>
            </div>
            <div className="text-center p-6 bg-white/70 rounded-xl">
              <div className="text-3xl font-bold text-purple-700">{overallCompletion}%</div>
              <div className="text-sm text-purple-600">Complete</div>
            </div>
          </div>

          <div className="w-full bg-gray-200 rounded-full h-4 mb-4">
            <div 
              className="bg-gradient-to-r from-green-500 to-blue-500 h-4 rounded-full transition-all duration-1000"
              style={{ width: `${Math.min(overallCompletion, 100)}%` }}
            ></div>
          </div>
          
          <div className="text-center text-blue-700">
            {overallStats.targetQuestions - overallStats.totalQuestions} questions remaining to reach vision
          </div>
        </div>

        {/* Certification Progress */}
        {isLoading ? (
          <div className="text-center py-12">
            <div className="text-4xl mb-4">⏳</div>
            <p className="text-green-600">Loading certification progress...</p>
          </div>
        ) : (
          <div className="space-y-8">
            {progressData.map((cert) => (
              <div key={cert.certification} className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-lg">
                <div className="flex justify-between items-center mb-6">
                  <h3 className="text-xl font-semibold text-green-800">{cert.certification}</h3>
                  <div className="text-right">
                    <div className="text-2xl font-bold text-green-700">{cert.completionPercentage}%</div>
                    <div className="text-sm text-green-600">{cert.totalQuestions} of {cert.targetQuestions}</div>
                  </div>
                </div>

                <div className="w-full bg-gray-200 rounded-full h-3 mb-6">
                  <div 
                    className="bg-gradient-to-r from-green-500 to-green-600 h-3 rounded-full transition-all duration-500"
                    style={{ width: `${Math.min(cert.completionPercentage, 100)}%` }}
                  ></div>
                </div>

                {/* Domain Breakdown */}
                <div className="grid gap-4">
                  {cert.domains.map((domain) => (
                    <div key={domain.name} className="bg-green-50 rounded-lg p-4">
                      <div className="flex justify-between items-center mb-3">
                        <h4 className="font-medium text-green-800">{domain.name}</h4>
                        <span className="text-sm text-green-600">
                          {domain.total} / {domain.target} questions
                        </span>
                      </div>
                      
                      <div className="grid grid-cols-3 gap-3 text-sm">
                        <div className="text-center p-2 bg-blue-100 rounded">
                          <div className="font-bold text-blue-700">{domain.foundation}</div>
                          <div className="text-blue-600">Foundation</div>
                        </div>
                        <div className="text-center p-2 bg-green-100 rounded">
                          <div className="font-bold text-green-700">{domain.application}</div>
                          <div className="text-green-600">Application</div>
                        </div>
                        <div className="text-center p-2 bg-purple-100 rounded">
                          <div className="font-bold text-purple-700">{domain.advanced}</div>
                          <div className="text-purple-600">Advanced</div>
                        </div>
                      </div>

                      <div className="mt-3 w-full bg-gray-200 rounded-full h-2">
                        <div 
                          className="bg-gradient-to-r from-green-400 to-green-500 h-2 rounded-full transition-all duration-300"
                          style={{ width: `${Math.min((domain.total / domain.target) * 100, 100)}%` }}
                        ></div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Quick Actions */}
        <div className="mt-8 grid md:grid-cols-3 gap-6">
          <Link
            href="/admin/questions/new"
            className="block p-6 bg-gradient-to-br from-green-100 to-green-50 rounded-2xl border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105"
          >
            <div className="text-3xl mb-3">➕</div>
            <h3 className="text-lg font-semibold text-green-800 mb-2">Add Single Question</h3>
            <p className="text-green-600 text-sm">Create a carefully crafted question</p>
          </Link>

          <Link
            href="/admin/questions/import"
            className="block p-6 bg-gradient-to-br from-blue-100 to-blue-50 rounded-2xl border border-blue-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105"
          >
            <div className="text-3xl mb-3">📤</div>
            <h3 className="text-lg font-semibold text-blue-800 mb-2">Bulk Import</h3>
            <p className="text-blue-600 text-sm">Upload multiple questions efficiently</p>
          </Link>

          <Link
            href="/admin/questions"
            className="block p-6 bg-gradient-to-br from-purple-100 to-purple-50 rounded-2xl border border-purple-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105"
          >
            <div className="text-3xl mb-3">📋</div>
            <h3 className="text-lg font-semibold text-purple-800 mb-2">Manage Questions</h3>
            <p className="text-purple-600 text-sm">Edit and organize existing questions</p>
          </Link>
        </div>
      </div>
    </div>
  );
}
