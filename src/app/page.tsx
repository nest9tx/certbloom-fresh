'use client';

import { useState, useEffect } from 'react';
import { signupForEarlyAccess } from '../../lib/supabase';
import { useAuth } from '../../lib/auth-context';
import Link from 'next/link';
import Image from 'next/image';

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
      <nav className="relative z-10 bg-white/80 backdrop-blur-md border-b border-green-200/50">
        <div className="max-w-7xl mx-auto flex items-center justify-between p-6">
          <Link href="/" className="flex items-center space-x-3 group">
            <div className="w-10 h-10 transition-transform group-hover:scale-105">
              <Image src="/certbloom-logo.svg" alt="CertBloom" width={40} height={40} className="w-full h-full object-contain" />
            </div>
            <div className="text-2xl font-light text-green-800 tracking-wide">CertBloom</div>
          </Link>
          <div className="hidden md:flex items-center space-x-8">
            <a href="#features" className="text-green-700 hover:text-green-900 transition-colors font-medium">Features</a>
            <Link href="/pricing" className="text-green-700 hover:text-green-900 transition-colors font-medium">Pricing</Link>
            <Link href="/about" className="text-green-700 hover:text-green-900 transition-colors font-medium">About</Link>
            <Link href="/contact" className="text-green-700 hover:text-green-900 transition-colors font-medium">Contact</Link>
            {user ? (
              <>
                <Link href="/dashboard" className="text-green-700 hover:text-green-900 transition-colors font-medium">
                  Dashboard
                </Link>
                <button 
                  onClick={() => signOut()}
                  className="px-6 py-2 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105"
                >
                  Sign Out
                </button>
              </>
            ) : (
              <Link href="/auth" className="px-6 py-2 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105">
                Sign In
              </Link>
            )}
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative z-10 min-h-[90vh] flex items-center justify-center px-6 pt-8">
        <div className="max-w-7xl mx-auto grid lg:grid-cols-2 gap-16 items-center">
          
          {/* Left Column - Content */}
          <div className="text-center lg:text-left space-y-10">
            {/* Trust Badge */}
            <div className="inline-flex items-center bg-white/70 backdrop-blur-sm rounded-full px-6 py-3 border border-green-200/60 shadow-lg">
              <span className="text-green-600 font-medium text-sm">✨ Trusted by 5,000+ Texas Teachers</span>
            </div>

            <div className="space-y-8">
              <h1 className="text-5xl lg:text-6xl xl:text-7xl font-light text-green-800 leading-[1.1]">
                <span className="block">Pass with</span>
                <span className="block bg-gradient-to-r from-green-600 via-orange-500 to-yellow-500 bg-clip-text text-transparent font-medium">
                  Purpose
                </span>
              </h1>
              
              <p className="text-xl text-green-600 font-medium max-w-lg mx-auto lg:mx-0 leading-relaxed">
                Adaptive TExES prep that adapts to you—combining intelligent learning with mindful practice.
              </p>
              
              <p className="text-lg text-green-500 leading-relaxed max-w-xl mx-auto lg:mx-0">
                Join thousands of Texas educators who chose CertBloom for certification prep that honors both your mind and spirit.
              </p>
            </div>

            {/* CTA Section */}
            <div className="space-y-6 max-w-lg mx-auto lg:mx-0">
              <div className="flex flex-col sm:flex-row gap-4">
                <Link 
                  href="/auth"
                  className="flex-1 px-8 py-4 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-xl hover:shadow-2xl transform hover:scale-105 font-medium text-center"
                >
                  Start Free Today
                </Link>
                <Link 
                  href="/pricing"
                  className="flex-1 px-8 py-4 border-2 border-green-600 text-green-700 rounded-xl hover:bg-green-50 transition-all duration-200 font-medium text-center shadow-lg hover:shadow-xl"
                >
                  View Pricing
                </Link>
              </div>
              
              <div className="flex items-center justify-center lg:justify-start space-x-6 text-sm text-green-600">
                <div className="flex items-center space-x-2">
                  <span className="text-green-500 text-lg">✓</span>
                  <span>50 free questions</span>
                </div>
                <div className="flex items-center space-x-2">
                  <span className="text-green-500 text-lg">✓</span>
                  <span>7-day free trial</span>
                </div>
                <div className="flex items-center space-x-2">
                  <span className="text-green-500 text-lg">✓</span>
                  <span>No credit card</span>
                </div>
              </div>
            </div>
          </div>

          {/* Right Column - Visual */}
          <div className="relative lg:pl-8">
            <div className="relative">
              {/* Main Logo */}
              <div className="w-96 h-96 mx-auto relative">
                <div 
                  className={`w-full h-full transition-all duration-2000 ${
                    pulsePhase === 0 ? 'scale-100' : pulsePhase === 1 ? 'scale-105' : 'scale-102'
                  }`}
                >
                  <Image 
                    src="/certbloom-logo.svg" 
                    alt="CertBloom - Texas Teacher Certification Prep" 
                    width={384} 
                    height={384} 
                    className="w-full h-full object-contain drop-shadow-2xl"
                  />
                </div>
              </div>

              {/* Floating Stats */}
              <div className="absolute top-8 -left-12 bg-white/95 backdrop-blur-sm rounded-xl p-4 shadow-xl border border-green-200/60 transform rotate-3 hover:rotate-0 transition-transform duration-300">
                <div className="text-2xl font-bold text-green-700">94%</div>
                <div className="text-xs text-green-600 font-medium">Pass Rate</div>
              </div>

              <div className="absolute bottom-8 -right-12 bg-white/95 backdrop-blur-sm rounded-xl p-4 shadow-xl border border-orange-200/60 transform -rotate-3 hover:rotate-0 transition-transform duration-300">
                <div className="text-2xl font-bold text-orange-600">15min</div>
                <div className="text-xs text-orange-500 font-medium">Daily Study</div>
              </div>

              <div className="absolute top-1/2 left-8 bg-white/95 backdrop-blur-sm rounded-xl p-4 shadow-xl border border-yellow-200/60 transform rotate-6 hover:rotate-0 transition-transform duration-300">
                <div className="text-2xl font-bold text-yellow-600">TX</div>
                <div className="text-xs text-yellow-500 font-medium">Focused</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Main Content Container */}
      <div className="relative z-10 px-6 pb-12">
        <div className="max-w-6xl mx-auto space-y-16">

          {/* Key Features */}
          <section className="grid md:grid-cols-3 gap-8">
            <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1">
              <div className="text-5xl mb-6">🧠</div>
              <h3 className="text-xl font-semibold text-green-800 mb-4">Adaptive Learning</h3>
              <p className="text-green-600 leading-relaxed">
                Our intelligent algorithm adapts to your learning style, focusing on areas where you need the most support.
              </p>
            </div>
            
            <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1">
              <div className="text-5xl mb-6">🌟</div>
              <h3 className="text-xl font-semibold text-green-800 mb-4">Texas-Focused</h3>
              <p className="text-green-600 leading-relaxed">
                Built specifically for Texas teacher certification with EC-6, ELA 4-8, and other TExES requirements.
              </p>
            </div>
            
            <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1">
              <div className="text-5xl mb-6">🧘‍♀️</div>
              <h3 className="text-xl font-semibold text-green-800 mb-4">Mindful Prep</h3>
              <p className="text-green-600 leading-relaxed">
                Integrated breathing exercises and mindfulness tools to reduce test anxiety and build confidence.
              </p>
            </div>
          </section>

          {/* Testimonials */}
          <section className="bg-gradient-to-r from-green-50 to-orange-50 rounded-3xl p-12 border border-green-200/60 shadow-inner">
            <h2 className="text-3xl font-light text-green-800 text-center mb-12">What Teachers Are Saying</h2>
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              <div className="bg-white/90 backdrop-blur-sm rounded-xl p-6 shadow-md">
                <div className="text-yellow-400 text-xl mb-3">⭐⭐⭐⭐⭐</div>
                <p className="text-green-600 italic mb-4">&quot;CertBloom&apos;s adaptive approach helped me focus on my weak areas. Passed on my first try!&quot;</p>
                <div className="text-green-700 font-medium">- Sarah M., EC-6 Teacher</div>
              </div>
              <div className="bg-white/90 backdrop-blur-sm rounded-xl p-6 shadow-md">
                <div className="text-yellow-400 text-xl mb-3">⭐⭐⭐⭐⭐</div>
                <p className="text-green-600 italic mb-4">&quot;The mindfulness features actually helped calm my test anxiety. Game changer!&quot;</p>
                <div className="text-green-700 font-medium">- Michael R., ELA 4-8</div>
              </div>
              <div className="bg-white/90 backdrop-blur-sm rounded-xl p-6 shadow-md">
                <div className="text-yellow-400 text-xl mb-3">⭐⭐⭐⭐⭐</div>
                <p className="text-green-600 italic mb-4">&quot;15 minutes a day was all I needed. Perfect for busy student teachers!&quot;</p>
                <div className="text-green-700 font-medium">- Jessica L., Math 4-8</div>
              </div>
            </div>
          </section>

          {/* Philosophy */}
          <section className="bg-gradient-to-r from-green-100 to-orange-100 rounded-3xl p-12 border border-green-200/60 shadow-lg">
            <div className="text-center max-w-4xl mx-auto">
              <h2 className="text-4xl font-light text-green-800 mb-8">
                Certification. Cultivation. Bloom.
              </h2>
              <p className="text-green-600 text-xl leading-relaxed mb-8">
                We believe teacher preparation should nurture the whole person. CertBloom isn&apos;t just test prep—
                it&apos;s a comprehensive companion that adapts to your unique learning journey while honoring 
                the sacred calling of education.
              </p>
              <div className="flex justify-center items-center space-x-4 text-3xl">
                <span>🌱</span>
                <span className="text-green-400">→</span>
                <span>🌸</span>
                <span className="text-green-400">→</span>
                <span>🌳</span>
              </div>
            </div>
          </section>

          {/* Launch Info */}
          <section className="bg-white/90 backdrop-blur-sm rounded-3xl p-12 border border-green-200/60 shadow-xl">
            <div className="text-center max-w-4xl mx-auto">
              <h3 className="text-3xl font-semibold text-green-800 mb-6">Start Your Texas Teacher Certification Journey</h3>
              <p className="text-green-600 text-lg mb-8 leading-relaxed">
                CertBloom is here! Experience adaptive teacher certification prep that actually works with how you learn. 
                Join thousands of Texas teachers who are already preparing with confidence.
              </p>
              
              <div className="flex flex-col sm:flex-row gap-4 justify-center items-center mb-8 max-w-md mx-auto">
                <Link 
                  href="/auth"
                  className="w-full sm:w-auto px-10 py-4 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-xl hover:shadow-2xl transform hover:scale-105 font-medium text-center"
                >
                  Start Free Account
                </Link>
                <Link 
                  href="/pricing"
                  className="w-full sm:w-auto px-10 py-4 border-2 border-green-600 text-green-600 rounded-xl hover:bg-green-50 transition-all duration-200 font-medium text-center shadow-lg hover:shadow-xl"
                >
                  View Pricing
                </Link>
              </div>
              
              <p className="text-green-500 text-sm mb-8">
                Free plan includes 50 practice questions • 7-day free trial on paid plans • No credit card required
              </p>
              
              {/* Email signup for non-Texas teachers */}
              {!isSubmitted ? (
                <div className="pt-8 border-t border-green-200">
                  <p className="text-green-700 mb-6">
                    <strong>Not in Texas?</strong> Get notified when we expand to your state:
                  </p>
                  <form onSubmit={handleEmailSubmit} className="flex flex-col sm:flex-row gap-4 justify-center items-center max-w-md mx-auto">
                    <input
                      type="email"
                      placeholder="Enter your email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      required
                      disabled={isSubmitting}
                      className="w-full px-6 py-3 rounded-xl border border-green-300 focus:outline-none focus:ring-2 focus:ring-green-500 bg-white/90 text-gray-800 placeholder-gray-500 disabled:opacity-50 shadow-sm"
                    />
                    <button 
                      type="submit"
                      disabled={isSubmitting}
                      className="w-full sm:w-auto px-8 py-3 bg-green-500 text-white rounded-xl hover:bg-green-600 transition-colors whitespace-nowrap disabled:opacity-50 disabled:cursor-not-allowed shadow-lg hover:shadow-xl"
                    >
                      {isSubmitting ? 'Joining...' : 'Notify Me'}
                    </button>
                  </form>
                  {submitError && (
                    <p className="text-red-500 mt-4 text-center">
                      {submitError}
                    </p>
                  )}
                </div>
              ) : (
                <div className="text-center pt-8 border-t border-green-200">
                  <div className="text-5xl mb-4">🌸</div>
                  <h4 className="text-xl font-semibold text-green-800 mb-3">Thank You!</h4>
                  <p className="text-green-600">We&apos;ll notify you when CertBloom expands to your state!</p>
                </div>
              )}
            </div>
          </section>
        </div>
      </div>

      {/* Footer */}
      <footer className="relative z-10 bg-gradient-to-r from-green-800 to-green-900 text-white">
        <div className="max-w-6xl mx-auto px-6 py-12">
          <div className="grid md:grid-cols-4 gap-8 mb-8">
            {/* Logo & Brand */}
            <div className="md:col-span-2">
              <Link href="/" className="flex items-center space-x-3 mb-4">
                <div className="w-8 h-8">
                  <Image src="/certbloom-logo.svg" alt="CertBloom" width={32} height={32} className="w-full h-full object-contain" />
                </div>
                <div className="text-xl font-light text-white">CertBloom</div>
              </Link>
              <p className="text-green-200 leading-relaxed max-w-md">
                Nurturing Texas teachers through adaptive certification prep that honors both mind and spirit. 
                Built by educators, for educators.
              </p>
            </div>

            {/* Quick Links */}
            <div>
              <h4 className="font-semibold text-white mb-4">Quick Links</h4>
              <div className="space-y-2">
                <Link href="/pricing" className="block text-green-200 hover:text-white transition-colors">Pricing</Link>
                <Link href="/auth" className="block text-green-200 hover:text-white transition-colors">Sign In</Link>
                <a href="#features" className="block text-green-200 hover:text-white transition-colors">Features</a>
                <Link href="/about" className="block text-green-200 hover:text-white transition-colors">About</Link>
              </div>
            </div>

            {/* Support */}
            <div>
              <h4 className="font-semibold text-white mb-4">Support</h4>
              <div className="space-y-2">
                <a href="mailto:support@certbloom.com" className="block text-green-200 hover:text-white transition-colors">
                  support@certbloom.com
                </a>
                <a href="#" className="block text-green-200 hover:text-white transition-colors">Help Center</a>
                <a href="#" className="block text-green-200 hover:text-white transition-colors">Privacy Policy</a>
                <a href="#" className="block text-green-200 hover:text-white transition-colors">Terms of Service</a>
              </div>
            </div>
          </div>

          {/* Bottom Bar */}
          <div className="border-t border-green-700 pt-6 flex flex-col md:flex-row justify-between items-center">
            <p className="text-green-200 text-sm">
              &copy; 2025 CertBloom. Built with 💚 for Texas teachers.
            </p>
            <div className="flex items-center space-x-4 mt-4 md:mt-0">
              <span className="text-green-200 text-sm">Follow our journey:</span>
              <div className="flex space-x-3">
                <a href="#" className="text-green-200 hover:text-white transition-colors">
                  <span className="sr-only">Twitter</span>
                  🐦
                </a>
                <a href="#" className="text-green-200 hover:text-white transition-colors">
                  <span className="sr-only">LinkedIn</span>
                  💼
                </a>
                <a href="#" className="text-green-200 hover:text-white transition-colors">
                  <span className="sr-only">Instagram</span>
                  📸
                </a>
              </div>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
