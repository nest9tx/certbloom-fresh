import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error('❌ Missing environment variables');
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function fixAnswerKey() {
    try {
        console.log('🔧 Fixing incorrect answer key for fraction subtraction question...');
        
        // Find and update the incorrect question
        const { data: questions, error: findError } = await supabase
            .from('content_items')
            .select('*')
            .eq('title', 'Challenge: Complex Fraction Subtraction')
            .eq('type', 'practice_question');
            
        if (findError) {
            console.error('❌ Error finding question:', findError);
            return;
        }
        
        if (!questions || questions.length === 0) {
            console.log('⚠️  Question not found');
            return;
        }
        
        console.log(`📝 Found ${questions.length} questions to fix`);
        
        for (const question of questions) {
            console.log('Current question data:', question.content);
            
            // Fix the correct answer index from 1 to 0
            const correctedContent = {
                ...question.content,
                correct: 0  // Change from 1 (3 9/24) to 0 (3 1/24)
            };
            
            const { error: updateError } = await supabase
                .from('content_items')
                .update({ content: correctedContent })
                .eq('id', question.id);
                
            if (updateError) {
                console.error('❌ Error updating question:', updateError);
            } else {
                console.log('✅ Fixed answer key for question:', question.id);
                console.log('New correct answer: A) 3 1/24');
            }
        }
        
        console.log('🎯 Answer key fix completed!');
        
    } catch (error) {
        console.error('❌ Error fixing answer key:', error);
    }
}

fixAnswerKey();
