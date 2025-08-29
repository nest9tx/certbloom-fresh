require('dotenv').config({ path: '.env.local' });
const fs = require('fs');
const { createClient } = require('@supabase/supabase-js');

const sqlFile = process.argv[2];
if (!sqlFile) {
  console.error('Usage: node run-sql.js <sql-file>');
  process.exit(1);
}

const sql = fs.readFileSync(sqlFile, 'utf8');
const client = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

console.log(`Executing ${sqlFile}...`);

// Split the SQL into individual statements
const statements = sql.split(';').filter(s => s.trim().length > 0);

async function executeSql() {
  try {
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i].trim();
      if (statement) {
        console.log(`Executing statement ${i + 1}/${statements.length}...`);
        const { data, error } = await client.rpc('query', { sql: statement + ';' });
        
        if (error) {
          console.error(`Error in statement ${i + 1}:`, error);
          break;
        } else {
          console.log(`Statement ${i + 1} executed successfully`);
          if (data && data.length > 0) {
            console.log('Result:', data);
          }
        }
      }
    }
    console.log('All statements executed!');
  } catch (err) {
    console.error('Execution failed:', err);
  }
}

executeSql();
