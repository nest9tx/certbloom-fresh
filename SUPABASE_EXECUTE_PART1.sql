-- 🚀 EXECUTE THIS IN SUPABASE SQL EDITOR
-- Domain 1: Number Concepts and Operations - Learning Module Content

-- Create the template function first
CREATE OR REPLACE FUNCTION build_concept_learning_modules(
    p_concept_name TEXT,
    p_core_explanation TEXT,
    p_key_principles TEXT[],
    p_visual_aids TEXT[],
    p_key_vocabulary TEXT[],
    p_teaching_sequence TEXT[],
    p_differentiation_strategies TEXT[],
    p_assessment_ideas TEXT[],
    p_engagement_activities TEXT[],
    p_common_misconceptions JSONB[],
    p_diagnostic_questions TEXT[],
    p_intervention_strategies TEXT[]
) RETURNS TEXT AS $$
DECLARE
    concept_id UUID;
    result TEXT;
BEGIN
    -- Get concept ID
    SELECT c.id INTO concept_id
    FROM concepts c
    JOIN domains d ON c.domain_id = d.id
    JOIN certifications cert ON d.certification_id = cert.id
    WHERE cert.test_code = '902' AND c.name = p_concept_name;
    
    IF concept_id IS NULL THEN
        RETURN 'ERROR: Concept not found: ' || p_concept_name;
    END IF;
    
    -- Update Module 1: Concept Introduction
    UPDATE learning_modules 
    SET content_data = jsonb_build_object(
        'core_explanation', p_core_explanation,
        'key_principles', p_key_principles,
        'visual_aids', p_visual_aids,
        'key_vocabulary', p_key_vocabulary,
        'interactive_elements', ARRAY[
            'Explore concept with virtual manipulatives',
            'Practice core skills with immediate feedback',
            'Analyze student work samples',
            'Apply concept to real-world problems'
        ]
    )
    WHERE module_type = 'concept_introduction' AND learning_modules.concept_id = concept_id;
    
    -- Update Module 2: Teaching Demonstration
    UPDATE learning_modules 
    SET content_data = jsonb_build_object(
        'lesson_structure', jsonb_build_object(
            'warm_up', 'Activate prior knowledge and introduce vocabulary',
            'introduction', 'Connect to previous learning and set objectives',
            'guided_practice', 'Model thinking and practice together',
            'independent_practice', 'Students apply learning with support',
            'closure', 'Summarize key concepts and preview next steps'
        ),
        'teaching_sequence', p_teaching_sequence,
        'differentiation_strategies', p_differentiation_strategies,
        'assessment_ideas', p_assessment_ideas,
        'engagement_activities', p_engagement_activities
    )
    WHERE module_type = 'teaching_demonstration' AND learning_modules.concept_id = concept_id;
    
    -- Update Module 3: Interactive Practice
    UPDATE learning_modules 
    SET content_data = jsonb_build_object(
        'guided_questions', ARRAY[
            'What strategy would work best here?',
            'How do you know your answer is reasonable?',
            'What might a student find confusing about this?',
            'How would you explain this to a colleague?',
            'What real-world connections can you make?'
        ],
        'reflection_prompts', ARRAY[
            'What misconception might lead to this error?',
            'How would you help a student who made this mistake?',
            'What visual aid would be most helpful here?',
            'How does this connect to other math concepts?',
            'What would you do if a student still doesn''t understand?'
        ]
    )
    WHERE module_type = 'interactive_practice' AND learning_modules.concept_id = concept_id;
    
    -- Update Module 4: Classroom Scenario
    UPDATE learning_modules 
    SET content_data = jsonb_build_object(
        'scenario_setup', 'Navigate realistic teaching challenges with diverse student needs and responses.',
        'response_options', ARRAY[
            jsonb_build_object(
                'approach', 'Address misconceptions directly with whole class',
                'pros', ARRAY['Clear explanation', 'Prevents spread of errors'],
                'cons', ARRAY['May embarrass students', 'One-size-fits-all approach']
            ),
            jsonb_build_object(
                'approach', 'Use small group differentiated instruction',
                'pros', ARRAY['Targeted support', 'Meets individual needs'],
                'cons', ARRAY['Time intensive', 'Classroom management challenges']
            ),
            jsonb_build_object(
                'approach', 'Implement peer teaching and collaboration',
                'pros', ARRAY['Student engagement', 'Multiple perspectives'],
                'cons', ARRAY['Quality of explanations varies', 'May reinforce errors']
            )
        ],
        'follow_up_activities', ARRAY[
            'Plan differentiated practice for next lesson',
            'Create targeted interventions for struggling students',
            'Design enrichment activities for advanced learners',
            'Communicate with families about student progress'
        ]
    )
    WHERE module_type = 'classroom_scenario' AND learning_modules.concept_id = concept_id;
    
    -- Update Module 5: Misconception Alert
    UPDATE learning_modules 
    SET content_data = jsonb_build_object(
        'misconception_categories', p_common_misconceptions,
        'diagnostic_questions', p_diagnostic_questions,
        'intervention_strategies', p_intervention_strategies,
        'prevention_strategies', ARRAY[
            'Use concrete manipulatives before abstract concepts',
            'Emphasize mathematical vocabulary and language',
            'Connect new learning to prior knowledge',
            'Provide multiple representations of concepts',
            'Use formative assessment to catch errors early'
        ]
    )
    WHERE module_type = 'misconception_alert' AND learning_modules.concept_id = concept_id;
    
    RETURN 'SUCCESS: Built learning modules for ' || p_concept_name;
END;
$$ LANGUAGE plpgsql;
