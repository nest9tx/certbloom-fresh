import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function fixDatabaseFunction() {
    try {
        console.log('🔧 Fixing database function signature...');
        
        const functionSQL = `
        DROP FUNCTION IF EXISTS handle_content_engagement_update(UUID, UUID, INTEGER, NUMERIC);
        DROP FUNCTION IF EXISTS handle_content_engagement_update(UUID, UUID, INTEGER);

        CREATE OR REPLACE FUNCTION handle_content_engagement_update(
            target_user_id UUID,
            target_content_item_id UUID,
            time_spent INTEGER
        )
        RETURNS JSON AS $$
        BEGIN
            -- Use UPSERT to handle duplicates safely
            INSERT INTO content_engagement (
                user_id,
                content_item_id,
                time_spent_seconds,
                completed_at,
                created_at,
                updated_at
            ) VALUES (
                target_user_id,
                target_content_item_id,
                time_spent,
                NOW(),
                NOW(),
                NOW()
            )
            ON CONFLICT (user_id, content_item_id) 
            DO UPDATE SET
                time_spent_seconds = content_engagement.time_spent_seconds + EXCLUDED.time_spent_seconds,
                completed_at = NOW(),
                updated_at = NOW();
            
            RETURN json_build_object(
                'success', true,
                'message', 'Content engagement updated successfully'
            );
        EXCEPTION
            WHEN OTHERS THEN
                RETURN json_build_object(
                    'success', false,
                    'error', SQLERRM
                );
        END;
        $$ LANGUAGE plpgsql;`;
        
        const { error } = await supabase.rpc('exec_sql', { sql: functionSQL });
        
        if (error) {
            console.error('❌ Error fixing function:', error);
        } else {
            console.log('✅ Database function signature fixed!');
            console.log('🎯 Function now expects exactly 3 parameters: user_id, content_item_id, time_spent');
        }
        
    } catch (error) {
        console.error('❌ Error:', error);
    }
}

fixDatabaseFunction();
