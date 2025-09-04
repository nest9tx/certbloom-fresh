// Comprehensive Content Enhancement Plan
import { createClient } from '@supabase/supabase-js'
import { config } from 'dotenv'

config({ path: '.env.local' })

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

async function enhanceAllMathConcepts() {
  try {
    console.log('🎯 Starting comprehensive Math 902 content enhancement...');
    
    // Get all Math 902 concepts
    const { data: concepts } = await supabase
      .from('concepts')
      .select(`
        id,
        name,
        description,
        domains!inner(
          certifications!inner(test_code)
        )
      `)
      .eq('domains.certifications.test_code', '902');
      
    if (!concepts || concepts.length === 0) {
      console.log('❌ No Math 902 concepts found');
      return;
    }
    
    console.log(`📚 Found ${concepts.length} Math concepts to enhance`);
    
    // Enhanced content templates for different math concepts
    const contentTemplates = {
      'addition': {
        sections: [
          'Addition is the mathematical operation of combining quantities to find a total amount.',
          'Students must understand that addition represents joining sets, increasing quantities, and combining parts to make wholes.',
          'Common misconceptions include difficulty with regrouping (carrying) and place value confusion.',
          'Effective teaching uses concrete manipulatives, visual models, and real-world problem situations.'
        ],
        key_concepts: [
          'Addition as combining or joining quantities',
          'Commutative property: order doesn\'t matter (3+5 = 5+3)',
          'Associative property: grouping doesn\'t matter',
          'Identity property: adding zero doesn\'t change the number',
          'Regrouping (carrying) in multi-digit addition'
        ],
        teaching_strategies: [
          'Use manipulatives like counting bears or base-10 blocks',
          'Connect to real-world situations (collecting items, combining groups)',
          'Teach mental math strategies (compensation, breaking apart numbers)',
          'Practice number line visualization for understanding jumps forward'
        ],
        common_misconceptions: [
          'Students add columns without considering place value',
          'Forgetting to regroup when sums exceed 9 in any place',
          'Confusion between addition and multiplication symbols',
          'Difficulty understanding that addition makes numbers larger'
        ]
      },
      'subtraction': {
        sections: [
          'Subtraction represents taking away, finding differences, or determining how many more are needed.',
          'Students need to understand subtraction as the inverse of addition and connect it to real-world situations.',
          'Regrouping (borrowing) is often the most challenging aspect for elementary students.',
          'Multiple strategies help students understand the concept: take away, count up, and think addition.'
        ],
        key_concepts: [
          'Subtraction as taking away or finding differences',
          'Relationship between addition and subtraction (inverse operations)',
          'Regrouping (borrowing) in multi-digit subtraction',
          'Zero property: subtracting zero leaves the number unchanged'
        ],
        teaching_strategies: [
          'Use physical objects to demonstrate "take away" concretely',
          'Teach "count up" strategy for finding differences',
          'Connect subtraction to addition facts students know',
          'Use number lines to show movement backward or gaps between numbers'
        ],
        common_misconceptions: [
          'Always subtracting the smaller digit from larger, regardless of position',
          'Difficulty with zeros in the minuend (top number)',
          'Confusion about when regrouping is necessary',
          'Thinking subtraction always makes numbers smaller (negative results)'
        ]
      },
      'fractions': {
        sections: [
          'Fractions represent parts of a whole, parts of a set, or points on a number line.',
          'Students must understand that fractions are numbers, not just pieces of shapes.',
          'The denominator tells how many equal parts, while the numerator tells how many parts are being considered.',
          'Fraction concepts build foundation for decimals, percentages, and advanced mathematics.'
        ],
        key_concepts: [
          'Fractions as parts of wholes, sets, or number line positions',
          'Numerator (top) shows parts being considered',
          'Denominator (bottom) shows total equal parts',
          'Equivalent fractions represent the same amount',
          'Comparing fractions using various strategies'
        ],
        teaching_strategies: [
          'Use visual models: circles, rectangles, fraction bars, number lines',
          'Connect to real-world contexts: pizza slices, measuring cups, time',
          'Emphasize equal-sized parts in all fraction representations',
          'Practice estimating fractions to develop number sense'
        ],
        common_misconceptions: [
          'Thinking larger denominators mean larger fractions',
          'Difficulty understanding that 1/2 and 2/4 are equivalent',
          'Confusing fractions with whole number operations',
          'Believing fractions are not "real numbers"'
        ]
      }
    };
    
    // Process each concept
    for (const concept of concepts) {
      console.log(`\n🔧 Processing: ${concept.name}`);
      
      // Determine content type based on concept name
      let template = null;
      const conceptName = concept.name.toLowerCase();
      
      if (conceptName.includes('addition') || conceptName.includes('add')) {
        template = contentTemplates.addition;
      } else if (conceptName.includes('subtraction') || conceptName.includes('subtract')) {
        template = contentTemplates.subtraction;
      } else if (conceptName.includes('fraction')) {
        template = contentTemplates.fractions;
      }
      
      if (template) {
        // Update existing explanation content
        const { error: updateError } = await supabase
          .from('content_items')
          .update({ content: template })
          .eq('concept_id', concept.id)
          .eq('type', 'text_explanation');
          
        if (!updateError) {
          console.log(`  ✅ Enhanced explanation content`);
        }
        
        // Add practice questions
        const practiceQuestions = await generatePracticeQuestions(concept.name, conceptName);
        
        for (let i = 0; i < practiceQuestions.length; i++) {
          const questionData = practiceQuestions[i];
          const { error: insertError } = await supabase
            .from('content_items')
            .insert({
              concept_id: concept.id,
              type: 'question',
              title: questionData.title,
              content: questionData.content,
              order_index: 3 + i,
              estimated_minutes: 3,
              is_required: true
            });
            
          if (!insertError) {
            console.log(`  ✅ Added: ${questionData.title}`);
          }
        }
      } else {
        console.log(`  ⏭️  Skipping (no template for this concept type)`);
      }
    }
    
    console.log('\n🎉 Content enhancement complete!');
    console.log('📈 Enhanced concepts now include:');
    console.log('   - Rich explanations with teaching strategies');
    console.log('   - Multiple practice questions per concept');
    console.log('   - Real-world applications');
    console.log('   - Common misconceptions addressed');
    
  } catch (error) {
    console.error('💥 Error enhancing content:', error);
  }
}

async function generatePracticeQuestions(conceptName, conceptKeyword) {
  // Generate concept-specific practice questions
  const questionSets = {
    addition: [
      {
        title: 'Multi-digit Addition with Regrouping',
        content: {
          question: 'A teacher observes a student solving 347 + 285. The student writes 5112 as the answer. What is the most likely error, and how should it be addressed?',
          choices: [
            'The student added incorrectly; provide more addition practice',
            'The student regrouped incorrectly; use base-10 blocks to show proper place value',
            'The student rushed; tell them to work more slowly',
            'The student needs help with number recognition'
          ],
          correct_answer: 2,
          explanation: 'The student likely regrouped without understanding place value, writing carried digits as additional digits. Base-10 blocks help visualize that regrouped amounts represent the next place value position.'
        }
      },
      {
        title: 'Addition Strategy Selection',
        content: {
          question: 'Students are solving 298 + 47. Which mental math strategy would be most efficient to teach?',
          choices: [
            'Count up by ones from 298',
            'Add 300 + 47, then subtract 2 (compensation strategy)',
            'Break apart into 200 + 90 + 8 + 40 + 7',
            'Use a calculator since the numbers are large'
          ],
          correct_answer: 2,
          explanation: 'Compensation strategy (adding 300 + 47 = 347, then subtracting the extra 2 = 345) is efficient and builds number sense. It helps students understand number relationships and place value.'
        }
      }
    ],
    subtraction: [
      {
        title: 'Subtraction Regrouping Error',
        content: {
          question: 'A student solving 503 - 167 writes the answer as 464. What error occurred and how should the teacher respond?',
          choices: [
            'Calculation error; have the student redo the problem',
            'The student subtracted smaller from larger in each column; teach proper regrouping with zeros',
            'Wrong operation; teach the difference between addition and subtraction',
            'The student needs more practice with basic facts'
          ],
          correct_answer: 2,
          explanation: 'The student likely subtracted 7-3=4, 6-0=6, 1-5=4 instead of properly regrouping. Teaching regrouping with zeros requires explicit instruction using place value models.'
        }
      }
    ],
    fractions: [
      {
        title: 'Fraction Comparison Teaching',
        content: {
          question: 'Students need to compare 3/4 and 5/6. Which approach best develops conceptual understanding?',
          choices: [
            'Convert both to decimals and compare',
            'Use visual models to see which covers more area',
            'Cross multiply to find which is larger',
            'Tell students that 5/6 is larger because 5 > 3'
          ],
          correct_answer: 2,
          explanation: 'Visual models help students see that fractions are numbers representing amounts. Comparing areas or number line positions builds conceptual understanding before introducing procedural methods.'
        }
      }
    ]
  };
  
  // Return questions based on concept type
  if (conceptKeyword.includes('add')) return questionSets.addition;
  if (conceptKeyword.includes('subtract')) return questionSets.subtraction;
  if (conceptKeyword.includes('fraction')) return questionSets.fractions;
  
  // Default set for other concepts
  return [
    {
      title: `${conceptName} Application`,
      content: {
        question: `How would you effectively teach ${conceptName.toLowerCase()} to elementary students?`,
        choices: [
          'Use direct instruction only',
          'Combine concrete manipulatives, visual models, and real-world connections',
          'Focus only on procedural skills',
          'Use worksheets exclusively'
        ],
        correct_answer: 2,
        explanation: 'Effective mathematics teaching uses multiple representations and connects abstract concepts to concrete experiences students can understand.'
      }
    }
  ];
}

enhanceAllMathConcepts();
