require('dotenv').config({ path: '.env.local' });
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function verifySubscriptionFix() {
  try {
    console.log('🔍 Verifying subscription fix...');
    
    // Check table structure
    const { data: tableData, error: tableError } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('email', 'admin@certbloom.com')
      .single();
    
    if (tableError) {
      console.error('❌ Error checking user profile:', tableError);
      return;
    }
    
    console.log('\n📊 Current user profile structure:');
    Object.keys(tableData).forEach((column, index) => {
      console.log(`   ${index + 1}. ${column}: ${tableData[column] || 'null'}`);
    });
    
    // Verify subscription status
    const hasNewColumns = tableData.hasOwnProperty('stripe_subscription_id') && 
                          tableData.hasOwnProperty('subscription_plan') && 
                          tableData.hasOwnProperty('subscription_end_date');
    
    console.log('\n✅ Database Migration Status:');
    console.log(`   - stripe_subscription_id column: ${hasNewColumns ? '✅ Added' : '❌ Missing'}`);
    console.log(`   - subscription_plan column: ${hasNewColumns ? '✅ Added' : '❌ Missing'}`);
    console.log(`   - subscription_end_date column: ${hasNewColumns ? '✅ Added' : '❌ Missing'}`);
    console.log(`   - Current subscription_status: ${tableData.subscription_status}`);
    
    if (hasNewColumns && tableData.subscription_status === 'active') {
      console.log('\n🎉 SUCCESS: Database migration completed and subscription is active!');
      console.log('   - Dashboard should now show Pro features');
      console.log('   - Study paths should grant full access');
      console.log('   - Future webhooks will work correctly');
    } else if (!hasNewColumns) {
      console.log('\n⚠️  INCOMPLETE: Database migration may not have completed');
      console.log('   - Please re-run the SQL migration in Supabase');
    } else {
      console.log('\n⚠️  PARTIAL: Columns added but subscription status is not active');
      console.log('   - You may need to process a new subscription to test webhook');
    }
    
  } catch (err) {
    console.error('💥 Unexpected error:', err);
  }
}

verifySubscriptionFix();
