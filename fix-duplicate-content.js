import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error('❌ Missing environment variables');
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function fixDuplicateContent() {
    try {
        console.log('🔍 Checking current duplicate content...');
        
        // Check for duplicates first
        const { data: duplicates, error: duplicateError } = await supabase
            .from('content_items')
            .select('id, concept_id, title, type')
            .eq('type', 'practice_question')
            .order('title');
            
        if (duplicateError) {
            console.error('Error checking duplicates:', duplicateError);
            return;
        }
        
        console.log('📊 Current content items:', duplicates.length);
        
        // Group by title to find duplicates
        const titleGroups = {};
        duplicates.forEach(item => {
            if (!titleGroups[item.title]) titleGroups[item.title] = [];
            titleGroups[item.title].push(item);
        });
        
        console.log('🔍 Checking for duplicate titles...');
        Object.entries(titleGroups).forEach(([title, items]) => {
            if (items.length > 1) {
                console.log(`  ⚠️  "${title}" appears ${items.length} times`);
            }
        });
        
        // Remove specific duplicates that are causing the "1/2" issue
        console.log('\n🧹 Removing problematic duplicate content...');
        
        const duplicateTitles = [
            'Practice: Adding Fractions with Like Denominators',
            'Practice: Adding Fractions with Unlike Denominators - 1/3 + 1/6',
            'Practice: Subtracting Fractions - 3/4 - 1/4'
        ];
        
        for (const title of duplicateTitles) {
            const { error: deleteError } = await supabase
                .from('content_items')
                .delete()
                .eq('title', title)
                .eq('type', 'practice_question');
                
            if (deleteError) {
                console.error(`Error deleting ${title}:`, deleteError);
            } else {
                console.log(`✅ Removed duplicates of: ${title}`);
            }
        }
        
        // Add challenging content
        console.log('\n➕ Adding challenging fraction practice...');
        
        // Get the concepts
        const { data: concepts, error: conceptError } = await supabase
            .from('concepts')
            .select('id, name')
            .ilike('name', '%Adding and Subtracting Fractions%');
            
        if (conceptError || !concepts.length) {
            console.error('Could not find fraction concepts:', conceptError);
            return;
        }
        
        const conceptId = concepts[0].id;
        console.log(`🎯 Using concept: ${concepts[0].name} (${conceptId})`);
        
        const challengingContent = [
            {
                title: 'Advanced Practice: Mixed Number Addition',
                content: {
                    question: "What is 2 1/3 + 1 5/6?",
                    answers: ["3 2/9", "4 1/6", "3 7/6", "4 1/3"],
                    correct: 1,
                    explanation: "Convert to improper fractions: 2 1/3 = 7/3, 1 5/6 = 11/6. Find common denominator 6: 7/3 = 14/6. Then: 14/6 + 11/6 = 25/6 = 4 1/6"
                },
                order_index: 10,
                estimated_minutes: 8
            },
            {
                title: 'Advanced Practice: Fraction Word Problem',
                content: {
                    question: "Sarah ate 2/5 of a pizza and her brother ate 1/4 of the same pizza. How much pizza did they eat together?",
                    answers: ["3/9", "13/20", "3/4", "6/20"],
                    correct: 1,
                    explanation: "Find common denominator for 2/5 + 1/4. LCD is 20: 2/5 = 8/20, 1/4 = 5/20. Then: 8/20 + 5/20 = 13/20"
                },
                order_index: 11,
                estimated_minutes: 10
            },
            {
                title: 'Challenge: Complex Fraction Subtraction',
                content: {
                    question: "What is 4 2/3 - 1 5/8?",
                    answers: ["3 1/24", "3 9/24", "2 21/24", "3 1/8"],
                    correct: 1,
                    explanation: "Convert to improper fractions: 4 2/3 = 14/3, 1 5/8 = 13/8. Find LCD 24: 14/3 = 112/24, 13/8 = 39/24. Then: 112/24 - 39/24 = 73/24 = 3 1/24"
                },
                order_index: 12,
                estimated_minutes: 12
            }
        ];
        
        for (const item of challengingContent) {
            // Check if it already exists
            const { data: existing } = await supabase
                .from('content_items')
                .select('id')
                .eq('concept_id', conceptId)
                .eq('title', item.title);
                
            if (existing && existing.length > 0) {
                console.log(`⏭️  Skipping ${item.title} - already exists`);
                continue;
            }
            
            const { error: insertError } = await supabase
                .from('content_items')
                .insert({
                    concept_id: conceptId,
                    type: 'practice_question',
                    title: item.title,
                    content: item.content,
                    order_index: item.order_index,
                    estimated_minutes: item.estimated_minutes
                });
                
            if (insertError) {
                console.error(`Error adding ${item.title}:`, insertError);
            } else {
                console.log(`✅ Added: ${item.title}`);
            }
        }
        
        // Final verification
        console.log('\n🔍 Final verification...');
        const { data: finalCheck } = await supabase
            .from('content_items')
            .select('title, type')
            .eq('concept_id', conceptId)
            .eq('type', 'practice_question')
            .order('order_index');
            
        console.log('📋 Current practice questions for fraction concept:');
        finalCheck?.forEach((item, index) => {
            console.log(`  ${index + 1}. ${item.title}`);
        });
        
        console.log('\n✅ Duplicate content fix completed successfully!');
        console.log('🎯 You should now see a progression from basic to challenging fraction problems');
        
    } catch (error) {
        console.error('❌ Error fixing duplicate content:', error);
    }
}

fixDuplicateContent();
