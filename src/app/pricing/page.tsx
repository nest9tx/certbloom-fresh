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
            
            <Link 
              href="/auth"
              className="w-full block text-center py-3 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors"
            >
              Start 7-Day Free Trial
            </Link>
            <p className="text-green-400 text-xs text-center mt-2">
              No credit card required
            </p>
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
