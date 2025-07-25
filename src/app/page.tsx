'use client';

import { useState, useEffect } from 'react';
import { signupForEarlyAccess } from '../../lib/supabase';
import { useAuth } from '../../lib/auth-context';
import Link from 'next/link';

export default function HomePage() {
  const [pulsePhase, setPulsePhase] = useState(0);
  const [email, setEmail] = useState('');
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');
  const [floatingElements, setFloatingElements] = useState<Array<{left: string, top: string, delay: string, duration: string}>>([]);
  
  const { user, signOut } = useAuth();

  useEffect(() => {
    const interval = setInterval(() => {
      setPulsePhase(prev => (prev + 1) % 3);
    }, 2000);

    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    // Generate floating elements on client side only to prevent hydration mismatch
    const elements = Array(20).fill(0).map(() => ({
      left: `${Math.random() * 100}%`,
      top: `${20 + Math.random() * 70}%`,
      delay: `${Math.random() * 4}s`,
      duration: `${3 + Math.random() * 2}s`
    }));
    setFloatingElements(elements);
  }, []);

  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || isSubmitting) return;
    
    setIsSubmitting(true);
    setSubmitError('');
    
    const result = await signupForEarlyAccess(email);
    
    if (result.success) {
      setIsSubmitted(true);
      console.log('Email submitted successfully:', email);
    } else {
      setSubmitError(result.error || 'Something went wrong. Please try again.');
    }
    
    setIsSubmitting(false);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 relative overflow-hidden">
      {/* Floating Elements */}
      <div className="absolute inset-0">
        {floatingElements.map((element, i) => (
          <div
            key={i}
            className="absolute animate-pulse text-green-300 opacity-30"
            style={{
              left: element.left,
              top: element.top,
              animationDelay: element.delay,
              animationDuration: element.duration
            }}
          >
            🌸
          </div>
        ))}
      </div>

      {/* Navigation */}
      <nav className="relative z-10 flex items-center justify-between p-6">
        <div className="flex items-center space-x-3">
          <div className="text-3xl">🌸</div>
          <div className="text-2xl font-bold text-green-800">CertBloom</div>
        </div>
        <div className="hidden md:flex items-center space-x-6">
          <a href="#features" className="text-green-600 hover:text-green-800 transition-colors">Features</a>
          <Link href="/pricing" className="text-green-600 hover:text-green-800 transition-colors">Pricing</Link>
          <a href="#about" className="text-green-600 hover:text-green-800 transition-colors">About</a>
          <a href="#contact" className="text-green-600 hover:text-green-800 transition-colors">Contact</a>
          {user ? (
            <>
              <Link href="/dashboard" className="text-green-600 hover:text-green-800 transition-colors">
                Dashboard
              </Link>
              <button 
                onClick={() => signOut()}
                className="px-6 py-2 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors"
              >
                Sign Out
              </button>
            </>
          ) : (
            <Link href="/auth" className="px-6 py-2 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors">
              Sign In
            </Link>
          )}
        </div>
      </nav>

      {/* Hero Section */}
      <div className="relative z-10 flex items-center justify-center min-h-[80vh] px-6">
        <div className="text-center max-w-4xl">
          
          {/* Logo Animation */}
          <div className="mb-8">
            <div 
              className={`text-8xl transition-all duration-1000 ${
                pulsePhase === 0 ? 'scale-100' : pulsePhase === 1 ? 'scale-110' : 'scale-105'
              }`}
            >
              🌸
            </div>
          </div>
          
          <h1 className="text-6xl font-light text-green-800 mb-6">
            CertBloom
          </h1>
          
          <p className="text-2xl text-green-600 mb-4 font-medium">
            Prep with Pace. Pass with Purpose.
          </p>
          
          <p className="text-lg text-green-500 mb-12 leading-relaxed max-w-2xl mx-auto">
            Adaptive teacher certification preparation designed specifically for Texas educators. 
            Combining intelligent learning with mindful practice to help you bloom into your certification with confidence and peace of mind.
          </p>
          
          <div className="w-32 h-0.5 bg-gradient-to-r from-transparent via-green-300 to-transparent mx-auto mb-12"></div>

          {/* Key Features */}
          <div className="grid md:grid-cols-3 gap-8 mb-12">
            <div className="bg-white/70 backdrop-blur-sm rounded-2xl p-6 border border-green-200/50">
              <div className="text-4xl mb-4">🧠</div>
              <h3 className="text-xl font-semibold text-green-800 mb-3">Adaptive Learning</h3>
              <p className="text-green-600 text-sm">
                Our intelligent algorithm adapts to your learning style, focusing on areas where you need the most support.
              </p>
            </div>
            
            <div className="bg-white/70 backdrop-blur-sm rounded-2xl p-6 border border-green-200/50">
              <div className="text-4xl mb-4">🌟</div>
              <h3 className="text-xl font-semibold text-green-800 mb-3">Texas-Focused</h3>
              <p className="text-green-600 text-sm">
                Built specifically for Texas teacher certification with EC-6, ELA 4-8, and other TExES requirements.
              </p>
            </div>
            
            <div className="bg-white/70 backdrop-blur-sm rounded-2xl p-6 border border-green-200/50">
              <div className="text-4xl mb-4">🧘‍♀️</div>
              <h3 className="text-xl font-semibold text-green-800 mb-3">Mindful Prep</h3>
              <p className="text-green-600 text-sm">
                Integrated breathing exercises and mindfulness tools to reduce test anxiety and build confidence.
              </p>
            </div>
          </div>

          {/* Philosophy */}
          <div className="bg-gradient-to-r from-green-100 to-orange-100 rounded-2xl p-8 mb-12 border border-green-200/50">
            <h2 className="text-3xl font-light text-green-800 mb-6">
              Certification. Cultivation. Bloom.
            </h2>
            <p className="text-green-600 text-lg leading-relaxed">
              We believe teacher preparation should nurture the whole person. CertBloom isn&apos;t just test prep—
              it&apos;s a comprehensive companion that adapts to your unique learning journey while honoring 
              the sacred calling of education.
            </p>
          </div>

          {/* Launch Info */}
          <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-8 border border-green-200/50">
            <h3 className="text-2xl font-semibold text-green-800 mb-4">Start Your Texas Teacher Certification Journey</h3>
            <p className="text-green-600 mb-6">
              CertBloom is here! Experience adaptive teacher certification prep that actually works with how you learn. 
              Join thousands of Texas teachers who are already preparing with confidence.
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4 justify-center items-center mb-6">
              <Link 
                href="/auth"
                className="w-full sm:w-auto px-8 py-3 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors font-medium text-center"
              >
                Start Free Account
              </Link>
              <Link 
                href="/pricing"
                className="w-full sm:w-auto px-8 py-3 border-2 border-green-600 text-green-600 rounded-xl hover:bg-green-50 transition-colors font-medium text-center"
              >
                View Pricing
              </Link>
            </div>
            
            <p className="text-green-400 text-sm">
              Free plan includes 50 practice questions • 7-day free trial on paid plans • No credit card required
            </p>
            
            {/* Email signup for non-Texas teachers */}
            {!isSubmitted ? (
              <div className="mt-8 pt-6 border-t border-green-200">
                <p className="text-green-700 text-sm mb-4">
                  <strong>Not in Texas?</strong> Get notified when we expand to your state:
                </p>
                <form onSubmit={handleEmailSubmit} className="flex flex-col sm:flex-row gap-3 justify-center items-center max-w-md mx-auto">
                  <input
                    type="email"
                    placeholder="Enter your email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    disabled={isSubmitting}
                    className="w-full px-4 py-2 rounded-lg border border-green-300 focus:outline-none focus:ring-2 focus:ring-green-500 bg-white/90 text-gray-800 placeholder-gray-500 disabled:opacity-50 text-sm"
                  />
                  <button 
                    type="submit"
                    disabled={isSubmitting}
                    className="w-full sm:w-auto px-6 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors text-sm whitespace-nowrap disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isSubmitting ? 'Joining...' : 'Notify Me'}
                  </button>
                </form>
                {submitError && (
                  <p className="text-red-500 text-sm mt-3 text-center">
                    {submitError}
                  </p>
                )}
              </div>
            ) : (
              <div className="text-center mt-8 pt-6 border-t border-green-200">
                <div className="text-4xl mb-3">🌸</div>
                <h4 className="text-lg font-semibold text-green-800 mb-2">Thank You!</h4>
                <p className="text-green-600 text-sm">We&apos;ll notify you when CertBloom expands to your state!</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="relative z-10 text-center py-8 text-green-500 border-t border-green-200/50">
        {/* Updated footer with authentication features - Auto-deployment test */}
        <p>&copy; 2025 CertBloom. Built with 💚 for Texas teachers.</p>
        <div className="mt-2">
          <a href="mailto:support@certbloom.com" className="hover:text-green-700 transition-colors">
            support@certbloom.com
          </a>
        </div>
      </footer>
    </div>
  );
}
