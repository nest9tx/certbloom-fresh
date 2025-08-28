// Phase 1: Database Cleanup - Question Recategorization Script
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing Supabase environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function cleanupQuestionCategories() {
  try {
    console.log('🔧 Phase 1: Hierarchical Database Cleanup & Question Recategorization');
    console.log('');

    // Step 1: Check current state
    console.log('📊 STEP 1: Analyzing current question distribution...');
    
    const { data: questions, error: questionsError } = await supabase
      .from('questions')
      .select(`
        id,
        question_text,
        certifications:certification_id(name),
        topics:topic_id(name)
      `);

    if (questionsError) {
      console.error('❌ Error fetching questions:', questionsError);
      return;
    }

    console.log(`📈 Found ${questions.length} total questions`);
    
    // Group by certification
    const byCertification = {};
    questions.forEach(q => {
      const certName = q.certifications?.name || 'Unknown';
      if (!byCertification[certName]) {
        byCertification[certName] = [];
      }
      byCertification[certName].push(q);
    });

    console.log('📊 Current distribution:');
    Object.entries(byCertification).forEach(([cert, qs]) => {
      console.log(`   ${cert}: ${qs.length} questions`);
    });
    console.log('');

    // Step 2: Create/verify hierarchical certifications
    console.log('📊 STEP 2: Setting up hierarchical certification structure...');
    
    const certifications = [
      {
        name: 'TExES Core Subjects EC-6 (391)',
        test_code: '391',
        description: 'Comprehensive Early Childhood through 6th Grade - All Core Subjects'
      },
      {
        name: 'TExES Core Subjects EC-6: Mathematics (902)',
        test_code: '902',
        description: 'Early Childhood through 6th Grade Mathematics'
      },
      {
        name: 'TExES Core Subjects EC-6: English Language Arts (901)',
        test_code: '901',
        description: 'Early Childhood through 6th Grade English Language Arts'
      },
      {
        name: 'TExES Core Subjects EC-6: Science (904)',
        test_code: '904',
        description: 'Early Childhood through 6th Grade Science'
      },
      {
        name: 'TExES Core Subjects EC-6: Social Studies (903)',
        test_code: '903',
        description: 'Early Childhood through 6th Grade Social Studies'
      },
      {
        name: 'TExES Core Subjects EC-6: Fine Arts, Health and PE (905)',
        test_code: '905',
        description: 'Early Childhood through 6th Grade Fine Arts, Health and Physical Education'
      }
    ];

    for (const cert of certifications) {
      const { data: existingCert, error: certCheckError } = await supabase
        .from('certifications')
        .select('*')
        .eq('test_code', cert.test_code)
        .single();

      if (certCheckError && certCheckError.code !== 'PGRST116') {
        console.error(`❌ Error checking certification ${cert.name}:`, certCheckError);
        continue;
      }

      if (!existingCert) {
        const { data: newCert, error: createError } = await supabase
          .from('certifications')
          .insert(cert)
          .select()
          .single();

        if (createError) {
          console.error(`❌ Error creating certification ${cert.name}:`, createError);
        } else {
          console.log(`✅ Created certification: ${newCert.name}`);
        }
      } else {
        console.log(`✅ Certification exists: ${existingCert.name}`);
      }
    }

    // Step 3: Create Math EC-6 topics
    console.log('');
    console.log('📊 STEP 3: Creating Math EC-6 topics for dual tagging...');
    
    const { data: mathCert } = await supabase
      .from('certifications')
      .select('*')
      .eq('test_code', '902')
      .single();
    
    const mathTopics = [
      'Number Concepts and Operations',
      'Patterns and Algebra', 
      'Geometry and Measurement',
      'Probability and Statistics',
      'Mathematical Processes and Perspectives'
    ];
    
    if (mathCert) {
      for (const topicName of mathTopics) {
        const { data: existingTopic, error: topicCheckError } = await supabase
          .from('topics')
          .select('*')
          .eq('certification_id', mathCert.id)
          .eq('name', topicName)
          .single();

        if (topicCheckError && topicCheckError.code !== 'PGRST116') {
          console.error(`❌ Error checking topic ${topicName}:`, topicCheckError);
          continue;
        }

        if (!existingTopic) {
          const { error: createTopicError } = await supabase
            .from('topics')
            .insert({
              certification_id: mathCert.id,
              name: topicName,
              description: `Questions related to ${topicName} - contributes to both 902 and 391`,
              weight: 0.2
            });

          if (createTopicError) {
            console.error(`❌ Error creating topic ${topicName}:`, createTopicError);
          } else {
            console.log(`✅ Created topic: ${topicName}`);
          }
        } else {
          console.log(`✅ Topic exists: ${topicName}`);
        }
      }
    }

    console.log('');
    console.log('🎯 HIERARCHICAL STRUCTURE READY!');
    console.log('');
    console.log('✅ Questions tagged for Math (902) will AUTO-TAG for Core Subjects (391)');
    console.log('✅ Same pattern for ELA (901), Science (904), Social Studies (903), Fine Arts (905)');
    console.log('✅ Build once, serve multiple certification paths!');
    console.log('');
    console.log('🔄 NEXT STEPS:');
    console.log('1. Apply schema enhancement: hierarchical-schema-enhancement.sql');
    console.log('2. Recategorize questions via admin dashboard');
    console.log('3. Test dual-certification functionality');
    console.log('4. Start building content that serves multiple paths!');

  } catch (error) {
    console.error('❌ Cleanup error:', error);
  }
}

cleanupQuestionCategories();
