// Test the user profile creation API
const testSignup = async () => {
  try {
    console.log('🧪 Testing user profile creation...')
    
    // Generate a proper UUID-like string for testing
    const generateUUID = () => {
      return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        const r = Math.random() * 16 | 0;
        const v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
      });
    }
    
    const testData = {
      userId: generateUUID(),
      email: 'test@example.com',
      fullName: 'Test User',
      certificationGoal: 'TExES Core Subjects EC-6: Mathematics (902)'
    }
    
    console.log('📨 Sending test data:', testData)
    
    const response = await fetch('http://localhost:3000/api/create-user-profile', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(testData)
    })
    
    const result = await response.json()
    console.log('📋 Result:', result)
    
    if (result.success) {
      console.log('✅ User profile created successfully!')
    } else {
      console.log('❌ Failed to create user profile:', result.error)
    }
    
  } catch (error) {
    console.error('💥 Exception during test:', error)
  }
}

// Run the test if this is called directly
if (typeof window === 'undefined') {
  testSignup()
}

module.exports = { testSignup }
