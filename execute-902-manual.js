#!/usr/bin/env node

import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';
import { config } from 'dotenv';
import { fileURLToPath } from 'url';

// ESM equivalent of __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
    console.error('❌ Missing Supabase environment variables');
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function executeSQL(sql) {
    try {
        console.log('🚀 Executing SQL...');
        
        // Split SQL into individual statements and execute them
        const statements = sql
            .split(';')
            .map(s => s.trim())
            .filter(s => s && !s.startsWith('--'));
            
        for (const statement of statements) {
            if (statement) {
                console.log(`📋 Executing: ${statement.substring(0, 50)}...`);
                const { error } = await supabase.rpc('execute_sql', { sql_text: statement + ';' });
                
                if (error) {
                    console.error('❌ Error:', error);
                    return false;
                }
            }
        }
        
        console.log('✅ All statements executed successfully!');
        return true;
    } catch (err) {
        console.error('❌ Error:', err.message);
        return false;
    }
}

async function main() {
    console.log('🏗️ Setting up proper 902 structure...');
    
    try {
        const sqlContent = fs.readFileSync(path.join(__dirname, 'create-proper-902-structure.sql'), 'utf8');
        
        const success = await executeSQL(sqlContent);
        
        if (success) {
            console.log('🎉 902 structure setup complete!');
            console.log('📚 Ready to create comprehensive question bank with analytics and wellness features');
        } else {
            console.log('💥 Setup failed - check the errors above');
            console.log('📝 Try running the SQL manually in Supabase SQL Editor instead');
        }
    } catch (err) {
        console.error('❌ Error reading SQL file:', err.message);
        console.log('📝 Please run the SQL manually in Supabase SQL Editor:');
        console.log('🔗 https://supabase.com/dashboard/project/aqxdbizfulpdmajhvedy/sql');
    }
}

main().catch(console.error);
