'use client';

import { useState, useEffect, Suspense } from 'react';
import { useAuth } from '../../../lib/auth-context';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';

function AuthPageContent() {
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [showEmailSent, setShowEmailSent] = useState(false);
  
  const { signUp, signIn, user } = useAuth();
  const router = useRouter();
  const searchParams = useSearchParams();

  // Check for error messages in URL parameters
  useEffect(() => {
    const errorParam = searchParams.get('error');
    if (errorParam) {
      switch (errorParam) {
        case 'confirmation_failed':
          setError('Email confirmation failed. Please try signing up again.');
          break;
        case 'unexpected_error':
          setError('An unexpected error occurred. Please try again.');
          break;
        default:
          setError('Something went wrong. Please try again.');
      }
    }
  }, [searchParams]);

  // Redirect if already logged in
  useEffect(() => {
    if (user) {
      router.push('/dashboard');
    }
  }, [user, router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      if (isSignUp) {
        const result = await signUp(email, password, fullName);
        if (result.success) {
          setShowEmailSent(true);
          // Don't redirect immediately for sign up - user needs to confirm email
        } else {
          setError(result.error || 'Something went wrong');
        }
      } else {
        const result = await signIn(email, password);
        if (result.success) {
          router.push('/dashboard');
        } else {
          setError(result.error || 'Something went wrong');
        }
      }
    } catch {
      setError('An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center px-6">
      <div className="max-w-md w-full">
        <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-8 border border-green-200/50 shadow-lg">
          {/* Header */}
          <div className="text-center mb-8">
            <div className="text-6xl mb-4">🌸</div>
            <h1 className="text-3xl font-light text-green-800 mb-2">
              {isSignUp ? 'Join CertBloom' : 'Welcome Back'}
            </h1>
            <p className="text-green-600">
              {isSignUp 
                ? 'Start your mindful certification journey' 
                : 'Continue your learning path'
              }
            </p>
          </div>

          {/* Show email sent message */}
          {showEmailSent ? (
            <div className="text-center space-y-6">
              <div className="bg-green-50 border border-green-200 rounded-xl p-6">
                <div className="text-4xl mb-4">📧</div>
                <h2 className="text-xl font-medium text-green-800 mb-2">Check your email!</h2>
                <p className="text-green-600 mb-4">
                  We&apos;ve sent you a confirmation link at <strong>{email}</strong>
                </p>
                <p className="text-sm text-green-500">
                  Click the link in your email to activate your CertBloom account and start your journey.
                </p>
              </div>
              
              <button
                onClick={() => setShowEmailSent(false)}
                className="text-green-600 hover:text-green-800 transition-colors"
              >
                ← Back to sign up
              </button>
            </div>
          ) : (
            /* Form */
            <form onSubmit={handleSubmit} className="space-y-6">
            {isSignUp && (
              <div>
                <label htmlFor="fullName" className="block text-sm font-medium text-green-700 mb-2">
                  Full Name
                </label>
                <input
                  type="text"
                  id="fullName"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  required
                  className="w-full px-4 py-3 rounded-xl border border-green-300 focus:outline-none focus:ring-2 focus:ring-green-500 bg-white/90 text-gray-800"
                  placeholder="Enter your full name"
                />
              </div>
            )}

            <div>
              <label htmlFor="email" className="block text-sm font-medium text-green-700 mb-2">
                Email
              </label>
              <input
                type="email"
                id="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full px-4 py-3 rounded-xl border border-green-300 focus:outline-none focus:ring-2 focus:ring-green-500 bg-white/90 text-gray-800"
                placeholder="Enter your email"
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-green-700 mb-2">
                Password
              </label>
              <input
                type="password"
                id="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                minLength={6}
                className="w-full px-4 py-3 rounded-xl border border-green-300 focus:outline-none focus:ring-2 focus:ring-green-500 bg-white/90 text-gray-800"
                placeholder="Enter your password"
              />
            </div>

            {error && (
              <div className="bg-red-50 border border-red-200 rounded-xl p-4">
                <p className="text-red-600 text-sm">{error}</p>
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors font-medium disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading 
                ? (isSignUp ? 'Creating Account...' : 'Signing In...') 
                : (isSignUp ? 'Create Account' : 'Sign In')
              }
            </button>
          </form>
          )}

          {/* Toggle */}
          {!showEmailSent && (
            <div className="text-center mt-6">
              <button
                type="button"
                onClick={() => {
                  setIsSignUp(!isSignUp);
                  setError('');
                }}
                className="text-green-600 hover:text-green-800 transition-colors"
              >
                {isSignUp 
                  ? 'Already have an account? Sign in' 
                  : 'Need an account? Sign up'
                }
              </button>
            </div>
          )}

          {/* Back to Home */}
          <div className="text-center mt-4">
            <Link
              href="/"
              className="text-sm text-green-500 hover:text-green-700 transition-colors"
            >
              ← Back to Home
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function AuthPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4 animate-pulse">🌸</div>
          <h1 className="text-2xl font-light text-green-800 mb-4">Loading...</h1>
        </div>
      </div>
    }>
      <AuthPageContent />
    </Suspense>
  );
}
