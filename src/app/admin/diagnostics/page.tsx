'use client';

import { useAuth } from '../../../lib/auth-context';
import { useEffect, useState } from 'react';

interface DiagnosticData {
  questions: unknown;
  users: unknown;
  questionStats: unknown;
  userStats: unknown;
}

export default function DiagnosticPage() {
  const { user } = useAuth();
  const [data, setData] = useState<DiagnosticData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const isAdmin = user?.email === 'admin@certbloom.com' || user?.email?.includes('@luminanova.com');

  useEffect(() => {
    if (user && isAdmin) {
      runDiagnostics();
    }
  }, [user, isAdmin]);

  const runDiagnostics = async () => {
    setLoading(true);
    setError(null);
    
    try {
      console.log('🔍 Starting diagnostic checks...');
      
      // Get auth token for API calls
      const { data: { session } } = await fetch('/auth/session').then(res => res.json()).catch(() => ({ data: { session: null } }));
      const token = session?.access_token;
      
      if (!token) {
        throw new Error('No authentication token available');
      }

      const headers = {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      };

      // Test direct Supabase queries
      console.log('🔍 Testing question stats API...');
      const questionStatsRes = await fetch('/api/admin/question-stats', { headers });
      const questionStats = questionStatsRes.ok ? await questionStatsRes.json() : { error: await questionStatsRes.text() };
      
      console.log('🔍 Testing user stats API...');
      const userStatsRes = await fetch('/api/admin/user-stats', { headers });
      const userStats = userStatsRes.ok ? await userStatsRes.json() : { error: await userStatsRes.text() };

      // Test questions API
      console.log('🔍 Testing questions API...');
      const questionsRes = await fetch('/api/admin/questions', { headers });
      const questions = questionsRes.ok ? await questionsRes.json() : { error: await questionsRes.text() };

      setData({
        questions,
        users: { placeholder: 'user data' },
        questionStats,
        userStats
      });

      console.log('✅ Diagnostic complete!', {
        questionStats,
        userStats,
        questions
      });

    } catch (err) {
      console.error('❌ Diagnostic error:', err);
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  if (!user) {
    return <div className="p-8">Please log in to access diagnostics.</div>;
  }

  if (!isAdmin) {
    return <div className="p-8">Admin access required.</div>;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 p-8">
      <div className="max-w-6xl mx-auto">
        <div className="bg-white rounded-2xl shadow-xl p-8">
          <h1 className="text-3xl font-bold text-green-800 mb-6">🔍 System Diagnostics</h1>
          
          <button 
            onClick={runDiagnostics}
            disabled={loading}
            className="mb-6 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
          >
            {loading ? '⏳ Running Diagnostics...' : '🔄 Run Diagnostics'}
          </button>

          {error && (
            <div className="mb-6 p-4 bg-red-100 border border-red-300 rounded-lg">
              <h3 className="font-semibold text-red-800">Error:</h3>
              <p className="text-red-700">{error}</p>
            </div>
          )}

          {data && (
            <div className="space-y-6">
              <div className="bg-blue-50 p-6 rounded-lg">
                <h2 className="text-xl font-semibold text-blue-800 mb-4">📊 Question Statistics</h2>
                <pre className="bg-white p-4 rounded border overflow-auto text-sm">
                  {JSON.stringify(data.questionStats, null, 2)}
                </pre>
              </div>

              <div className="bg-green-50 p-6 rounded-lg">
                <h2 className="text-xl font-semibold text-green-800 mb-4">👥 User Statistics</h2>
                <pre className="bg-white p-4 rounded border overflow-auto text-sm">
                  {JSON.stringify(data.userStats, null, 2)}
                </pre>
              </div>

              <div className="bg-purple-50 p-6 rounded-lg">
                <h2 className="text-xl font-semibold text-purple-800 mb-4">❓ Questions Data</h2>
                <pre className="bg-white p-4 rounded border overflow-auto text-sm max-h-96">
                  {JSON.stringify(data.questions, null, 2)}
                </pre>
              </div>
            </div>
          )}

          <div className="mt-8 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
            <h3 className="font-semibold text-yellow-800 mb-2">📝 CSV Import Tips:</h3>
            <ul className="text-yellow-700 text-sm space-y-1">
              <li>• Ensure CSV has proper comma separation (not all in one column)</li>
              <li>• Use the template file: <code>question-import-template.csv</code></li>
              <li>• Required headers: question_text, certification_id, domain, concept, difficulty_level, question_type, correct_answer, explanation</li>
              <li>• Certification IDs should match: &ldquo;math-ec-6&rdquo;, &ldquo;ela-ec-6&rdquo;, &ldquo;science-ec-6&rdquo;, &ldquo;social-studies-ec-6&rdquo;, &ldquo;core-subjects-ec-6&rdquo;</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
