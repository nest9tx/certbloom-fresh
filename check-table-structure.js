#!/usr/bin/env node

import { createClient } from '@supabase/supabase-js';
import { config } from 'dotenv';

// Load environment variables
config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
    console.error('❌ Missing Supabase environment variables');
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function checkTableStructure() {
    try {
        console.log('🔍 Checking content_items table structure...');
        
        // Query the information schema to see what columns exist
        const { data, error } = await supabase
            .from('information_schema.columns')
            .select('column_name, data_type, is_nullable')
            .eq('table_name', 'content_items')
            .order('ordinal_position');
            
        if (error) {
            console.error('❌ Error querying table structure:', error);
            
            // Try a simpler approach - just select from the table
            console.log('🔄 Trying alternative approach...');
            const { data: sampleData, error: sampleError } = await supabase
                .from('content_items')
                .select('*')
                .limit(1);
                
            if (sampleError) {
                console.error('❌ Error accessing content_items:', sampleError);
            } else {
                console.log('✅ Sample content_items record:');
                console.log(JSON.stringify(sampleData, null, 2));
            }
            return;
        }
        
        console.log('📋 content_items table columns:');
        data.forEach(col => {
            console.log(`  ${col.column_name}: ${col.data_type} ${col.is_nullable === 'YES' ? '(nullable)' : '(not null)'}`);
        });
        
        // Check if we have any existing data
        const { data: existingData, error: dataError } = await supabase
            .from('content_items')
            .select('*')
            .limit(5);
            
        if (dataError) {
            console.error('❌ Error querying content_items data:', dataError);
        } else {
            console.log(`\n📊 Found ${existingData.length} existing content items`);
            if (existingData.length > 0) {
                console.log('Sample record keys:', Object.keys(existingData[0]));
            }
        }
        
    } catch (err) {
        console.error('❌ Error:', err.message);
    }
}

checkTableStructure();
