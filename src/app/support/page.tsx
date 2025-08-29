'use client';

import { useState } from 'react';
import Link from 'next/link';
import Navigation from '../../components/Navigation';
import { useAuth } from '../../lib/auth-context';

export default function SupportPage() {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState('help');
  const [ticketForm, setTicketForm] = useState({
    subject: '',
    category: 'technical',
    priority: 'medium',
    message: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(false);

  const handleTicketSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      // Create mailto link for now - in production this would submit to a support API
      const subject = encodeURIComponent(`[${ticketForm.category.toUpperCase()}] ${ticketForm.subject}`);
      const body = encodeURIComponent(
        `Priority: ${ticketForm.priority}\n` +
        `User: ${user?.email || 'Guest'}\n\n` +
        `Message:\n${ticketForm.message}`
      );
      
      window.location.href = `mailto:support@certbloom.com?subject=${subject}&body=${body}`;
      
      setSubmitSuccess(true);
      setTicketForm({ subject: '', category: 'technical', priority: 'medium', message: '' });
    } catch (error) {
      console.error('Error submitting ticket:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const faqData = [
    {
      question: "How does the adaptive learning system work?",
      answer: "Our AI analyzes your responses and learning patterns to identify knowledge gaps and strengths. It then adjusts the difficulty and focus areas to optimize your study time and maximize learning efficiency."
    },
    {
      question: "Can I track my progress across different certification exams?",
      answer: "Yes! Your dashboard provides detailed analytics for each certification you're studying for, including concept mastery, time spent, and estimated readiness for the exam."
    },
    {
      question: "What if I'm struggling with a particular concept?",
      answer: "The system will automatically provide additional practice questions and alternative explanations for concepts you find challenging. You can also use our mindful learning breaks to reset and refocus."
    },
    {
      question: "How accurate are the practice questions compared to real exams?",
      answer: "Our questions are crafted by certified educators and aligned with official exam standards. We continuously update our question bank based on the latest exam changes and user feedback."
    },
    {
      question: "Can I study offline?",
      answer: "Currently, CertBloom requires an internet connection for the adaptive features and progress tracking. We're working on offline capabilities for future releases."
    },
    {
      question: "How do I cancel my subscription?",
      answer: "You can manage your subscription from your account settings. Cancellations take effect at the end of your current billing period, and you'll retain access until then."
    }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50">
      {/* Floating Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-20 left-10 animate-pulse text-green-300 opacity-20 text-4xl">🌸</div>
        <div className="absolute top-40 right-20 animate-pulse text-orange-300 opacity-20 text-3xl" style={{animationDelay: '1s'}}>🍃</div>
        <div className="absolute bottom-32 left-1/4 animate-pulse text-yellow-300 opacity-20 text-5xl" style={{animationDelay: '2s'}}>✨</div>
        <div className="absolute top-1/3 right-10 animate-pulse text-green-300 opacity-20 text-4xl" style={{animationDelay: '0.5s'}}>🌱</div>
      </div>

      <Navigation currentPage="support" />

      <div className="relative z-10 max-w-7xl mx-auto px-6 py-12">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-4xl md:text-5xl font-light text-green-800 mb-6">
            Support Center
          </h1>
          <p className="text-xl text-green-700 max-w-3xl mx-auto">
            We&apos;re here to help you succeed. Find answers, get support, and make the most of your CertBloom experience.
          </p>
        </div>

        {/* Tab Navigation */}
        <div className="flex justify-center mb-8">
          <div className="bg-white/60 backdrop-blur-sm rounded-2xl p-2 shadow-lg">
            <button
              onClick={() => setActiveTab('help')}
              className={`px-6 py-3 rounded-xl font-medium transition-all duration-200 ${
                activeTab === 'help'
                  ? 'bg-white text-green-800 shadow-md'
                  : 'text-green-600 hover:text-green-800'
              }`}
            >
              Help & FAQ
            </button>
            <button
              onClick={() => setActiveTab('contact')}
              className={`px-6 py-3 rounded-xl font-medium transition-all duration-200 ${
                activeTab === 'contact'
                  ? 'bg-white text-green-800 shadow-md'
                  : 'text-green-600 hover:text-green-800'
              }`}
            >
              Contact Support
            </button>
            <button
              onClick={() => setActiveTab('resources')}
              className={`px-6 py-3 rounded-xl font-medium transition-all duration-200 ${
                activeTab === 'resources'
                  ? 'bg-white text-green-800 shadow-md'
                  : 'text-green-600 hover:text-green-800'
              }`}
            >
              Resources
            </button>
          </div>
        </div>

        {/* Content */}
        {activeTab === 'help' && (
          <div className="max-w-4xl mx-auto">
            <div className="bg-white/80 backdrop-blur-sm rounded-3xl p-8 shadow-xl">
              <h2 className="text-2xl font-semibold text-green-800 mb-8 text-center">
                Frequently Asked Questions
              </h2>
              <div className="space-y-6">
                {faqData.map((faq, index) => (
                  <details
                    key={index}
                    className="group bg-gradient-to-r from-green-50 to-orange-50 rounded-2xl p-6 shadow-md hover:shadow-lg transition-all duration-200"
                  >
                    <summary className="font-semibold text-green-800 cursor-pointer list-none flex items-center justify-between">
                      <span>{faq.question}</span>
                      <span className="text-green-600 group-open:rotate-180 transition-transform duration-200">
                        ▼
                      </span>
                    </summary>
                    <div className="mt-4 text-green-700 leading-relaxed">
                      {faq.answer}
                    </div>
                  </details>
                ))}
              </div>
            </div>
          </div>
        )}

        {activeTab === 'contact' && (
          <div className="max-w-2xl mx-auto">
            <div className="bg-white/80 backdrop-blur-sm rounded-3xl p-8 shadow-xl">
              <h2 className="text-2xl font-semibold text-green-800 mb-2 text-center">
                Contact Support
              </h2>
              <p className="text-green-600 text-center mb-8">
                Can&apos;t find what you&apos;re looking for? Send us a message and we&apos;ll get back to you soon.
              </p>

              {submitSuccess && (
                <div className="bg-green-100 border border-green-200 rounded-2xl p-4 mb-6 text-center">
                  <div className="text-green-800 font-medium">Message sent successfully!</div>
                  <div className="text-green-600 text-sm mt-1">
                    Your email client should open. If not, please email us directly at support@certbloom.com
                  </div>
                </div>
              )}

              <form onSubmit={handleTicketSubmit} className="space-y-6">
                <div>
                  <label className="block text-green-800 font-medium mb-2">
                    Subject *
                  </label>
                  <input
                    type="text"
                    required
                    value={ticketForm.subject}
                    onChange={(e) => setTicketForm({ ...ticketForm, subject: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-green-200 focus:border-green-500 focus:ring-2 focus:ring-green-200 outline-none transition-all duration-200"
                    placeholder="Brief description of your issue"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-green-800 font-medium mb-2">
                      Category
                    </label>
                    <select
                      value={ticketForm.category}
                      onChange={(e) => setTicketForm({ ...ticketForm, category: e.target.value })}
                      className="w-full px-4 py-3 rounded-xl border border-green-200 focus:border-green-500 focus:ring-2 focus:ring-green-200 outline-none transition-all duration-200"
                    >
                      <option value="technical">Technical Issue</option>
                      <option value="billing">Billing Question</option>
                      <option value="content">Content Question</option>
                      <option value="account">Account Help</option>
                      <option value="feature">Feature Request</option>
                      <option value="other">Other</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-green-800 font-medium mb-2">
                      Priority
                    </label>
                    <select
                      value={ticketForm.priority}
                      onChange={(e) => setTicketForm({ ...ticketForm, priority: e.target.value })}
                      className="w-full px-4 py-3 rounded-xl border border-green-200 focus:border-green-500 focus:ring-2 focus:ring-green-200 outline-none transition-all duration-200"
                    >
                      <option value="low">Low</option>
                      <option value="medium">Medium</option>
                      <option value="high">High</option>
                      <option value="urgent">Urgent</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-green-800 font-medium mb-2">
                    Message *
                  </label>
                  <textarea
                    required
                    rows={6}
                    value={ticketForm.message}
                    onChange={(e) => setTicketForm({ ...ticketForm, message: e.target.value })}
                    className="w-full px-4 py-3 rounded-xl border border-green-200 focus:border-green-500 focus:ring-2 focus:ring-green-200 outline-none transition-all duration-200 resize-none"
                    placeholder="Please describe your issue or question in detail..."
                  />
                </div>

                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="w-full py-4 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed font-medium"
                >
                  {isSubmitting ? 'Sending...' : 'Send Message'}
                </button>
              </form>

              <div className="mt-8 pt-6 border-t border-green-200 text-center">
                <p className="text-green-600 mb-2">
                  Or reach us directly:
                </p>
                <a
                  href="mailto:support@certbloom.com"
                  className="inline-flex items-center text-green-700 hover:text-green-900 font-medium transition-colors"
                >
                  📧 support@certbloom.com
                </a>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'resources' && (
          <div className="max-w-4xl mx-auto">
            <div className="grid md:grid-cols-2 gap-8">
              {/* Quick Links */}
              <div className="bg-white/80 backdrop-blur-sm rounded-3xl p-8 shadow-xl">
                <h3 className="text-xl font-semibold text-green-800 mb-6">
                  Quick Links
                </h3>
                <div className="space-y-4">
                  <Link
                    href="/dashboard"
                    className="block p-4 bg-gradient-to-r from-green-50 to-orange-50 rounded-xl hover:shadow-md transition-all duration-200"
                  >
                    <div className="font-medium text-green-800">📊 Dashboard</div>
                    <div className="text-green-600 text-sm mt-1">
                      View your progress and analytics
                    </div>
                  </Link>
                  <Link
                    href="/settings"
                    className="block p-4 bg-gradient-to-r from-green-50 to-orange-50 rounded-xl hover:shadow-md transition-all duration-200"
                  >
                    <div className="font-medium text-green-800">⚙️ Account Settings</div>
                    <div className="text-green-600 text-sm mt-1">
                      Manage your account and preferences
                    </div>
                  </Link>
                  <Link
                    href="/pricing"
                    className="block p-4 bg-gradient-to-r from-green-50 to-orange-50 rounded-xl hover:shadow-md transition-all duration-200"
                  >
                    <div className="font-medium text-green-800">💳 Subscription</div>
                    <div className="text-green-600 text-sm mt-1">
                      View plans and manage billing
                    </div>
                  </Link>
                </div>
              </div>

              {/* Study Tips */}
              <div className="bg-white/80 backdrop-blur-sm rounded-3xl p-8 shadow-xl">
                <h3 className="text-xl font-semibold text-green-800 mb-6">
                  Study Tips
                </h3>
                <div className="space-y-4">
                  <div className="p-4 bg-gradient-to-r from-green-50 to-orange-50 rounded-xl">
                    <div className="font-medium text-green-800">🎯 Focus Sessions</div>
                    <div className="text-green-600 text-sm mt-1">
                      Study in 25-minute focused blocks for better retention
                    </div>
                  </div>
                  <div className="p-4 bg-gradient-to-r from-green-50 to-orange-50 rounded-xl">
                    <div className="font-medium text-green-800">🔄 Regular Practice</div>
                    <div className="text-green-600 text-sm mt-1">
                      Consistent daily practice beats long cramming sessions
                    </div>
                  </div>
                  <div className="p-4 bg-gradient-to-r from-green-50 to-orange-50 rounded-xl">
                    <div className="font-medium text-green-800">🧘 Mindful Breaks</div>
                    <div className="text-green-600 text-sm mt-1">
                      Use our mindful learning breaks to reset and refocus
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* System Status */}
            <div className="mt-8 bg-white/80 backdrop-blur-sm rounded-3xl p-8 shadow-xl">
              <h3 className="text-xl font-semibold text-green-800 mb-6 text-center">
                System Status
              </h3>
              <div className="flex items-center justify-center space-x-2">
                <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
                <span className="text-green-700 font-medium">All systems operational</span>
              </div>
              <p className="text-center text-green-600 text-sm mt-2">
                Last updated: {new Date().toLocaleString()}
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
