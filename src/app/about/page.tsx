'use client';

import Link from 'next/link';
import Image from 'next/image';

export default function AboutPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 relative">
      {/* Floating Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-20 left-10 animate-pulse text-green-300 opacity-20 text-4xl">🌸</div>
        <div className="absolute top-40 right-20 animate-pulse text-orange-300 opacity-20 text-3xl" style={{animationDelay: '1s'}}>🍃</div>
        <div className="absolute bottom-32 left-1/4 animate-pulse text-yellow-300 opacity-20 text-5xl" style={{animationDelay: '2s'}}>✨</div>
        <div className="absolute top-1/3 right-10 animate-pulse text-green-300 opacity-20 text-4xl" style={{animationDelay: '0.5s'}}>🌱</div>
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
            <Link href="/" className="text-green-700 hover:text-green-900 transition-colors font-medium">Home</Link>
            <Link href="/pricing" className="text-green-700 hover:text-green-900 transition-colors font-medium">Pricing</Link>
            <Link href="/about" className="text-green-900 font-semibold">About</Link>
            <Link href="/contact" className="text-green-700 hover:text-green-900 transition-colors font-medium">Contact</Link>
            <Link href="/auth" className="px-6 py-2 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105">
              Sign In
            </Link>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <div className="relative z-10 container mx-auto px-6 py-12">
        <div className="max-w-6xl mx-auto">
          
          {/* Hero Section */}
          <div className="text-center mb-16">
            <div className="text-6xl mb-6">🌸</div>
            <h1 className="text-4xl lg:text-5xl font-light text-green-800 mb-6">
              Our Story
            </h1>
            <p className="text-xl text-green-600 max-w-3xl mx-auto leading-relaxed">
              CertBloom was born from a simple belief: teacher preparation should nurture the whole person, 
              not just academic knowledge. We&apos;re here to transform how educators approach certification.
            </p>
          </div>

          {/* Mission Statement */}
          <div className="grid lg:grid-cols-2 gap-12 mb-16">
            <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
              <div className="text-4xl mb-6">🎯</div>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Our Mission</h2>
              <p className="text-green-600 leading-relaxed">
                To empower Texas educators with adaptive, mindful certification preparation that honors both 
                academic excellence and personal well-being. We believe learning should be a journey of growth, 
                not stress.
              </p>
            </div>

            <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
              <div className="text-4xl mb-6">🌱</div>
              <h2 className="text-2xl font-semibold text-green-800 mb-4">Our Vision</h2>
              <p className="text-green-600 leading-relaxed">
                A world where every educator enters their classroom confident, prepared, and centered. Where 
                certification preparation strengthens rather than overwhelms, and where mindfulness and learning 
                unite for lasting success.
              </p>
            </div>
          </div>

          {/* Values */}
          <div className="mb-16">
            <h2 className="text-3xl font-light text-green-800 text-center mb-12">Our Core Values</h2>
            
            <div className="grid md:grid-cols-3 gap-8">
              <div className="text-center p-6">
                <div className="text-5xl mb-4">🧠</div>
                <h3 className="text-xl font-semibold text-green-800 mb-3">Adaptive Intelligence</h3>
                <p className="text-green-600">
                  Every learner is unique. Our platform adapts to your pace, style, and needs, 
                  ensuring personalized growth at every step.
                </p>
              </div>

              <div className="text-center p-6">
                <div className="text-5xl mb-4">🧘‍♀️</div>
                <h3 className="text-xl font-semibold text-green-800 mb-3">Mindful Learning</h3>
                <p className="text-green-600">
                  Stress and anxiety have no place in learning. We integrate mindfulness practices 
                  to keep you centered and confident.
                </p>
              </div>

              <div className="text-center p-6">
                <div className="text-5xl mb-4">🌟</div>
                <h3 className="text-xl font-semibold text-green-800 mb-3">Holistic Growth</h3>
                <p className="text-green-600">
                  We prepare not just your mind, but your spirit. Because great teachers 
                  are whole humans who inspire through their presence.
                </p>
              </div>
            </div>
          </div>

          {/* The CertBloom Difference */}
          <div className="bg-gradient-to-r from-green-100 to-orange-100 rounded-2xl p-8 border border-green-200/60 shadow-xl mb-16">
            <h2 className="text-3xl font-light text-green-800 text-center mb-8">The CertBloom Difference</h2>
            
            <div className="grid lg:grid-cols-2 gap-8">
              <div>
                <h3 className="text-xl font-semibold text-green-800 mb-4">Traditional Test Prep</h3>
                <ul className="space-y-3 text-green-600">
                  <li className="flex items-start">
                    <span className="text-red-500 mr-3">❌</span>
                    One-size-fits-all approach
                  </li>
                  <li className="flex items-start">
                    <span className="text-red-500 mr-3">❌</span>
                    High stress, high pressure
                  </li>
                  <li className="flex items-start">
                    <span className="text-red-500 mr-3">❌</span>
                    Focus only on passing scores
                  </li>
                  <li className="flex items-start">
                    <span className="text-red-500 mr-3">❌</span>
                    Disconnected from real teaching
                  </li>
                </ul>
              </div>

              <div>
                <h3 className="text-xl font-semibold text-green-800 mb-4">The CertBloom Way</h3>
                <ul className="space-y-3 text-green-600">
                  <li className="flex items-start">
                    <span className="text-green-500 mr-3">✓</span>
                    Personalized adaptive learning
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-3">✓</span>
                    Mindful, stress-reducing practices
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-3">✓</span>
                    Holistic educator development
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-3">✓</span>
                    Real-world teaching preparation
                  </li>
                </ul>
              </div>
            </div>
          </div>

          {/* Our Commitment */}
          <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl mb-16">
            <div className="text-center max-w-4xl mx-auto">
              <div className="text-4xl mb-6">💚</div>
              <h2 className="text-3xl font-light text-green-800 mb-6">Our Commitment to You</h2>
              <p className="text-green-600 text-lg leading-relaxed mb-8">
                We&apos;re not just another test prep company. We&apos;re educators who understand the sacred 
                responsibility of teaching. Every feature we build, every question we craft, and every mindful 
                moment we create is designed with one goal: helping you become the confident, centered educator 
                that Texas students deserve.
              </p>
              
              <div className="grid md:grid-cols-3 gap-6">
                <div className="text-center">
                  <div className="text-2xl font-bold text-green-700 mb-1">94%</div>
                  <div className="text-green-600 text-sm">Pass Rate</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-orange-700 mb-1">5,000+</div>
                  <div className="text-orange-600 text-sm">Teachers Supported</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-blue-700 mb-1">15min</div>
                  <div className="text-blue-600 text-sm">Daily Study Time</div>
                </div>
              </div>
            </div>
          </div>

          {/* Join Our Mission */}
          <div className="text-center">
            <h2 className="text-3xl font-light text-green-800 mb-6">Ready to Begin Your Journey?</h2>
            <p className="text-xl text-green-600 mb-8 max-w-2xl mx-auto">
              Join thousands of Texas educators who chose CertBloom for certification prep that nurtures 
              both mind and spirit.
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link 
                href="/auth"
                className="px-10 py-4 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-xl hover:shadow-2xl transform hover:scale-105 font-medium text-center"
              >
                Start Free Today
              </Link>
              <Link 
                href="/contact"
                className="px-10 py-4 border-2 border-green-600 text-green-600 rounded-xl hover:bg-green-50 transition-all duration-200 font-medium text-center shadow-lg hover:shadow-xl"
              >
                Contact Us
              </Link>
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
                <Link href="/contact" className="block text-green-200 hover:text-white transition-colors">
                  Get Help
                </Link>
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
