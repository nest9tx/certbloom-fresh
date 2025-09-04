// Quick auth test
console.log('🔍 Testing auth from browser console...');

// Test 1: Check if we have a session
import('../../lib/supabase').then(({ supabase }) => {
  supabase.auth.getSession().then(({ data, error }) => {
    console.log('Session check:', { 
      hasSession: !!data.session, 
      userId: data.session?.user?.id,
      email: data.session?.user?.email,
      error 
    });
  });
});

// Test 2: Check current user
import('../../lib/supabase').then(({ getCurrentUser }) => {
  getCurrentUser().then((result) => {
    console.log('getCurrentUser result:', result);
  });
});
