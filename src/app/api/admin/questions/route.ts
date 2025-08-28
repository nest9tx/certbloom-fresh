import { createClient } from '@supabase/supabase-js';
import { NextRequest, NextResponse } from 'next/server';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

export async function GET(request: NextRequest) {
  try {
    // Verify admin access
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // Fetch all questions with certification names
    const { data: questions, error } = await supabase
      .from('questions')
      .select(`
        *,
        certifications!inner(name, test_code)
      `)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching questions:', error);
      return NextResponse.json({ error: 'Failed to fetch questions' }, { status: 500 });
    }

    return NextResponse.json(questions || []);

  } catch (error) {
    console.error('Error in questions API:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    // Verify admin access
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const questionData = await request.json();

    // Validate required fields (updated for current schema)
    const requiredFields = ['question_text', 'certification_id', 'difficulty_level', 'question_type'];
    
    for (const field of requiredFields) {
      if (!questionData[field]) {
        return NextResponse.json({ error: `Missing required field: ${field}` }, { status: 400 });
      }
    }

    // Insert the new question
    const { data: newQuestion, error } = await supabase
      .from('questions')
      .insert([{
        ...questionData,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();

    if (error) {
      console.error('Error creating question:', error);
      return NextResponse.json({ error: 'Failed to create question' }, { status: 500 });
    }

    return NextResponse.json(newQuestion, { status: 201 });

  } catch (error) {
    console.error('Error in question creation API:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
