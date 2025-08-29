'use client';

import Link from 'next/link';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../../lib/auth-context';
import StaticNavigation from '../../components/StaticNavigation';

export default function PricingPage() {
  const { user } = useAuth();
  const router = useRouter();
  const [loadingPlan, setLoadingPlan] = useState<'monthly' | 'yearly' | null>(null);
  const [isClient, setIsClient] = useState(false);

  // Ensure this only runs on the client side
  useEffect(() => {
    setIsClient(true);
  }, []);

  const handleCheckout = async (plan: 'monthly' | 'yearly') => {
    if (!user) {
      alert('Please sign in to choose a plan.');
      router.push('/auth');
      return;
    }

    setLoadingPlan(plan);

    try {
      const { supabase } = await import('../../lib/supabase');
      const { data } = await supabase.auth.getSession();
      const token = data.session?.access_token;

      if (!token) {
        alert('Your session has expired. Please sign in again.');
        setLoadingPlan(null);
        router.push('/auth');
        return;
      }

      const res = await fetch('/api/stripe/create-checkout-session', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify({ plan }),
      });

      const result = await res.json();

      if (!res.ok) {
        throw new Error(result.error || `API Error: ${res.status} ${res.statusText}`);
      }

      if (result.url) {
        window.location.href = result.url;
      } else {
        throw new Error('Error creating checkout session: No URL returned.');
      }
    } catch (error: unknown) {
      console.error('Checkout error:', error);
      if (error instanceof Error) {
        alert(`Checkout Error: ${error.message}`);
      } else {
        alert('Checkout Error: An unknown error occurred.');
      }
    } finally {
      setLoadingPlan(null);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50">
      <StaticNavigation currentPage="pricing" />

      {/* Main Content */}
      <div className="container mx-auto px-6 py-12">
        <div className="max-w-6xl mx-auto">
          
          {/* Header */}
          <div className="text-center mb-16">
            <div className="text-6xl mb-6">💰</div>
            <h1 className="text-4xl lg:text-5xl font-light text-green-800 mb-6">
              Transparent Pricing
            </h1>
            <p className="text-xl text-green-600 mb-4">
              Supporting Texas teachers while funding educational pods in the four corners region
            </p>
            <p className="text-lg text-green-500">
              To get started, first select your TExES certification path, then choose your plan inside your dashboard
            </p>
          </div>

          {/* Pricing Cards */}
          <div className="grid lg:grid-cols-2 gap-8 mb-16 max-w-4xl mx-auto">
            
            {/* Free Plan */}
            <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
              <div className="text-center mb-8">
                <div className="text-4xl mb-4">🌱</div>
                <h2 className="text-3xl font-bold text-green-800 mb-2">Free Forever</h2>
                <p className="text-green-600 mb-6">Perfect for getting started</p>
                <div className="text-5xl font-bold text-green-700 mb-2">$0</div>
                <p className="text-green-500">Always free</p>
              </div>

              <div className="space-y-4 mb-8">
                <div className="flex items-center space-x-3">
                  <div className="text-green-500 text-xl">✓</div>
                  <span className="text-green-700">3 study sessions per day</span>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="text-green-500 text-xl">✓</div>
                  <span className="text-green-700">5 questions per session</span>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="text-green-500 text-xl">✓</div>
                  <span className="text-green-700">Certification-specific questions</span>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="text-green-500 text-xl">✓</div>
                  <span className="text-green-700">Basic explanations</span>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="text-green-500 text-xl">✓</div>
                  <span className="text-green-700">Mindful learning features</span>
                </div>
              </div>

              <div className="text-center">
                {isClient && user ? (
                  <div className="px-8 py-3 bg-green-100 text-green-700 rounded-xl font-medium">
                    Your Current Plan
                  </div>
                ) : (
                  <Link
                    href="/select-certification"
                    className="block px-8 py-3 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 font-medium"
                  >
                    🎯 Start Free
                  </Link>
                )}
              </div>
            </div>

            {/* Pro Plan */}
            <div className="bg-gradient-to-br from-yellow-50 to-orange-50 rounded-2xl p-8 border-2 border-yellow-300 shadow-xl relative">
              <div className="absolute -top-4 left-1/2 transform -translate-x-1/2">
                <span className="bg-yellow-400 text-green-900 px-6 py-2 rounded-full text-sm font-bold">MOST POPULAR</span>
              </div>
              
              <div className="text-center mb-8">
                <div className="text-4xl mb-4">🌟</div>
                <h2 className="text-3xl font-bold text-green-800 mb-2">CertBloom Pro</h2>
                <p className="text-green-600 mb-6">Complete certification preparation</p>
                <div className="text-5xl font-bold text-green-700 mb-2">$29</div>
                <p className="text-green-500">per month</p>
                <p className="text-sm text-green-600 mt-2">or $99/year (save $249!)</p>
              </div>

              <div className="space-y-4 mb-8">
                <div className="flex items-center space-x-3">
                  <div className="text-green-500 text-xl">✓</div>
                  <span className="text-green-700">Unlimited concept learning</span>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="text-green-500 text-xl">✓</div>
                  <span className="text-green-700">Complete question bank</span>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="text-green-500 text-xl">✓</div>
                  <span className="text-green-700">Detailed explanations & tips</span>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="text-green-500 text-xl">✓</div>
                  <span className="text-green-700">Advanced progress tracking</span>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="text-green-500 text-xl">✓</div>
                  <span className="text-green-700">Adaptive learning algorithm</span>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="text-green-500 text-xl">✓</div>
                  <span className="text-green-700">Priority support</span>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="text-orange-500 text-xl">🌱</div>
                  <span className="text-green-700 font-medium">Funds educational pods</span>
                </div>
              </div>

              <div className="text-center space-y-3">
                {isClient && user ? (
                  <>
                    <button
                      onClick={() => handleCheckout('monthly')}
                      disabled={loadingPlan !== null}
                      className="block w-full px-8 py-3 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 font-medium disabled:opacity-50"
                    >
                      {loadingPlan === 'monthly' ? 'Processing...' : '💳 Subscribe Monthly - $29/month'}
                    </button>
                    <button
                      onClick={() => handleCheckout('yearly')}
                      disabled={loadingPlan !== null}
                      className="block w-full px-8 py-3 bg-gradient-to-r from-yellow-400 to-orange-400 text-green-900 rounded-xl hover:from-yellow-500 hover:to-orange-500 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 font-medium disabled:opacity-50"
                    >
                      {loadingPlan === 'yearly' ? 'Processing...' : '🎯 Subscribe Yearly - $99/year (Save $249!)'}
                    </button>
                  </>
                ) : (
                  <>
                    <Link
                      href="/select-certification"
                      className="block px-8 py-3 bg-gradient-to-r from-yellow-400 to-orange-400 text-green-900 rounded-xl hover:from-yellow-500 hover:to-orange-500 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 font-medium"
                    >
                      🎯 Start Your Journey
                    </Link>
                    <p className="text-xs text-green-600 mt-2">Select certification first, then upgrade inside</p>
                  </>
                )}
              </div>
            </div>
          </div>

          {/* Features Grid */}
          <div className="grid md:grid-cols-3 gap-8 mb-16">
            <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-6 border border-green-200/60 shadow-lg text-center">
              <div className="text-4xl mb-4">🎯</div>
              <h3 className="text-xl font-semibold text-green-800 mb-3">Adaptive Learning</h3>
              <p className="text-green-600">
                Our AI adjusts question difficulty based on your performance, focusing on areas where you need the most practice.
              </p>
            </div>
            
            <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-6 border border-green-200/60 shadow-lg text-center">
              <div className="text-4xl mb-4">🧘</div>
              <h3 className="text-xl font-semibold text-green-800 mb-3">Mindful Learning</h3>
              <p className="text-green-600">
                Built-in breathing exercises and mindfulness features help you stay calm and focused during study sessions.
              </p>
            </div>
            
            <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-6 border border-green-200/60 shadow-lg text-center">
              <div className="text-4xl mb-4">🌱</div>
              <h3 className="text-xl font-semibold text-green-800 mb-3">Purpose-Driven</h3>
              <p className="text-green-600">
                Every subscription funds educational pods in underserved communities, making your success part of a larger mission.
              </p>
            </div>
          </div>

          {/* Mission Statement */}
          <div className="bg-gradient-to-r from-green-100 to-blue-100 rounded-2xl p-8 border border-green-200/60 shadow-xl text-center mb-12">
            <div className="text-4xl mb-4">🌱</div>
            <h3 className="text-2xl font-semibold text-green-800 mb-4">Our Mission</h3>
            <p className="text-green-600 text-lg leading-relaxed max-w-4xl mx-auto">
              Every CertBloom Pro subscription directly funds educational pods and learning communities 
              in the four corners region and Peru. Your success becomes a catalyst for transformative 
              education that honors both traditional wisdom and innovative learning approaches.
            </p>
          </div>

          {/* FAQ Section */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl mb-12">
            <h3 className="text-2xl font-semibold text-green-800 mb-8 text-center">Frequently Asked Questions</h3>
            
            <div className="grid md:grid-cols-2 gap-8">
              <div>
                <h4 className="text-lg font-semibold text-green-800 mb-2">Can I upgrade anytime?</h4>
                <p className="text-green-600 mb-4">Yes! You can upgrade to Pro from your dashboard once you&apos;ve selected your certification path.</p>
                
                <h4 className="text-lg font-semibold text-green-800 mb-2">What&apos;s included in the free plan?</h4>
                <p className="text-green-600">3 study sessions daily with concept-based learning, plus all our mindful learning features.</p>
              </div>
              
              <div>
                <h4 className="text-lg font-semibold text-green-800 mb-2">How does the money fund educational pods?</h4>
                <p className="text-green-600 mb-4">75% of Pro subscriptions go directly to funding educational initiatives in the four corners region and Peru.</p>
                
                <h4 className="text-lg font-semibold text-green-800 mb-2">What&apos;s your refund policy?</h4>
                <p className="text-green-600 mb-2">We offer a 30-day money-back guarantee if you&apos;re not completely satisfied, with some guidelines:</p>
                <ul className="text-green-600 text-sm space-y-1 mb-4 pl-4">
                  <li>• Guarantee applies to users who haven&apos;t completed more than 75% of any certification program</li>
                  <li>• Annual subscribers can access all certification programs during their subscription</li>
                  <li>• After 30 days, no refunds are available, but you keep access until your billing period ends</li>
                </ul>
                
                <h4 className="text-lg font-semibold text-green-800 mb-2">What happens if I cancel?</h4>
                <p className="text-green-600">Your subscription continues until the end of your current billing cycle. No partial refunds are issued for early cancellation, but you retain full access until the subscription expires.</p>
              </div>
            </div>
          </div>

          {/* Call to Action */}
          {!user && (
            <div className="text-center">
              <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
                <div className="text-5xl mb-6">🎯</div>
                <h3 className="text-3xl font-semibold text-green-800 mb-4">Ready to Begin?</h3>
                <p className="text-xl text-green-600 mb-8">
                  Start by selecting your TExES certification path to create your personalized study program
                </p>
                <Link
                  href="/select-certification"
                  className="inline-flex items-center px-10 py-4 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-xl hover:shadow-2xl transform hover:scale-105 font-medium text-lg"
                >
                  Choose Your Certification Path →
                </Link>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
