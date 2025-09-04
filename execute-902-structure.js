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

async function executeSQLFile(filename) {
    try {
        console.log(`📋 Reading ${filename}...`);
        const sqlContent = fs.readFileSync(path.join(__dirname, filename), 'utf8');
        
        console.log(`🚀 Executing ${filename}...`);
        const { data, error } = await supabase.rpc('exec_sql', { sql: sqlContent });
        
        if (error) {
            console.error('❌ Error executing SQL:', error);
            return false;
        }
        
        console.log('✅ SQL executed successfully!');
        if (data) {
            console.log('📊 Results:', data);
        }
        return true;
    } catch (err) {
        console.error('❌ Error:', err.message);
        return false;
    }
}

async function main() {
    console.log('🏗️ Setting up proper 902 structure...');
    
    const success = await executeSQLFile('create-proper-902-structure.sql');
    
    if (success) {
        console.log('🎉 902 structure setup complete!');
        console.log('📚 Ready to create comprehensive question bank with analytics and wellness features');
    } else {
        console.log('💥 Setup failed - check the errors above');
    }
}

main().catch(console.error);
