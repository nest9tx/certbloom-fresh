import { supabase } from './supabase';

// Diagnostic function to test database connectivity and structure
export async function diagnoseDatabaseIssues(userId: string) {
  const results = {
    userProfile: null as Record<string, unknown> | null,
    certifications: null as Record<string, unknown>[] | null,
    questions: null as Record<string, unknown>[] | null,
    errors: [] as string[]
  };

  try {
    console.log('🔍 Starting database diagnostics...');

    // Test 1: Check user profile
    try {
      const { data: profile, error: profileError } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('id', userId)
        .single();

      if (profileError) {
        results.errors.push(`User profile error: ${profileError.message}`);
      } else {
        results.userProfile = profile;
        console.log('✅ User profile found:', profile);
      }
    } catch (err) {
      results.errors.push(`User profile exception: ${err}`);
    }

    // Test 2: Check certifications table
    try {
      const { data: certs, error: certsError } = await supabase
        .from('certifications')
        .select('*')
        .limit(5);

      if (certsError) {
        results.errors.push(`Certifications error: ${certsError.message}`);
      } else {
        results.certifications = certs;
        console.log('✅ Certifications found:', certs?.length || 0);
      }
    } catch (err) {
      results.errors.push(`Certifications exception: ${err}`);
    }

    // Test 3: Check questions table
    try {
      const { data: questions, error: questionsError } = await supabase
        .from('questions')
        .select('id, question_text, active')
        .limit(3);

      if (questionsError) {
        results.errors.push(`Questions error: ${questionsError.message}`);
      } else {
        results.questions = questions;
        console.log('✅ Questions found:', questions?.length || 0);
      }
    } catch (err) {
      results.errors.push(`Questions exception: ${err}`);
    }

    // Test 4: Try the randomized function
    try {
      const { data: randomized, error: randomizedError } = await supabase
        .rpc('get_randomized_adaptive_questions', {
          session_user_id: userId,
          certification_name: 'EC-6 Core Subjects',
          session_length: 3,
          exclude_recent_hours: 2
        });

      if (randomizedError) {
        results.errors.push(`Randomized function error: ${randomizedError.message}`);
      } else {
        console.log('✅ Randomized function works:', randomized?.length || 0);
      }
    } catch (err) {
      results.errors.push(`Randomized function exception: ${err}`);
    }

    return results;
  } catch (err) {
    results.errors.push(`General diagnostic error: ${err}`);
    return results;
  }
}

// Quick test to see if basic tables exist
export async function testBasicTables() {
  const tables = ['user_profiles', 'certifications', 'questions', 'answer_choices'];
  const results: { [key: string]: boolean } = {};

  for (const table of tables) {
    try {
      const { error } = await supabase
        .from(table)
        .select('*')
        .limit(1);

      results[table] = !error;
      if (error) {
        console.error(`❌ Table ${table} error:`, error.message);
      } else {
        console.log(`✅ Table ${table} accessible`);
      }
    } catch (err) {
      results[table] = false;
      console.error(`❌ Table ${table} exception:`, err);
    }
  }

  return results;
}
