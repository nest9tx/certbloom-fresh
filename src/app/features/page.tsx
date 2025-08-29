'use client';

import Navigation from '../../components/Navigation';

export default function FeaturesPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-orange-50 to-yellow-50 relative">
      {/* Floating Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-20 left-10 animate-pulse text-green-300 opacity-20 text-4xl">🌸</div>
        <div className="absolute top-40 right-20 animate-pulse text-orange-300 opacity-20 text-3xl" style={{animationDelay: '1s'}}>🍃</div>
        <div className="absolute bottom-32 left-1/4 animate-pulse text-yellow-300 opacity-20 text-5xl" style={{animationDelay: '2s'}}>✨</div>
        <div className="absolute top-1/3 right-10 animate-pulse text-green-300 opacity-20 text-4xl" style={{animationDelay: '0.5s'}}>🌱</div>
      </div>

      <Navigation currentPage="features" />

      {/* Main Content */}
      <div className="relative z-10 container mx-auto px-6 py-12">
        <div className="max-w-6xl mx-auto">
          
          {/* Hero Section */}
          <div className="text-center mb-16">
            <div className="text-6xl mb-6">✨</div>
            <h1 className="text-4xl lg:text-5xl font-light text-green-800 mb-6">
              Features
            </h1>
            <p className="text-xl text-green-600 max-w-3xl mx-auto leading-relaxed">
              Discover how CertBloom combines intelligent learning with mindful practice 
              to transform your certification journey.
            </p>
          </div>

          {/* Features Grid */}
          <div className="grid lg:grid-cols-2 gap-12 mb-16">
            
            {/* Adaptive Learning */}
            <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
              <div className="text-4xl mb-4">🧠</div>
              <h3 className="text-2xl font-semibold text-green-800 mb-4">Adaptive Learning</h3>
              <p className="text-green-600 mb-6">
                Our intelligent system adapts to your learning style, identifying strengths and areas for growth. 
                Questions adjust in real-time based on your performance.
              </p>
              <ul className="space-y-2 text-green-700">
                <li className="flex items-start space-x-2">
                  <span className="text-green-500 mt-1">•</span>
                  <span>Personalized question difficulty</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-green-500 mt-1">•</span>
                  <span>Progress tracking by domain</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-green-500 mt-1">•</span>
                  <span>Intelligent content recommendations</span>
                </li>
              </ul>
            </div>

            {/* Mindful Practice */}
            <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
              <div className="text-4xl mb-4">🌸</div>
              <h3 className="text-2xl font-semibold text-green-800 mb-4">Mindful Practice</h3>
              <p className="text-green-600 mb-6">
                Reduce test anxiety and improve focus with integrated mindfulness exercises. 
                Breathe your way to certification success.
              </p>
              <ul className="space-y-2 text-green-700">
                <li className="flex items-start space-x-2">
                  <span className="text-green-500 mt-1">•</span>
                  <span>Guided breathing exercises</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-green-500 mt-1">•</span>
                  <span>Stress reduction techniques</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-green-500 mt-1">•</span>
                  <span>Focus enhancement tools</span>
                </li>
              </ul>
            </div>

            {/* Comprehensive Content */}
            <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
              <div className="text-4xl mb-4">📚</div>
              <h3 className="text-2xl font-semibold text-green-800 mb-4">Comprehensive Content</h3>
              <p className="text-green-600 mb-6">
                Expertly crafted questions and explanations covering all TExES certification domains. 
                Content created by Texas educators, for Texas educators.
              </p>
              <ul className="space-y-2 text-green-700">
                <li className="flex items-start space-x-2">
                  <span className="text-green-500 mt-1">•</span>
                  <span>All certification areas covered</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-green-500 mt-1">•</span>
                  <span>Detailed explanations and rationales</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-green-500 mt-1">•</span>
                  <span>Real-world teaching scenarios</span>
                </li>
              </ul>
            </div>

            {/* Progress Analytics */}
            <div className="bg-white/90 backdrop-blur-sm rounded-2xl p-8 border border-green-200/60 shadow-xl">
              <div className="text-4xl mb-4">📊</div>
              <h3 className="text-2xl font-semibold text-green-800 mb-4">Progress Analytics</h3>
              <p className="text-green-600 mb-6">
                Track your growth with detailed analytics and insights. Understand your learning patterns 
                and optimize your study strategy.
              </p>
              <ul className="space-y-2 text-green-700">
                <li className="flex items-start space-x-2">
                  <span className="text-green-500 mt-1">•</span>
                  <span>Visual progress tracking</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-green-500 mt-1">•</span>
                  <span>Performance by topic analysis</span>
                </li>
                <li className="flex items-start space-x-2">
                  <span className="text-green-500 mt-1">•</span>
                  <span>Study time optimization</span>
                </li>
              </ul>
            </div>

          </div>

          {/* Call to Action */}
          <div className="bg-gradient-to-r from-green-100 via-orange-50 to-yellow-100 rounded-2xl p-8 border border-green-200/60 shadow-lg text-center">
            <div className="text-4xl mb-4">🚀</div>
            <h2 className="text-3xl font-semibold text-green-800 mb-4">Ready to Transform Your Prep?</h2>
            <p className="text-green-600 text-lg mb-6 max-w-2xl mx-auto">
              Join thousands of Texas educators who chose CertBloom for certification prep that honors both your mind and spirit.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <a 
                href="/auth" 
                className="px-8 py-3 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 font-medium"
              >
                Start Free Today
              </a>
              <a 
                href="/pricing" 
                className="px-8 py-3 bg-white text-green-700 border-2 border-green-600 rounded-xl hover:bg-green-50 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105 font-medium"
              >
                View Pricing
              </a>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
