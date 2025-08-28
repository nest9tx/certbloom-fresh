import { createClient } from '@supabase/supabase-js';
import fs from 'fs';

// Read the SQL fix
const sqlContent = fs.readFileSync('./fix-session-completion.sql', 'utf8');

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing Supabase environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function applyFix() {
  try {
    console.log('🔧 Applying session completion database fix...');
    
    // Split SQL by semicolon and execute each statement
    const statements = sqlContent.split(';').filter(stmt => stmt.trim());
    
    for (const statement of statements) {
      if (statement.trim()) {
        console.log('⚡ Executing:', statement.trim().substring(0, 50) + '...');
        const { error } = await supabase.rpc('exec_sql', { sql: statement.trim() });
        
        if (error) {
          console.error('❌ Database error:', error);
          // Try direct query if rpc fails
          const { error: queryError } = await supabase.from('_').select().limit(0);
          if (queryError && queryError.code === '42883') {
            // exec_sql function doesn't exist, try raw SQL
            console.log('🔄 Trying alternative execution method...');
            // We'll need to manually execute through Supabase UI or CLI
            console.log('📝 Please execute this SQL manually in Supabase dashboard:');
            console.log(statement);
          }
        } else {
          console.log('✅ Statement executed successfully');
        }
      }
    }
    
    console.log('✅ Database fix application completed');
  } catch (err) {
    console.error('❌ Script error:', err);
    console.log('📝 Please execute the SQL manually in Supabase dashboard');
  }
}

applyFix();
