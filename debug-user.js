// Quick debug script to check user data
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

async function debugUserData() {
  try {
    // Get all users to find the current one
    const { data: profiles, error: profilesError } = await supabase
      .from('user_profiles')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(5)

    if (profilesError) {
      console.error('❌ Error fetching profiles:', profilesError)
      return
    }

    console.log('📊 Recent user profiles:', profiles)

    if (profiles && profiles.length > 0) {
      const latestUser = profiles[0]
      console.log('🔍 Latest user:', latestUser)

      // Check their study plans
      const { data: studyPlans, error: plansError } = await supabase
        .from('study_plans')
        .select(`
          *,
          certifications (
            id,
            name,
            test_code
          )
        `)
        .eq('user_id', latestUser.id)

      if (plansError) {
        console.error('❌ Error fetching study plans:', plansError)
      }

      console.log('📚 Study plans for user:', studyPlans)

      // Check certifications table
      const { data: certifications, error: certsError } = await supabase
        .from('certifications')
        .select('*')
        .eq('test_code', '160')

      if (certsError) {
        console.error('❌ Error fetching certifications:', certsError)
      }

      console.log('🎯 Math EC-6 certification (test code 160):', certifications)
    }

  } catch (error) {
    console.error('❌ Debug error:', error)
  }
}

debugUserData()
