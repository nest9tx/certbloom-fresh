/**
 * Create Sample Math 902 Content
 * Works with existing schema and structure
 */

import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function createSampleMath902Content() {
  console.log('🎯 Creating sample Math 902 content...\n');
  
  try {
    // Get Math 902 concepts
    const { data: math902Concepts, error: conceptsError } = await supabase
      .from('concepts')
      .select(`
        id, 
        name, 
        domains!inner(
          name,
          certifications!inner(test_code)
        )
      `)
      .eq('domains.certifications.test_code', '902');
    
    if (conceptsError) {
      console.error('❌ Error fetching Math 902 concepts:', conceptsError);
      return false;
    }
    
    console.log(`📚 Found ${math902Concepts?.length || 0} Math 902 concepts`);
    
    if (!math902Concepts || math902Concepts.length === 0) {
      console.log('⚠️ No Math 902 concepts found');
      return false;
    }
    
    // Clean existing content for Math 902
    console.log('🧹 Cleaning existing Math 902 content...');
    
    const conceptIds = math902Concepts.map(c => c.id);
    
    // Delete answer choices first
    const { data: existingContent } = await supabase
      .from('content_items')
      .select('id')
      .in('concept_id', conceptIds);
    
    if (existingContent && existingContent.length > 0) {
      const contentIds = existingContent.map(c => c.id);
      
      await supabase
        .from('answer_choices')
        .delete()
        .in('question_id', contentIds);
      
      console.log('✅ Deleted existing answer choices');
    }
    
    // Delete content items
    await supabase
      .from('content_items')
      .delete()
      .in('concept_id', conceptIds);
    
    console.log('✅ Deleted existing content items');
    
    // Create sample questions for each concept
    console.log('📝 Creating sample questions...\n');
    
    const sampleQuestions = [
      {
        conceptName: 'Number Theory & Operations',
        questions: [
          {
            title: 'Prime Number Identification',
            content: 'Which of the following numbers is a prime number?',
            explanation: 'A prime number has exactly two factors: 1 and itself. 7 is prime because its only factors are 1 and 7.',
            answers: [
              { text: '6', correct: false, explanation: '6 = 2 × 3, so it has more than two factors' },
              { text: '7', correct: true, explanation: '7 is only divisible by 1 and 7' },
              { text: '8', correct: false, explanation: '8 = 2 × 4, so it has more than two factors' },
              { text: '9', correct: false, explanation: '9 = 3 × 3, so it has more than two factors' }
            ]
          },
          {
            title: 'Number Operations',
            content: 'What is the result of 24 ÷ 6 + 3 × 2?',
            explanation: 'Following order of operations (PEMDAS): 24 ÷ 6 = 4, then 3 × 2 = 6, then 4 + 6 = 10',
            answers: [
              { text: '8', correct: false, explanation: 'This ignores order of operations' },
              { text: '10', correct: true, explanation: 'Correct: 4 + 6 = 10' },
              { text: '12', correct: false, explanation: 'This calculates incorrectly' },
              { text: '14', correct: false, explanation: 'This ignores division priority' }
            ]
          }
        ]
      },
      {
        conceptName: 'Place Value & Numeration',
        questions: [
          {
            title: 'Place Value Understanding',
            content: 'In the number 3,847, what is the value of the digit 8?',
            explanation: 'The digit 8 is in the hundreds place, so its value is 8 × 100 = 800',
            answers: [
              { text: '8', correct: false, explanation: 'This is just the digit, not its place value' },
              { text: '80', correct: false, explanation: 'This would be if 8 were in the tens place' },
              { text: '800', correct: true, explanation: 'Correct: 8 is in the hundreds place' },
              { text: '8,000', correct: false, explanation: 'This would be if 8 were in the thousands place' }
            ]
          }
        ]
      },
      {
        conceptName: 'Pattern Recognition',
        questions: [
          {
            title: 'Number Patterns',
            content: 'What is the next number in the pattern: 2, 6, 18, 54, ?',
            explanation: 'Each number is multiplied by 3: 2×3=6, 6×3=18, 18×3=54, 54×3=162',
            answers: [
              { text: '108', correct: false, explanation: 'This adds 54 instead of multiplying by 3' },
              { text: '162', correct: true, explanation: 'Correct: 54 × 3 = 162' },
              { text: '216', correct: false, explanation: 'This multiplies by 4 instead of 3' },
              { text: '158', correct: false, explanation: 'This uses addition instead of multiplication' }
            ]
          }
        ]
      }
    ];
    
    let totalCreated = 0;
    
    for (const conceptData of sampleQuestions) {
      // Find the concept
      const concept = math902Concepts.find(c => c.name === conceptData.conceptName);
      
      if (!concept) {
        console.log(`⚠️ Concept "${conceptData.conceptName}" not found, skipping...`);
        continue;
      }
      
      console.log(`📝 Creating questions for: ${concept.name}`);
      
      for (const [index, questionData] of conceptData.questions.entries()) {
        // Create content item
        const { data: contentItem, error: contentError } = await supabase
          .from('content_items')
          .insert([{
            concept_id: concept.id,
            type: 'practice_question',
            title: questionData.title,
            content: questionData.content,
            order_index: index + 1,
            estimated_minutes: 3,
            is_required: true
          }])
          .select('id')
          .single();
        
        if (contentError) {
          console.error(`❌ Error creating content item:`, contentError);
          continue;
        }
        
        // Create answer choices
        const answerChoices = questionData.answers.map((answer, choiceIndex) => ({
          question_id: contentItem.id,
          choice_order: choiceIndex + 1,
          choice_text: answer.text,
          is_correct: answer.correct,
          explanation: answer.explanation
        }));
        
        const { error: choicesError } = await supabase
          .from('answer_choices')
          .insert(answerChoices);
        
        if (choicesError) {
          console.error(`❌ Error creating answer choices:`, choicesError);
          continue;
        }
        
        console.log(`  ✅ Created: ${questionData.title}`);
        totalCreated++;
      }
    }
    
    console.log(`\n🎉 Created ${totalCreated} sample questions for Math 902!`);
    return true;
    
  } catch (err) {
    console.error('❌ Error creating content:', err.message);
    return false;
  }
}

async function verifyMath902Content() {
  console.log('\n🔍 Verifying Math 902 content...');
  
  try {
    // Get Math 902 content with answers
    const { data: contentWithAnswers } = await supabase
      .from('content_items')
      .select(`
        id,
        title,
        content,
        concepts!inner(
          name,
          domains!inner(
            name,
            certifications!inner(test_code)
          )
        ),
        answer_choices(choice_text, is_correct, choice_order)
      `)
      .eq('concepts.domains.certifications.test_code', '902')
      .order('created_at');
    
    console.log(`\n📊 Math 902 Content Summary:`);
    console.log(`Total questions: ${contentWithAnswers?.length || 0}`);
    
    contentWithAnswers?.forEach((item, index) => {
      const correctAnswer = item.answer_choices?.find(a => a.is_correct);
      console.log(`\n${index + 1}. ${item.title}`);
      console.log(`   Concept: ${item.concepts?.name}`);
      console.log(`   Domain: ${item.concepts?.domains?.name}`);
      console.log(`   Question: ${item.content}`);
      console.log(`   Correct Answer: ${correctAnswer?.choice_text || 'None'}`);
      console.log(`   Total Choices: ${item.answer_choices?.length || 0}`);
    });
    
    return true;
  } catch (err) {
    console.error('❌ Error verifying content:', err.message);
    return false;
  }
}

async function main() {
  console.log('🌟 Math 902 Sample Content Creation\n');
  
  const success = await createSampleMath902Content();
  
  if (success) {
    await verifyMath902Content();
    console.log('\n✨ Math 902 sample content is ready for testing!');
    console.log('\n🚀 Next steps:');
    console.log('1. Test the practice session UI');
    console.log('2. Verify answer scoring works correctly');
    console.log('3. Ensure only Math content appears in Math 902 sessions');
  } else {
    console.log('\n❌ Content creation failed. Check the errors above.');
    process.exit(1);
  }
}

main().catch(console.error);
