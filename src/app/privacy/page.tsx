'use client';

import Link from 'next/link';
import Image from 'next/image';

export default function PrivacyPolicyPage() {
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
            <Link href="/pricing" className="text-green-700 hover:text-green-900 transition-colors font-medium">Pricing</Link>
            <Link href="/about" className="text-green-700 hover:text-green-900 transition-colors font-medium">About</Link>
            <Link href="/contact" className="text-green-700 hover:text-green-900 transition-colors font-medium">Contact</Link>
            <Link href="/auth" className="px-6 py-2 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105">
              Sign In
            </Link>
          </div>
        </div>
      </nav>

      {/* Content */}
      <div className="max-w-4xl mx-auto px-6 py-16">
        <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-12 border border-green-200/60 shadow-xl">
          <h1 className="text-4xl font-light text-green-800 mb-2">Privacy Policy</h1>
          <p className="text-green-600 mb-8">Effective Date: July 28, 2025</p>

          <div className="prose prose-green max-w-none space-y-8">
            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Our Commitment to Your Privacy</h2>
              <p className="text-gray-700 leading-relaxed">
                At CertBloom, we honor the sacred trust you place in us with your personal information. 
                This Privacy Policy explains how we collect, use, protect, and share information about you 
                when you use our adaptive teacher certification preparation platform.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Information We Collect</h2>
              
              <h3 className="text-xl font-medium text-green-700 mb-3">Account Information</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>Email address and full name when you create an account</li>
                <li>Profile information including certification goals and study preferences</li>
                <li>Learning style assessments and anxiety level indicators</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">Learning Data</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>Practice session results, including questions answered and accuracy</li>
                <li>Study patterns, time spent, and progress tracking</li>
                <li>Mood check-ins and mindfulness exercise participation</li>
                <li>Confidence ratings and self-assessment responses</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">Payment Information</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>Billing information processed securely through Stripe</li>
                <li>Subscription status and payment history</li>
                <li>We do not store credit card numbers on our servers</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">Technical Information</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2">
                <li>Device type, browser information, and IP address</li>
                <li>Usage analytics to improve our adaptive algorithms</li>
                <li>Error logs and performance metrics</li>
              </ul>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">How We Use Your Information</h2>
              
              <h3 className="text-xl font-medium text-green-700 mb-3">Adaptive Learning</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>Personalizing your study experience and question selection</li>
                <li>Tracking your progress and identifying areas for improvement</li>
                <li>Generating adaptive study plans and recommendations</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">Service Delivery</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>Providing access to practice questions and study materials</li>
                <li>Managing your subscription and billing</li>
                <li>Sending important updates about your account or our service</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">Improvement & Analytics</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2">
                <li>Analyzing usage patterns to enhance our adaptive algorithms</li>
                <li>Improving the effectiveness of our study materials</li>
                <li>Developing new features and wellness tools</li>
              </ul>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Information Sharing</h2>
              <p className="text-gray-700 leading-relaxed mb-4">
                We do not sell, rent, or share your personal information with third parties except in these limited circumstances:
              </p>
              
              <ul className="list-disc list-inside text-gray-700 space-y-2">
                <li><strong>Service Providers:</strong> Trusted partners like Supabase (data hosting) and Stripe (payment processing)</li>
                <li><strong>Legal Requirements:</strong> When required by law or to protect our rights and safety</li>
                <li><strong>Business Transfers:</strong> In the event of a merger or acquisition (with notice to you)</li>
                <li><strong>Aggregate Data:</strong> De-identified, statistical information for research purposes</li>
              </ul>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Data Security</h2>
              <p className="text-gray-700 leading-relaxed mb-4">
                We implement industry-standard security measures to protect your information:
              </p>
              
              <ul className="list-disc list-inside text-gray-700 space-y-2">
                <li>Encryption of data in transit and at rest</li>
                <li>Secure authentication through Supabase</li>
                <li>Regular security assessments and updates</li>
                <li>Limited access to personal data on a need-to-know basis</li>
                <li>PCI-compliant payment processing through Stripe</li>
              </ul>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Your Rights and Choices</h2>
              
              <h3 className="text-xl font-medium text-green-700 mb-3">Access and Control</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>View and update your profile information at any time</li>
                <li>Download your learning data and progress history</li>
                <li>Delete your account and associated data</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">Communication Preferences</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>Opt out of non-essential emails</li>
                <li>Adjust notification settings in your dashboard</li>
                <li>Unsubscribe from marketing communications</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">California Residents (CCPA)</h3>
              <p className="text-gray-700 leading-relaxed">
                California residents have additional rights including the right to know what personal information 
                we collect, delete personal information, and opt-out of sale (though we don&apos;t sell personal information).
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Cookies and Tracking</h2>
              <p className="text-gray-700 leading-relaxed mb-4">
                We use cookies and similar technologies to:
              </p>
              
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>Keep you logged in and remember your preferences</li>
                <li>Analyze how you use our platform to improve it</li>
                <li>Provide personalized study recommendations</li>
              </ul>

              <p className="text-gray-700 leading-relaxed">
                You can control cookies through your browser settings, though some features may not work properly without them.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Children&apos;s Privacy</h2>
              <p className="text-gray-700 leading-relaxed">
                CertBloom is designed for prospective teachers who are 18 years or older. We do not knowingly 
                collect personal information from children under 13. If you believe we have inadvertently 
                collected such information, please contact us immediately.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Changes to This Policy</h2>
              <p className="text-gray-700 leading-relaxed">
                We may update this Privacy Policy to reflect changes in our practices or for legal reasons. 
                We&apos;ll notify you of significant changes via email or through our platform. Your continued 
                use of CertBloom after such changes constitutes acceptance of the updated policy.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Contact Us</h2>
              <p className="text-gray-700 leading-relaxed mb-4">
                If you have questions about this Privacy Policy or want to exercise your rights, please contact us:
              </p>
              
              <div className="bg-green-50 rounded-xl p-6">
                <p className="text-gray-700 mb-2"><strong>Email:</strong> support@certbloom.com</p>
                <p className="text-gray-700 mb-2"><strong>Subject Line:</strong> Privacy Policy Inquiry</p>
                <p className="text-gray-700"><strong>Response Time:</strong> We respond to privacy requests within 48 hours</p>
              </div>
            </section>
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="px-6 py-8 text-center">
        <div className="max-w-6xl mx-auto">
          <p className="text-green-600">
            <Link href="/" className="hover:text-green-800 transition-colors">Return to CertBloom</Link> • 
            <Link href="/terms" className="hover:text-green-800 transition-colors ml-2">Terms of Service</Link>
          </p>
        </div>
      </footer>
    </div>
  );
}
