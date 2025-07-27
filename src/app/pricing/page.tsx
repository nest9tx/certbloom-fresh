'use client';

import Link from 'next/link';
import Image from 'next/image';

export default function PricingPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50">
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
            <Link href="/" className="text-green-700 hover:text-green-900 transition-colors font-medium">Home</Link>
            <Link href="/pricing" className="text-green-900 font-semibold">Pricing</Link>
            <Link href="/about" className="text-green-700 hover:text-green-900 transition-colors font-medium">About</Link>
            <Link href="/contact" className="text-green-700 hover:text-green-900 transition-colors font-medium">Contact</Link>
            <Link href="/auth" className="px-6 py-2 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105">
              Sign In
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="px-6 py-16 text-center">
        <div className="max-w-4xl mx-auto">
          {/* Test Mode Banner */}
          <div className="bg-yellow-100 border border-yellow-300 rounded-lg p-4 mb-6 inline-block">
            <div className="flex items-center justify-center space-x-2">
              <span className="text-yellow-600 text-2xl">⚠️</span>
              <span className="text-yellow-800 font-medium">TEST MODE</span>
              <span className="text-yellow-600 text-2xl">⚠️</span>
            </div>
            <p className="text-yellow-700 text-sm mt-1">
              Payment links are in test mode - no real charges will be made
            </p>
          </div>

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
        <div className="max-w-4xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-8">
          
          {/* Free Plan */}
          <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-8 border border-green-200/50 shadow-lg">
            <div className="text-center mb-8">
              <h3 className="text-2xl font-light text-green-800 mb-2">Free</h3>
              <div className="text-4xl font-light text-green-600 mb-4">$0</div>
              <p className="text-green-500">Perfect for getting started</p>
            </div>
            
            <ul className="space-y-4 mb-8">
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">50 practice questions</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Basic study materials</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Test-taking strategies</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Mindfulness exercises</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Progress tracking</span>
              </li>
            </ul>
            
            <Link 
              href="/auth"
              className="w-full block text-center py-3 border-2 border-green-600 text-green-600 rounded-xl hover:bg-green-50 transition-colors"
            >
              Get Started Free
            </Link>
          </div>

          {/* Pro Plan */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border-2 border-green-400 shadow-xl relative">
            <div className="absolute -top-4 left-1/2 transform -translate-x-1/2">
              <span className="bg-green-600 text-white px-4 py-1 rounded-full text-sm font-medium">
                Most Popular
              </span>
            </div>
            <div className="text-center mb-8">
              <h3 className="text-2xl font-light text-green-800 mb-2">CertBloom Pro</h3>
              <div className="flex items-center justify-center mb-2">
                <div className="text-4xl font-light text-green-600">$25</div>
                <div className="text-sm text-green-500 ml-2">/month</div>
              </div>
              <div className="text-sm text-green-500 mb-4">or $99/year (save $201)</div>
              <p className="text-green-500">Complete certification prep</p>
            </div>
            
            <ul className="space-y-4 mb-8">
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Everything in Free</span>
              </li>
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
                <span className="text-gray-700">Full-length practice exams</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Detailed progress analytics</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Stress management tools</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">✓</span>
                <span className="text-gray-700">Priority support</span>
              </li>
              <li className="flex items-center">
                <span className="text-green-500 mr-3">🌟</span>
                <span className="text-gray-700 font-medium">Pass Guarantee*</span>
              </li>
            </ul>
            
            <div className="space-y-4">
              {/* Monthly Plan */}
              <div className="border border-green-300 rounded-xl p-4">
                <div className="flex justify-between items-center mb-2">
                  <span className="font-medium text-green-800">Monthly Plan</span>
                  <span className="text-green-600 font-bold">$25/month</span>
                </div>
                <a 
                  href="https://buy.stripe.com/test_bJe7sM8M296I4YtbNqfnO00"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="w-full block text-center py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-medium"
                >
                  Start Monthly Plan
                </a>
              </div>

              {/* Yearly Plan - Highlighted */}
              <div className="border-2 border-yellow-400 rounded-xl p-4 bg-gradient-to-r from-yellow-50 to-orange-50 relative">
                <div className="absolute -top-2 right-4">
                  <span className="bg-yellow-400 text-yellow-900 px-3 py-1 rounded-full text-xs font-bold">
                    BEST VALUE
                  </span>
                </div>
                <div className="flex justify-between items-center mb-2">
                  <span className="font-medium text-green-800">Yearly Plan</span>
                  <div className="text-right">
                    <div className="text-green-600 font-bold">$99/year</div>
                    <div className="text-xs text-green-500 line-through">$300/year</div>
                  </div>
                </div>
                <div className="text-center mb-3">
                  <span className="bg-yellow-200 text-yellow-800 px-3 py-1 rounded-full text-sm font-medium">
                    Save $201 (67% off!)
                  </span>
                </div>
                <a 
                  href="https://buy.stripe.com/test_eVqbJ21jAaaM0IddVyfnO01"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="w-full block text-center py-3 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-lg hover:from-green-700 hover:to-green-800 transition-colors font-medium shadow-lg"
                >
                  Get Yearly Plan - Save $201!
                </a>
              </div>
            </div>
            
            <div className="text-center mt-4">
              <p className="text-green-400 text-xs">
                ✓ Start free, upgrade anytime • Cancel anytime
              </p>
              <p className="text-green-500 text-xs mt-1">
                📧 Email support@certbloom.com for billing assistance
              </p>
            </div>
          </div>
        </div>

        {/* Pass Guarantee Section */}
        <div className="max-w-4xl mx-auto mt-12">
          <div className="bg-gradient-to-r from-green-100 to-orange-100 rounded-2xl p-8 border border-green-200/50">
            <h3 className="text-2xl font-light text-green-800 text-center mb-4">
              🌟 CertBloom Pass Guarantee
            </h3>
            <p className="text-green-600 text-center leading-relaxed">
              We&apos;re so confident in our adaptive learning system that if you complete 90% of your personalized study plan 
              but don&apos;t pass your TExES exam, we&apos;ll extend your subscription for <strong>2 additional months at no cost</strong>. 
              No refund hassles—just more time to succeed with CertBloom.
            </p>
            <p className="text-green-500 text-sm text-center mt-4">
              *Applies to Pro subscribers who complete their full study plan and take the exam within 30 days of plan completion.
            </p>
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
                Can I try before I buy?
              </h3>
              <p className="text-green-600">
                Absolutely! Start with our generous free plan (50 practice questions, basic study materials, mindfulness tools) to experience CertBloom. When you&apos;re ready for unlimited questions and advanced features, upgrade to Pro anytime.
              </p>
            </div>
            
            <div className="bg-white/80 rounded-xl p-6">
              <h3 className="text-lg font-medium text-green-800 mb-3">
                Can I upgrade or cancel anytime?
              </h3>
              <p className="text-green-600">
                Yes! You can upgrade from Free to Pro or cancel your subscription at any time. No long-term commitments or cancellation fees.
              </p>
            </div>
            
            <div className="bg-white/80 rounded-xl p-6">
              <h3 className="text-lg font-medium text-green-800 mb-3">
                What TExES certifications do you support?
              </h3>
              <p className="text-green-600">
                We support all major Texas teacher certifications including Core Subjects EC-6, Core Subjects 4-8, PPR, STR, and content-specific exams for high school teachers.
              </p>
            </div>
            
            <div className="bg-white/80 rounded-xl p-6">
              <h3 className="text-lg font-medium text-green-800 mb-3">
                How does the Pass Guarantee work?
              </h3>
              <p className="text-green-600">
                Complete 90% of your personalized study plan and take your exam within 30 days. If you don&apos;t pass, we&apos;ll extend your Pro subscription for 2 additional months at no cost—giving you more time to study and retake your exam.
              </p>
            </div>
            
            <div className="bg-white/80 rounded-xl p-6">
              <h3 className="text-lg font-medium text-green-800 mb-3">
                How do I manage my billing or cancel my subscription?
              </h3>
              <p className="text-green-600">
                You can cancel your subscription anytime by emailing us at support@certbloom.com. We&apos;re working on a self-service billing portal in your dashboard for even easier management.
              </p>
            </div>
            
            <div className="bg-white/80 rounded-xl p-6">
              <h3 className="text-lg font-medium text-green-800 mb-3">
                Do you offer yearly subscriptions?
              </h3>
              <p className="text-green-600">
                Yes! Save $201 with our annual Pro plan at $99/year instead of $25/month. Perfect for those planning ahead or taking multiple certification exams.
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
