'use client';

import Link from 'next/link';
import Image from 'next/image';

export default function TermsOfServicePage() {
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
          <h1 className="text-4xl font-light text-green-800 mb-2">Terms of Service</h1>
          <p className="text-green-600 mb-8">Effective Date: July 28, 2025</p>

          <div className="prose prose-green max-w-none space-y-8">
            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Welcome to CertBloom</h2>
              <p className="text-gray-700 leading-relaxed">
                These Terms of Service (&quot;Terms&quot;) govern your use of CertBloom, an adaptive teacher 
                certification preparation platform. By creating an account or using our services, you agree 
                to these Terms. If you don&apos;t agree, please don&apos;t use CertBloom.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Our Service</h2>
              
              <h3 className="text-xl font-medium text-green-700 mb-3">What CertBloom Provides</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>Adaptive practice questions for Texas teacher certification exams (TExES)</li>
                <li>Personalized study plans based on your learning style and progress</li>
                <li>Mindfulness and wellness tools to support your preparation journey</li>
                <li>Progress tracking and performance analytics</li>
                <li>Access to study materials and test-taking strategies</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">Service Availability</h3>
              <p className="text-gray-700 leading-relaxed">
                We strive to provide continuous access to CertBloom, but we may occasionally experience 
                downtime for maintenance, updates, or technical issues. We&apos;ll do our best to minimize 
                disruptions and provide advance notice when possible.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Your Account</h2>
              
              <h3 className="text-xl font-medium text-green-700 mb-3">Account Creation</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>You must be 18 years or older to create an account</li>
                <li>You must provide accurate and complete information</li>
                <li>You&apos;re responsible for maintaining the security of your account</li>
                <li>You may not share your account with others</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">Account Responsibilities</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2">
                <li>Keep your login credentials secure and confidential</li>
                <li>Notify us immediately of any unauthorized use of your account</li>
                <li>Use CertBloom only for your personal teacher certification preparation</li>
                <li>Comply with all applicable laws and regulations</li>
              </ul>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Subscription Plans and Billing</h2>
              
              <h3 className="text-xl font-medium text-green-700 mb-3">Plan Types</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li><strong>Free Plan:</strong> Access to 50 practice questions and basic features</li>
                <li><strong>Pro Plan:</strong> Unlimited access to all features, questions, and materials</li>
                <li>Monthly Pro: $25 per month</li>
                <li>Yearly Pro: $99 per year (significant savings)</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">Billing and Payment</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>All payments are processed securely through Stripe</li>
                <li>Subscriptions automatically renew unless cancelled</li>
                <li>You&apos;ll be charged on the same date each billing cycle</li>
                <li>All fees are non-refundable except as required by law</li>
                <li>We may change subscription prices with 30 days&apos; notice</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">Cancellation</h3>
              <p className="text-gray-700 leading-relaxed mb-4">
                You may cancel your subscription at any time by emailing support@certbloom.com. 
                Cancellation takes effect at the end of your current billing period. You&apos;ll retain 
                access to Pro features until your subscription expires.
              </p>

              <h3 className="text-xl font-medium text-green-700 mb-3">Failed Payments</h3>
              <p className="text-gray-700 leading-relaxed">
                If your payment method fails, we&apos;ll attempt to process payment several times. 
                If payment continues to fail, your account may be downgraded to the Free plan.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">CertBloom Pass Guarantee</h2>
              
              <h3 className="text-xl font-medium text-green-700 mb-3">Guarantee Terms</h3>
              <p className="text-gray-700 leading-relaxed mb-4">
                For Pro subscribers who meet the following requirements, we offer our Pass Guarantee:
              </p>
              
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>Complete at least 90% of your personalized study plan</li>
                <li>Take your TExES exam within 30 days of completing your study plan</li>
                <li>Provide proof of exam registration and results</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">Guarantee Benefit</h3>
              <p className="text-gray-700 leading-relaxed mb-4">
                If you meet the requirements but don&apos;t pass your exam, we&apos;ll extend your Pro 
                subscription for an additional 2 months at no cost. This gives you more time to study 
                and retake your exam.
              </p>

              <h3 className="text-xl font-medium text-green-700 mb-3">Limitations</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2">
                <li>Guarantee applies only once per user, per certification exam</li>
                <li>You must request guarantee benefits within 14 days of receiving exam results</li>
                <li>Guarantee is void if account sharing or other Terms violations are detected</li>
                <li>We reserve the right to verify completion and exam results</li>
              </ul>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Acceptable Use</h2>
              
              <h3 className="text-xl font-medium text-green-700 mb-3">Permitted Uses</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2 mb-4">
                <li>Personal use for Texas teacher certification preparation</li>
                <li>Accessing and practicing with our study materials</li>
                <li>Using mindfulness and wellness features for your benefit</li>
                <li>Providing feedback to help us improve CertBloom</li>
              </ul>

              <h3 className="text-xl font-medium text-green-700 mb-3">Prohibited Uses</h3>
              <ul className="list-disc list-inside text-gray-700 space-y-2">
                <li>Sharing your account credentials with others</li>
                <li>Copying, reproducing, or distributing our content</li>
                <li>Using automated tools or bots to access our service</li>
                <li>Attempting to reverse engineer our adaptive algorithms</li>
                <li>Using CertBloom for any commercial or unauthorized purpose</li>
                <li>Harassing other users or our support team</li>
                <li>Violating any applicable laws or regulations</li>
              </ul>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Content and Intellectual Property</h2>
              
              <h3 className="text-xl font-medium text-green-700 mb-3">Our Content</h3>
              <p className="text-gray-700 leading-relaxed mb-4">
                All content on CertBloom, including practice questions, study materials, explanations, 
                and our adaptive algorithm, is owned by CertBloom and protected by intellectual property laws. 
                You may not copy, modify, or distribute our content without written permission.
              </p>

              <h3 className="text-xl font-medium text-green-700 mb-3">Your Content</h3>
              <p className="text-gray-700 leading-relaxed mb-4">
                You retain ownership of any content you provide (like profile information or feedback). 
                By using CertBloom, you grant us permission to use this content to provide and improve our service.
              </p>

              <h3 className="text-xl font-medium text-green-700 mb-3">DMCA Policy</h3>
              <p className="text-gray-700 leading-relaxed">
                We respect intellectual property rights. If you believe content on CertBloom infringes 
                your copyright, please contact us at support@certbloom.com with details of the alleged infringement.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Disclaimers and Limitations</h2>
              
              <h3 className="text-xl font-medium text-green-700 mb-3">Educational Tool Disclaimer</h3>
              <p className="text-gray-700 leading-relaxed mb-4">
                CertBloom is a study aid designed to help you prepare for Texas teacher certification exams. 
                We cannot guarantee exam success, as this depends on many factors including your effort, 
                study habits, and individual circumstances. Our Pass Guarantee has specific terms outlined above.
              </p>

              <h3 className="text-xl font-medium text-green-700 mb-3">Service Limitations</h3>
              <p className="text-gray-700 leading-relaxed mb-4">
                CertBloom is provided &quot;as is&quot; without warranties of any kind. We don&apos;t guarantee 
                that our service will be uninterrupted, error-free, or meet all your needs. We&apos;re not 
                responsible for any indirect, incidental, or consequential damages.
              </p>

              <h3 className="text-xl font-medium text-green-700 mb-3">Limitation of Liability</h3>
              <p className="text-gray-700 leading-relaxed">
                Our total liability to you for any claims related to CertBloom is limited to the amount 
                you paid us in the 12 months before the claim arose. This limitation applies to the 
                fullest extent permitted by law.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Privacy and Data</h2>
              <p className="text-gray-700 leading-relaxed">
                Your privacy is important to us. Our collection and use of your personal information is 
                governed by our <Link href="/privacy" className="text-green-600 hover:text-green-800 transition-colors">Privacy Policy</Link>, 
                which is incorporated into these Terms by reference.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Changes to Terms</h2>
              <p className="text-gray-700 leading-relaxed">
                We may update these Terms from time to time to reflect changes in our service or legal requirements. 
                We&apos;ll notify you of significant changes via email or through our platform. Your continued use 
                of CertBloom after changes take effect constitutes acceptance of the new Terms.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Termination</h2>
              
              <h3 className="text-xl font-medium text-green-700 mb-3">Your Right to Terminate</h3>
              <p className="text-gray-700 leading-relaxed mb-4">
                You may stop using CertBloom at any time and delete your account through your dashboard 
                or by contacting us. Upon termination, your access to Pro features will end, but we may 
                retain some information as described in our Privacy Policy.
              </p>

              <h3 className="text-xl font-medium text-green-700 mb-3">Our Right to Terminate</h3>
              <p className="text-gray-700 leading-relaxed">
                We may suspend or terminate your account if you violate these Terms, fail to pay subscription fees, 
                or engage in behavior that harms CertBloom or other users. We&apos;ll provide notice when possible, 
                but may act immediately in serious cases.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Dispute Resolution</h2>
              
              <h3 className="text-xl font-medium text-green-700 mb-3">Informal Resolution</h3>
              <p className="text-gray-700 leading-relaxed mb-4">
                If you have concerns about CertBloom, please contact us first at support@certbloom.com. 
                We&apos;re committed to working with you to resolve any issues.
              </p>

              <h3 className="text-xl font-medium text-green-700 mb-3">Governing Law</h3>
              <p className="text-gray-700 leading-relaxed">
                These Terms are governed by the laws of the State of Texas, without regard to conflict 
                of law principles. Any disputes will be resolved in the courts of Texas.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Contact Information</h2>
              <p className="text-gray-700 leading-relaxed mb-4">
                If you have questions about these Terms or need to contact us for any reason:
              </p>
              
              <div className="bg-green-50 rounded-xl p-6">
                <p className="text-gray-700 mb-2"><strong>Email:</strong> support@certbloom.com</p>
                <p className="text-gray-700 mb-2"><strong>Subject Line:</strong> Terms of Service Inquiry</p>
                <p className="text-gray-700"><strong>Response Time:</strong> We respond to all inquiries within 48 hours</p>
              </div>
            </section>

            <section>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Acknowledgment</h2>
              <p className="text-gray-700 leading-relaxed">
                By using CertBloom, you acknowledge that you have read, understood, and agree to be bound 
                by these Terms of Service. You also acknowledge that you have read and understood our 
                Privacy Policy. Thank you for choosing CertBloom for your teacher certification journey.
              </p>
            </section>
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="px-6 py-8 text-center">
        <div className="max-w-6xl mx-auto">
          <p className="text-green-600">
            <Link href="/" className="hover:text-green-800 transition-colors">Return to CertBloom</Link> • 
            <Link href="/privacy" className="hover:text-green-800 transition-colors ml-2">Privacy Policy</Link>
          </p>
        </div>
      </footer>
    </div>
  );
}
