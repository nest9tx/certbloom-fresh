'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'

export default function PracticeSessionRedirect() {
  const router = useRouter()

  useEffect(() => {
    // Auto-redirect to enhanced learning after showing upgrade message
    const timer = setTimeout(() => {
      router.push('/enhanced-learning')
    }, 3000)

    return () => clearTimeout(timer)
  }, [router])

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 flex items-center justify-center">
      <div className="max-w-2xl mx-auto text-center p-8">
        <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-8 border border-white/50 shadow-xl">
          <div className="text-6xl mb-6">🚀</div>
          <h1 className="text-3xl font-bold text-gray-900 mb-4">
            Practice Sessions Have Been Upgraded!
          </h1>
          <p className="text-lg text-gray-600 mb-6">
            We&apos;ve moved beyond basic practice sessions to our revolutionary Enhanced Learning Experience 
            with interactive modules, teaching strategies, and real classroom scenarios.
          </p>
          
          <div className="bg-blue-50 rounded-lg p-4 mb-6">
            <p className="text-blue-800 font-medium">
              🔄 Redirecting you to Enhanced Learning in 3 seconds...
            </p>
          </div>

          <div className="space-y-4">
            <Link 
              href="/enhanced-learning"
              className="inline-block px-6 py-3 bg-gradient-to-r from-purple-600 to-pink-600 text-white font-medium rounded-lg hover:from-purple-700 hover:to-pink-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105"
            >
              🌟 Go to Enhanced Learning Now
            </Link>
            <div className="flex justify-center space-x-6 text-sm">
              <Link 
                href="/dashboard"
                className="text-purple-600 hover:text-purple-700 underline"
              >
                Return to Dashboard
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}