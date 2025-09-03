/**
 * Check Current Database Schema
 * Inspect the actual structure before setup
 */

import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function inspectSchema() {
  console.log('🔍 Inspecting current database schema...\n');
  
  // Check content_items structure
  try {
    const { data: contentSample } = await supabase
      .from('content_items')
      .select('*')
      .limit(1);
    
    if (contentSample && contentSample.length > 0) {
      console.log('📋 content_items columns:');
      Object.keys(contentSample[0]).forEach(col => {
        console.log(`  - ${col}`);
      });
    } else {
      console.log('📋 content_items table exists but is empty');
    }
  } catch (err) {
    console.log('❌ Error reading content_items:', err.message);
  }
  
  console.log('');
  
  // Check answer_choices structure
  try {
    const { data: answerSample } = await supabase
      .from('answer_choices')
      .select('*')
      .limit(1);
    
    if (answerSample && answerSample.length > 0) {
      console.log('📋 answer_choices columns:');
      Object.keys(answerSample[0]).forEach(col => {
        console.log(`  - ${col}`);
      });
    } else {
      console.log('📋 answer_choices table exists but is empty');
    }
  } catch (err) {
    console.log('❌ Error reading answer_choices:', err.message);
  }
  
  console.log('');
  
  // Check existing certifications
  try {
    const { data: certs } = await supabase
      .from('certifications')
      .select('*');
    
    console.log('📚 Existing certifications:');
    certs?.forEach(cert => {
      console.log(`  - ${cert.test_code}: ${cert.name}`);
    });
  } catch (err) {
    console.log('❌ Error reading certifications:', err.message);
  }
  
  console.log('');
  
  // Check existing domains
  try {
    const { data: domains } = await supabase
      .from('domains')
      .select('*, certifications(test_code, name)');
    
    console.log('📂 Existing domains:');
    domains?.forEach(domain => {
      console.log(`  - ${domain.certifications?.test_code}: ${domain.name} (${domain.code})`);
    });
  } catch (err) {
    console.log('❌ Error reading domains:', err.message);
  }
  
  console.log('');
  
  // Check existing concepts
  try {
    const { data: concepts } = await supabase
      .from('concepts')
      .select('*, domains(name, certifications(test_code))');
    
    console.log('🎯 Existing concepts:');
    concepts?.forEach(concept => {
      const testCode = concept.domains?.certifications?.test_code;
      const domainName = concept.domains?.name;
      console.log(`  - ${testCode}: ${domainName} -> ${concept.name}`);
    });
  } catch (err) {
    console.log('❌ Error reading concepts:', err.message);
  }
}

inspectSchema().catch(console.error);
