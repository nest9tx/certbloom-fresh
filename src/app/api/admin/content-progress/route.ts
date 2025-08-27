import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

// Initialize Supabase client with service role
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

// Vision targets for each certification
const CERTIFICATION_TARGETS = {
  'Math EC-6': {
    total: 450,
    domains: {
      'Number Concepts and Operations': 75,
      'Patterns and Algebra': 70,
      'Geometry and Measurement': 80,
      'Probability and Statistics': 65,
      'Mathematical Processes': 85,
      'Mathematical Learning and Instruction': 75
    }
  },
  'ELA EC-6': {
    total: 400,
    domains: {
      'Oral Language and Communication': 60,
      'Reading Development': 85,
      'Reading Comprehension': 90,
      'Written Language': 80,
      'Literature and Informational Texts': 85
    }
  },
  'Science EC-6': {
    total: 350,
    domains: {
      'Physical Science': 70,
      'Life Science': 75,
      'Earth and Space Science': 65,
      'Science Learning and Instruction': 60,
      'Scientific Inquiry and Processes': 80
    }
  },
  'Social Studies EC-6': {
    total: 350,
    domains: {
      'History and Social Science Concepts': 80,
      'Geography and Culture': 70,
      'Economics and Government': 65,
      'Social Studies Learning and Instruction': 60,
      'Social Studies Skills and Processes': 75
    }
  },
  'EC-6 Core Subjects': {
    total: 300,
    domains: {
      'Mathematics Instruction': 75,
      'English Language Arts Instruction': 75,
      'Science Instruction': 75,
      'Social Studies Instruction': 75
    }
  }
};

interface Question {
  certification_area: string;
  domain: string;
  difficulty_level: string;
}

interface ContentProgress {
  certification: string;
  domains: {
    name: string;
    foundation: number;
    application: number;
    advanced: number;
    total: number;
    target: number;
  }[];
  totalQuestions: number;
  targetQuestions: number;
  completionPercentage: number;
}

export async function GET() {
  try {
    // Get all questions grouped by certification and domain
    const { data: questions, error: questionsError } = await supabase
      .from('questions')
      .select('certification_area, domain, difficulty_level');

    if (questionsError) {
      console.error('Error fetching questions:', questionsError);
      return NextResponse.json({ error: 'Failed to fetch questions' }, { status: 500 });
    }

    // Process data for each certification
    const progressData: ContentProgress[] = [];

    for (const [certificationName, targets] of Object.entries(CERTIFICATION_TARGETS)) {
      const certQuestions = (questions as Question[]).filter(q => q.certification_area === certificationName);
      
      // Group by domain
      const domainData = Object.entries(targets.domains).map(([domainName, target]) => {
        const domainQuestions = certQuestions.filter(q => q.domain === domainName);
        
        const foundation = domainQuestions.filter(q => q.difficulty_level === 'foundation').length;
        const application = domainQuestions.filter(q => q.difficulty_level === 'application').length;
        const advanced = domainQuestions.filter(q => q.difficulty_level === 'advanced').length;
        
        return {
          name: domainName,
          foundation,
          application,
          advanced,
          total: foundation + application + advanced,
          target: target as number
        };
      });

      const totalQuestions = certQuestions.length;
      const targetQuestions = targets.total;
      const completionPercentage = targetQuestions > 0 
        ? Math.round((totalQuestions / targetQuestions) * 100)
        : 0;

      progressData.push({
        certification: certificationName,
        domains: domainData,
        totalQuestions,
        targetQuestions,
        completionPercentage
      });
    }

    return NextResponse.json(progressData);

  } catch (error) {
    console.error('Error in content progress API:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
