/**
 * Execute Math 902 Foundation Setup
 * Run with: node execute-foundation.js
 */

import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing Supabase environment variables');
  console.error('Need: NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

// Create Supabase client with service role key
const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function checkAnswerChoicesStructure() {
  try {
    console.log('🔍 Checking answer_choices table structure...');
    
    // Try to get a sample record to see the structure
    const { data, error } = await supabase
      .from('answer_choices')
      .select('*')
      .limit(1);
    
    if (error) {
      console.log('⚠️ Cannot read answer_choices table:', error.message);
      return null;
    }
    
    if (data && data.length > 0) {
      const columns = Object.keys(data[0]);
      console.log('📋 answer_choices columns:', columns);
      
      if (columns.includes('content_item_id')) {
        console.log('✅ Using content_item_id foreign key');
        return 'content_item_id';
      } else if (columns.includes('question_id')) {
        console.log('✅ Using question_id foreign key');
        return 'question_id';
      }
    }
    
    console.log('📝 Table exists but is empty, checking schema...');
    return null;
  } catch (err) {
    console.error('❌ Error checking structure:', err.message);
    return null;
  }
}

async function setupMath902Foundation() {
  try {
    console.log('🚀 Setting up Math 902 foundation...');
    
    // Step 1: Clean existing Math 902 data
    console.log('🧹 Cleaning existing Math 902 data...');
    
    // Delete answer choices first (to avoid foreign key issues)
    const { data: mathItems } = await supabase
      .from('content_items')
      .select('id')
      .eq('certification_area', 'MATH-902');
    
    if (mathItems && mathItems.length > 0) {
      const itemIds = mathItems.map(item => item.id);
      
      // Try both foreign key approaches
      await supabase
        .from('answer_choices')
        .delete()
        .in('content_item_id', itemIds);
      
      await supabase
        .from('answer_choices')
        .delete()
        .in('question_id', itemIds);
    }
    
    // Delete content items
    await supabase
      .from('content_items')
      .delete()
      .eq('certification_area', 'MATH-902');
    
    console.log('✅ Cleaned existing data');
    
    // Step 2: Get or create Math 902 certification
    console.log('📚 Setting up Math 902 certification...');
    
    const { data: existingCert } = await supabase
      .from('certifications')
      .select('id')
      .eq('test_code', '902')
      .single();
    
    let certId = existingCert?.id;
    
    if (!certId) {
      const { data: newCert, error } = await supabase
        .from('certifications')
        .insert([{
          name: 'TExES Mathematics EC-6 (902)',
          test_code: '902',
          description: 'Elementary Mathematics certification for Early Childhood through Grade 6',
          total_concepts: 16
        }])
        .select('id')
        .single();
      
      if (error) {
        console.error('❌ Error creating certification:', error);
        return false;
      }
      
      certId = newCert.id;
    }
    
    console.log('✅ Math 902 certification ready:', certId);
    
    // Step 3: Create domains
    console.log('📂 Creating domains...');
    
    const domains = [
      {
        certification_id: certId,
        name: 'Number Concepts',
        code: 'I',
        description: 'Number theory, operations, place value, fractions, decimals, and percentages',
        weight_percentage: 25,
        order_index: 1
      },
      {
        certification_id: certId,
        name: 'Patterns & Algebra',
        code: 'II',
        description: 'Algebraic reasoning, patterns, functions, and linear relationships',
        weight_percentage: 25,
        order_index: 2
      },
      {
        certification_id: certId,
        name: 'Geometry & Measurement',
        code: 'III',
        description: 'Geometric properties, measurement concepts, and coordinate geometry',
        weight_percentage: 25,
        order_index: 3
      },
      {
        certification_id: certId,
        name: 'Data Analysis & Statistics',
        code: 'IV',
        description: 'Data collection, analysis, probability, and statistical reasoning',
        weight_percentage: 25,
        order_index: 4
      }
    ];
    
    const { data: createdDomains, error: domainsError } = await supabase
      .from('domains')
      .upsert(domains, { onConflict: 'certification_id,code' })
      .select('id, name, code');
    
    if (domainsError) {
      console.error('❌ Error creating domains:', domainsError);
      return false;
    }
    
    console.log('✅ Created domains:', createdDomains?.length || 0);
    
    // Step 4: Create sample concepts
    console.log('🎯 Creating sample concepts...');
    
    const numberConceptsDomain = createdDomains?.find(d => d.code === 'I');
    
    if (numberConceptsDomain) {
      const sampleConcepts = [
        {
          domain_id: numberConceptsDomain.id,
          name: 'Number Theory & Operations',
          description: 'Understanding whole numbers, integers, rational numbers, and basic number theory',
          difficulty_level: 2,
          estimated_study_minutes: 45,
          order_index: 1,
          learning_objectives: ['Understand number theory concepts', 'Apply number operations', 'Solve problems with different number types'],
          prerequisites: []
        },
        {
          domain_id: numberConceptsDomain.id,
          name: 'Place Value & Numeration',
          description: 'Place value concepts, number representation, and numeration systems',
          difficulty_level: 1,
          estimated_study_minutes: 30,
          order_index: 2,
          learning_objectives: ['Master place value concepts', 'Convert between number forms', 'Understand base-10 system'],
          prerequisites: []
        }
      ];
      
      const { data: createdConcepts, error: conceptsError } = await supabase
        .from('concepts')
        .upsert(sampleConcepts, { onConflict: 'domain_id,name' })
        .select('id, name');
      
      if (conceptsError) {
        console.error('❌ Error creating concepts:', conceptsError);
        return false;
      }
      
      console.log('✅ Created concepts:', createdConcepts?.length || 0);
      
      // Step 5: Create sample content
      console.log('📝 Creating sample content...');
      
      const firstConcept = createdConcepts?.[0];
      
      if (firstConcept) {
        const sampleContent = {
          concept_id: firstConcept.id,
          type: 'practice_question',
          title: 'Number Theory Sample Question',
          question_text: 'Which number is a prime number?',
          certification_area: 'MATH-902',
          subject_area: 'Mathematics',
          explanation: 'A prime number has exactly two factors: 1 and itself. 7 is prime because its only factors are 1 and 7.',
          difficulty_level: 2,
          competency: firstConcept.name,
          skill: 'Number Theory',
          order_index: 1,
          estimated_minutes: 3,
          is_required: true
        };
        
        const { data: createdContent, error: contentError } = await supabase
          .from('content_items')
          .insert([sampleContent])
          .select('id')
          .single();
        
        if (contentError) {
          console.error('❌ Error creating content:', contentError);
          return false;
        }
        
        console.log('✅ Created sample question:', createdContent.id);
        
        // Step 6: Create answer choices
        console.log('🎯 Creating answer choices...');
        
        const fkColumn = await checkAnswerChoicesStructure();
        const useContentItemId = fkColumn === 'content_item_id' || fkColumn === null;
        
        const answerChoices = [
          {
            [useContentItemId ? 'content_item_id' : 'question_id']: createdContent.id,
            choice_order: 1,
            choice_text: '6',
            is_correct: false
          },
          {
            [useContentItemId ? 'content_item_id' : 'question_id']: createdContent.id,
            choice_order: 2,
            choice_text: '7',
            is_correct: true
          },
          {
            [useContentItemId ? 'content_item_id' : 'question_id']: createdContent.id,
            choice_order: 3,
            choice_text: '8',
            is_correct: false
          },
          {
            [useContentItemId ? 'content_item_id' : 'question_id']: createdContent.id,
            choice_order: 4,
            choice_text: '9',
            is_correct: false
          }
        ];
        
        const { data: createdChoices, error: choicesError } = await supabase
          .from('answer_choices')
          .insert(answerChoices)
          .select('choice_text, is_correct');
        
        if (choicesError) {
          console.error('❌ Error creating answer choices:', choicesError);
          return false;
        }
        
        console.log('✅ Created answer choices:', createdChoices?.length || 0);
      }
    }
    
    return true;
  } catch (err) {
    console.error('❌ Foundation setup failed:', err.message);
    return false;
  }
}

async function verifySetup() {
  try {
    console.log('\n🔍 Verifying Math 902 setup...');
    
    // Check certification
    const { data: cert } = await supabase
      .from('certifications')
      .select('*')
      .eq('test_code', '902')
      .single();
    
    console.log('📚 Certification:', cert?.name || 'Not found');
    
    // Check domains
    const { data: domains } = await supabase
      .from('domains')
      .select('*')
      .eq('certification_id', cert?.id);
    
    console.log('📂 Domains:', domains?.length || 0);
    
    // Check concepts
    const { data: concepts } = await supabase
      .from('concepts')
      .select('*')
      .in('domain_id', domains?.map(d => d.id) || []);
    
    console.log('🎯 Concepts:', concepts?.length || 0);
    
    // Check content
    const { data: content } = await supabase
      .from('content_items')
      .select('*, answer_choices(*)')
      .eq('certification_area', 'MATH-902');
    
    console.log('📝 Content items:', content?.length || 0);
    
    content?.forEach(item => {
      console.log(`  - ${item.title}: ${item.answer_choices?.length || 0} answer choices`);
    });
    
    return true;
  } catch (err) {
    console.error('❌ Verification failed:', err.message);
    return false;
  }
}

async function main() {
  console.log('🌟 Math 902 Foundation Setup Starting...\n');
  
  const success = await setupMath902Foundation();
  
  if (success) {
    console.log('\n🎉 Foundation setup complete!');
    await verifySetup();
    console.log('\n✨ Math 902 is ready for development!');
  } else {
    console.log('\n❌ Setup failed. Check the errors above.');
    process.exit(1);
  }
}

main().catch(console.error);
