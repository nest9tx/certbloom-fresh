// Enhanced content structure implementation
import { createClient } from '@supabase/supabase-js'
import { config } from 'dotenv'

config({ path: '.env.local' })

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

async function enhancePlaceValueContent() {
  try {
    console.log('🔧 Enhancing Place Value content structure...');
    
    // First, get the Place Value concept ID
    const { data: concept } = await supabase
      .from('concepts')
      .select('id')
      .ilike('name', '%Place Value%')
      .single();
      
    if (!concept) {
      console.log('❌ Place Value concept not found');
      return;
    }
    
    console.log(`📚 Found concept ID: ${concept.id}`);
    
    // Enhance the main explanation content
    const enhancedExplanation = {
      sections: [
        'Place value is the foundation of our number system. Each digit in a number has a specific value based on its position.',
        'Understanding place value helps students recognize that the digit 4 in 456 represents 400 (4 hundreds), not just 4.',
        'Common misconceptions include thinking that larger digits always represent larger values, regardless of position.',
        'Key teaching strategy: Use base-10 blocks, place value charts, and real-world examples like money to make abstract concepts concrete.'
      ],
      key_concepts: [
        'Each position represents a power of 10',
        'Reading numbers from left (largest place value) to right',
        'Comparing numbers by examining place values systematically',
        'Rounding using place value understanding'
      ],
      teaching_strategies: [
        'Use manipulatives like base-10 blocks for visual representation',
        'Create place value charts for organizing thinking',
        'Connect to money concepts (dollars, dimes, pennies)',
        'Practice with real-world examples (population numbers, distances)'
      ],
      common_misconceptions: [
        'Students think 456 has "three 4s" instead of understanding positional value',
        'Confusion between number of digits and actual value',
        'Difficulty with zeros as placeholders (e.g., 405)',
        'Mixing up place value names (hundreds vs thousandths)'
      ]
    };
    
    // Update existing explanation content
    const { error: updateError } = await supabase
      .from('content_items')
      .update({ content: enhancedExplanation })
      .eq('concept_id', concept.id)
      .eq('type', 'text_explanation');
      
    if (updateError) {
      console.error('❌ Error updating explanation:', updateError);
    } else {
      console.log('✅ Enhanced explanation content');
    }
    
    // Add comprehensive practice questions
    const practiceQuestions = [
      {
        title: 'Place Value Identification',
        content: {
          question: 'In the number 3,574, what is the value of the digit 5?',
          choices: ['5', '50', '500', '5,000'],
          correct_answer: 3,
          explanation: 'The digit 5 is in the hundreds place, so its value is 5 × 100 = 500. Position determines value in our base-10 number system.'
        },
        order_index: 3,
        estimated_minutes: 2
      },
      {
        title: 'Comparing Numbers Using Place Value',
        content: {
          question: 'A teacher wants to help students compare 2,341 and 2,413. Which place value should students examine first?',
          choices: ['Ones place', 'Tens place', 'Hundreds place', 'Thousands place'],
          correct_answer: 3,
          explanation: 'When comparing numbers, start with the highest place value (leftmost). Both numbers have 2 thousands, so examine hundreds: 3 < 4, therefore 2,341 < 2,413.'
        },
        order_index: 4,
        estimated_minutes: 3
      },
      {
        title: 'Place Value Teaching Scenario',
        content: {
          question: 'A student consistently reads 405 as "forty-five." What is the most likely cause of this error, and how should the teacher address it?',
          choices: [
            'The student cannot read numbers; provide basic counting practice',
            'The student does not understand that 0 is a placeholder; use place value charts to show empty positions',
            'The student is rushing; tell them to slow down',
            'The student needs more addition practice with zeros'
          ],
          correct_answer: 2,
          explanation: 'The student is ignoring the zero placeholder, reading only the visible digits. Use place value charts to explicitly show that 0 holds the tens place, making the number four hundred five, not forty-five.'
        },
        order_index: 5,
        estimated_minutes: 4
      },
      {
        title: 'Real-World Place Value Application',
        content: {
          question: 'Students are comparing city populations: Austin (964,254) and Fort Worth (918,915). Which teaching approach best helps students understand which city is larger?',
          choices: [
            'Have students count each population number aloud',
            'Guide students to compare place values starting from the left: both have 9 hundred thousands, so compare ten thousands place',
            'Tell students that Austin is bigger because it comes first alphabetically',
            'Have students round both numbers to the nearest thousand first'
          ],
          correct_answer: 2,
          explanation: 'Systematic place value comparison is the most reliable method. Starting from the left: both have 9 hundred thousands, Austin has 6 ten thousands while Fort Worth has 1, so Austin > Fort Worth. This teaches the algorithm they can use for any comparison.'
        },
        order_index: 6,
        estimated_minutes: 3
      }
    ];
    
    // Insert the practice questions
    for (const questionData of practiceQuestions) {
      const { error: insertError } = await supabase
        .from('content_items')
        .insert({
          concept_id: concept.id,
          type: 'question',
          title: questionData.title,
          content: questionData.content,
          order_index: questionData.order_index,
          estimated_minutes: questionData.estimated_minutes,
          is_required: true
        });
        
      if (insertError) {
        console.error(`❌ Error inserting ${questionData.title}:`, insertError);
      } else {
        console.log(`✅ Added question: ${questionData.title}`);
      }
    }
    
    console.log('🎉 Place Value content enhancement complete!');
    console.log('📝 The concept now includes:');
    console.log('   - Rich explanations with teaching strategies');
    console.log('   - 4 comprehensive practice questions');
    console.log('   - Real-world applications');
    console.log('   - Common misconceptions addressed');
    
  } catch (error) {
    console.error('💥 Error enhancing content:', error);
  }
}

enhancePlaceValueContent();
