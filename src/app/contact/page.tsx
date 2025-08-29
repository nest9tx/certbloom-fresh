'use client';

import { useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import StaticNavigation from '../../components/StaticNavigation';

export default function ContactPage() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    
    // Simulate form submission
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    setIsSubmitted(true);
    setIsSubmitting(false);
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 relative">
      {/* Floating Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-20 left-10 animate-pulse text-green-300 opacity-20 text-4xl">🌸</div>
        <div className="absolute top-40 right-20 animate-pulse text-orange-300 opacity-20 text-3xl" style={{animationDelay: '1s'}}>🍃</div>
        <div className="absolute bottom-32 left-1/4 animate-pulse text-yellow-300 opacity-20 text-5xl" style={{animationDelay: '2s'}}>✨</div>
        <div className="absolute top-1/3 right-10 animate-pulse text-green-300 opacity-20 text-4xl" style={{animationDelay: '0.5s'}}>🌱</div>
      </div>

      <StaticNavigation currentPage="contact" />

      {/* Main Content */}
      <div className="relative z-10 container mx-auto px-6 py-12">
        <div className="max-w-6xl mx-auto">
          
          {/* Hero Section */}
          <div className="text-center mb-16">
            <div className="text-6xl mb-6">💌</div>
            <h1 className="text-4xl lg:text-5xl font-light text-green-800 mb-6">
              Get in Touch
            </h1>
            <p className="text-xl text-green-600 max-w-3xl mx-auto leading-relaxed">
              We&apos;re here to support your teaching journey. Whether you have questions, feedback, 
              or just want to say hello, we&apos;d love to hear from you.
            </p>
          </div>

          <div className="grid lg:grid-cols-2 gap-12">
            
            {/* Contact Form */}
            <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
              {!isSubmitted ? (
                <>
                  <h2 className="text-2xl font-semibold text-green-800 mb-6">Send us a Message</h2>
                  
                  <form onSubmit={handleSubmit} className="space-y-6">
                    <div>
                      <label htmlFor="name" className="block text-green-700 font-medium mb-2">
                        Your Name
                      </label>
                      <input
                        type="text"
                        id="name"
                        name="name"
                        value={formData.name}
                        onChange={handleChange}
                        required
                        className="w-full px-4 py-3 rounded-xl border border-green-300 focus:outline-none focus:ring-2 focus:ring-green-500 bg-white text-gray-800"
                        placeholder="Enter your full name"
                      />
                    </div>

                    <div>
                      <label htmlFor="email" className="block text-green-700 font-medium mb-2">
                        Email Address
                      </label>
                      <input
                        type="email"
                        id="email"
                        name="email"
                        value={formData.email}
                        onChange={handleChange}
                        required
                        className="w-full px-4 py-3 rounded-xl border border-green-300 focus:outline-none focus:ring-2 focus:ring-green-500 bg-white text-gray-800"
                        placeholder="your@email.com"
                      />
                    </div>

                    <div>
                      <label htmlFor="subject" className="block text-green-700 font-medium mb-2">
                        Subject
                      </label>
                      <select
                        id="subject"
                        name="subject"
                        value={formData.subject}
                        onChange={handleChange}
                        required
                        className="w-full px-4 py-3 rounded-xl border border-green-300 focus:outline-none focus:ring-2 focus:ring-green-500 bg-white text-gray-800"
                      >
                        <option value="">Select a topic...</option>
                        <option value="general">General Question</option>
                        <option value="technical">Technical Support</option>
                        <option value="billing">Billing & Pricing</option>
                        <option value="content">Content Feedback</option>
                        <option value="partnership">Partnership Inquiry</option>
                        <option value="other">Other</option>
                      </select>
                    </div>

                    <div>
                      <label htmlFor="message" className="block text-green-700 font-medium mb-2">
                        Message
                      </label>
                      <textarea
                        id="message"
                        name="message"
                        value={formData.message}
                        onChange={handleChange}
                        required
                        rows={5}
                        className="w-full px-4 py-3 rounded-xl border border-green-300 focus:outline-none focus:ring-2 focus:ring-green-500 bg-white text-gray-800 resize-none"
                        placeholder="Tell us how we can help you on your teaching journey..."
                      />
                    </div>

                    <button
                      type="submit"
                      disabled={isSubmitting}
                      className="w-full py-3 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-[1.02] font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {isSubmitting ? 'Sending...' : 'Send Message 💚'}
                    </button>
                  </form>
                </>
              ) : (
                <div className="text-center py-8">
                  <div className="text-6xl mb-6">🌸</div>
                  <h3 className="text-2xl font-semibold text-green-800 mb-4">Message Sent!</h3>
                  <p className="text-green-600 mb-6">
                    Thank you for reaching out. We&apos;ll get back to you within 24 hours to continue 
                    supporting your teaching journey.
                  </p>
                  <button
                    onClick={() => {
                      setIsSubmitted(false);
                      setFormData({ name: '', email: '', subject: '', message: '' });
                    }}
                    className="px-6 py-2 text-green-600 hover:text-green-700 transition-colors"
                  >
                    Send Another Message
                  </button>
                </div>
              )}
            </div>

            {/* Contact Information */}
            <div className="space-y-8">
              
              {/* Quick Contact */}
              <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
                <h3 className="text-2xl font-semibold text-green-800 mb-6">Quick Contact</h3>
                
                <div className="space-y-6">
                  <div className="flex items-start space-x-4">
                    <div className="text-2xl">📧</div>
                    <div>
                      <h4 className="font-semibold text-green-800">Email Support</h4>
                      <p className="text-green-600">support@certbloom.com</p>
                      <p className="text-green-500 text-sm">Response within 1-2 business days</p>
                    </div>
                  </div>

                  <div className="flex items-start space-x-4">
                    <div className="text-2xl">�</div>
                    <div>
                      <h4 className="font-semibold text-green-800">Help Center</h4>
                      <p className="text-green-600">Self-service guides & FAQs</p>
                      <p className="text-green-500 text-sm">Available 24/7</p>
                    </div>
                  </div>

                  <div className="flex items-start space-x-4">
                    <div className="text-2xl">📍</div>
                    <div>
                      <h4 className="font-semibold text-green-800">Texas Based</h4>
                      <p className="text-green-600">Built by Texas educators</p>
                      <p className="text-green-500 text-sm">For Texas teachers</p>
                    </div>
                  </div>
                </div>
              </div>

              {/* FAQ Quick Links */}
              <div className="bg-gradient-to-r from-green-100 to-orange-100 rounded-2xl p-8 border border-green-200/60 shadow-xl">
                <h3 className="text-2xl font-semibold text-green-800 mb-6">Common Questions</h3>
                
                <div className="space-y-4">
                  <div>
                    <h4 className="font-semibold text-green-800 mb-2">How does adaptive learning work?</h4>
                    <p className="text-green-600 text-sm">
                      Our platform adjusts difficulty and content based on your performance, learning style, 
                      and even your current mood to optimize your study experience.
                    </p>
                  </div>

                  <div>
                    <h4 className="font-semibold text-green-800 mb-2">Is the free plan really free?</h4>
                    <p className="text-green-600 text-sm">
                      Yes! You get 50 practice questions and access to mindfulness features with no credit card required.
                    </p>
                  </div>

                  <div>
                    <h4 className="font-semibold text-green-800 mb-2">What TExES exams do you cover?</h4>
                    <p className="text-green-600 text-sm">
                      We currently support EC-6, ELA 4-8, Math 4-8, and are continuously adding more certifications.
                    </p>
                  </div>
                </div>
              </div>

              {/* Community */}
              <div className="bg-gradient-to-r from-blue-100 to-purple-100 rounded-2xl p-8 border border-blue-200/60 shadow-xl">
                <h3 className="text-2xl font-semibold text-green-800 mb-4">Join Our Community</h3>
                <p className="text-green-600 mb-6">
                  Connect with fellow Texas educators on their certification journey. Share experiences, 
                  celebrate victories, and support each other.
                </p>
                
                <div className="flex space-x-4">
                  <a href="#" className="text-2xl hover:scale-110 transition-transform">🐦</a>
                  <a href="#" className="text-2xl hover:scale-110 transition-transform">💼</a>
                  <a href="#" className="text-2xl hover:scale-110 transition-transform">📸</a>
                  <a href="#" className="text-2xl hover:scale-110 transition-transform">📘</a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="relative z-10 bg-gradient-to-r from-green-800 to-green-900 text-white mt-16">
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
                <Link href="/about" className="block text-green-200 hover:text-white transition-colors">About</Link>
                <Link href="/contact" className="block text-green-200 hover:text-white transition-colors">Contact</Link>
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
