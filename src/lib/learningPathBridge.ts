// 🌸 BRIDGE BETWEEN EXISTING SIGNUP AND NEW CONCEPT-BASED LEARNING
// This connects the current certification selection flow with structured study plans

import { supabase } from './supabase'
import { createStudyPlan } from './conceptLearning'

interface UserCertificationSetup {
  userId: string
  certificationGoal: string
  isPrimary?: boolean
  targetExamDate?: string
}

// Map existing certification names to concept-based learning certification IDs
const CERTIFICATION_MAPPING = {
  'Math EC-6': '902', // Maps to TExES Core Subjects EC-6: Mathematics (902)
  'TExES Core Subjects EC-6: Mathematics (902)': '902',
  'Elementary Mathematics': '902'
  // Add more mappings as we build out other certifications
}

export async function setupUserLearningPath(setup: UserCertificationSetup): Promise<{
  success: boolean
  hasStructuredContent: boolean
  studyPlanId?: string
  error?: string
}> {
  try {
    // Update the existing user_profiles table (maintains backward compatibility)
    const { error: profileError } = await supabase
      .from('user_profiles')
      .update({ 
        certification_goal: setup.certificationGoal,
        updated_at: new Date().toISOString()
      })
      .eq('id', setup.userId)

    if (profileError) {
      throw new Error(`Profile update failed: ${profileError.message}`)
    }

    // Check if this certification has structured concept-based content
    const testCode = CERTIFICATION_MAPPING[setup.certificationGoal as keyof typeof CERTIFICATION_MAPPING]
    
    if (!testCode) {
      // No structured content yet - user goes to traditional dashboard
      return {
        success: true,
        hasStructuredContent: false
      }
    }

    // Find the certification in our concept-based learning system
    const { data: certification, error: certError } = await supabase
      .from('certifications')
      .select('id')
      .eq('test_code', testCode)
      .single()

    if (certError || !certification) {
      // Structured content not ready yet
      return {
        success: true,
        hasStructuredContent: false
      }
    }

    // Create structured study plan (this is the magic connection!)
    const studyPlan = await createStudyPlan(
      setup.userId,
      certification.id,
      30, // Default 30 minutes daily
      setup.targetExamDate
    )

    // Mark this as their PRIMARY study plan (for guarantee purposes)
    await supabase
      .from('study_plans')
      .update({ 
        name: `Primary: ${setup.certificationGoal}`,
        is_primary: true // We'll need to add this column
      })
      .eq('id', studyPlan.id)

    return {
      success: true,
      hasStructuredContent: true,
      studyPlanId: studyPlan.id
    }

  } catch (error) {
    console.error('Error setting up user learning path:', error)
    return {
      success: false,
      hasStructuredContent: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    }
  }
}

// Check if user has access to structured learning for their primary certification
export async function getUserPrimaryLearningPath(userId: string): Promise<{
  hasStructuredPath: boolean
  certificationId?: string
  studyPlanId?: string
  certificationName?: string
}> {
  try {
    console.log('🔍 DEBUG: getUserPrimaryLearningPath called with userId:', userId);
    
    // Get user's current certification goal
    const { data: profile, error: profileError } = await supabase
      .from('user_profiles')
      .select('certification_goal')
      .eq('id', userId)
      .single()

    if (profileError || !profile) {
      console.log('🔍 DEBUG: No profile found or error:', profileError);
      return { hasStructuredPath: false }
    }

    console.log('🔍 DEBUG: User profile found:', profile);

    // Check for structured study plan
    const { data: studyPlan, error: planError } = await supabase
      .from('study_plans')
      .select(`
        id,
        certification_id,
        certifications (
          id,
          name,
          test_code
        )
      `)
      .eq('user_id', userId)
      .eq('is_active', true)
      .eq('is_primary', true)
      .single()

    if (planError || !studyPlan) {
      console.log('🔍 DEBUG: No study plan found or error:', planError);
      console.log('🔍 DEBUG: Query was for is_primary=true, is_active=true');
      return { hasStructuredPath: false }
    }

    console.log('🔍 DEBUG: Study plan found:', studyPlan);

    return {
      hasStructuredPath: true,
      certificationId: studyPlan.certification_id,
      studyPlanId: studyPlan.id,
      certificationName: (studyPlan.certifications as { name?: string })?.name
    }

  } catch (error) {
    console.error('Error checking user primary learning path:', error)
    return { hasStructuredPath: false }
  }
}

// Allow users to explore additional certifications (no guarantee)
export async function addSecondaryExploration(
  userId: string, 
  certificationId: string
): Promise<{ success: boolean; studyPlanId?: string }> {
  try {
    const studyPlan = await createStudyPlan(
      userId,
      certificationId,
      15, // Less time for secondary explorations
      undefined // No target date
    )

    // Mark as secondary exploration
    await supabase
      .from('study_plans')
      .update({ 
        name: 'Exploration',
        is_primary: false
      })
      .eq('id', studyPlan.id)

    return {
      success: true,
      studyPlanId: studyPlan.id
    }

  } catch (error) {
    console.error('Error adding secondary exploration:', error)
    return { success: false }
  }
}
