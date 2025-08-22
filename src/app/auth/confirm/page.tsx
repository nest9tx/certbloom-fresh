'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '../../../../lib/supabase';

export default function AuthConfirmPage() {
  const router = useRouter();
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading');
  const [message, setMessage] = useState('');

  useEffect(() => {
    const handleAuthCallback = async () => {
      try {
        if (!supabase) {
          setStatus('error');
          setMessage('Configuration error. Please try again later.');
          return;
        }

        // Supabase sends auth data in URL hash, need to parse it
        const hashParams = new URLSearchParams(window.location.hash.substring(1));
        const accessToken = hashParams.get('access_token');
        const refreshToken = hashParams.get('refresh_token');
        
        if (accessToken && refreshToken) {
          // Set the session with the tokens from the URL
          const { data, error } = await supabase.auth.setSession({
            access_token: accessToken,
            refresh_token: refreshToken,
          });

          if (error) {
            console.error('Error setting session:', error);
            setStatus('error');
            setMessage('Failed to confirm your account. Please try again.');
            return;
          }

          if (data.session) {
            setStatus('success');
            setMessage('Account confirmed successfully! Redirecting to dashboard...');
            // Force a page reload to trigger auth context update, then redirect
            setTimeout(() => {
              window.location.href = '/dashboard';
            }, 2000);
          } else {
            setStatus('error');
            setMessage('Unable to create session. Please try signing in again.');
          }
        } else {
          // Fallback to checking existing session
          if (!supabase) {
            setStatus('error');
            setMessage('Configuration error. Please try again later.');
            return;
          }

          const { data, error } = await supabase.auth.getSession();
          
          if (error) {
            console.error('Auth callback error:', error);
            setStatus('error');
            setMessage('Confirmation failed. Please try again.');
            return;
          }

          if (data.session) {
            setStatus('success');
            setMessage('Already signed in! Redirecting to dashboard...');
            setTimeout(() => {
              window.location.href = '/dashboard';
            }, 1000);
          } else {
            setStatus('error');
            setMessage('No confirmation data found. Please check your email link.');
          }
        }
      } catch (error) {
        console.error('Unexpected error during auth callback:', error);
        setStatus('error');
        setMessage('An unexpected error occurred. Please try again.');
      }
    };

    handleAuthCallback();
  }, [router]);

  if (status === 'success') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4">✅</div>
          <h1 className="text-2xl font-light text-green-800 mb-4">Account Confirmed!</h1>
          <p className="text-green-600">{message}</p>
        </div>
      </div>
    );
  }

  if (status === 'error') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4">❌</div>
          <h1 className="text-2xl font-light text-red-800 mb-4">Confirmation Failed</h1>
          <p className="text-red-600 mb-6">{message}</p>
          <button
            onClick={() => router.push('/auth')}
            className="px-6 py-3 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors"
          >
            Back to Sign In
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 flex items-center justify-center">
      <div className="text-center">
        <div className="text-6xl mb-4 animate-pulse">🌸</div>
        <h1 className="text-2xl font-light text-green-800 mb-4">Confirming your account...</h1>
        <p className="text-green-600">Please wait while we set up your CertBloom journey.</p>
      </div>
    </div>
  );
}