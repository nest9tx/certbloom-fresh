// Test User Profile Creation
// This script tests the user profile creation functionality

import { createUserProfile, getUserProfile } from './lib/supabase.js';

const testUserProfile = async () => {
  try {
    // Test data
    const testUserId = 'test-user-' + Date.now();
    const testProfile = {
      email: 'test@example.com',
      full_name: 'Test User',
      certification_goal: 'EC-6 Core Subjects'
    };
    
    console.log('🧪 Testing user profile creation...');
    console.log('Test User ID:', testUserId);
    console.log('Test Profile Data:', testProfile);
    
    // Create profile
    const createResult = await createUserProfile(testUserId, testProfile);
    console.log('Create Result:', createResult);
    
    if (createResult.success) {
      console.log('✅ Profile creation successful!');
      
      // Try to get the profile
      const getResult = await getUserProfile(testUserId);
      console.log('Get Result:', getResult);
      
      if (getResult.success) {
        console.log('✅ Profile retrieval successful!');
        console.log('Retrieved Profile:', getResult.profile);
      } else {
        console.log('❌ Profile retrieval failed:', getResult.error);
      }
    } else {
      console.log('❌ Profile creation failed:', createResult.error);
    }
    
  } catch (error) {
    console.error('❌ Test failed with exception:', error);
  }
};

// Run the test
testUserProfile();

export { testUserProfile };
