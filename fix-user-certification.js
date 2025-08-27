import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing Supabase environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

/**
 * Quick fix for users who don't have certification goals set
 * Usage: node fix-user-certification.js [email] [certification]
 */
async function fixUserCertification() {
  const email = process.argv[2];
  const certification = process.argv[3] || 'Math EC-6';

  if (!email) {
    console.log('Usage: node fix-user-certification.js [email] [certification]');
    console.log('Example: node fix-user-certification.js user@example.com "Math EC-6"');
    return;
  }

  console.log(`🔧 Fixing certification for ${email}...`);

  try {
    // Find user profile
    const { data: profile, error: findError } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('email', email)
      .single();

    if (findError) {
      console.error('❌ User not found:', findError.message);
      return;
    }

    console.log('👤 Found user:', profile.email);
    console.log('📋 Current certification:', profile.certification_goal || 'Not set');

    // Update certification goal
    const { error } = await supabase
      .from('user_profiles')
      .update({ certification_goal: certification })
      .eq('email', email)
      .select();

    if (error) {
      console.error('❌ Update failed:', error.message);
      return;
    }

    console.log('✅ Successfully updated certification to:', certification);
    console.log('🎯 User can now access personalized learning paths');

  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

fixUserCertification();
