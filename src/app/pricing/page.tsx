'use client';

import Link from 'next/link';

export default function PricingPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50">
      {/* Header */}
      <header className="px-6 py-8">
        <div className="max-w-6xl mx-auto flex items-center justify-between">
          <Link href="/" className="flex items-center space-x-2">
            <span className="text-4xl">🌸</span>
            <span className="text-2xl font-light text-green-800">CertBloom</span>
          </Link>
          <Link 
            href="/auth" 
            className="px-6 py-3 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors"
          >
            Get Started
          </Link>
        </div>
      </header>

      {/* Hero Section */}
      <section className="px-6 py-16 text-center">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-5xl font-light text-green-800 mb-6">
            Simple, Transparent Pricing
          </h1>
          <p className="text-xl text-green-600 mb-12">
            Choose the plan that fits your Texas teacher certification journey
          </p>
        </div>
      </section>

      {/* Pricing Cards */}
      <section className="px-6 pb-16">
        <div className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-8">
          
          {/* Free Plan */}
          <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-8 border border-green-200/50 shadow-lg">
            <div className="text-center mb-8">
              <h3 className="text-2xl font-light text-green-800 mb-2">Starter</h3>
              <div className="text-4xl font-light text-green-600 mb-4">Free</div>
              <p className="text-green-500">Perfect for getting started</p>
            </div>
            
            <ul className="space-y-4 mb-8">
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">50 practice questions</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Basic study tracking</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Wellness check-ins</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Study reminders</span>
              </li>
            </ul>
            
            <Link 
              href="/auth"
              className="w-full block text-center py-3 border-2 border-green-600 text-green-600 rounded-xl hover:bg-green-50 transition-colors"
            >
              Start Free
            </Link>
          </div>

          {/* Pro Plan */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border-2 border-green-400 shadow-xl relative">
            <div className="absolute -top-4 left-1/2 transform -translate-x-1/2 bg-green-500 text-white px-4 py-2 rounded-full text-sm">
              Most Popular
            </div>
            
            <div className="text-center mb-8">
              <h3 className="text-2xl font-light text-green-800 mb-2">Pro</h3>
              <div className="text-4xl font-light text-green-600 mb-1">$19</div>
              <div className="text-sm text-green-500 mb-4">/month</div>
              <p className="text-green-500">Everything you need to pass</p>
            </div>
            
            <ul className="space-y-4 mb-8">
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Unlimited practice questions</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Adaptive learning algorithm</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Detailed performance analytics</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Mindfulness exercises</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Study plan optimization</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Priority support</span>
              </li>
            </ul>
            
            <Link 
              href="/auth"
              className="w-full block text-center py-3 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors"
            >
              Start Pro Trial
            </Link>
          </div>

          {/* Premium Plan */}
          <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-8 border border-green-200/50 shadow-lg">
            <div className="text-center mb-8">
              <h3 className="text-2xl font-light text-green-800 mb-2">Premium</h3>
              <div className="text-4xl font-light text-green-600 mb-1">$39</div>
              <div className="text-sm text-green-500 mb-4">/month</div>
              <p className="text-green-500">For comprehensive preparation</p>
            </div>
            
            <ul className="space-y-4 mb-8">
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Everything in Pro</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">1-on-1 coaching sessions</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Custom study materials</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Stress management workshops</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Guaranteed pass program</span>
              </li>
            </ul>
            
            <Link 
              href="/auth"
              className="w-full block text-center py-3 border-2 border-green-600 text-green-600 rounded-xl hover:bg-green-50 transition-colors"
            >
              Start Premium Trial
            </Link>
          </div>
        </div>
      </section>

      {/* FAQ Section */}
      <section className="px-6 py-16 bg-white/30">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-light text-green-800 text-center mb-12">
            Frequently Asked Questions
          </h2>
          
          <div className="space-y-8">
            <div className="bg-white/80 rounded-xl p-6">
              <h3 className="text-lg font-medium text-green-800 mb-3">
                Can I upgrade or downgrade anytime?
              </h3>
              <p className="text-green-600">
                Yes! You can change your plan at any time. Changes take effect immediately and billing is prorated.
              </p>
            </div>
            
            <div className="bg-white/80 rounded-xl p-6">
              <h3 className="text-lg font-medium text-green-800 mb-3">
                What certifications do you support?
              </h3>
              <p className="text-green-600">
                We currently support all Texas teacher certifications including PPR, Content Area Exams, and alternative certification programs.
              </p>
            </div>
            
            <div className="bg-white/80 rounded-xl p-6">
              <h3 className="text-lg font-medium text-green-800 mb-3">
                Is there a free trial?
              </h3>
              <p className="text-green-600">
                Yes! All paid plans come with a 7-day free trial. No credit card required to start.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="px-6 py-8 text-center">
        <div className="max-w-6xl mx-auto">
          <p className="text-green-600">
            Questions? <Link href="/contact" className="hover:text-green-800 transition-colors">Contact us</Link>
          </p>
        </div>
      </footer>
    </div>
  );
}
