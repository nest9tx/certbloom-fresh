'use client';

import { useAuth } from '../../../../lib/auth-context';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';

interface Question {
  id: string;
  question_text: string;
  certification_id: string;
  domain: string;
  concept: string;
  difficulty_level: 'foundation' | 'application' | 'advanced';
  question_type: 'multiple_choice' | 'true_false' | 'short_answer';
  options?: string[];
  correct_answer: string;
  explanation: string;
  created_at: string;
  updated_at: string;
}

export default function QuestionsPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [questions, setQuestions] = useState<Question[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterDomain, setFilterDomain] = useState('');
  const [filterDifficulty, setFilterDifficulty] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const questionsPerPage = 20;

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
      fetchQuestions();
    }
  }, [user, isAdmin]);

  const fetchQuestions = async () => {
    setIsLoading(true);
    try {
      // Get Supabase session for auth header
      const { createClient } = await import('@supabase/supabase-js');
      const supabase = createClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
      );
      
      const { data: { session } } = await supabase.auth.getSession();
      const authHeader = session?.access_token ? `Bearer ${session.access_token}` : 'Bearer admin-access';

      const response = await fetch('/api/admin/questions', {
        headers: { 'Authorization': authHeader }
      });
      
      if (response.ok) {
        const data = await response.json();
        console.log('Questions received:', data.length, 'questions');
        setQuestions(data);
      } else {
        console.error('Questions fetch error:', await response.text());
      }
    } catch (error) {
      console.error('Error fetching questions:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const deleteQuestion = async (questionId: string) => {
    if (!confirm('Are you sure you want to delete this question?')) return;

    try {
      const response = await fetch(`/api/admin/questions/${questionId}`, {
        method: 'DELETE'
      });

      if (response.ok) {
        setQuestions(questions.filter(q => q.id !== questionId));
      } else {
        alert('Failed to delete question');
      }
    } catch (error) {
      console.error('Error deleting question:', error);
      alert('Error deleting question');
    }
  };

  // Filter questions based on search and filters
  const filteredQuestions = questions.filter(question => {
    const matchesSearch = question.question_text.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         question.concept.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesDomain = !filterDomain || question.domain === filterDomain;
    const matchesDifficulty = !filterDifficulty || question.difficulty_level === filterDifficulty;
    
    return matchesSearch && matchesDomain && matchesDifficulty;
  });

  // Pagination
  const totalPages = Math.ceil(filteredQuestions.length / questionsPerPage);
  const startIndex = (currentPage - 1) * questionsPerPage;
  const paginatedQuestions = filteredQuestions.slice(startIndex, startIndex + questionsPerPage);

  // Get unique domains and difficulties for filters
  const domains = [...new Set(questions.map(q => q.domain))].filter(Boolean);
  const difficulties = ['foundation', 'application', 'advanced'];

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4 animate-pulse">🌸</div>
          <p className="text-green-600">Loading question sanctuary...</p>
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
            <div className="text-2xl font-light text-green-800 tracking-wide">CertBloom Admin</div>
          </Link>
          <div className="flex items-center space-x-4">
            <Link href="/admin" className="text-green-700 hover:text-green-900 transition-colors font-medium">
              Dashboard
            </Link>
            <Link href="/dashboard" className="text-green-700 hover:text-green-900 transition-colors font-medium">
              User View
            </Link>
          </div>
        </div>
      </nav>

      <div className="container mx-auto px-6 py-8">
        {/* Header */}
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold text-green-800 mb-2">Question Management</h1>
            <p className="text-green-600">Manage your adaptive learning question bank</p>
          </div>
          <Link
            href="/admin/questions/new"
            className="px-6 py-3 bg-gradient-to-r from-green-600 to-blue-600 text-white rounded-xl hover:from-green-700 hover:to-blue-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 font-medium"
          >
            ➕ Add New Question
          </Link>
        </div>

        {/* Filters and Search */}
        <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-6 border border-green-200/60 shadow-lg mb-8">
          <div className="grid md:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Search</label>
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search questions or concepts..."
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Domain</label>
              <select
                value={filterDomain}
                onChange={(e) => setFilterDomain(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              >
                <option value="">All Domains</option>
                {domains.map(domain => (
                  <option key={domain} value={domain}>{domain}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Difficulty</label>
              <select
                value={filterDifficulty}
                onChange={(e) => setFilterDifficulty(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              >
                <option value="">All Difficulties</option>
                {difficulties.map(difficulty => (
                  <option key={difficulty} value={difficulty} className="capitalize">
                    {difficulty}
                  </option>
                ))}
              </select>
            </div>
            <div className="flex items-end">
              <button
                onClick={() => {
                  setSearchTerm('');
                  setFilterDomain('');
                  setFilterDifficulty('');
                  setCurrentPage(1);
                }}
                className="w-full px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
              >
                Clear Filters
              </button>
            </div>
          </div>
        </div>

        {/* Statistics */}
        <div className="grid md:grid-cols-3 gap-6 mb-8">
          <div className="bg-blue-50 rounded-xl p-4 border border-blue-200">
            <div className="text-2xl font-bold text-blue-700">{questions.length}</div>
            <div className="text-sm text-blue-600">Total Questions</div>
          </div>
          <div className="bg-green-50 rounded-xl p-4 border border-green-200">
            <div className="text-2xl font-bold text-green-700">{filteredQuestions.length}</div>
            <div className="text-sm text-green-600">Filtered Results</div>
          </div>
          <div className="bg-purple-50 rounded-xl p-4 border border-purple-200">
            <div className="text-2xl font-bold text-purple-700">{domains.length}</div>
            <div className="text-sm text-purple-600">Unique Domains</div>
          </div>
        </div>

        {/* Questions List */}
        <div className="bg-white/90 backdrop-blur-sm rounded-2xl border border-green-200/60 shadow-lg overflow-hidden">
          {isLoading ? (
            <div className="p-8 text-center">
              <div className="text-4xl mb-4">🌸</div>
              <p className="text-green-600">Loading questions...</p>
            </div>
          ) : paginatedQuestions.length === 0 ? (
            <div className="p-8 text-center">
              <div className="text-4xl mb-4">📝</div>
              <p className="text-gray-600 mb-4">No questions found</p>
              <Link
                href="/admin/questions/new"
                className="inline-flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
              >
                Create Your First Question
              </Link>
            </div>
          ) : (
            <>
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-green-50 border-b border-green-200">
                    <tr>
                      <th className="text-left p-4 font-medium text-green-800">Question</th>
                      <th className="text-left p-4 font-medium text-green-800">Domain</th>
                      <th className="text-left p-4 font-medium text-green-800">Concept</th>
                      <th className="text-left p-4 font-medium text-green-800">Difficulty</th>
                      <th className="text-left p-4 font-medium text-green-800">Type</th>
                      <th className="text-left p-4 font-medium text-green-800">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {paginatedQuestions.map((question, index) => (
                      <tr key={question.id} className={index % 2 === 0 ? 'bg-white' : 'bg-green-25'}>
                        <td className="p-4">
                          <div className="max-w-md">
                            <p className="text-sm text-gray-900 line-clamp-2">
                              {question.question_text}
                            </p>
                          </div>
                        </td>
                        <td className="p-4 text-sm text-gray-600">{question.domain}</td>
                        <td className="p-4 text-sm text-gray-600">{question.concept}</td>
                        <td className="p-4">
                          <span className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${
                            question.difficulty_level === 'foundation' 
                              ? 'bg-green-100 text-green-700'
                              : question.difficulty_level === 'application'
                              ? 'bg-blue-100 text-blue-700'
                              : 'bg-purple-100 text-purple-700'
                          }`}>
                            {question.difficulty_level}
                          </span>
                        </td>
                        <td className="p-4 text-sm text-gray-600 capitalize">
                          {question.question_type.replace('_', ' ')}
                        </td>
                        <td className="p-4">
                          <div className="flex space-x-2">
                            <Link
                              href={`/admin/questions/${question.id}/edit`}
                              className="text-blue-600 hover:text-blue-800 text-sm font-medium"
                            >
                              Edit
                            </Link>
                            <button
                              onClick={() => deleteQuestion(question.id)}
                              className="text-red-600 hover:text-red-800 text-sm font-medium"
                            >
                              Delete
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="px-6 py-4 border-t border-green-200 bg-green-25">
                  <div className="flex items-center justify-between">
                    <div className="text-sm text-gray-600">
                      Showing {startIndex + 1} to {Math.min(startIndex + questionsPerPage, filteredQuestions.length)} of {filteredQuestions.length} questions
                    </div>
                    <div className="flex space-x-2">
                      <button
                        onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                        disabled={currentPage === 1}
                        className="px-3 py-1 text-sm bg-white border border-gray-300 rounded hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        Previous
                      </button>
                      <span className="px-3 py-1 text-sm bg-green-600 text-white rounded">
                        {currentPage} of {totalPages}
                      </span>
                      <button
                        onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                        disabled={currentPage === totalPages}
                        className="px-3 py-1 text-sm bg-white border border-gray-300 rounded hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50"
                      >
                        Next
                      </button>
                    </div>
                  </div>
                </div>
              )}
            </>
          )}
        </div>

        {/* Quick Actions */}
        <div className="mt-8 grid md:grid-cols-3 gap-6">
          <Link
            href="/admin/questions/import"
            className="block p-6 bg-gradient-to-br from-purple-100 to-purple-50 rounded-2xl border border-purple-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105"
          >
            <div className="text-3xl mb-3">📤</div>
            <h3 className="text-lg font-semibold text-purple-800 mb-2">Bulk Import</h3>
            <p className="text-purple-600 text-sm">Import multiple questions from CSV or Excel files</p>
          </Link>

          <Link
            href="/admin/questions/export"
            className="block p-6 bg-gradient-to-br from-orange-100 to-orange-50 rounded-2xl border border-orange-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105"
          >
            <div className="text-3xl mb-3">📥</div>
            <h3 className="text-lg font-semibold text-orange-800 mb-2">Export Questions</h3>
            <p className="text-orange-600 text-sm">Download your question bank for backup or sharing</p>
          </Link>

          <Link
            href="/admin/analytics"
            className="block p-6 bg-gradient-to-br from-green-100 to-green-50 rounded-2xl border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105"
          >
            <div className="text-3xl mb-3">📊</div>
            <h3 className="text-lg font-semibold text-green-800 mb-2">Question Analytics</h3>
            <p className="text-green-600 text-sm">View performance metrics and user feedback</p>
          </Link>
        </div>
      </div>
    </div>
  );
}
