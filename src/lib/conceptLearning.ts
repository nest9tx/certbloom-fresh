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
  [key: string]: unknown // Allow additional properties
}

export interface ContentItem {
  id: string
  concept_id: string
  type: 'text_explanation' | 'interactive_example' | 'practice_question' | 'real_world_scenario' | 'teaching_strategy' | 'common_misconception' | 'memory_technique'
  title: string
  content: ContentData
  order_index: number
  estimated_minutes: number
  is_required: boolean
  created_at: string
  updated_at: string
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
  return data || []
}

export async function getCertificationWithFullStructure(certificationId: string, userId?: string): Promise<CertificationWithStructure | null> {
  // Get certification with domains, concepts, content items, and user progress
  const { data, error } = await supabase
    .from('certifications')
    .select(`
      *,
      domains (
        *,
        concepts (
          *,
          content_items (*),
          concept_progress!concept_progress_concept_id_fkey (*)
        )
      )
    `)
    .eq('id', certificationId)
    .eq('concept_progress.user_id', userId || '')
    .single()

  if (error) throw error
  return data as CertificationWithStructure
}

// ============================================
// CONCEPT FUNCTIONS
// ============================================

export async function getConceptWithContent(conceptId: string, userId?: string): Promise<ConceptWithContent | null> {
  const { data, error } = await supabase
    .from('concepts')
    .select(`
      *,
      content_items (*),
      concept_progress!concept_progress_concept_id_fkey (*)
    `)
    .eq('id', conceptId)
    .eq('concept_progress.user_id', userId || '')
    .single()

  if (error) throw error
  return data as ConceptWithContent
}

export async function getConceptsByDomain(domainId: string, userId?: string): Promise<ConceptWithContent[]> {
  const { data, error } = await supabase
    .from('concepts')
    .select(`
      *,
      content_items (*),
      concept_progress!concept_progress_concept_id_fkey (*)
    `)
    .eq('domain_id', domainId)
    .eq('concept_progress.user_id', userId || '')
    .order('order_index')

  if (error) throw error
  return data as ConceptWithContent[]
}

// ============================================
// PROGRESS TRACKING FUNCTIONS
// ============================================

export async function updateConceptProgress(
  userId: string,
  conceptId: string,
  updates: Partial<ConceptProgress>
): Promise<ConceptProgress> {
  const { data, error } = await supabase
    .from('concept_progress')
    .upsert({
      user_id: userId,
      concept_id: conceptId,
      ...updates,
      updated_at: new Date().toISOString()
    })
    .select()
    .single()

  if (error) throw error
  return data
}

export async function recordContentEngagement(
  userId: string,
  contentItemId: string,
  timeSpentSeconds: number,
  engagementScore: number = 0.5
): Promise<void> {
  const { error } = await supabase
    .from('content_engagement')
    .upsert({
      user_id: userId,
      content_item_id: contentItemId,
      time_spent_seconds: timeSpentSeconds,
      engagement_score: engagementScore,
      completed_at: new Date().toISOString()
    })

  if (error) throw error
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
    memory_technique: 'Memory Aid'
  }
  return labels[type] || type
}
