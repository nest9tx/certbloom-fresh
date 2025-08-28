import { createClient } from '@supabase/supabase-js';
import { NextRequest, NextResponse } from 'next/server';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

interface QuestionRow {
  question_text: string;
  certification_id: string;
  difficulty_level: 'foundation' | 'application' | 'advanced' | 'easy' | 'medium' | 'hard';
  question_type: 'multiple_choice' | 'true_false' | 'short_answer';
  option_a?: string;
  option_b?: string;
  option_c?: string;
  option_d?: string;
  option_e?: string;
  correct_answer?: string;
  explanation?: string;
  rationale?: string;
  teaching_notes?: string;
}

export async function POST(request: NextRequest) {
  try {
    // Verify admin access
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const formData = await request.formData();
    const file = formData.get('file') as File;

    if (!file) {
      return NextResponse.json({ error: 'No file provided' }, { status: 400 });
    }

    // Read file content
    const content = await file.text();
    const lines = content.split('\n').filter(line => line.trim());
    
    if (lines.length < 2) {
      return NextResponse.json({ error: 'File must contain header and at least one data row' }, { status: 400 });
    }

    // Parse CSV
    const headers = parseCSVLine(lines[0]);
    const rows: QuestionRow[] = [];
    const errors: string[] = [];
    let skippedCount = 0;

    // Validate headers (updated for current schema)
    const requiredHeaders = [
      'question_text', 'certification_id', 'difficulty_level', 'question_type'
    ];
    
    for (const required of requiredHeaders) {
      if (!headers.includes(required)) {
        return NextResponse.json({ 
          error: `Missing required header: ${required}` 
        }, { status: 400 });
      }
    }

    // Parse data rows
    for (let i = 1; i < lines.length; i++) {
      const lineNumber = i + 1;
      try {
        const values = parseCSVLine(lines[i]);
        
        if (values.length === 0 || values.every(v => !v.trim())) {
          skippedCount++;
          continue; // Skip empty rows
        }

        const row: Record<string, string> = {};
        headers.forEach((header, index) => {
          row[header] = values[index] || '';
        });

        // Validate required fields
        const missingFields = requiredHeaders.filter(field => !row[field]?.trim());
        if (missingFields.length > 0) {
          errors.push(`Line ${lineNumber}: Missing required fields: ${missingFields.join(', ')}`);
          continue;
        }

        // Validate field values (updated for current schema)
        if (!['foundation', 'application', 'advanced', 'easy', 'medium', 'hard'].includes(row.difficulty_level)) {
          errors.push(`Line ${lineNumber}: Invalid difficulty_level. Must be: foundation, application, advanced, easy, medium, or hard`);
          continue;
        }

        if (!['multiple_choice', 'true_false', 'short_answer'].includes(row.question_type)) {
          errors.push(`Line ${lineNumber}: Invalid question_type. Must be: multiple_choice, true_false, or short_answer`);
          continue;
        }

        // Process options for multiple choice
        const options: string[] = [];
        if (row.question_type === 'multiple_choice') {
          ['option_a', 'option_b', 'option_c', 'option_d', 'option_e'].forEach(optKey => {
            if (row[optKey]?.trim()) {
              options.push(row[optKey].trim());
            }
          });

          if (options.length < 2) {
            errors.push(`Line ${lineNumber}: Multiple choice questions need at least 2 options`);
            continue;
          }
        }

        // Create question object
        const question = {
          question_text: row.question_text.trim(),
          certification_id: row.certification_id.trim(),
          domain: row.domain.trim(),
          concept: row.concept.trim(),
          difficulty_level: row.difficulty_level.trim() as 'foundation' | 'application' | 'advanced',
          question_type: row.question_type.trim() as 'multiple_choice' | 'true_false' | 'short_answer',
          correct_answer: row.correct_answer.trim(),
          explanation: row.explanation.trim(),
          options: options.length > 0 ? options : null,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };

        rows.push(question);

      } catch (error) {
        errors.push(`Line ${lineNumber}: Error parsing row - ${error instanceof Error ? error.message : 'Unknown error'}`);
      }
    }

    // Insert valid questions into database
    let importedCount = 0;
    if (rows.length > 0) {
      const { data, error: insertError } = await supabase
        .from('questions')
        .insert(rows)
        .select();

      if (insertError) {
        console.error('Database insert error:', insertError);
        return NextResponse.json({ 
          error: `Database error: ${insertError.message}` 
        }, { status: 500 });
      }

      importedCount = data?.length || 0;
    }

    return NextResponse.json({
      success: true,
      importedCount,
      skippedCount,
      errors,
      message: `Successfully imported ${importedCount} questions. ${skippedCount} rows skipped. ${errors.length} errors.`
    });

  } catch (error) {
    console.error('Error in import API:', error);
    return NextResponse.json({ 
      error: 'Internal server error during import' 
    }, { status: 500 });
  }
}

// Helper function to parse CSV line (handles quotes and commas)
function parseCSVLine(line: string): string[] {
  const result: string[] = [];
  let current = '';
  let inQuotes = false;
  let i = 0;

  while (i < line.length) {
    const char = line[i];
    const nextChar = line[i + 1];

    if (char === '"') {
      if (inQuotes && nextChar === '"') {
        // Escaped quote
        current += '"';
        i += 2;
      } else {
        // Toggle quote state
        inQuotes = !inQuotes;
        i++;
      }
    } else if (char === ',' && !inQuotes) {
      // End of field
      result.push(current);
      current = '';
      i++;
    } else {
      current += char;
      i++;
    }
  }

  // Add the last field
  result.push(current);

  return result;
}
