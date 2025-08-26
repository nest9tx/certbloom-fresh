// Simple test to check what's happening with certification goal updates
// Run this with: node test-cert-update.js

const testCertUpdate = async () => {
  try {
    console.log('🧪 Testing certification goal update API...')
    
    // Test the update endpoint that's failing in the UI
    const testData = {
      certificationGoal: 'TExES Core Subjects EC-6: Mathematics (902)'
    }
    
    console.log('📨 Testing certification update with:', testData)
    
    const response = await fetch('http://localhost:3000/api/update-certification-goal', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        // Note: In real usage, this would need proper auth token
      },
      body: JSON.stringify(testData)
    })
    
    const result = await response.json()
    console.log('📋 API Response Status:', response.status)
    console.log('📋 API Response:', result)
    
    if (result.success) {
      console.log('✅ Certification update would work!')
    } else {
      console.log('❌ Certification update failed:', result.error)
      if (result.error.includes('check constraint')) {
        console.log('🚨 CONFIRMED: Database constraint is blocking updates!')
        console.log('💡 Solution: Run the emergency-constraint-fix.sql in Supabase')
      }
    }
    
  } catch (error) {
    console.error('💥 Exception during test:', error)
  }
}

// Run the test
testCertUpdate()
