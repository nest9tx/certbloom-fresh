// 🌸 CONCEPT-BASED LEARNING DATA FUNCTIONS
// Functions to interact with the new structured learning schema

import { supabase } from './supabase'

// ============================================
// TYPE DEFINITIONS
// ============================================

export interface Certification {
  id: string
  name: string
  test_code: string
  description: string | null
  total_concepts: number
  created_at: string
  updated_at: string
}

export interface Domain {
  id: string
  certification_id: string
  name: string
  code: string
  description: string | null
  weight_percentage: number
  order_index: number
  created_at: string
}

export interface Concept {
  id: string
  domain_id: string
  name: string
  description: string | null
  learning_objectives: string[]
  difficulty_level: number
  estimated_study_minutes: number
  order_index: number
  prerequisites: string[]
  created_at: string
  updated_at: string
}

// Content structure varies by type
export interface ContentData {
  sections?: string[]
  steps?: string[]
  example?: string
  question?: string
  answers?: string[]
  correct?: number
  explanation?: string
  scenario?: string
  strategy?: string
  misconception?: string
  technique?: string
  // Practice session specific properties
  session_type?: string
  target_question_count?: number
  estimated_minutes?: number
  description?: string
  instructions?: string
  concept_id?: string
  difficulty_levels?: string[]
  question_source?: string
  [key: string]: unknown // Allow additional properties
}

export interface ContentItem {
  id: string
  concept_id: string
  type: 'text_explanation' | 'interactive_example' | 'practice_question' | 'real_world_scenario' | 'teaching_strategy' | 'common_misconception' | 'memory_technique' | 'practice' | 'explanation' | 'review' | 'question'
  title: string
  content: ContentData | string
  order_index: number
  estimated_minutes: number
  is_required: boolean
  created_at: string
  updated_at: string
  // Question-specific fields (optional)
  question_text?: string
  explanation?: string
  answer_choices?: AnswerChoice[]
}

export interface AnswerChoice {
  id: string
  content_item_id: string
  choice_order: number
  choice_text: string
  is_correct: boolean
  created_at: string
}

export interface ConceptProgress {
  id: string
  user_id: string
  concept_id: string
  mastery_level: number // 0.00 to 1.00
  confidence_score: number // 1 to 5
  time_spent_minutes: number
  last_studied_at: string | null
  times_reviewed: number
  is_mastered: boolean
  created_at: string
  updated_at: string
}

export interface StudyPlan {
  id: string
  user_id: string
  certification_id: string
  target_exam_date: string | null
  daily_study_minutes: number
  current_concept_id: string | null
  is_active: boolean
  created_at: string
  updated_at: string
}

// Question interface for practice sessions (matches content_items table)
export interface Question {
  id: string
  concept_id: string | null
  question_text: string
  certification_area: string
  subject_area: string | null
  explanation: string | null
  difficulty_level: number | null
  competency: string | null
  skill: string | null
  choice_1: string | null
  choice_2: string | null  
  choice_3: string | null
  choice_4: string | null
  correct_choice: number | null
  choice_order: string | null
  answer_choices?: AnswerChoice[]
  created_at: string
  updated_at: string
}

// Answer choice interface
export interface AnswerChoice {
  id: string
  content_item_id: string
  choice_order: number
  choice_text: string
  is_correct: boolean
  created_at: string
}

// Combined types for rich data
export interface ConceptWithContent extends Concept {
  content_items: ContentItem[]
  user_progress?: ConceptProgress
}

export interface DomainWithConcepts extends Domain {
  concepts: ConceptWithContent[]
}

export interface CertificationWithStructure extends Certification {
  domains: DomainWithConcepts[]
}

// ============================================
// CERTIFICATION FUNCTIONS
// ============================================

export async function getCertifications(): Promise<Certification[]> {
  const { data, error } = await supabase
    .from('certifications')
    .select('*')
    .order('name')

  if (error) throw error
  
  const allCerts = data || []
  
  console.log('🔍 getCertifications debug:', {
    totalCerts: allCerts.length,
    allTestCodes: allCerts.map(c => c.test_code),
    allNames: allCerts.map(c => c.name)
  })
  
  // Filter to show only meaningful, primary certifications for EC-6 teachers
  const primaryCertifications = allCerts.filter(cert => {
    // Include main EC-6 Core Subjects (comprehensive exam)
    if (cert.test_code === '391') return true
    
    // Include individual EC-6 subject tests (for teachers focusing on specific subjects)
    if (['901', '902', '903', '904', '905'].includes(cert.test_code)) {
      console.log(`✅ Including individual EC-6 subject: ${cert.test_code} (${cert.name})`)
      return true
    }
    
    // Include PPR (required for all teachers)  
    if (cert.test_code === '160') return true
    
    // Include 4-8 grade certifications (middle school teachers)
    if (['117', '118', '119', '120'].includes(cert.test_code)) return true
    
    // For now, include other certifications (we can refine this later)
    console.log(`🤔 Including other certification: ${cert.test_code} (${cert.name})`)
    return true
  })
  
  console.log('✅ Final certification list:', {
    originalCount: allCerts.length,
    filteredCount: primaryCertifications.length,
    finalTestCodes: primaryCertifications.map(c => c.test_code),
    finalNames: primaryCertifications.map(c => c.name)
  })
  
  return primaryCertifications
}

// Raw Supabase response types
interface SupabaseConceptResponse {
  id: string
  [key: string]: unknown
}

interface SupabaseDomainResponse {
  id: string
  concepts?: SupabaseConceptResponse[]
  [key: string]: unknown
}

interface SupabaseCertResponse {
  id: string
  domains?: SupabaseDomainResponse[]
  [key: string]: unknown
}

export async function getCertificationWithFullStructure(certificationId: string, userId?: string): Promise<CertificationWithStructure | null> {
  try {
    // Step 1: Get certification with domains and concepts
    const { data: certData, error: certError } = await supabase
      .from('certifications')
      .select(`
        *,
        domains (
          *,
          concepts (
            *,
            content_items (*)
          )
        )
      `)
      .eq('id', certificationId)
      .single()

    if (certError) {
      console.error('Error fetching certification structure:', certError)
      throw certError
    }

    if (!certData) {
      return null
    }

    // Step 2: If userId provided, get user progress for all concepts
    if (userId && certData.domains) {
      const rawCertData = certData as SupabaseCertResponse
      const conceptIds = (rawCertData.domains || [])
        .flatMap((domain: SupabaseDomainResponse) => domain.concepts || [])
        .map((concept: SupabaseConceptResponse) => concept.id)

      if (conceptIds.length > 0) {
        const { data: progressData, error: progressError } = await supabase
          .from('concept_progress')
          .select('*')
          .eq('user_id', userId)
          .in('concept_id', conceptIds)

        if (progressError) {
          console.error('Error fetching user progress:', progressError)
          // Don't throw - just continue without progress data
        } else {
          console.log('📊 Loaded progress data:', { userId, conceptIds: conceptIds.length, progressCount: progressData?.length || 0 });
          // Attach progress data to concepts
          const progressMap = new Map(progressData?.map(p => [p.concept_id, p]) || [])
          
          ;(rawCertData.domains || []).forEach((domain: SupabaseDomainResponse) => {
            if (domain.concepts) {
              domain.concepts.forEach((concept: SupabaseConceptResponse) => {
                const progressForConcept = progressMap.get(concept.id);
                // Fix: Use user_progress to match TypeScript interface
                ;(concept as SupabaseConceptResponse & { user_progress?: unknown }).user_progress = progressForConcept || undefined
                if (progressForConcept) {
                  console.log(`📈 Progress for ${concept.name}:`, progressForConcept);
                }
              })
            }
          })
        }
      }
    }

    return certData as CertificationWithStructure
  } catch (error) {
    console.error('Unexpected error in getCertificationWithFullStructure:', error)
    throw error
  }
}

// ============================================
// CONCEPT FUNCTIONS
// ============================================

export async function getConceptWithContent(conceptId: string, userId?: string): Promise<ConceptWithContent | null> {
  try {
    // Step 1: Get concept with content items
    const { data: conceptData, error: conceptError } = await supabase
      .from('concepts')
      .select(`
        *,
        content_items (*)
      `)
      .eq('id', conceptId)
      .single()

    if (conceptError) {
      console.error('Error fetching concept:', conceptError)
      throw conceptError
    }

    if (!conceptData) {
      return null
    }

    // Step 2: Get user progress if userId provided
    if (userId) {
      const { data: progressData, error: progressError } = await supabase
        .from('concept_progress')
        .select('*')
        .eq('user_id', userId)
        .eq('concept_id', conceptId)
        .maybeSingle()

      if (progressError) {
        console.error('Error fetching concept progress:', progressError)
        // Continue without progress data
      } else {
        conceptData.concept_progress = progressData ? [progressData] : []
      }
    }

    return conceptData as ConceptWithContent
  } catch (error) {
    console.error('Unexpected error in getConceptWithContent:', error)
    throw error
  }
}

export async function getConceptsByDomain(domainId: string, userId?: string): Promise<ConceptWithContent[]> {
  try {
    // Step 1: Get concepts with content items and answer choices
    const { data: conceptsData, error: conceptsError } = await supabase
      .from('concepts')
      .select(`
        *,
        content_items (
          *,
          answer_choices!content_item_id(
            id,
            choice_order,
            choice_text,
            is_correct,
            created_at
          )
        )
      `)
      .eq('domain_id', domainId)
      .order('order_index')

    if (conceptsError) {
      console.error('Error fetching concepts:', conceptsError)
      throw conceptsError
    }

    if (!conceptsData) {
      return []
    }

    // Transform content items to include question_text for question types
    conceptsData.forEach(concept => {
      if (concept.content_items) {
        concept.content_items.forEach((item: ContentItem & { answer_choices?: AnswerChoice[] }) => {
          if (item.type === 'question' && typeof item.content === 'string') {
            item.question_text = item.content
          }
        })
      }
    })

    // Step 2: Get user progress if userId provided
    if (userId && conceptsData.length > 0) {
      const conceptIds = conceptsData.map(concept => concept.id)
      
      const { data: progressData, error: progressError } = await supabase
        .from('concept_progress')
        .select('*')
        .eq('user_id', userId)
        .in('concept_id', conceptIds)

      if (progressError) {
        console.error('Error fetching concepts progress:', progressError)
        // Continue without progress data
      } else {
        // Attach progress data to concepts
        const progressMap = new Map(progressData?.map(p => [p.concept_id, p]) || [])
        
        conceptsData.forEach((concept: SupabaseConceptResponse) => {
          ;(concept as SupabaseConceptResponse & { concept_progress?: unknown[] }).concept_progress = progressMap.get(concept.id) ? [progressMap.get(concept.id)] : []
        })
      }
    }

    return conceptsData as ConceptWithContent[]
  } catch (error) {
    console.error('Unexpected error in getConceptsByDomain:', error)
    throw error
  }
}

// ============================================
// QUESTION FUNCTIONS
// ============================================

export async function getQuestionsForConcept(
  conceptId: string, 
  limit?: number,
  shuffle = true
): Promise<Question[]> {
  try {
    // First try the questions table (preferred)
    let query = supabase
      .from('questions')
      .select(`
        id,
        question_text,
        certification_id,
        topic_id,
        explanation,
        difficulty_level,
        created_at,
        updated_at,
        answer_choices!question_id(
          id,
          choice_order,
          choice_text,
          is_correct,
          created_at
        )
      `)
      .eq('concept_id', conceptId)
      .eq('active', true)

    if (limit) {
      query = query.limit(limit)
    }

    let { data: questions, error } = await query

    // If no questions found in questions table, try content_items as fallback
    if (!questions || questions.length === 0) {
      console.log(`No questions in questions table for concept ${conceptId}, trying content_items...`)
      
      let contentQuery = supabase
        .from('content_items')
        .select(`
          id,
          concept_id,
          content,
          explanation,
          difficulty_level,
          created_at,
          updated_at,
          answer_choices!content_item_id(
            id,
            choice_order,
            choice_text,
            is_correct,
            created_at
          )
        `)
        .eq('concept_id', conceptId)
        .eq('type', 'question')

      if (limit) {
        contentQuery = contentQuery.limit(limit)
      }

      const { data: contentQuestions, error: contentError } = await contentQuery
      
      if (contentError) {
        console.error('Error fetching questions from content_items:', contentError)
        throw contentError
      }

      // Transform content_items to match questions table structure
      questions = contentQuestions?.map((item) => ({
        id: item.id,
        question_text: item.content || '',
        certification_id: null,
        topic_id: null,
        explanation: item.explanation || null,
        difficulty_level: item.difficulty_level || null,
        created_at: item.created_at,
        updated_at: item.updated_at,
        answer_choices: item.answer_choices?.map((choice) => ({
          id: choice.id,
          choice_order: choice.choice_order,
          choice_text: choice.choice_text,
          is_correct: choice.is_correct,
          created_at: choice.created_at
        })) || []
      })) || []

      // Update error for the rest of the function
      error = contentError
    }

    if (error) {
      console.error('Error fetching questions:', error)
      throw error
    }

    if (!questions || questions.length === 0) {
      console.warn(`No questions found for concept ${conceptId} in either table`)
      return []
    }

    // Transform questions table results to match Question interface
    const transformedQuestions = questions.map((question) => ({
      id: question.id,
      concept_id: conceptId,
      question_text: question.question_text || '',
      certification_area: '',
      subject_area: null,
      explanation: question.explanation || null,
      difficulty_level: question.difficulty_level || null,
      competency: null,
      skill: null,
      choice_1: null,
      choice_2: null,
      choice_3: null,
      choice_4: null,
      correct_choice: null,
      choice_order: null,
      answer_choices: question.answer_choices?.map((choice) => ({
        id: choice.id,
        content_item_id: question.id,
        choice_order: choice.choice_order,
        choice_text: choice.choice_text,
        is_correct: choice.is_correct,
        created_at: choice.created_at
      })) || [],
      created_at: question.created_at,
      updated_at: question.updated_at
    }))

    // Shuffle questions if requested
    if (shuffle) {
      for (let i = transformedQuestions.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [transformedQuestions[i], transformedQuestions[j]] = [transformedQuestions[j], transformedQuestions[i]]
      }
    }

    console.log(`📚 Loaded ${transformedQuestions.length} questions for concept ${conceptId}`)
    return transformedQuestions as Question[]
  } catch (error) {
    console.error('Unexpected error in getQuestionsForConcept:', error)
    throw error
  }
}

// ============================================
// PROGRESS TRACKING FUNCTIONS
// ============================================

export async function updateConceptProgress(
  userId: string,
  conceptId: string,
  updates: Partial<ConceptProgress>
): Promise<ConceptProgress> {
  try {
    // Use the database function to handle constraints safely
    const { data, error } = await supabase.rpc('handle_concept_progress_update', {
      target_user_id: userId,
      target_concept_id: conceptId,
      new_mastery_level: updates.mastery_level,
      new_time_spent: updates.time_spent_minutes,
      new_times_reviewed: updates.times_reviewed,
      set_mastered: updates.is_mastered
    });

    if (error) {
      console.error('❌ Error updating concept progress:', error);
      throw error;
    }

    console.log('✅ Concept progress updated via database function:', data);
    return data;
  } catch (error) {
    console.error('❌ Failed to update concept progress:', error);
    throw error;
  }
}

export async function recordContentEngagement(
  userId: string,
  contentItemId: string,
  timeSpentSeconds: number
): Promise<void> {
  try {
    // Use the updated database function to handle constraints safely
    const { data, error } = await supabase.rpc('handle_content_engagement_update', {
      target_user_id: userId,
      target_content_item_id: contentItemId,
      time_spent: timeSpentSeconds
    });

    if (error) {
      console.warn('⚠️ Content engagement tracking failed:', error.message);
      // Don't throw - this is non-critical tracking
      return;
    }

    console.log('✅ Content engagement recorded:', data);
  } catch (error) {
    console.warn('⚠️ Content engagement tracking error:', error);
    // Silently fail to avoid breaking the learning flow
  }
}

// ============================================
// STUDY PLAN FUNCTIONS
// ============================================

export async function getUserStudyPlan(userId: string, certificationId?: string): Promise<StudyPlan | null> {
  let query = supabase
    .from('study_plans')
    .select('*')
    .eq('user_id', userId)
    .eq('is_active', true)

  if (certificationId) {
    query = query.eq('certification_id', certificationId)
  }

  const { data, error } = await query.single()

  if (error && error.code !== 'PGRST116') throw error // PGRST116 = no rows found
  return data
}

export async function createStudyPlan(
  userId: string,
  certificationId: string,
  dailyStudyMinutes: number = 30,
  targetExamDate?: string
): Promise<StudyPlan> {
  // Deactivate any existing plans for this certification
  await supabase
    .from('study_plans')
    .update({ is_active: false })
    .eq('user_id', userId)
    .eq('certification_id', certificationId)

  // Create new active plan
  const { data, error } = await supabase
    .from('study_plans')
    .insert({
      user_id: userId,
      certification_id: certificationId,
      daily_study_minutes: dailyStudyMinutes,
      target_exam_date: targetExamDate,
      is_active: true
    })
    .select()
    .single()

  if (error) throw error
  return data
}

// ============================================
// RECOMMENDATION FUNCTIONS
// ============================================

export interface Recommendation {
  id: string
  user_id: string
  type: string
  target_concept_id: string | null
  target_content_id: string | null
  priority_score: number
  reason: string | null
  is_dismissed: boolean
  created_at: string
  expires_at: string
  target_concept?: Concept
  target_content?: ContentItem
}

export async function getRecommendationsForUser(userId: string): Promise<Recommendation[]> {
  const { data, error } = await supabase
    .from('recommendations')
    .select(`
      *,
      target_concept:concepts(*),
      target_content:content_items(*)
    `)
    .eq('user_id', userId)
    .eq('is_dismissed', false)
    .gt('expires_at', new Date().toISOString())
    .order('priority_score', { ascending: false })

  if (error) throw error
  return data as Recommendation[] || []
}

// ============================================
// UTILITY FUNCTIONS
// ============================================

export function calculateMasteryLevel(correct: number, total: number): number {
  if (total === 0) return 0
  return Math.min(correct / total, 1.0)
}

export function getDifficultyLabel(level: number): string {
  const labels = ['', 'Beginner', 'Intermediate', 'Advanced', 'Expert', 'Master']
  return labels[level] || 'Unknown'
}

export function getContentTypeLabel(type: ContentItem['type']): string {
  const labels = {
    text_explanation: 'Explanation',
    interactive_example: 'Example',
    practice_question: 'Practice',
    real_world_scenario: 'Real-World',
    teaching_strategy: 'Teaching',
    common_misconception: 'Misconception',
    memory_technique: 'Memory Aid',
    practice: 'Practice Session',
    explanation: 'Explanation',
    review: 'Review',
    question: 'Question'
  }
  return labels[type] || type
}
